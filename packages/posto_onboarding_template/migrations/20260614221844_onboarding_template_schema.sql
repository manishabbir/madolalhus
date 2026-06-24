create extension if not exists pgcrypto;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  business_type text not null default 'general',
  tenant_features jsonb not null default '[]'::jsonb,
  language text not null default 'en',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.organization_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  role text not null default 'member' check (role in ('admin', 'manager', 'cashier', 'waiter', 'kitchen', 'viewer')),
  joined_at timestamptz default now(),
  unique(user_id, organization_id)
);

create index if not exists idx_org_members_user on public.organization_members(user_id);
create index if not exists idx_org_members_org on public.organization_members(organization_id);
create index if not exists idx_organizations_slug on public.organizations(slug);

alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;

drop policy if exists "Users can view their organizations" on public.organizations;
drop policy if exists "Authenticated users can create organizations" on public.organizations;
drop policy if exists "Users can view their own memberships" on public.organization_members;
drop policy if exists "Users can insert their own membership" on public.organization_members;
drop policy if exists "Admins can manage members" on public.organization_members;

create policy "template_organizations_select_members"
  on public.organizations
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.organization_members
      where organization_members.organization_id = organizations.id
        and organization_members.user_id = auth.uid()
    )
  );

create policy "template_organization_members_select_own"
  on public.organization_members
  for select
  to authenticated
  using (user_id = auth.uid());

create policy "template_organization_members_insert_own"
  on public.organization_members
  for insert
  to authenticated
  with check (user_id = auth.uid());

create or replace function public.is_org_admin(p_org_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return exists (
    select 1
    from public.organization_members
    where user_id = auth.uid()
      and organization_id = p_org_id
      and role = 'admin'
  );
end;
$$;

create policy "template_organization_members_admin_manage"
  on public.organization_members
  for all
  to authenticated
  using (
    public.is_org_admin(organization_members.organization_id)
  )
  with check (
    public.is_org_admin(organization_members.organization_id)
  );

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists organizations_updated_at on public.organizations;
create trigger organizations_updated_at
before update on public.organizations
for each row
execute function public.set_updated_at();

create or replace function public.create_organization(
  org_name text,
  biz_types text default 'general',
  features jsonb default '[]'::jsonb,
  p_language text default 'en'
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  current_user_id uuid;
  new_org_id uuid;
  new_slug text;
  normalized_language text;
  result jsonb;
begin
  current_user_id := auth.uid();
  if current_user_id is null then
    raise exception 'not authenticated';
  end if;

  if org_name is null or btrim(org_name) = '' then
    raise exception 'organization name is required';
  end if;

  normalized_language := case when p_language in ('en', 'ur') then p_language else 'en' end;

  new_slug := trim(both '-' from lower(regexp_replace(org_name, '[^a-zA-Z0-9]+', '-', 'g')));

  insert into public.organizations (name, slug, business_type, tenant_features, language)
  values (org_name, new_slug, biz_types, features, normalized_language)
  returning id into new_org_id;

  insert into public.organization_members (user_id, organization_id, role)
  values (current_user_id, new_org_id, 'admin');

  select jsonb_build_object(
    'id', new_org_id,
    'name', org_name,
    'slug', new_slug,
    'role', 'admin',
    'business_type', biz_types,
    'tenant_features', features,
    'language', normalized_language
  ) into result;

  return result;
end;
$$;

create or replace function public.update_tenant_features(
  p_org_id uuid,
  p_features jsonb,
  p_language text default null
)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  if p_language is null then
    update public.organizations
    set tenant_features = p_features,
        updated_at = now()
    where id = p_org_id
      and exists (
        select 1
        from public.organization_members
        where user_id = auth.uid()
          and organization_id = p_org_id
          and role = 'admin'
      );
  else
    update public.organizations
    set tenant_features = p_features,
        language = p_language,
        updated_at = now()
    where id = p_org_id
      and exists (
        select 1
        from public.organization_members
        where user_id = auth.uid()
          and organization_id = p_org_id
          and role = 'admin'
      );
  end if;
end;
$$;

revoke all on function public.create_organization(text, text, jsonb, text) from public;
grant execute on function public.create_organization(text, text, jsonb, text) to authenticated;

revoke all on function public.update_tenant_features(uuid, jsonb, text) from public;
grant execute on function public.update_tenant_features(uuid, jsonb, text) to authenticated;

revoke all on function public.is_org_admin(uuid) from public;
grant execute on function public.is_org_admin(uuid) to authenticated;
