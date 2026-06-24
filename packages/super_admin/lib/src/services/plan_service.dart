import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/plan.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/exceptions/app_exception.dart';
import '../data/repositories/supabase_plan_repository_impl.dart';
import 'api_response.dart';
import 'super_admin_guard.dart';
import 'audit_log_service.dart';

class PlanService {
  final PlanRepository _repository;
  final SuperAdminGuard _guard;
  final AuditLogService _auditLog;

  PlanService(SupabaseClient supabase)
      : _repository = SupabasePlanRepositoryImpl(supabase),
        _guard = SuperAdminGuard(supabase),
        _auditLog = AuditLogService(supabase);

  Future<ApiResponse<List<Plan>>> getAllPlans() async {
    try {
      final plans = await _repository.getAllPlans();
      return ApiResponse.success(plans);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch plans', e));
    }
  }

  Future<ApiResponse<List<Plan>>> getActivePlans() async {
    try {
      final plans = await _repository.getActivePlans();
      return ApiResponse.success(plans);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch active plans', e));
    }
  }

  Future<ApiResponse<Plan?>> getPlanById(String id) async {
    try {
      final plan = await _repository.getPlanById(id);
      return ApiResponse.success(plan);
    } catch (e) {
      return ApiResponse.error(e is AppException ? e : AppException('Failed to fetch plan', e));
    }
  }

  Future<ApiResponse<Plan>> createPlan({
    required String name,
    String? description,
    required int priceCents,
    required BillingInterval billingInterval,
    List<String> featureFlags = const [],
  }) async {
    try {
      await _guard.ensureSuperAdmin();
      final plan = await _repository.createPlan(
        name: name,
        description: description,
        priceCents: priceCents,
        billingInterval: billingInterval,
        featureFlags: featureFlags,
      );
      await _auditLog.log(
        action: 'create_plan',
        targetType: 'plan',
        targetId: plan.id,
        changes: {'name': name, 'priceCents': priceCents},
      );
      return ApiResponse.success(plan);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to create plan', e));
    }
  }

  Future<ApiResponse<Plan>> updatePlan({
    required String id,
    String? name,
    String? description,
    int? priceCents,
    BillingInterval? billingInterval,
    List<String>? featureFlags,
    bool? isActive,
  }) async {
    try {
      await _guard.ensureSuperAdmin();
      final plan = await _repository.updatePlan(
        id: id,
        name: name,
        description: description,
        priceCents: priceCents,
        billingInterval: billingInterval,
        featureFlags: featureFlags,
        isActive: isActive,
      );
      await _auditLog.log(
        action: 'update_plan',
        targetType: 'plan',
        targetId: id,
        changes: {
          if (name != null) 'name': name,
          if (priceCents != null) 'priceCents': priceCents,
          if (isActive != null) 'isActive': isActive,
        },
      );
      return ApiResponse.success(plan);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to update plan', e));
    }
  }

  Future<ApiResponse<void>> deletePlan(String id) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.deletePlan(id);
      await _auditLog.log(
        action: 'delete_plan',
        targetType: 'plan',
        targetId: id,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to delete plan', e));
    }
  }

  Future<ApiResponse<void>> activatePlan(String id) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.activatePlan(id);
      await _auditLog.log(
        action: 'activate_plan',
        targetType: 'plan',
        targetId: id,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to activate plan', e));
    }
  }

  Future<ApiResponse<void>> deactivatePlan(String id) async {
    try {
      await _guard.ensureSuperAdmin();
      await _repository.deactivatePlan(id);
      await _auditLog.log(
        action: 'deactivate_plan',
        targetType: 'plan',
        targetId: id,
      );
      return ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.error(e);
    } catch (e) {
      return ApiResponse.error(AppException('Failed to deactivate plan', e));
    }
  }
}
