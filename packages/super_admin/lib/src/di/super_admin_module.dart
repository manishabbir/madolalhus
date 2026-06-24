import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/plan.dart';
import '../domain/entities/tenant_plan.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/tenant_plan_repository.dart';
import '../data/repositories/supabase_plan_repository_impl.dart';
import '../data/repositories/supabase_tenant_plan_repository_impl.dart';
import '../services/super_admin_guard.dart';
import '../services/audit_log_service.dart';
import '../services/plan_service.dart';
import '../services/tenant_plan_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return SupabasePlanRepositoryImpl(ref.watch(supabaseClientProvider));
});

final tenantPlanRepositoryProvider = Provider<TenantPlanRepository>((ref) {
  return SupabaseTenantPlanRepositoryImpl(ref.watch(supabaseClientProvider));
});

final superAdminGuardProvider = Provider<SuperAdminGuard>((ref) {
  return SuperAdminGuard(ref.watch(supabaseClientProvider));
});

final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  return AuditLogService(ref.watch(supabaseClientProvider));
});

final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(ref.watch(supabaseClientProvider));
});

final tenantPlanServiceProvider = Provider<TenantPlanService>((ref) {
  return TenantPlanService(ref.watch(supabaseClientProvider));
});

final plansProvider = FutureProvider.autoDispose<List<Plan>>((ref) async {
  final service = ref.watch(planServiceProvider);
  final response = await service.getAllPlans();
  if (response.hasError) throw response.error!;
  return response.data ?? [];
});

final activePlansProvider = FutureProvider.autoDispose<List<Plan>>((ref) async {
  final service = ref.watch(planServiceProvider);
  final response = await service.getActivePlans();
  if (response.hasError) throw response.error!;
  return response.data ?? [];
});

final tenantPlansProvider = FutureProvider.autoDispose<List<TenantPlanWithOrg>>((ref) async {
  final service = ref.watch(tenantPlanServiceProvider);
  final response = await service.getAllTenantPlans();
  if (response.hasError) throw response.error!;
  return response.data ?? [];
});

final tenantPlanWithFeaturesProvider = FutureProvider.autoDispose.family<TenantPlanWithFeatures?, String>((ref, orgId) async {
  final service = ref.watch(tenantPlanServiceProvider);
  final response = await service.getTenantPlanWithFeatures(orgId);
  if (response.hasError) throw response.error!;
  return response.data;
});

final dashboardStatsProvider = FutureProvider.autoDispose<({int planCount, int tenantCount})>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final plansResponse = await client.from('plans').select('id').count(CountOption.exact);
  final tenantsResponse = await client.from('tenant_plans').select('id').count(CountOption.exact);
  return (planCount: plansResponse.count, tenantCount: tenantsResponse.count);
});
