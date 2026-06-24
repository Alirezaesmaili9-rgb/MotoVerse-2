-- ============================================================================
-- MotoVerse — embedded tool results
-- Stores outputs an embedded HTML tool (MotoFix / MotoSanj / MotoType) sends
-- back through the `MotoVerseBridge` JS channel. The raw payload is kept as
-- JSONB so each tool can evolve its own result shape without a schema change.
-- ============================================================================

create table public.tool_results (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  tool       text not null check (tool in ('motofix', 'motosanj', 'mototype')),
  motorcycle_id uuid references public.motorcycles(id) on delete set null,
  payload    jsonb not null default '{}'::jsonb,
  summary    text,
  created_at timestamptz not null default now()
);
create index idx_tool_results_user on public.tool_results(user_id);

alter table public.tool_results enable row level security;

create policy "tool_results_owner_all"
  on public.tool_results for all
  using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id);
