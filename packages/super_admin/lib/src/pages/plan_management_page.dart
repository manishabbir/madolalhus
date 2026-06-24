import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/plan.dart';
import '../di/super_admin_module.dart';
import '../widgets/plan_card.dart';
import '../presentation/widgets/shared/error_state.dart';
import 'plan_editor_page.dart';

class PlanManagementPage extends StatefulWidget {
  const PlanManagementPage({super.key});

  @override
  State<PlanManagementPage> createState() => _PlanManagementPageState();
}

class _PlanManagementPageState extends State<PlanManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final plansAsync = ref.watch(plansProvider);
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Plan Management'),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlanEditorPage(),
                ),
              );
              ref.invalidate(plansProvider);
            },
            backgroundColor: theme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString(), onRetry: () => ref.refresh(plansProvider.future)),
            data: (plans) => _buildBody(context, ref, plans),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<Plan> plans) {
    if (plans.isEmpty) {
      return const Center(child: Text('No plans found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(plansProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return PlanCard(
            plan: plan,
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlanEditorPage(plan: plan),
                ),
              );
              ref.invalidate(plansProvider);
            },
            onDelete: () => _deletePlan(context, ref, plan),
            onToggleActive: () => _togglePlanActive(context, ref, plan),
          );
        },
      ),
    );
  }

  Future<void> _togglePlanActive(BuildContext context, WidgetRef ref, Plan plan) async {
    final service = ref.read(planServiceProvider);
    final response = plan.isActive
        ? await service.deactivatePlan(plan.id)
        : await service.activatePlan(plan.id);
    if (!context.mounted) return;
    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
      return;
    }
    ref.invalidate(plansProvider);
  }

  Future<void> _deletePlan(BuildContext context, WidgetRef ref, Plan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(planServiceProvider);
      final response = await service.deletePlan(plan.id);
      if (!context.mounted) return;
      if (response.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error?.message}')),
        );
        return;
      }
      ref.invalidate(plansProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan deleted')),
      );
    }
  }
}
