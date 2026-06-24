-- ============================================================================
-- MotoVerse — initial schema
-- PostgreSQL / Supabase. Row Level Security is enabled on every user-owned
-- table; ownership is enforced via auth.uid().
-- ============================================================================

create extension if not exists "uuid-ossp";

-- Reusable updated_at trigger ------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ============================================================================
-- PROFILES  (1:1 with auth.users)
-- ============================================================================
create table public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  phone         text,
  full_name     text,
  avatar_url    text,
  wallet_balance bigint not null default 0,           -- Toman
  role          text not null default 'rider'
                  check (role in ('rider', 'admin', 'technician')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create trigger trg_profiles_updated
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- New auth user → profile row
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, phone, full_name)
  values (new.id, new.phone, new.raw_user_meta_data->>'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- MOTORCYCLES  (My Garage)
-- ============================================================================
create table public.motorcycles (
  id              uuid primary key default uuid_generate_v4(),
  owner_id        uuid not null references public.profiles(id) on delete cascade,
  brand           text not null,
  model           text not null,
  production_year int,
  engine_cc       int,
  mileage         int not null default 0,
  plate_top       text,                                -- 3 digits
  plate_bottom    text,                                -- 5 digits
  chassis_number  text,
  engine_number   text,
  is_primary      boolean not null default false,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index idx_motorcycles_owner on public.motorcycles(owner_id);
create trigger trg_motorcycles_updated
  before update on public.motorcycles
  for each row execute function public.set_updated_at();

-- ============================================================================
-- MAINTENANCE RECORDS
-- ============================================================================
create table public.maintenance_records (
  id             uuid primary key default uuid_generate_v4(),
  motorcycle_id  uuid not null references public.motorcycles(id) on delete cascade,
  type           text not null,                        -- engineOil, chainService, ...
  service_date   timestamptz not null default now(),
  mileage        int not null,
  interval_km    int not null,
  cost           bigint,                               -- Toman
  service_center text,
  notes          text,
  created_at     timestamptz not null default now()
);
create index idx_maint_motorcycle on public.maintenance_records(motorcycle_id);

-- ============================================================================
-- INSURANCE POLICIES  (MotoBimeh)
-- ============================================================================
create table public.insurance_policies (
  id            uuid primary key default uuid_generate_v4(),
  motorcycle_id uuid not null references public.motorcycles(id) on delete cascade,
  owner_id      uuid not null references public.profiles(id) on delete cascade,
  kind          text not null check (kind in ('third_party','comprehensive','theft')),
  provider      text,
  premium       bigint,                                -- Toman
  start_date    date,
  end_date      date,
  status        text not null default 'active'
                  check (status in ('active','expired','pending')),
  created_at    timestamptz not null default now()
);
create index idx_insurance_owner on public.insurance_policies(owner_id);

-- ============================================================================
-- SERVICE CENTERS  (public catalog) + bookings
-- ============================================================================
create table public.service_centers (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  address     text,
  lat         double precision,
  lng         double precision,
  brands      text[] default '{}',
  rating      numeric(2,1) default 0,
  phone       text,
  created_at  timestamptz not null default now()
);

create table public.service_bookings (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  service_center_id uuid not null references public.service_centers(id) on delete cascade,
  motorcycle_id   uuid references public.motorcycles(id) on delete set null,
  scheduled_at    timestamptz,
  status          text not null default 'requested'
                    check (status in ('requested','confirmed','done','cancelled')),
  notes           text,
  created_at      timestamptz not null default now()
);
create index idx_bookings_user on public.service_bookings(user_id);

-- ============================================================================
-- ROADSIDE ASSISTANCE
-- ============================================================================
create table public.roadside_requests (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  kind         text not null check (kind in
                  ('tire','battery','fuel','towing','mechanical')),
  lat          double precision,
  lng          double precision,
  status       text not null default 'requested'
                  check (status in ('requested','assigned','enroute','done','cancelled')),
  technician_id uuid references public.profiles(id) on delete set null,
  eta_minutes  int,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index idx_roadside_user on public.roadside_requests(user_id);
create trigger trg_roadside_updated
  before update on public.roadside_requests
  for each row execute function public.set_updated_at();

-- ============================================================================
-- MARKETPLACE  (parts + accessories) + orders + wallet
-- ============================================================================
create table public.products (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  category    text not null check (category in ('parts','accessories')),
  subcategory text,
  price       bigint not null,                         -- Toman
  image_url   text,
  rating      numeric(2,1) default 0,
  stock       int not null default 0,
  description text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);
create index idx_products_category on public.products(category);

create table public.orders (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  total       bigint not null,
  status      text not null default 'pending'
                check (status in ('pending','paid','shipped','delivered','cancelled')),
  created_at  timestamptz not null default now()
);
create index idx_orders_user on public.orders(user_id);

create table public.order_items (
  id         uuid primary key default uuid_generate_v4(),
  order_id   uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity   int not null default 1,
  unit_price bigint not null
);

create table public.wallet_transactions (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  amount      bigint not null,                         -- +recharge / -spend
  kind        text not null check (kind in
                ('recharge','purchase','cashback','withdrawal','refund')),
  reference   text,
  created_at  timestamptz not null default now()
);
create index idx_wallet_user on public.wallet_transactions(user_id);

-- ============================================================================
-- MOTOR WORLD  (news) + notifications
-- ============================================================================
create table public.news_articles (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  summary     text,
  body        text,
  cover_url   text,
  tag         text,
  source      text,
  published_at timestamptz not null default now(),
  is_published boolean not null default true
);

create table public.notifications (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  title       text not null,
  body        text,
  type        text,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);
create index idx_notifications_user on public.notifications(user_id);
