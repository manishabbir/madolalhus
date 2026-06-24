-- First, drop ANY version of the function (with or without params)
-- The old version had no params; the new one has p_limit/p_offset/p_search
DROP FUNCTION IF EXISTS public.get_all_tenant_plans();
DROP FUNCTION IF EXISTS public.get_all_tenant_plans(int, int, text);

-- Now create the new paginated version
CREATE FUNCTION public.get_all_tenant_plans(
  p_limit int DEFAULT 20,
  p_offset int DEFAULT 0,
  p_search text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Access denied: super admin privileges required';
  END IF;

  SELECT jsonb_agg(
    jsonb_build_object(
      'id', o.id,
      'name', o.name,
      'slug', o.slug,
      'tenant_plans', CASE
        WHEN tp.id IS NOT NULL THEN jsonb_build_object(
          'id', tp.id,
          'organization_id', tp.organization_id,
          'plan_id', tp.plan_id,
          'custom_features', COALESCE(tp.custom_features, '[]'::jsonb),
          'disabled_features', COALESCE(tp.disabled_features, '[]'::jsonb),
          'status', tp.status,
          'ends_at', tp.ends_at,
          'plans', CASE
            WHEN p.id IS NOT NULL THEN jsonb_build_object(
              'id', p.id,
              'name', p.name
            )
            ELSE NULL
          END
        )
        ELSE NULL
      END
    )
    ORDER BY o.name
  )
  INTO result
  FROM public.organizations o
  LEFT JOIN public.tenant_plans tp ON tp.organization_id = o.id
  LEFT JOIN public.plans p ON p.id = tp.plan_id
  WHERE p_search IS NULL OR o.name ILIKE '%' || p_search || '%'
  LIMIT p_limit
  OFFSET p_offset;

  RETURN COALESCE(result, '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_all_tenant_plans() TO authenticated;

COMMENT ON FUNCTION public.get_all_tenant_plans() IS
  'Returns paginated organizations with tenant plan data. Super admin only.';
