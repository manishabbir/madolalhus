import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/localization/app_localization.dart';
import '../modules/module_registry.dart';
import '../services/auth_service.dart';
import '../services/organization_service.dart';
import '../services/connectivity_service.dart';
import '../data/sync/sync_service.dart';

/// A dashboard page with built-in online/offline awareness.
///
/// Shows:
/// - A coloured connectivity banner (green online / red offline)
/// - Profile card with org info
/// - Sync status card with pending count
/// - Quick actions (Sync Now, Check Status)
/// - Business type card
/// - Auto-syncs when coming back online
class DashboardPage extends StatefulWidget {
  final ModuleRegistry moduleRegistry;
  final bool showCoreDashboardCards;
  final Widget Function(BuildContext, String)? emptyStateBuilder;

  const DashboardPage({
    super.key,
    required this.moduleRegistry,
    this.showCoreDashboardCards = false,
    this.emptyStateBuilder,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authService = AuthService();
  final _orgService = OrganizationService();
  final _connectivityService = ConnectivityService();
  final _syncService = SyncService();

  String _orgName = '';
  String _userRole = 'unknown';
  List<String> _businessTypes = ['general'];
  String _userEmail = '';
  bool _isLoading = true;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _connectivityService.addListener(_onConnectivityChanged);
    _loadOrgInfo();
    _refreshSyncCount();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (mounted) {
      setState(() {});
      if (_connectivityService.isOnline && _pendingSyncCount > 0) {
        _syncNow();
      }
    }
  }

  Future<void> _loadOrgInfo() async {
    try {
      final orgId = _authService.currentOrganizationId;
      if (orgId == null) {
        final orgs = await _orgService.getUserOrganizations();
        if (!mounted) return;
        if (orgs.isNotEmpty) {
          final org = orgs.first;
          _authService.setCurrentOrganization(org.id, role: org.role);
          _setOrgData(org);
        }
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final orgs = await _orgService.getUserOrganizations();
      if (!mounted) return;
      final org = orgs.where((item) => item.id == orgId).firstOrNull;
      setState(() {
        _orgName = org?.name ?? '';
        _userRole = org?.role ?? _authService.currentRole;
        _businessTypes = org?.businessTypes ?? ['general'];
        _userEmail = _authService.currentUser?.email ?? '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _setOrgData(Organization org) {
    setState(() {
      _orgName = org.name;
      _userRole = org.role;
      _businessTypes = org.businessTypes;
      _userEmail = _authService.currentUser?.email ?? '';
      _isLoading = false;
    });
  }

  Future<void> _refreshSyncCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = prefs.getStringList('sync_queue') ?? [];
      if (mounted) {
        setState(() => _pendingSyncCount = items.length);
      }
    } catch (_) {
      // SharedPreferences not available — ignore
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await _syncService.syncPendingItems();
    } finally {
      await _refreshSyncCount();
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isOnline = _connectivityService.isOnline;
    final user = _authService.currentUser?.email ?? _userEmail;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('dashboard')),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refreshSyncCount();
              _loadOrgInfo();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(theme),
      body: Column(
        children: [
          _buildConnectivityBanner(theme, isOnline),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPlanUpgradeBanner(theme),
                  const SizedBox(height: 16),
                  _buildProfileCard(theme, user),
                  const SizedBox(height: 20),
                  _buildSyncStatusCard(theme, isOnline),
                  const SizedBox(height: 20),
                  _buildQuickActions(theme, l10n, isOnline),
                  const SizedBox(height: 24),
                  _buildBusinessTypeCard(theme, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityBanner(ThemeData theme, bool isOnline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOnline ? Colors.green : Colors.red.shade700,
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOnline
                  ? 'Online — connected to server'
                  : 'Offline — working locally',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (_pendingSyncCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_pendingSyncCount pending',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, String email) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.primaryColor,
              child: Text(
                (_orgName.isNotEmpty ? _orgName[0] : _initialFor(email))
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_orgName.isNotEmpty)
                    Text(
                      _orgName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_orgName.isNotEmpty) const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: _orgName.isNotEmpty ? 14 : 18,
                      color: _orgName.isNotEmpty ? Colors.grey.shade600 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${l10n(context, 'role')}: $_userRole'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String l10n(BuildContext context, String key) {
    return AppLocalizations.of(context).get(key);
  }

  Widget _buildSyncStatusCard(ThemeData theme, bool isOnline) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: isOnline ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data Sync Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.sync,
                  label: 'Pending',
                  value: '$_pendingSyncCount',
                  color: _pendingSyncCount > 0 ? Colors.orange : Colors.green,
                ),
                _buildStatItem(
                  icon: isOnline ? Icons.wifi : Icons.wifi_off,
                  label: 'Status',
                  value: isOnline ? 'Online' : 'Offline',
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    ThemeData theme,
    AppLocalizations l10n,
    bool isOnline,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.sync,
                label: 'Sync Now',
                subtitle:
                    _pendingSyncCount > 0
                        ? '$_pendingSyncCount pending'
                        : 'All synced',
                backgroundColor:
                    _isSyncing
                        ? Colors.grey.shade300
                        : theme.primaryColor.withValues(alpha: 0.1),
                onTap: _isSyncing ? null : _syncNow,
                isLoading: _isSyncing,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.wifi_find,
                label: 'Check Status',
                subtitle: isOnline ? 'Connected' : 'Offline',
                backgroundColor:
                    isOnline
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                onTap: () {
                  _refreshSyncCount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isOnline
                            ? 'Connected to server'
                            : 'Working offline. Data will sync when connected.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 1,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTypeCard(ThemeData theme, AppLocalizations l10n) {
    final businessType =
        _businessTypes.isNotEmpty ? _businessTypes.first : 'general';

    final typeLabel =
        businessType == 'restaurant'
            ? 'Restaurant & Cafe'
            : businessType == 'retail'
            ? 'Retail & Fashion'
            : businessType == 'grocery'
            ? 'Grocery & Supermarket'
            : businessType == 'pharmacy'
            ? 'Health & Beauty / Pharmacy'
            : 'General / Other';

    final typeIcon =
        businessType == 'restaurant'
            ? Icons.restaurant
            : businessType == 'retail'
            ? Icons.shopping_cart
            : businessType == 'grocery'
            ? Icons.local_grocery_store
            : businessType == 'pharmacy'
            ? Icons.medical_services
            : Icons.store;

    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(typeIcon, color: theme.primaryColor, size: 32),
        title: Text('Business Type'),
        subtitle: Text(typeLabel),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                _connectivityService.isOnline
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _buildStatusLabel(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  _connectivityService.isOnline ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  String _buildStatusLabel() {
    if (_connectivityService.isOnline) {
      return _pendingSyncCount > 0 ? 'Syncing...' : 'Active';
    }
    return 'Offline';
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty ? trimmed[0] : 'U';
  }

  Future<bool> _checkHasPaidPlan() async {
    try {
      final orgId = _authService.currentOrganizationId;
      if (orgId == null) return false;

      final response = await Supabase.instance.client
          .from('tenant_plans')
          .select('''
        plans!inner (
          price_cents
        )
      ''')
          .eq('organization_id', orgId)
          .eq('status', 'active')
          .limit(1);

      final list = response as List;
      if (list.isEmpty) return false;

      final plan = list.first as Map<String, dynamic>;
      final plans = plan['plans'] as Map<String, dynamic>;
      return (plans['price_cents'] as int? ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  Widget _buildPlanUpgradeBanner(ThemeData theme) {
    return FutureBuilder<bool>(
      future: _checkHasPaidPlan(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return const SizedBox.shrink();
        }

        return Card(
          color: Colors.orange.shade50,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Free Plan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'You are on the Free plan. Upgrade to remove ads and unlock all features.',
                  style: TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade, size: 18),
                    label: const Text('Upgrade Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/tenant/select-plan');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkSuperAdmin() async {
    try {
      final response = await Supabase.instance.client
          .from('super_admins')
          .select('id')
          .eq('user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
          .limit(1);
      return (response as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _openAdminPanel(NavigatorState rootNavigator) {
    showModalBottomSheet(
      context: rootNavigator.context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Super Admin Panel',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Plan Management'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    rootNavigator.pushNamed('/admin/plans');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Tenant Plans'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    rootNavigator.pushNamed('/admin/tenants');
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.store, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Posto POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upgrade),
            title: const Text('My Plan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/tenant/select-plan');
            },
          ),
          FutureBuilder<bool>(
            future: _checkSuperAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Panel'),
                  onTap: () {
                    // Capture navigator BEFORE popping — drawer's context
                    // will be invalid after Navigator.pop.
                    final nav = Navigator.of(context);
                    Navigator.pop(context);
                    _openAdminPanel(nav);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
