import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posto_onboarding_template/posto_onboarding_template.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: _EmptyAsyncStorage(),
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
  });

  test('localization falls back to English keys', () {
    final localization = AppLocalizations(const Locale('en'));
    expect(localization.get('empty_dashboard_title'), 'Workspace ready');
    expect(localization.get('missing_key'), 'missing_key');
  });

  test('feature registry enables selected business template', () {
    final registry = FeatureRegistry();
    registry.clearTenant();
    registry.initialize();
    registry.setTenant('org-id', ['retail']);

    expect(registry.isFeatureEnabled('SECURE_AUTHENTICATION'), isTrue);
    expect(registry.isFeatureEnabled('INVENTORY_MANAGEMENT'), isTrue);
    expect(registry.isFeatureEnabled('POS_REGISTER'), isTrue);
  });

  test('module registry returns selected module and pack', () {
    final pack = _TestPack();
    final registry = ModuleRegistry(
      templates: DefaultBusinessModules.all(),
      packs: [pack],
    );

    expect(registry.getTemplate('retail')?.id, 'retail');
    expect(registry.getPack('retail'), same(pack));
  });

  testWidgets('empty dashboard renders empty module state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: EmptyDashboardPage(
          moduleRegistry: ModuleRegistry(templates: []),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Workspace ready'), findsOneWidget);
    expect(find.text('Add your first business module'), findsOneWidget);
  });
}

class _EmptyAsyncStorage extends GotrueAsyncStorage {
  const _EmptyAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> setItem({required String key, required String value}) async {}

  @override
  Future<void> removeItem({required String key}) async {}
}

class _TestPack extends BusinessPack {
  @override
  String get id => 'retail';

  @override
  String get name => 'Retail';

  @override
  String get description => 'Retail pack';

  @override
  List<NavigationItem> buildNavigationItems({required String userRole}) {
    return const [
      NavigationItem(route: '/retail', icon: Icons.shopping_bag, label: 'Retail'),
    ];
  }
}
