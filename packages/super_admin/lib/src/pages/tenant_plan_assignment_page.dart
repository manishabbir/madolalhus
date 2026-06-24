import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/plan.dart';
import '../domain/entities/tenant_plan.dart';
import '../domain/constants/feature_registry.dart';
import '../di/super_admin_module.dart';
import '../widgets/feature_toggle_chip.dart';
import '../presentation/widgets/shared/error_state.dart';

class TenantPlanAssignmentPage extends StatefulWidget {
  const TenantPlanAssignmentPage({super.key});

  @override
  State<TenantPlanAssignmentPage> createState() =>
      _TenantPlanAssignmentPageState();
}

class _TenantPlanAssignmentPageState extends State<TenantPlanAssignmentPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final tenantPlansAsync = ref.watch(tenantPlansProvider);
        final activePlansAsync = ref.watch(activePlansProvider);
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Tenant Plan Assignment'),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: tenantPlansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString(), onRetry: () => ref.refresh(tenantPlansProvider.future)),
            data: (tenantPlans) => activePlansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(message: error.toString(), onRetry: () => ref.refresh(activePlansProvider.future)),
              data: (plans) => _buildBody(context, ref, tenantPlans, plans),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<TenantPlanWithOrg> tenantPlans, List<Plan> plans) {
    if (tenantPlans.isEmpty) {
      return const Center(child: Text('No organizations found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(tenantPlansProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tenantPlans.length,
        itemBuilder: (context, index) {
          final tenantPlan = tenantPlans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tenantPlan.organizationName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tenantPlan.status == TenantPlanStatus.active
                              ? Colors.green.withAlpha(0x1A)
                              : Colors.red.withAlpha(0x1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tenantPlan.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: tenantPlan.status == TenantPlanStatus.active
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan: ${tenantPlan.planName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (tenantPlan.customFeatures.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Custom Features:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final feature in tenantPlan.customFeatures)
                          Chip(
                            label: Text(feature),
                            labelStyle: const TextStyle(fontSize: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                  if (tenantPlan.disabledFeatures.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Disabled Features:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final feature in tenantPlan.disabledFeatures)
                          Chip(
                            label: Text(feature),
                            labelStyle: const TextStyle(fontSize: 10),
                            backgroundColor: Colors.red.shade50,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (tenantPlan.planId.isNotEmpty) ...[
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Customize'),
                          onPressed: () => _customizeFeatures(context, ref, tenantPlan, plans),
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton.icon(
                        icon: Icon(
                          tenantPlan.status == TenantPlanStatus.active
                              ? Icons.block
                              : Icons.check_circle,
                          size: 16,
                        ),
                        label: Text(
                          tenantPlan.status == TenantPlanStatus.active
                              ? 'Disable'
                              : 'Enable',
                        ),
                        onPressed: () => _togglePlanStatus(context, ref, tenantPlan),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _customizeFeatures(BuildContext context, WidgetRef ref, TenantPlanWithOrg tenantPlan, List<Plan> plans) async {
    final plan = plans.firstWhere((p) => p.id == tenantPlan.planId);
    final result = await showDialog<Map<String, List<String>>>(
      context: context,
      builder:
          (context) => _FeatureCustomizationDialog(
            plan: plan,
            initialCustomFeatures: tenantPlan.customFeatures,
            initialDisabledFeatures: tenantPlan.disabledFeatures,
          ),
    );

    if (result == null) return;

    final service = ref.read(tenantPlanServiceProvider);
    final response = await service.customizeTenantPlan(
      orgId: tenantPlan.organizationId,
      customFeatures: result['customFeatures'] ?? [],
      disabledFeatures: result['disabledFeatures'] ?? [],
    );
    if (!context.mounted) return;
    if (response.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
      return;
    }
    ref.invalidate(tenantPlansProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plan customized')));
  }

  Future<void> _togglePlanStatus(BuildContext context, WidgetRef ref, TenantPlanWithOrg tenantPlan) async {
    final service = ref.read(tenantPlanServiceProvider);
    final response = tenantPlan.status == TenantPlanStatus.active
        ? await service.disableTenantPlan(tenantPlan.organizationId)
        : await service.enableTenantPlan(tenantPlan.organizationId);
    if (!context.mounted) return;
    if (response.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
      return;
    }
    ref.invalidate(tenantPlansProvider);
  }
}

class _FeatureCustomizationDialog extends StatefulWidget {
  final Plan plan;
  final List<String> initialCustomFeatures;
  final List<String> initialDisabledFeatures;

  const _FeatureCustomizationDialog({
    required this.plan,
    required this.initialCustomFeatures,
    required this.initialDisabledFeatures,
  });

  @override
  State<_FeatureCustomizationDialog> createState() =>
      _FeatureCustomizationDialogState();
}

class _FeatureCustomizationDialogState
    extends State<_FeatureCustomizationDialog> {
  late List<String> _customFeatures;
  late List<String> _disabledFeatures;

  @override
  void initState() {
    super.initState();
    _customFeatures = List.from(widget.initialCustomFeatures);
    _disabledFeatures = List.from(widget.initialDisabledFeatures);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Customize Features'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan: ${widget.plan.name}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Enable Additional Features',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final feature in availableFeatures)
                  if (!widget.plan.featureFlags.contains(feature))
                    FeatureToggleChip(
                      featureId: feature,
                      isSelected: _customFeatures.contains(feature),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _customFeatures.add(feature);
                          } else {
                            _customFeatures.remove(feature);
                          }
                        });
                      },
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Disable Features',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final feature in widget.plan.featureFlags)
                  FeatureToggleChip(
                    featureId: feature,
                    isSelected: _disabledFeatures.contains(feature),
                    isDisabled: false,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _disabledFeatures.add(feature);
                        } else {
                          _disabledFeatures.remove(feature);
                        }
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed:
              () => Navigator.pop(context, {
                'customFeatures': _customFeatures,
                'disabledFeatures': _disabledFeatures,
              }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
