-- RPC function for super admins to get all tenant plans across ALL organizations.
-- Uses security definer to bypass RLS on the organizations table.
-- The function first verifies the caller is a super admin, then returns
-- all organizations with their associated tenant plan data.

create or replace function public.get_all_tenant_plans()
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  result jsonb;
begin
  -- Verify super admin privileges
  if not exists (
    select 1 from public.super_admins where user_id = auth.uid()
  ) then
    raise exception 'Access denied: super admin privileges required';
  end if;

  -- Build the response as a JSON array matching the shape:
  -- [{ id, name, slug, tenant_plans: [{ id, organization_id, plan_id,
  --      custom_features, disabled_features, status, ends_at,
  --      plans: { id, name } }] }]
  select jsonb_agg(
    jsonb_build_object(
      'id', o.id,
      'name', o.name,
      'slug', o.slug,
      'tenant_plans', case
        when tp.id is not null then jsonb_build_object(
          'id', tp.id,
          'organization_id', tp.organization_id,
          'plan_id', tp.plan_id,
          'custom_features', coalesce(tp.custom_features, '[]'::jsonb),
          'disabled_features', coalesce(tp.disabled_features, '[]'::jsonb),
          'status', tp.status,
          'ends_at', tp.ends_at,
          'plans', case
            when p.id is not null then jsonb_build_object(
              'id', p.id,
              'name', p.name
            )
            else null
          end
        )
        else null
      end
    )
    order by o.name
  )
  into result
  from public.organizations o
  left join public.tenant_plans tp on tp.organization_id = o.id
  left join public.plans p on p.id = tp.plan_id;

  return coalesce(result, '[]'::jsonb);
end;
$$;

-- Grant execution to authenticated users (super admin check is inside)
grant execute on function public.get_all_tenant_plans() to authenticated;

comment on function public.get_all_tenant_plans() is
  'Returns all organizations with their tenant plan data. Super admin only.';