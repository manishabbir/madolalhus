import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/plan.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/supabase_plan_datasource.dart';

class SupabasePlanRepositoryImpl implements PlanRepository {
  final SupabasePlanDataSource _ds;

  SupabasePlanRepositoryImpl(SupabaseClient client) : _ds = SupabasePlanDataSource(client);

  @override
  Future<List<Plan>> getAllPlans() async {
    try {
      final maps = await _ds.getAllPlans();
      return maps.map(Plan.fromMap).toList();
    } catch (e) {
      throw AppException('Failed to fetch plans', e);
    }
  }

  @override
  Future<List<Plan>> getActivePlans() async {
    try {
      final maps = await _ds.getActivePlans();
      return maps.map(Plan.fromMap).toList();
    } catch (e) {
      throw AppException('Failed to fetch active plans', e);
    }
  }

  @override
  Future<Plan?> getPlanById(String id) async {
    try {
      final map = await _ds.getPlanById(id);
      return map == null ? null : Plan.fromMap(map);
    } catch (e) {
      throw AppException('Failed to fetch plan', e);
    }
  }

  @override
  Future<Plan> createPlan({
    required String name,
    String? description,
    required int priceCents,
    required BillingInterval billingInterval,
    List<String> featureFlags = const [],
  }) async {
    try {
      final map = await _ds.createPlan({
        'name': name,
        'description': description,
        'price_cents': priceCents,
        'billing_interval': billingInterval.name,
        'feature_flags': featureFlags,
      });
      return Plan.fromMap(map);
    } catch (e) {
      throw AppException('Failed to create plan', e);
    }
  }

  @override
  Future<Plan> updatePlan({
    required String id,
    String? name,
    String? description,
    int? priceCents,
    BillingInterval? billingInterval,
    List<String>? featureFlags,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (priceCents != null) updates['price_cents'] = priceCents;
      if (billingInterval != null) updates['billing_interval'] = billingInterval.name;
      if (featureFlags != null) updates['feature_flags'] = featureFlags;
      if (isActive != null) updates['is_active'] = isActive;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final map = await _ds.updatePlan(id, updates);
      return Plan.fromMap(map);
    } catch (e) {
      throw AppException('Failed to update plan', e);
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    try {
      await _ds.deletePlan(id);
    } catch (e) {
      throw AppException('Failed to delete plan', e);
    }
  }

  @override
  Future<void> activatePlan(String id) async {
    try {
      await _ds.activatePlan(id);
    } catch (e) {
      throw AppException('Failed to activate plan', e);
    }
  }

  @override
  Future<void> deactivatePlan(String id) async {
    try {
      await _ds.deactivatePlan(id);
    } catch (e) {
      throw AppException('Failed to deactivate plan', e);
    }
  }
}
