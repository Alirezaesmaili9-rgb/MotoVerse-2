-- ============================================================================
-- MotoVerse — Marketplace + Wallet
-- Adds reviews, favorites, server-backed cart, and the trusted RPCs that
-- mutate the wallet (recharge / checkout). Client code never writes
-- wallet_transactions directly — it calls these SECURITY DEFINER functions so
-- balance changes are atomic and tamper-proof.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PRODUCT REVIEWS  (ratings & reviews)
-- ---------------------------------------------------------------------------
create table public.product_reviews (
  id         uuid primary key default uuid_generate_v4(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  rating     int  not null check (rating between 1 and 5),
  comment    text,
  created_at timestamptz not null default now(),
  unique (product_id, user_id)              -- one review per user per product
);
create index idx_reviews_product on public.product_reviews(product_id);

-- Keep products.rating denormalized & in sync with its reviews.
create or replace function public.refresh_product_rating()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_product uuid := coalesce(new.product_id, old.product_id);
begin
  update public.products p
     set rating = coalesce((
       select round(avg(rating)::numeric, 1)
       from public.product_reviews where product_id = v_product
     ), 0)
   where p.id = v_product;
  return null;
end;
$$;
create trigger trg_reviews_rating
  after insert or update or delete on public.product_reviews
  for each row execute function public.refresh_product_rating();

-- ---------------------------------------------------------------------------
-- FAVORITES
-- ---------------------------------------------------------------------------
create table public.favorites (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);
create index idx_favorites_user on public.favorites(user_id);

-- ---------------------------------------------------------------------------
-- CART  (server-backed so it persists across devices)
-- ---------------------------------------------------------------------------
create table public.cart_items (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity   int  not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, product_id)
);
create index idx_cart_user on public.cart_items(user_id);
create trigger trg_cart_updated
  before update on public.cart_items
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.product_reviews enable row level security;
create policy "reviews_read_all"
  on public.product_reviews for select using (true);
create policy "reviews_write_own"
  on public.product_reviews for insert with check (auth.uid() = user_id);
create policy "reviews_update_own"
  on public.product_reviews for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "reviews_delete_own"
  on public.product_reviews for delete using (auth.uid() = user_id);

alter table public.favorites enable row level security;
create policy "favorites_owner_all"
  on public.favorites for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.cart_items enable row level security;
create policy "cart_owner_all"
  on public.cart_items for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================================
-- WALLET RPCs  (SECURITY DEFINER — the only sanctioned balance mutators)
-- ============================================================================

-- Recharge: credits the wallet after a successful gateway payment.
create or replace function public.wallet_recharge(
  p_amount bigint,
  p_reference text default null
) returns bigint
language plpgsql security definer set search_path = public as $$
declare v_new bigint;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  if p_amount <= 0 then raise exception 'amount must be positive'; end if;

  update public.profiles
     set wallet_balance = wallet_balance + p_amount
   where id = auth.uid()
   returning wallet_balance into v_new;

  insert into public.wallet_transactions (user_id, amount, kind, reference)
  values (auth.uid(), p_amount, 'recharge', p_reference);

  return v_new;
end;
$$;

-- Checkout: validates stock, debits wallet, writes order + items, credits
-- 2% cashback, and clears the cart — all atomically.
create or replace function public.place_order(p_items jsonb)
returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_uid      uuid := auth.uid();
  v_total    bigint := 0;
  v_order_id uuid;
  v_item     jsonb;
  v_product  public.products%rowtype;
  v_qty      int;
  v_balance  bigint;
  v_cashback bigint;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'cart is empty';
  end if;

  -- Validate & total (lock product rows).
  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    select * into v_product from public.products
      where id = (v_item->>'product_id')::uuid and is_active for update;
    if not found then raise exception 'product not available'; end if;
    if v_product.stock < v_qty then
      raise exception 'insufficient stock for %', v_product.title;
    end if;
    v_total := v_total + v_product.price * v_qty;
  end loop;

  select wallet_balance into v_balance from public.profiles
    where id = v_uid for update;
  if v_balance < v_total then raise exception 'insufficient wallet balance'; end if;

  insert into public.orders (user_id, total, status)
  values (v_uid, v_total, 'paid') returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_qty := (v_item->>'quantity')::int;
    select * into v_product from public.products
      where id = (v_item->>'product_id')::uuid;
    insert into public.order_items (order_id, product_id, quantity, unit_price)
    values (v_order_id, v_product.id, v_qty, v_product.price);
    update public.products set stock = stock - v_qty where id = v_product.id;
  end loop;

  update public.profiles set wallet_balance = wallet_balance - v_total
    where id = v_uid;
  insert into public.wallet_transactions (user_id, amount, kind, reference)
  values (v_uid, -v_total, 'purchase', v_order_id::text);

  v_cashback := floor(v_total * 0.02)::bigint;
  if v_cashback > 0 then
    update public.profiles set wallet_balance = wallet_balance + v_cashback
      where id = v_uid;
    insert into public.wallet_transactions (user_id, amount, kind, reference)
    values (v_uid, v_cashback, 'cashback', v_order_id::text);
  end if;

  delete from public.cart_items where user_id = v_uid;
  return v_order_id;
end;
$$;
