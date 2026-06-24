import '../config/database_config.dart';

Future<String> resolveDatabasePath(DatabaseConfig config) async {
  throw UnsupportedError(
    'SQLite via universal_drift_sqlite is not supported on web. '
    'Use a web-compatible Drift engine or provide a platform-specific package.',
  );
}
