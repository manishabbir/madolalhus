import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posto_onboarding_template/posto_onboarding_template.dart';
import 'package:universal_drift_sqlite/universal_drift_sqlite.dart';
import 'package:super_admin/super_admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await UniversalDriftSqlite.initialize(
      DatabaseConfig(databaseName: 'madolalhus.sqlite'),
    );
  } catch (e) {
    // SQLite is not supported on web. The app will continue without database access.
    debugPrint('SQLite initialization skipped (not supported on web): $e');
  }

  await Supabase.initialize(
    url: 'https://lxwrwhsdauzryjtemfnq.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4d3J3aHNkYXV6cnlqdGVtZm5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NjI3MjksImV4cCI6MjA5NzAzODcyOX0.45wNbk7F7sHWiZWA-D7yIghrcOZXamt9TS8nG8QC_KA',
  );

  final localeState = LocaleState();
  await localeState.load();

  runApp(const _AppInitializer());
}

class _AppInitializer extends StatelessWidget {
  const _AppInitializer();

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    String getOrganizationId() {
      final orgId = AuthService().currentOrganizationId;
      return orgId ?? '';
    }

    switch (settings.name) {
      case '/admin/plans':
        return MaterialPageRoute(builder: (_) => const PlanManagementPage());
      case '/admin/tenants':
        return MaterialPageRoute(
          builder: (_) => const TenantPlanAssignmentPage(),
        );
      case '/tenant/select-plan':
        return MaterialPageRoute(
          builder: (_) =>
              TenantPlanSelectionPage(organizationId: getOrganizationId()),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: PostoOnboardingTemplate(
        modules: DefaultBusinessModules.all(),
        localeState: LocaleState(),
        showCoreDashboardCards: true,
        onGenerateRoute: _generateRoute,
      ),
    );
  }
}
