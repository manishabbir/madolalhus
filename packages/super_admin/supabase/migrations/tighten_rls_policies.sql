drop policy if exists "super_admin_plans_all" on public.plans;
drop policy if exists "super_admin_tenant_plans_all" on public.tenant_plans;

create policy "super_admin_plans_all"
  on public.plans
  for all
  using (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()))
  with check (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()));

create policy "super_admin_tenant_plans_all"
  on public.tenant_plans
  for all
  using (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()))
  with check (EXISTS (SELECT 1 FROM public.super_admins WHERE user_id = auth.uid()));
