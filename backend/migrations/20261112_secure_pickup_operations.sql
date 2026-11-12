-- PadCare secure pickup operations. Apply only after reviewing in a staging project.
-- Mobile clients receive no direct table access for sensitive tables; all mutations
-- go through SECURITY DEFINER RPCs which derive identity from auth.uid().
begin;

create extension if not exists pgcrypto with schema extensions;

alter table public.requests
  add column if not exists owner_id uuid references auth.users(id) on delete cascade;
alter table public.requests
  add column if not exists collected_by uuid references auth.users(id);
alter table public.messages
  add column if not exists sender_user_id uuid references auth.users(id);
alter table public.messages
  add column if not exists request_id text;
alter table public.live_locations
  add column if not exists owner_id uuid references auth.users(id);
alter table public.live_locations
  add column if not exists hub_id text references public.distribution_points(id) on delete cascade;

create table if not exists public.hub_staff (
  user_id uuid not null references auth.users(id) on delete cascade,
  hub_id text not null references public.distribution_points(id) on delete cascade,
  staff_role text not null check (staff_role in ('caretaker','coordinator','admin')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (user_id, hub_id)
);
alter table public.hub_staff enable row level security;
revoke all on public.hub_staff from anon, authenticated;

-- Clear policies and direct grants for sensitive tables (idempotent).
do $$ declare p record; begin
  for p in select schemaname,tablename,policyname from pg_policies
    where schemaname='public' and tablename in ('requests','messages','live_locations','hub_staff')
  loop execute format('drop policy if exists %I on %I.%I',p.policyname,p.schemaname,p.tablename); end loop;
end $$;
revoke all on public.requests, public.messages, public.live_locations from anon, authenticated;

create or replace function public.create_pickup_request(
  p_hub_id text, p_allocation_summary text, p_pickup_window text default 'Within the next 2 hours'
) returns jsonb language plpgsql security definer set search_path=public,extensions,pg_temp as $$
declare u uuid := auth.uid(); h public.distribution_points%rowtype; r public.requests%rowtype; code text;
begin
  if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
  if length(trim(coalesce(p_allocation_summary,''))) not between 1 and 300 then raise exception 'invalid_allocation'; end if;
  select * into h from public.distribution_points where id=p_hub_id and is_verified=true;
  if not found then raise exception 'pickup_point_unavailable'; end if;
  code := upper(encode(extensions.gen_random_bytes(10),'hex'));
  insert into public.requests(id,voucher_code,hub_id,hub_name,allocation_summary,status,created_at,expires_at,pickup_window,pin,owner_id)
  values (gen_random_uuid()::text, code, h.id, h.name, trim(p_allocation_summary), 'readyForPickup', now(), now()+interval '3 hours',
          left(coalesce(nullif(trim(p_pickup_window),''),'Within the next 2 hours'),80), null, u)
  returning * into r;
  return jsonb_build_object('id',r.id,'voucher_code',r.voucher_code,'hub_id',r.hub_id,'hub_name',r.hub_name,
    'allocation_summary',r.allocation_summary,'status',r.status,'created_at',r.created_at,'expires_at',r.expires_at,
    'pickup_window',r.pickup_window,'pin',null);
end $$;

create or replace function public.list_my_pickup_requests()
returns setof jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid();
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 return query select jsonb_build_object('id',r.id,'voucher_code',r.voucher_code,'hub_id',r.hub_id,'hub_name',r.hub_name,
   'allocation_summary',r.allocation_summary,'status',r.status,'created_at',r.created_at,'expires_at',r.expires_at,
   'pickup_window',r.pickup_window,'pin',null)
 from public.requests r where r.owner_id=u order by r.created_at desc limit 50;
end $$;

create or replace function public.verify_pickup_voucher(p_voucher_code text)
returns boolean language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid(); r public.requests%rowtype;
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 select * into r from public.requests where upper(voucher_code)=upper(trim(p_voucher_code)) for update;
 if not found then return false; end if;
 if not exists(select 1 from public.hub_staff s where s.user_id=u and s.hub_id=r.hub_id and s.active and s.staff_role in ('caretaker','coordinator','admin')) then
   raise exception 'not_authorized_for_pickup_point' using errcode='42501';
 end if;
 if r.status not in ('readyForPickup','reserved') or r.expires_at <= now() then return false; end if;
 update public.requests set status='collected', collected_by=u where id=r.id;
 return true;
end $$;

create or replace function public.send_pickup_message(p_voucher_code text,p_message text)
returns jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid(); r public.requests%rowtype; m public.messages%rowtype;
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 if length(trim(coalesce(p_message,''))) not between 1 and 2000 then raise exception 'invalid_message'; end if;
 select * into r from public.requests where upper(voucher_code)=upper(trim(p_voucher_code));
 if not found or r.expires_at <= now() then raise exception 'request_unavailable'; end if;
 if r.owner_id <> u and not exists(select 1 from public.hub_staff s where s.user_id=u and s.hub_id=r.hub_id and s.active) then
   raise exception 'not_authorized_for_request' using errcode='42501';
 end if;
 insert into public.messages(id,voucher_code,sender_id,sender_name,message,timestamp,is_seeker,is_delivered,is_read,sender_user_id,request_id)
 values(gen_random_uuid()::text,r.voucher_code,u::text,'PadCare user',trim(p_message),now(),r.owner_id=u,false,false,u,r.id)
 returning * into m;
 return jsonb_build_object('id',m.id,'voucher_code',m.voucher_code,'sender_id',m.sender_id,'sender_name',m.sender_name,
   'message',m.message,'timestamp',m.timestamp,'is_seeker',m.is_seeker,'is_delivered',m.is_delivered,'is_read',m.is_read);
end $$;

create or replace function public.list_pickup_messages(p_voucher_code text)
returns setof jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid(); r public.requests%rowtype;
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 select * into r from public.requests where upper(voucher_code)=upper(trim(p_voucher_code));
 if not found then raise exception 'request_unavailable'; end if;
 if r.owner_id <> u and not exists(select 1 from public.hub_staff s where s.user_id=u and s.hub_id=r.hub_id and s.active) then
   raise exception 'not_authorized_for_request' using errcode='42501';
 end if;
 return query select jsonb_build_object('id',m.id,'voucher_code',m.voucher_code,'sender_id',m.sender_id,'sender_name',m.sender_name,
   'message',m.message,'timestamp',m.timestamp,'is_seeker',m.is_seeker,'is_delivered',m.is_delivered,'is_read',m.is_read)
 from public.messages m where m.request_id=r.id order by m.timestamp asc limit 500;
end $$;

create or replace function public.publish_staff_location(
 p_hub_id text,p_latitude double precision,p_longitude double precision,p_label text,p_type text
) returns boolean language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid();
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 if p_latitude not between -90 and 90 or p_longitude not between -180 and 180 then raise exception 'invalid_coordinates'; end if;
 if p_type not in ('volunteer','mobile_dispensary') then raise exception 'invalid_location_type'; end if;
 if not exists(select 1 from public.hub_staff s where s.user_id=u and s.hub_id=p_hub_id and s.active) then
   raise exception 'not_authorized_for_pickup_point' using errcode='42501';
 end if;
 insert into public.live_locations(entity_id,latitude,longitude,label,type,updated_at,owner_id,hub_id)
 values(u::text,p_latitude,p_longitude,left(trim(p_label),100),p_type,now(),u,p_hub_id)
 on conflict(entity_id) do update set latitude=excluded.latitude,longitude=excluded.longitude,label=excluded.label,
   type=excluded.type,updated_at=now(),owner_id=u,hub_id=excluded.hub_id;
 return true;
end $$;

create or replace function public.list_staff_locations(p_hub_id text)
returns setof jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare u uuid := auth.uid();
begin
 if u is null then raise exception 'authentication_required' using errcode='28000'; end if;
 if not exists(select 1 from public.hub_staff s where s.user_id=u and s.hub_id=p_hub_id and s.active) then
   raise exception 'not_authorized_for_pickup_point' using errcode='42501';
 end if;
 return query select jsonb_build_object('entity_id',l.entity_id,'latitude',l.latitude,'longitude',l.longitude,
  'label',l.label,'type',l.type,'updated_at',l.updated_at)
 from public.live_locations l where l.hub_id=p_hub_id and l.updated_at > now()-interval '15 minutes';
end $$;

revoke all on function public.create_pickup_request(text,text,text) from public,anon;
revoke all on function public.list_my_pickup_requests() from public,anon;
revoke all on function public.verify_pickup_voucher(text) from public,anon;
revoke all on function public.send_pickup_message(text,text) from public,anon;
revoke all on function public.list_pickup_messages(text) from public,anon;
revoke all on function public.publish_staff_location(text,double precision,double precision,text,text) from public,anon;
revoke all on function public.list_staff_locations(text) from public,anon;
grant execute on function public.create_pickup_request(text,text,text) to authenticated;
grant execute on function public.list_my_pickup_requests() to authenticated;
grant execute on function public.verify_pickup_voucher(text) to authenticated;
grant execute on function public.send_pickup_message(text,text) to authenticated;
grant execute on function public.list_pickup_messages(text) to authenticated;
grant execute on function public.publish_staff_location(text,double precision,double precision,text,text) to authenticated;
grant execute on function public.list_staff_locations(text) to authenticated;

commit;

-- Operations team must insert hub_staff rows through trusted admin SQL/dashboard.
-- Never grant clients INSERT/UPDATE on hub_staff or let client user_metadata assign roles.
-- Enable Realtime for these tables only after reviewing privacy requirements; client RPCs
-- intentionally avoid unscoped realtime table subscriptions.
