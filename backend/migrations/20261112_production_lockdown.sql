-- PadCare production lockdown migration.
-- Apply after reviewing the existing schema. This deliberately fails closed:
-- requests, messages, and live locations remain unavailable to mobile clients
-- until server-validated voucher/RPC access is implemented and tested.
--
-- Do not add a permissive policy to make the client work. The public anon key
-- is not a secret and cannot authorize access to another person's pickup data.

begin;

alter table if exists public.distribution_points enable row level security;
alter table if exists public.requests enable row level security;
alter table if exists public.messages enable row level security;
alter table if exists public.live_locations enable row level security;

-- Remove all existing policies on these tables, including policies whose names
-- differ from the original schema. This avoids leaving an overlooked permissive
-- policy that combines with the safer policies below.
do $$
declare
  p record;
begin
  for p in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in ('distribution_points', 'requests', 'messages', 'live_locations')
  loop
    execute format('drop policy if exists %I on %I.%I',
      p.policyname, p.schemaname, p.tablename);
  end loop;
end
$$;

-- Public users may browse pickup-point listings only. Never allow clients to
-- write verification, stock, partner, or location data directly.
create policy "Public can read distribution points"
  on public.distribution_points
  for select
  to anon, authenticated
  using (true);

revoke all on table public.distribution_points from anon, authenticated;
grant select on table public.distribution_points to anon, authenticated;

-- Fail closed for sensitive data. No anon or authenticated table privileges
-- are granted and no policies are created for these tables. Implement secure
-- server-side RPCs before enabling request creation, voucher collection,
-- messaging, or location publishing.
revoke all on table public.requests from anon, authenticated;
revoke all on table public.messages from anon, authenticated;
revoke all on table public.live_locations from anon, authenticated;

commit;

-- Before re-enabling sensitive operations, implement and test:
-- 1. server-generated high-entropy voucher codes (not 3-digit PINs),
-- 2. one-time, expiry-checked and rate-limited collection verification,
-- 3. voucher-scoped message access without exposing voucher secrets,
-- 4. authenticated/authorized location publishing,
-- 5. role assignment controlled by trusted server logic, never client metadata.
