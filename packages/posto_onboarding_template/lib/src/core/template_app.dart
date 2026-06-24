import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_gate.dart';
import '../auth/login_page.dart';
import '../auth/org_select_page.dart';
import '../auth/reset_password_page.dart';
import '../auth/signup_page.dart';
import '../dashboard/dashboard_page.dart';
import '../services/auth_service.dart';
import '../services/locale_state.dart';
import '../services/connectivity_service.dart';
import 'feature_registry.dart';
import 'localization/app_localization.dart';
import '../modules/business_module_template.dart';
import '../modules/business_pack.dart';
import '../modules/module_registry.dart';

/// Pre-built onboarding + dashboard shell.
///
/// Initializes [ConnectivityService] automatically. Routes [dashboard]
/// to [DashboardPage] which has built-in online/offline awareness.
class PostoOnboardingTemplate extends StatelessWidget {
  final List<BusinessModuleTemplate> modules;
  final List<BusinessPack> packs;
  final bool showCoreDashboardCards;
  final Widget Function(BuildContext, String)? emptyStateBuilder;
  final LocaleState localeState;
  final RouteFactory? onGenerateRoute;

  const PostoOnboardingTemplate({
    super.key,
    required this.modules,
    this.packs = const [],
    this.showCoreDashboardCards = false,
    this.emptyStateBuilder,
    required this.localeState,
    this.onGenerateRoute,
  });

  ModuleRegistry get _moduleRegistry =>
      ModuleRegistry(templates: modules, packs: packs);

  Map<String, WidgetBuilder> buildRoutes() {
    return {
      '/': (context) => const AuthGate(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => SignUpPage(modules: modules),
      '/loading': (context) => const _OfflineAwareOrgLoadingPage(),
      '/org-select': (context) => const OrgSelectPage(),
      '/reset-password': (context) => const ResetPasswordPage(),
      '/dashboard':
          (context) => _SuspensionAwareDashboardWrapper(
            child: DashboardPage(
              moduleRegistry: _moduleRegistry,
              showCoreDashboardCards: showCoreDashboardCards,
              emptyStateBuilder: emptyStateBuilder,
            ),
          ),
    };
  }

  void registerFeatureRegistry() {
    FeatureRegistry().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeState,
      builder: (context, _) {
        final isUrdu = localeState.locale.languageCode == 'ur';
        return MaterialApp(
          title: 'Posto POS',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Roboto',
            textTheme:
                isUrdu
                    ? GoogleFonts.notoNastaliqUrduTextTheme(
                      TextTheme(
                        displayLarge: const TextStyle(
                          height: 1.6,
                          letterSpacing: -0.5,
                        ),
                        displayMedium: const TextStyle(
                          height: 1.6,
                          letterSpacing: -0.5,
                        ),
                        displaySmall: const TextStyle(
                          height: 1.6,
                          letterSpacing: -0.5,
                        ),
                        headlineLarge: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.3,
                        ),
                        headlineMedium: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.3,
                        ),
                        headlineSmall: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.3,
                        ),
                        titleLarge: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.2,
                        ),
                        titleMedium: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.2,
                        ),
                        titleSmall: const TextStyle(
                          height: 1.5,
                          letterSpacing: -0.2,
                        ),
                        bodyLarge: const TextStyle(
                          height: 1.7,
                          letterSpacing: 0.0,
                        ),
                        bodyMedium: const TextStyle(
                          height: 1.7,
                          letterSpacing: 0.0,
                        ),
                        bodySmall: const TextStyle(
                          height: 1.6,
                          letterSpacing: 0.0,
                        ),
                        labelLarge: const TextStyle(
                          height: 1.4,
                          letterSpacing: 0.0,
                        ),
                        labelMedium: const TextStyle(
                          height: 1.4,
                          letterSpacing: 0.0,
                        ),
                        labelSmall: const TextStyle(
                          height: 1.4,
                          letterSpacing: 0.0,
                        ),
                      ),
                    )
                    : null,
          ),
          locale: localeState.locale,
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: buildRoutes(),
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}

/// Offline-aware loading page — checks connectivity before
/// attempting Supabase API calls so the user never sees a
/// raw SocketException when starting the app offline.
class _OfflineAwareOrgLoadingPage extends StatefulWidget {
  const _OfflineAwareOrgLoadingPage();

  @override
  State<_OfflineAwareOrgLoadingPage> createState() =>
      _OfflineAwareOrgLoadingPageState();
}

