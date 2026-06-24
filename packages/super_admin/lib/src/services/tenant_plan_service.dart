import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/tenant_plan.dart';
import '../domain/repositories/tenant_plan_repository.dart';
import '../domain/exceptions/app_exception.dart';
import '../data/repositories/supabase_tenant_plan_repository_impl.dart';
import 'api_response.dart';
import 'super_admin_guard.dart';
import 'audit_log_service.dart';

class TenantPlanService {
  final TenantPlanRepository _repository;
  final SuperAdminGuard _guard;
  final AuditLogService _auditLog;

  TenantPlanService(SupabaseClient supabase)
      : _repository = SupabaseTenantPlanRepositoryImpl(supabase),
        _guard = SuperAdminGuard(supabase),
        _auditLog = AuditLogService(supabase);

  Future<ApiResponse<List<TenantPlanWithOrg>>> getAllTenantPlans() async {
    try {
      final plans = await _repository.getAllTenantPlans();
      return ApiResponse.success(plans);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch tenant plans', e));
    }
  }

  Future<ApiResponse<TenantPlan?>> getTenantPlanByOrgId(String orgId) async {
    try {
      final plan = await _repository.getTenantPlanByOrgId(orgId);
      return ApiResponse.success(plan);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch tenant plan', e));
    }
  }

  Future<ApiResponse<void>> assignPlanToTenant({
    required String orgId,
    required String planId,
  }) async {
    try {
      await _repository.assignPlanToTenant(orgId: orgId, planId: planId);
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to assign plan', e));
    }
  }

  Future<ApiResponse<void>> customizeTenantPlan({
    required String orgId,
    required List<String> customFeatures,
    required List<String> disabledFeatures,
  }) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.customizeTenantPlan(
        orgId: orgId,
        customFeatures: customFeatures,
        disabledFeatures: disabledFeatures,
      );
      await _auditLog.log(
        action: 'customize_tenant_plan',
        targetType: 'tenant_plan',
        targetId: orgId,
        changes: {
          'customFeatures': customFeatures,
          'disabledFeatures': disabledFeatures,
        },
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to customize tenant plan', e));
    }
  }

  Future<ApiResponse<void>> disableTenantPlan(String orgId) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.disableTenantPlan(orgId);
      await _auditLog.log(
        action: 'disable_tenant_plan',
        targetType: 'tenant_plan',
        targetId: orgId,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to disable tenant plan', e));
    }
  }

  Future<ApiResponse<void>> enableTenantPlan(String orgId) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.enableTenantPlan(orgId);
      await _auditLog.log(
        action: 'enable_tenant_plan',
        targetType: 'tenant_plan',
        targetId: orgId,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to enable tenant plan', e));
    }
  }

  Future<ApiResponse<void>> removeTenantPlan(String orgId) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.removeTenantPlan(orgId);
      await _auditLog.log(
        action: 'remove_tenant_plan',
        targetType: 'tenant_plan',
        targetId: orgId,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to remove tenant plan', e));
    }
  }

  Future<ApiResponse<void>> setTenantPlanExpiry(String orgId, DateTime? endsAt) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.setTenantPlanExpiry(orgId, endsAt);
      await _auditLog.log(
        action: 'set_tenant_plan_expiry',
        targetType: 'tenant_plan',
        targetId: orgId,
        changes: {'endsAt': endsAt?.toIso8601String()},
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to set tenant plan expiry', e));
    }
  }

  Future<ApiResponse<bool>> hasPaidPlan(String orgId) async {
    try {
      final hasPaid = await _repository.hasPaidPlan(orgId);
      return ApiResponse.success(hasPaid);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to check paid plan', e));
    }
  }

  Future<ApiResponse<bool>> hasFeature(String orgId, String featureId) async {
    try {
      final hasFeature = await _repository.hasFeature(orgId, featureId);
      return ApiResponse.success(hasFeature);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to check feature', e));
    }
  }

  Future<ApiResponse<TenantPlanWithFeatures?>> getTenantPlanWithFeatures(String orgId) async {
    try {
      final plan = await _repository.getTenantPlanWithFeatures(orgId);
      return ApiResponse.success(plan);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch tenant plan with features', e));
    }
  }
}
