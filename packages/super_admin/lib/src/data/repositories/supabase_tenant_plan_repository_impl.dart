import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tenant_plan.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/repositories/tenant_plan_repository.dart';
import '../datasources/supabase_tenant_plan_datasource.dart';

class SupabaseTenantPlanRepositoryImpl implements TenantPlanRepository {
  final SupabaseTenantPlanDataSource _ds;

  SupabaseTenantPlanRepositoryImpl(SupabaseClient client) : _ds = SupabaseTenantPlanDataSource(client);

  @override
  Future<List<TenantPlanWithOrg>> getAllTenantPlans() async {
    try {
      final orgList = await _ds.getAllTenantPlans();
      return orgList.map((org) {
        final tenantPlansRaw = org['tenant_plans'];
        final tenantPlans = <Map<String, dynamic>>[];
        if (tenantPlansRaw is List) {
          tenantPlans.addAll(
            List<Map<String, dynamic>>.from(
              tenantPlansRaw.map((e) => Map<String, dynamic>.from(e as Map)),
            ),
          );
        } else if (tenantPlansRaw is Map) {
          tenantPlans.add(Map<String, dynamic>.from(tenantPlansRaw));
        }

        if (tenantPlans.isNotEmpty) {
          final tp = tenantPlans.first;
          final planData = tp['plans'] as Map<String, dynamic>?;
          return TenantPlanWithOrg(
            id: tp['id'] as String? ?? '',
            organizationId: org['id'] as String? ?? '',
            organizationName: org['name'] as String? ?? 'Unknown',
            organizationSlug: org['slug'] as String?,
            planId: tp['plan_id'] as String? ?? '',
            planName: planData?['name'] as String? ?? 'No Plan',
            customFeatures: _asStringList(tp['custom_features']),
            disabledFeatures: _asStringList(tp['disabled_features']),
            status: TenantPlanStatus.values.firstWhere(
              (e) => e.name == (tp['status'] as String? ?? 'active'),
              orElse: () => TenantPlanStatus.active,
            ),
            endsAt: tp['ends_at'] != null ? DateTime.parse(tp['ends_at'] as String) : null,
          );
        }

        return TenantPlanWithOrg(
          id: '',
          organizationId: org['id'] as String? ?? '',
          organizationName: org['name'] as String? ?? 'Unknown',
          organizationSlug: org['slug'] as String?,
          planId: '',
          planName: 'No Plan',
          customFeatures: const [],
          disabledFeatures: const [],
          status: TenantPlanStatus.suspended,
          endsAt: null,
        );
      }).toList();
    } catch (e) {
      throw AppException('Failed to fetch tenant plans', e);
    }
  }

  @override
  Future<TenantPlan?> getTenantPlanByOrgId(String orgId) async {
    try {
      final map = await _ds.getTenantPlanByOrgId(orgId);
      return map == null ? null : TenantPlan.fromMap(map);
    } catch (e) {
      throw AppException('Failed to fetch tenant plan', e);
    }
  }

  @override
  Future<void> assignPlanToTenant({
    required String orgId,
    required String planId,
  }) async {
    try {
      await _ds.assignPlanToTenant(orgId: orgId, planId: planId);
    } catch (e) {
      throw AppException('Failed to assign plan', e);
    }
  }

  @override
  Future<void> customizeTenantPlan({
    required String orgId,
    required List<String> customFeatures,
    required List<String> disabledFeatures,
  }) async {
    try {
      await _ds.customizeTenantPlan(
        orgId: orgId,
        customFeatures: customFeatures,
        disabledFeatures: disabledFeatures,
      );
    } catch (e) {
      throw AppException('Failed to customize tenant plan', e);
    }
  }

  @override
  Future<void> disableTenantPlan(String orgId) async {
    try {
      await _ds.disableTenantPlan(orgId);
    } catch (e) {
      throw AppException('Failed to disable tenant plan', e);
    }
  }

  @override
  Future<void> enableTenantPlan(String orgId) async {
    try {
      await _ds.enableTenantPlan(orgId);
    } catch (e) {
      throw AppException('Failed to enable tenant plan', e);
    }
  }

  @override
  Future<void> removeTenantPlan(String orgId) async {
    try {
      await _ds.removeTenantPlan(orgId);
    } catch (e) {
      throw AppException('Failed to remove tenant plan', e);
    }
  }

  @override
  Future<void> setTenantPlanExpiry(String orgId, DateTime? endsAt) async {
    try {
      await _ds.setTenantPlanExpiry(orgId, endsAt);
    } catch (e) {
      throw AppException('Failed to set tenant plan expiry', e);
    }
  }

  @override
  Future<bool> hasPaidPlan(String orgId) async {
    try {
      final result = await _ds.hasPaidPlan(orgId);
      if (result == null) return false;
      final priceCents = result['price_cents'] as int? ?? 0;
      return priceCents > 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasFeature(String orgId, String featureId) async {
    try {
      final plan = await getTenantPlanWithFeatures(orgId);
      if (plan == null) return false;

      if (plan.disabledFeatures.contains(featureId)) return false;
      return plan.featureFlags.contains(featureId) ||
          plan.customFeatures.contains(featureId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<TenantPlanWithFeatures?> getTenantPlanWithFeatures(String orgId) async {
    try {
      final map = await _ds.getTenantPlanWithFeatures(orgId);
      if (map == null) return null;

      final planMap = map['plans'] as Map<String, dynamic>;

      return TenantPlanWithFeatures(
        id: map['id'] as String,
        organizationId: map['organization_id'] as String,
        planId: map['plan_id'] as String,
        planName: planMap['name'] as String? ?? 'Unknown',
        priceCents: (planMap['price_cents'] as int?) ?? 0,
        status: TenantPlanStatus.values.firstWhere(
          (e) => e.name == (map['status'] as String? ?? 'active'),
          orElse: () => TenantPlanStatus.active,
        ),
        featureFlags: _asStringList(planMap['feature_flags']),
        customFeatures: _asStringList(map['custom_features']),
        disabledFeatures: _asStringList(map['disabled_features']),
      );
    } catch (e) {
      throw AppException('Failed to fetch tenant plan with features', e);
    }
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
