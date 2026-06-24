-- ============================================================================
-- MotoVerse — Row Level Security policies
-- Principle: a rider can only read/write their own rows. Public catalogs
-- (products, service_centers, news) are world-readable. Admins (profiles.role
-- = 'admin') get full access via a helper.
-- ============================================================================

-- Helper: is the current user an admin?
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- PROFILES
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id or public.is_admin());

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "profiles_insert_self"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- MOTORCYCLES
-- ---------------------------------------------------------------------------
alter table public.motorcycles enable row level security;

create policy "motorcycles_owner_all"
  on public.motorcycles for all
  using (auth.uid() = owner_id or public.is_admin())
  with check (auth.uid() = owner_id);

-- ---------------------------------------------------------------------------
-- MAINTENANCE RECORDS  (ownership via parent motorcycle)
-- ---------------------------------------------------------------------------
alter table public.maintenance_records enable row level security;

create policy "maintenance_owner_all"
  on public.maintenance_records for all
  using (
    public.is_admin() or exists (
      select 1 from public.motorcycles m
      where m.id = maintenance_records.motorcycle_id and m.owner_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.motorcycles m
      where m.id = maintenance_records.motorcycle_id and m.owner_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- INSURANCE
-- ---------------------------------------------------------------------------
alter table public.insurance_policies enable row level security;
create policy "insurance_owner_all"
  on public.insurance_policies for all
  using (auth.uid() = owner_id or public.is_admin())
  with check (auth.uid() = owner_id);

-- ---------------------------------------------------------------------------
-- SERVICE CENTERS (public read, admin write) + bookings (owner)
-- ---------------------------------------------------------------------------
alter table public.service_centers enable row level security;
create policy "service_centers_read_all"
  on public.service_centers for select using (true);
create policy "service_centers_admin_write"
  on public.service_centers for all
  using (public.is_admin()) with check (public.is_admin());

alter table public.service_bookings enable row level security;
create policy "bookings_owner_all"
  on public.service_bookings for all
  using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- ROADSIDE
-- ---------------------------------------------------------------------------
alter table public.roadside_requests enable row level security;
create policy "roadside_owner_select"
  on public.roadside_requests for select
  using (auth.uid() = user_id or auth.uid() = technician_id or public.is_admin());
create policy "roadside_owner_write"
  on public.roadside_requests for insert
  with check (auth.uid() = user_id);
create policy "roadside_owner_update"
  on public.roadside_requests for update
  using (auth.uid() = user_id or auth.uid() = technician_id or public.is_admin());

-- ---------------------------------------------------------------------------
-- MARKETPLACE
-- ---------------------------------------------------------------------------
alter table public.products enable row level security;
create policy "products_read_all"
  on public.products for select using (is_active or public.is_admin());
create policy "products_admin_write"
  on public.products for all
  using (public.is_admin()) with check (public.is_admin());

alter table public.orders enable row level security;
create policy "orders_owner_all"
  on public.orders for all
  using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id);

alter table public.order_items enable row level security;
create policy "order_items_owner_all"
  on public.order_items for all
  using (
    public.is_admin() or exists (
      select 1 from public.orders o
      where o.id = order_items.order_id and o.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id and o.user_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- WALLET (read own; writes go through trusted server / RPC only)
-- ---------------------------------------------------------------------------
alter table public.wallet_transactions enable row level security;
create policy "wallet_owner_select"
  on public.wallet_transactions for select
  using (auth.uid() = user_id or public.is_admin());

-- ---------------------------------------------------------------------------
-- NEWS (public read, admin write) + notifications (owner read)
-- ---------------------------------------------------------------------------
alter table public.news_articles enable row level security;
create policy "news_read_all"
  on public.news_articles for select using (is_published or public.is_admin());
create policy "news_admin_write"
  on public.news_articles for all
  using (public.is_admin()) with check (public.is_admin());

alter table public.notifications enable row level security;
create policy "notifications_owner_all"
  on public.notifications for all
  using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id);
