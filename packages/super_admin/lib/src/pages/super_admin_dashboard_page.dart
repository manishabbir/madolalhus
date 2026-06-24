import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'plan_management_page.dart';
import 'tenant_plan_assignment_page.dart';
import '../di/super_admin_module.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);
        final statsAsync = ref.watch(dashboardStatsProvider);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Super Admin Dashboard'),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.admin_panel_settings, size: 64, color: theme.primaryColor),
                const SizedBox(height: 12),
                Text(
                  'Super Admin Panel',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage tenant plans and subscriptions',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                statsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Center(child: CircularProgressIndicator()),
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.settings,
                          label: 'Plans',
                          value: stats.planCount.toString(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlanManagementPage()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.business,
                          label: 'Tenants',
                          value: stats.tenantCount.toString(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TenantPlanAssignmentPage()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildActionTile(
                  context,
                  icon: Icons.add,
                  title: 'Create New Plan',
                  subtitle: 'Add a subscription plan for tenants',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlanManagementPage()),
                  ),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.assignment,
                  title: 'Assign Plans',
                  subtitle: 'Assign or customize tenant plans',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TenantPlanAssignmentPage()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: theme.primaryColor),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
