import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/plan.dart';
import '../domain/entities/tenant_plan.dart';
import '../di/super_admin_module.dart';
import '../presentation/widgets/shared/error_state.dart';

class TenantPlanSelectionPage extends StatefulWidget {
  final String organizationId;

  const TenantPlanSelectionPage({
    super.key,
    required this.organizationId,
  });

  @override
  State<TenantPlanSelectionPage> createState() => _TenantPlanSelectionPageState();
}

class _TenantPlanSelectionPageState extends State<TenantPlanSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final plansAsync = ref.watch(activePlansProvider);
        final currentPlanAsync = ref.watch(tenantPlanWithFeaturesProvider(widget.organizationId));
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Select Your Plan'),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(activePlansProvider.future)),
        data: (plans) => currentPlanAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(tenantPlanWithFeaturesProvider(widget.organizationId).future)),
          data: (currentPlan) => _buildContent(context, ref, plans, currentPlan),
        ),
      ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Plan> plans, TenantPlanWithFeatures? currentPlan) {
    if (plans.isEmpty) {
      return const Center(child: Text('No plans available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentPlan != null) _buildCurrentPlanCard(currentPlan),
          const SizedBox(height: 20),
          Text(
            currentPlan != null ? 'Available Plans' : 'Select a Plan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...plans.map((p) => _buildPlanCard(context, ref, p, currentPlan)),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(TenantPlanWithFeatures plan) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.planName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.isPaid ? 'Paid Plan' : 'Free Plan (with ads)',
              style: TextStyle(
                color: plan.isPaid ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Plan plan, TenantPlanWithFeatures? currentPlan) {
    final isCurrent = currentPlan?.planId == plan.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrent ? 4 : 1,
      color: isCurrent ? Theme.of(context).primaryColor.withAlpha(0x0D) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.description ?? ''),
            const SizedBox(height: 12),
            Text(
              plan.formattedPrice,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: plan.featureFlags.take(4).map((feature) {
                return Chip(
                  label: Text(feature),
                  labelStyle: const TextStyle(fontSize: 11),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrent ? null : () {
                  if (currentPlan == null) {
                    _selectPlan(context, ref, plan);
                  } else {
                    _upgradePlan(context, ref, plan);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.grey : Theme.of(context).primaryColor,
                ),
                child: Text(isCurrent ? 'Selected' : 'Choose Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, WidgetRef ref, Plan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Plan'),
        content: Text('Are you sure you want to select "${plan.name}" plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final service = ref.read(tenantPlanServiceProvider);
    final response = await service.assignPlanToTenant(
      orgId: widget.organizationId,
      planId: plan.id,
    );
    if (!context.mounted) return;
    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
      return;
    }
    ref.invalidate(activePlansProvider);
    ref.invalidate(tenantPlanWithFeaturesProvider(widget.organizationId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan selected successfully')),
    );
  }

  Future<void> _upgradePlan(BuildContext context, WidgetRef ref, Plan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Plan'),
        content: Text('Upgrade to "${plan.name}" for ${plan.formattedPrice}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final service = ref.read(tenantPlanServiceProvider);
    final response = await service.assignPlanToTenant(
      orgId: widget.organizationId,
      planId: plan.id,
    );
    if (!context.mounted) return;
    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
      return;
    }
    ref.invalidate(activePlansProvider);
    ref.invalidate(tenantPlanWithFeaturesProvider(widget.organizationId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan upgraded successfully')),
    );
  }
}
