import '../entities/tenant_plan.dart';

abstract class TenantPlanRepository {
  Future<List<TenantPlanWithOrg>> getAllTenantPlans();
  Future<TenantPlan?> getTenantPlanByOrgId(String orgId);
  Future<void> assignPlanToTenant({
    required String orgId,
    required String planId,
  });
  Future<void> customizeTenantPlan({
    required String orgId,
    required List<String> customFeatures,
    required List<String> disabledFeatures,
  });
  Future<void> disableTenantPlan(String orgId);
  Future<void> enableTenantPlan(String orgId);
  Future<void> removeTenantPlan(String orgId);
  Future<void> setTenantPlanExpiry(String orgId, DateTime? endsAt);
  Future<bool> hasPaidPlan(String orgId);
  Future<bool> hasFeature(String orgId, String featureId);
  Future<TenantPlanWithFeatures?> getTenantPlanWithFeatures(String orgId);
}
