-- ============================================================================
-- MotoVerse — Admin override policies
-- The base RLS is owner-scoped (a rider only touches their own rows). The admin
-- dashboard needs to manage *other* users' data, so we add admin-only override
-- policies guarded by is_admin(). products / news_articles / service_centers
-- already have admin "for all" policies from migration 0002.
-- ============================================================================

-- Admins can update any profile (e.g. change a user's role).
create policy "profiles_admin_update"
  on public.profiles for update
  using (public.is_admin())
  with check (public.is_admin());

-- Admins can send notifications to any user.
create policy "notifications_admin_insert"
  on public.notifications for insert
  with check (public.is_admin());

-- Content moderation: admins can delete any product review.
create policy "reviews_admin_delete"
  on public.product_reviews for delete
  using (public.is_admin());

-- Admins can update any order (e.g. mark shipped / delivered).
create policy "orders_admin_update"
  on public.orders for update
  using (public.is_admin())
  with check (public.is_admin());

-- Admins can update any service booking (confirm / complete).
create policy "bookings_admin_update"
  on public.service_bookings for update
  using (public.is_admin())
  with check (public.is_admin());

-- Admins can update any insurance policy (activate / expire).
create policy "insurance_admin_update"
  on public.insurance_policies for update
  using (public.is_admin())
  with check (public.is_admin());

-- ----------------------------------------------------------------------------
-- Dashboard analytics in one round-trip (admin only).
-- ----------------------------------------------------------------------------
create or replace function public.admin_stats()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare result jsonb;
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'users',    (select count(*) from public.profiles),
    'products', (select count(*) from public.products),
    'orders',   (select count(*) from public.orders),
    'revenue',  (select coalesce(sum(total), 0) from public.orders
                  where status in ('paid', 'shipped', 'delivered')),
    'active_roadside', (select count(*) from public.roadside_requests
                  where status in ('requested', 'assigned', 'enroute')),
    'pending_bookings', (select count(*) from public.service_bookings
                  where status = 'requested'),
    'policies', (select count(*) from public.insurance_policies),
    'news',     (select count(*) from public.news_articles)
  ) into result;
  return result;
end;
$$;

