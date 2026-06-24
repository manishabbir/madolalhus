import 'package:drift/drift.dart';

import '../config/database_config.dart';

class DatabaseProvider {
  static Future<QueryExecutor> createExecutor(DatabaseConfig config) async {
    throw UnsupportedError(
      'SQLite via universal_drift_sqlite is not supported on web. '
      'Use a web-compatible Drift engine or provide a platform-specific package.',
    );
  }

  static Future<String> resolvePath(DatabaseConfig config) async {
    throw UnsupportedError(
      'SQLite via universal_drift_sqlite is not supported on web. '
      'Use a web-compatible Drift engine or provide a platform-specific package.',
    );
  }
}