class _OfflineAwareOrgLoadingPageState
    extends State<_OfflineAwareOrgLoadingPage> {
  final _authService = AuthService();
  final _connectivityService = ConnectivityService();
  String? _errorMessage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkOrgs();
  }

  Future<void> _checkOrgs() async {
    if (!_authService.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Ensure connectivity probe completes before checking status
    await _connectivityService.ensureReady();
    final isOnline = _connectivityService.isOnline;

    if (!isOnline) {
      // Offline — skip API call, navigate to dashboard.
      // DashboardPage will show offline status and work with cached data.
      if (!mounted) return;
      setState(() => _isOffline = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    try {
      final orgs = await _authService.loadUserOrganizations();
      if (!mounted) return;

      if (orgs.isEmpty) {
        Navigator.pushReplacementNamed(context, '/signup');
      } else if (orgs.length == 1) {
        final org = orgs.first;
        _authService.setCurrentOrganization(org.id, role: org.role);
        await LocaleState().setLocale(Locale(org.language));
        if (!mounted) return;

        // Check if the tenant's plan has been suspended by super admin
        final isSuspended = await _checkTenantSuspension(org.id);
        if (isSuspended) return;

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/org-select');
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString();
      // Network errors → treat as offline instead of showing raw exception
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup') ||
          message.contains('No such host') ||
          message.contains('HandshakeException') ||
          message.contains('Connection refused')) {
        setState(() => _isOffline = true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _errorMessage = message);
      }
    }
  }

  /// Checks whether the organization's tenant plan is suspended.
  /// Returns `true` if the tenant is suspended (and shows the suspension UI).
  Future<bool> _checkTenantSuspension(String orgId) async {
    try {
      final response = await Supabase.instance.client
          .from('tenant_plans')
          .select('status')
          .eq('organization_id', orgId)
          .eq('status', 'suspended')
          .limit(1);

      final list = response as List;
      if (list.isEmpty) return false;

      // Tenant is suspended — redirect to suspension page
      if (!mounted) return true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => _SuspendedTenantPage(
                organizationId: orgId,
                onSignOut: _handleSignOut,
              ),
        ),
      );
      return true;
    } catch (_) {
      // If the check fails (offline, network error), let the user in
      return false;
    }
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) return _buildErrorColumn();
    if (_isOffline) return _buildOfflineColumn();
    return _buildLoadingColumn();
  }

  Widget _buildLoadingColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.store, size: 64, color: const Color(0xFF2563EB)),
        const SizedBox(height: 16),
        const Text(
          'Posto POS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('Loading your workspace...'),
      ],
    );
  }

  Widget _buildOfflineColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off, size: 64, color: Colors.orange.shade700),
        const SizedBox(height: 16),
        const Text(
          'Posto POS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'You are offline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Don't worry — you can still use the app.\n"
          "Data will sync when you're back online.",
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('Loading dashboard in offline mode...'),
      ],
    );
  }

  Widget _buildErrorColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.store, size: 64, color: const Color(0xFF2563EB)),
        const SizedBox(height: 16),
        const Text(
          'Posto POS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Unable to load your workspace',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage!,
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isOffline = false;
                });
                _checkOrgs();
              },
              child: const Text('Retry'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _handleSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Wraps the [DashboardPage] with a suspension check so that every
/// navigation to the dashboard (including from org-select, refresh,
/// or deep links) verifies the tenant isn't suspended.
///
/// If suspended, the dashboard is replaced with [_SuspendedTenantPage].
class _SuspensionAwareDashboardWrapper extends StatefulWidget {
  final Widget child;

  const _SuspensionAwareDashboardWrapper({required this.child});

  @override
  State<_SuspensionAwareDashboardWrapper> createState() =>
      _SuspensionAwareDashboardWrapperState();
}

class _SuspensionAwareDashboardWrapperState
    extends State<_SuspensionAwareDashboardWrapper> {
  final _authService = AuthService();
  bool _checking = true;
  bool _suspended = false;

  @override
  void initState() {
    super.initState();
    _verifySuspension();
  }

  Future<void> _verifySuspension() async {
    final orgId = _authService.currentOrganizationId;
    if (orgId == null) {
      if (mounted) setState(() => _checking = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('tenant_plans')
          .select('status')
          .eq('organization_id', orgId)
          .eq('status', 'suspended')
          .limit(1);

      final list = response as List;
      if (mounted) {
        setState(() {
          _suspended = list.isNotEmpty;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
    } catch (_) {
      // Network sign out failed. Use forceSignOut to set the local
      // _forceSignedOut flag so AuthService.isAuthenticated returns false.
      // Otherwise LoginPage.initState will detect the stale session and
      // redirect back to /loading -> suspension check -> infinite loop.
      _authService.forceSignOut();
    }
    if (!mounted) return;
    // Wipe the entire navigation stack and land on a fresh login page.
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_suspended) {
      return _SuspendedTenantPage(
        organizationId: _authService.currentOrganizationId ?? '',
        onSignOut: _handleSignOut,
      );
    }

    return widget.child;
  }
}

/// Reusable contact tile used in the support bottom sheet.
class _SuspendedContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SuspendedContactTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.copy, size: 18, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen page shown when a tenant organization's plan has been
/// suspended by a super admin. Blocks access to the dashboard.
class _SuspendedTenantPage extends StatelessWidget {
  final String organizationId;
  final VoidCallback onSignOut;

  const _SuspendedTenantPage({
    required this.organizationId,
    required this.onSignOut,
  });

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Contact Support',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Give us up to 24 hours for a response via WhatsApp or Email.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SuspendedContactTile(
                  icon: Icons.phone,
                  iconBackground: Colors.green.shade50,
                  iconColor: Colors.green.shade700,
                  title: '+92 300 8932525',
                  subtitle: 'WhatsApp',
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: '+923008932525'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Phone number copied'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    launchUrl(Uri.parse('https://wa.me/923008932525'));
                  },
                ),
                const SizedBox(height: 12),
                _SuspendedContactTile(
                  icon: Icons.email_outlined,
                  iconBackground: Colors.blue.shade50,
                  iconColor: Colors.blue.shade700,
                  title: 'imranafmdc@gmail.com',
                  subtitle: 'Email',
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'imranafmdc@gmail.com'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email copied'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    launchUrl(Uri.parse('mailto:imranafmdc@gmail.com'));
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, size: 80, color: Colors.red.shade600),
                const SizedBox(height: 24),
                const Text(
                  'Account Suspended',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your organization\'s plan has been suspended.\n'
                  'Please contact support to regain access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: onSignOut,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showContactSheet(context),
                  child: Text(
                    'Need help? Contact your administrator',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
