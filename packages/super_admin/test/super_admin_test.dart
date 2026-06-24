import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/super_admin.dart';

void main() {
  group('Plan', () {
    test('fromMap creates Plan from json', () {
      final map = {
        'id': '123',
        'name': 'Test Plan',
        'description': 'Test description',
        'price_cents': 1000,
        'billing_interval': 'monthly',
        'feature_flags': ['INVENTORY_MANAGEMENT'],
        'is_active': true,
      };

      final plan = Plan.fromMap(map);

      expect(plan.id, '123');
      expect(plan.name, 'Test Plan');
      expect(plan.description, 'Test description');
      expect(plan.priceCents, 1000);
      expect(plan.billingInterval, BillingInterval.monthly);
      expect(plan.featureFlags, ['INVENTORY_MANAGEMENT']);
      expect(plan.isActive, true);
    });

    test('copyWith updates specified fields', () {
      const plan = Plan(
        id: '123',
        name: 'Test Plan',
        priceCents: 1000,
        billingInterval: BillingInterval.monthly,
        featureFlags: [],
      );

      final updated = plan.copyWith(name: 'Updated Plan');

      expect(updated.name, 'Updated Plan');
      expect(updated.id, '123');
    });
  });

  group('TenantPlan', () {
    test('fromMap creates TenantPlan from json', () {
      final map = {
        'id': '456',
        'organization_id': 'org-123',
        'plan_id': 'plan-456',
        'custom_features': ['EXTRA_FEATURE'],
        'disabled_features': ['CUSTOMER_MANAGEMENT'],
        'status': 'active',
      };

      final tenantPlan = TenantPlan.fromMap(map);

      expect(tenantPlan.id, '456');
      expect(tenantPlan.organizationId, 'org-123');
      expect(tenantPlan.planId, 'plan-456');
      expect(tenantPlan.customFeatures, ['EXTRA_FEATURE']);
      expect(tenantPlan.disabledFeatures, ['CUSTOMER_MANAGEMENT']);
      expect(tenantPlan.status, TenantPlanStatus.active);
    });
  });

  group('TenantPlanWithOrg', () {
    test('fromMap creates TenantPlanWithOrg with joined data', () {
      final map = {
        'id': '789',
        'organization_id': 'org-123',
        'plan_id': 'plan-456',
        'organizations': {
          'id': 'org-123',
          'name': 'Test Org',
          'slug': 'test-org',
        },
        'plans': {
          'id': 'plan-456',
          'name': 'Basic Plan',
        },
        'status': 'active',
      };

      final tenantPlan = TenantPlanWithOrg.fromMap(map);

      expect(tenantPlan.organizationName, 'Test Org');
      expect(tenantPlan.organizationSlug, 'test-org');
      expect(tenantPlan.planName, 'Basic Plan');
    });
  });
}