create extension if not exists pgcrypto;

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references auth.users(id) on delete cascade,
  action text not null,
  target_type text not null,
  target_id uuid,
  changes jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create index if not exists idx_audit_logs_actor on public.audit_logs(actor_id);
create index if not exists idx_audit_logs_target on public.audit_logs(target_type, target_id);
create index if not exists idx_audit_logs_created on public.audit_logs(created_at);

alter table public.audit_logs enable row level security;

create policy "audit_logs_super_admin_all"
  on public.audit_logs
  for all
  using (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()))
  with check (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()));
