import '../entities/plan.dart';

abstract class PlanRepository {
  Future<List<Plan>> getAllPlans();
  Future<List<Plan>> getActivePlans();
  Future<Plan?> getPlanById(String id);
  Future<Plan> createPlan({
    required String name,
    String? description,
    required int priceCents,
    required BillingInterval billingInterval,
    List<String> featureFlags = const [],
  });
  Future<Plan> updatePlan({
    required String id,
    String? name,
    String? description,
    int? priceCents,
    BillingInterval? billingInterval,
    List<String>? featureFlags,
    bool? isActive,
  });
  Future<void> deletePlan(String id);
  Future<void> activatePlan(String id);
  Future<void> deactivatePlan(String id);
}
