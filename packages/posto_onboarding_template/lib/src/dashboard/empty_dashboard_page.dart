import 'package:flutter/material.dart';
import '../core/localization/app_localization.dart';
import '../core/navigation_builder.dart';
import '../modules/module_registry.dart';
import '../services/auth_service.dart';
import '../services/organization_service.dart';

class EmptyDashboardPage extends StatefulWidget {
  final ModuleRegistry moduleRegistry;
  final bool showCoreDashboardCards;
  final Widget Function(BuildContext, String)? emptyStateBuilder;

  const EmptyDashboardPage({
    super.key,
    required this.moduleRegistry,
    this.showCoreDashboardCards = false,
    this.emptyStateBuilder,
  });

  @override
  State<EmptyDashboardPage> createState() => _EmptyDashboardPageState();
}

class _EmptyDashboardPageState extends State<EmptyDashboardPage> {
  final _authService = AuthService();
  final _orgService = OrganizationService();
  String _orgName = '';
  String _userRole = 'unknown';
  List<String> _businessTypes = ['general'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrgInfo();
  }

  Future<void> _loadOrgInfo() async {
    try {
      final orgId = _authService.currentOrganizationId;
      if (orgId == null) {
        final orgs = await _orgService.getUserOrganizations();
        if (!mounted) return;
        if (orgs.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }
        final org = orgs.first;
        _authService.setCurrentOrganization(org.id, role: org.role);
        setState(() {
          _orgName = org.name;
          _userRole = org.role;
          _businessTypes = org.businessTypes;
          _isLoading = false;
        });
        return;
      }

      final orgs = await _orgService.getUserOrganizations();
      if (!mounted) return;
      final org = orgs.where((item) => item.id == orgId).firstOrNull;
      setState(() {
        _orgName = org?.name ?? '';
        _userRole = org?.role ?? _authService.currentRole;
        _businessTypes = org?.businessTypes ?? ['general'];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final businessType = _businessTypes.isNotEmpty ? _businessTypes.first : 'general';
    final navItems = NavigationBuilder.buildNavigation(
      packs: _packInfos(),
      businessType: businessType,
      userRole: _userRole,
    );
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('dashboard')),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.get('sign_out'),
            onPressed: () async {
              await _authService.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, navItems, l10n),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(context, user?.email ?? 'Unknown User'),
                  const SizedBox(height: 32),
                  Text(
                    l10n.get('empty_dashboard_title'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('empty_dashboard_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: widget.emptyStateBuilder != null
                        ? widget.emptyStateBuilder!(context, businessType)
                        : _buildEmptyState(context, l10n),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String email) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
                (_orgName.isNotEmpty ? _orgName[0] : _initialFor(email)).toUpperCase(),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  if (_orgName.isNotEmpty) const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: _orgName.isNotEmpty ? 14 : 18,
                      color: _orgName.isNotEmpty ? Colors.grey.shade600 : null,
                      fontWeight: _orgName.isNotEmpty ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${l10n.get('role')}: $_userRole'.toUpperCase(),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_business_outlined, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  l10n.get('add_first_module'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.get('empty_dashboard_subtitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty ? trimmed[0] : 'U';
  }

  Drawer _buildDrawer(
    BuildContext context,
    List<NavigationItem> navItems,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orgName.isNotEmpty ? _orgName : l10n.get('app_name'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.get('role')}: $_userRole'.toUpperCase(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ...navItems.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                _safeNavigate(context, item.route);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.get('settings')),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.get('coming_soon')),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.get('sign_out'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _safeNavigate(BuildContext context, String route) {
    try {
      Navigator.pushNamed(context, route);
    } catch (_) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('coming_soon')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<BusinessPackInfo> _packInfos() {
    return widget.moduleRegistry.packs.map((pack) {
      return (
        id: pack.id,
        buildNavItems: (userRole) => pack.buildNavigationItems(userRole: userRole),
      );
    }).toList();
  }
}
