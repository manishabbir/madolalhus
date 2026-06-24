# Posto Packages

This directory contains reusable Flutter packages for the Posto ecosystem. Each package is designed to be dropped into any new Flutter project and extended with your own business logic.

---

## Package Overview

| Package | Version | Description |
|---------|---------|-------------|
| `posto_onboarding_template` | 0.4.0 | Supabase-backed onboarding, offline-aware dashboard shell with connectivity monitoring |
| `universal_drift_sqlite` | 0.1.0 | Reusable Flutter SQLite database layer built with Drift |

---

## posto_onboarding_template

A Supabase-backed onboarding and dashboard template for Flutter apps. Drop it into any new Flutter project to get login, signup, language selection, business module selection, organization loading/selection, and an **offline-aware dashboard** — ready to be extended with your own business logic.

### What this template provides

- Supabase-backed auth shell
- Login page
- Signup page (with business module selection)
- Language selection (English / Urdu)
- Business module selection (Restaurant, Retail, Grocery, Pharmacy, General)
- Organization loading / auto-redirect — **handles offline gracefully** (no SocketException)
- Organization selection (if multiple organizations exist)
- **Offline-aware dashboard** with:
  - Green/red connectivity banner
  - Sync status card with pending queue count
  - Quick actions: Sync Now, Check Status
  - Auto-sync when reconnecting online
  - Business type status badge
- `LocaleState` — reactive locale management
- `ConnectivityService` — polling-based network monitor (avoids Windows `NetworkManager` crash)
- `FeatureRegistry` — lightweight feature flag system
- `BusinessPack` extension points — add custom navigation items, dashboard cards, and POS overlays

### Dependencies

- `shared_preferences` — local key-value storage
- `connectivity_plus` — network connectivity detection (polling, not streaming — avoids Windows PlatformException)
- `url_launcher` — opening external URLs
- `google_fonts` — Google Fonts integration
- `supabase_flutter` — Supabase backend auth & data

### Adding to a project

```yaml
# In your app's pubspec.yaml
dependencies:
  posto_onboarding_template:
    path: packages/posto_onboarding_template
```

### Required setup

1. Copy the Supabase migration file from `packages/posto_onboarding_template/migrations/20260614221844_onboarding_template_schema.sql` to your project's `supabase/migrations/` directory.
2. Apply the migration in your Supabase project (via SQL Editor or `supabase db push`).
3. Initialize Supabase and the template in your app's `main.dart`.

### Minimal integration (offline-aware out of the box)

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posto_onboarding_template/posto_onboarding_template.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    publishableKey: 'your-key',
  );
  final localeState = LocaleState();
  await localeState.load();

  runApp(
    PostoOnboardingTemplate(
      modules: DefaultBusinessModules.all(),
      localeState: localeState,
    ),
  );
}
```

### Default routes

| Route | Page |
|-------|------|
| `/` | `AuthGate` (auto-route) |
| `/login` | Login page |
| `/signup` | Signup page |
| `/loading` | Offline-aware organization loading |
| `/org-select` | Organization selection |
| `/reset-password` | Reset password page |
| `/dashboard` | Offline-aware DashboardPage (green/red banner, sync status, auto-sync) |

### Offline behavior

- **Loading screen**: Detects no connectivity → shows "You are offline" message → navigates to dashboard
- **Dashboard**: Shows red banner "Offline — working locally" with pending sync count
- **Auto-sync**: When device reconnects, pending sync items are automatically uploaded
- **No crashes**: Network errors (`SocketException`, host lookup failures) are caught and treated as offline scenarios

### Extending with BusinessPack

Create a subclass of `BusinessPack` to add custom navigation items, dashboard cards, and POS features:

```dart
class MyRestaurantPack extends BusinessPack {
  @override
  String get id => 'restaurant';

  @override
  String get name => 'Restaurant';

  @override
  String get description => 'Restaurant business pack';

  @override
  List<NavigationItem> buildNavigationItems({required String userRole}) {
    return const [
      NavigationItem(
        route: '/restaurant/tables',
        icon: Icons.table_restaurant,
        label: 'Tables',
      ),
    ];
  }
}
```

---

## universal_drift_sqlite

Reusable Flutter SQLite database layer built with Drift. Provides one-line initialization, platform-aware database path resolution, built-in key-value storage, and in-memory mode for tests.

### Features

- One-line initialization for new Flutter apps
- Platform-aware SQLite database path resolution for Android, iOS, Windows, macOS, and Linux
- Drift database, DAO, and migration strategy included
- Built-in key-value table for lightweight app settings and cached values
- In-memory mode for tests
- Optional SQL statement logging
- Custom database path support

### Dependencies

- `drift` — SQLite ORM for Dart/Flutter
- `path` — cross-platform file path utilities
- `path_provider` — platform-specific directory resolution
- `sqlite3` — native SQLite bindings

### Adding to a project

```yaml
# In your app's pubspec.yaml
dependencies:
  universal_drift_sqlite:
    path: packages/universal_drift_sqlite
```

### Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:universal_drift_sqlite/universal_drift_sqlite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UniversalDriftSqlite.initialize(
    DatabaseConfig(databaseName: 'app.sqlite'),
  );

  runApp(const MyApp());
}
```

### Key-value store

```dart
final database = UniversalDriftSqlite.database;

await database.keyValue.upsert('theme', 'dark');

final theme = await database.keyValue.get('theme');
print(theme?.value);
```

### Custom database location

```dart
// Using a custom directory
await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'app.sqlite',
    databaseDirectory: '/custom/database/path',
  ),
);

// Using a full custom path
await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'app.sqlite',
    customDatabasePath: '/custom/path/app.sqlite',
  ),
);
```

### Testing with in-memory database

```dart
final database = await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'test.sqlite',
    inMemory: true,
  ),
);
```

### Platform support

This package uses native SQLite through Drift and supports Android, iOS, Windows, macOS, and Linux. Web support requires a web-compatible Drift engine and is not included in this package.

---

## Shared conventions

- All packages use `flutter_lints` for consistent linting.
- Both packages follow the `path: packages/<package_name>` convention for local dependency resolution.
- Each package includes its own `analysis_options.yaml` for customizable linting rules.

## License

Refer to each package's `LICENSE` file (if present) for licensing information. The `universal_drift_sqlite` package includes a `LICENSE` file; `posto_onboarding_template` is published with `publish_to: none` for internal use.