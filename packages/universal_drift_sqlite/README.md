# universal_drift_sqlite

Reusable Flutter SQLite database layer built with Drift.

## Features

- One-line initialization for new Flutter apps.
- Platform-aware SQLite database path resolution for Android, iOS, Windows, macOS, and Linux.
- Drift database, DAO, and migration strategy included.
- Built-in key-value table for lightweight app settings and cached values.
- In-memory mode for tests.
- Optional SQL statement logging.

## Usage

Add the package to your app:

```yaml
dependencies:
  universal_drift_sqlite:
    path: ../universal_drift_sqlite
```

Initialize it before `runApp`:

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

Use the built-in key-value store:

```dart
final database = UniversalDriftSqlite.database;

await database.keyValue.upsert('theme', 'dark');

final theme = await database.keyValue.get('theme');
print(theme?.value);
```

## Custom database location

Use `databaseDirectory` or `customDatabasePath`:

```dart
await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'app.sqlite',
    databaseDirectory: '/custom/database/path',
  ),
);

await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'app.sqlite',
    customDatabasePath: '/custom/path/app.sqlite',
  ),
);
```

## Testing

Use in-memory mode for fast tests:

```dart
final database = await UniversalDriftSqlite.initialize(
  DatabaseConfig(
    databaseName: 'test.sqlite',
    inMemory: true,
  ),
);
```

## Notes

This package uses native SQLite through Drift. Web support requires a web-compatible Drift engine and is not included in this package.
