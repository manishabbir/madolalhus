import 'package:flutter/material.dart';
import '../core/feature_registry.dart';
import '../core/localization/app_localization.dart';
import '../services/auth_service.dart';
import '../services/locale_state.dart';
import '../services/organization_service.dart';

class OrgSelectPage extends StatefulWidget {
  const OrgSelectPage({super.key});

  @override
  State<OrgSelectPage> createState() => _OrgSelectPageState();
}

class _OrgSelectPageState extends State<OrgSelectPage> {
  final _authService = AuthService();
  List<Organization> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrgs();
  }

  Future<void> _loadOrgs() async {
    try {
      final orgs = await _authService.loadUserOrganizations();
      if (!mounted) return;

      if (orgs.length == 1) {
        final org = orgs.first;
        _authService.setCurrentOrganization(org.id, role: org.role);
        await LocaleState().setLocale(Locale(org.language));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }

      setState(() {
        _organizations = orgs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectOrganization(Organization org) async {
    _authService.setCurrentOrganization(org.id, role: org.role);
    FeatureRegistry().setTenant(org.id, org.businessTypes, org.tenantFeatures);
    await LocaleState().setLocale(Locale(org.language));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'U';
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.get('select_workspace')),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.get('sign_out'),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _organizations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('no_organizations_found'),
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _handleLogout,
                        child: Text(l10n.get('sign_out_and_try_again')),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.store, size: 64, color: theme.primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('select_workspace'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.get('choose_organization'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _organizations.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final org = _organizations[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.primaryColor,
                                  child: Text(
                                    _initialFor(org.name),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(org.name),
                                subtitle: Text('${l10n.get('role')}: ${org.role.toUpperCase()}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _selectOrganization(org),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
