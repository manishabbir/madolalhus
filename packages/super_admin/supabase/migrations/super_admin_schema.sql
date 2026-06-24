create extension if not exists pgcrypto;

-- super_admins table: defines users with super admin privileges
create table if not exists public.super_admins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  granted_at timestamptz default now(),
  granted_by uuid,
  unique(user_id)
);

-- enable row level security on super_admins
alter table public.super_admins enable row level security;

-- Only authenticated users can check their own super admin status
create policy "super_admins_select_own"
  on public.super_admins
  for select
  using (user_id = auth.uid());

-- Allow insert for authenticated users (you may want to restrict this further)
create policy "super_admins_insert_auth"
  on public.super_admins
  for insert
  with check (true);

-- Allow delete for authenticated users
create policy "super_admins_delete_auth"
  on public.super_admins
  for delete
  using (true);

-- plans table: defines available subscription plans
create table if not exists public.plans (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  price_cents bigint not null default 0,
  billing_interval text not null default 'monthly' check (billing_interval in ('monthly', 'yearly')),
  feature_flags jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- tenant_plans table: links organizations to their assigned plans
create table if not exists public.tenant_plans (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  plan_id uuid not null references public.plans(id),
  custom_features jsonb default '[]'::jsonb,
  disabled_features jsonb default '[]'::jsonb,
  status text not null default 'active' check (status in ('active', 'suspended', 'expired', 'cancelled')),
  started_at timestamptz default now(),
  ends_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(organization_id)
);

-- indexes for performance
create index if not exists idx_plans_active on public.plans(is_active);
create index if not exists idx_tenant_plans_org on public.tenant_plans(organization_id);
create index if not exists idx_tenant_plans_plan on public.tenant_plans(plan_id);
create index if not exists idx_tenant_plans_status on public.tenant_plans(status);

-- enable row level security
alter table public.plans enable row level security;
alter table public.tenant_plans enable row level security;

-- RLS policies for super admin access (adjust based on your auth requirements)
-- For now, allow authenticated users full access - you may want to restrict to specific roles
drop policy if exists "super_admin_plans_all" on public.plans;
drop policy if exists "super_admin_tenant_plans_all" on public.tenant_plans;

create policy "super_admin_plans_all"
  on public.plans
  for all
  using (true)
  with check (true);

create policy "super_admin_tenant_plans_all"
  on public.tenant_plans
  for all
  using (true)
  with check (true);

-- trigger to update updated_at timestamp
drop trigger if exists plans_updated_at on public.plans;
create trigger plans_updated_at
before update on public.plans
for each row
execute function public.set_updated_at();

drop trigger if exists tenant_plans_updated_at on public.tenant_plans;
create trigger tenant_plans_updated_at
before update on public.tenant_plans
for each row
execute function public.set_updated_at();

-- RPC function to get available features for reference
create or replace function public.get_available_features()
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return jsonb_build_array(
    jsonb_build_object('id', 'SECURE_AUTHENTICATION', 'name', 'Secure Authentication'),
    jsonb_build_object('id', 'INVENTORY_MANAGEMENT', 'name', 'Inventory Management'),
    jsonb_build_object('id', 'POS_REGISTER', 'name', 'POS Register'),
    jsonb_build_object('id', 'CUSTOMER_MANAGEMENT', 'name', 'Customer Management'),
    jsonb_build_object('id', 'ADS_DISABLED', 'name', 'Ads Disabled')
  );
end;
$$;

grant execute on function public.get_available_features() to authenticated;

-- Insert default Free plan with ads
insert into public.plans (name, description, price_cents, billing_interval, feature_flags, is_active)
values (
  'Free',
  'Free plan with ads support',
  0,
  'monthly',
  '[]'::jsonb,
  true
) on conflict (name) do nothing;

-- Function to assign free plan to new organizations
create or replace function public.assign_free_plan_to_org()
returns trigger
language plpgsql
security definer
as $$
declare
  free_plan_id uuid;
begin
  -- Get the Free plan ID
  select id into free_plan_id from public.plans where name = 'Free' limit 1;
  
  -- If Free plan exists, assign it to the new organization
  if free_plan_id is not null then
    insert into public.tenant_plans (organization_id, plan_id, status, started_at)
    values (NEW.id, free_plan_id, 'active', now());
  end if;
  
  return NEW;
end;
$$;

-- Trigger to auto-assign Free plan on organization creation
drop trigger if exists assign_free_plan_trigger on public.organizations;
create trigger assign_free_plan_trigger
  after insert on public.organizations
  for each row
  execute function public.assign_free_plan_to_org();