import '../config/database_config.dart';
import '../database/universal_database.dart';
import '../platform/database_provider.dart';

class UniversalDriftSqlite {
  UniversalDriftSqlite._();

  static UniversalDatabase? _database;

  static Future<UniversalDatabase> initialize(DatabaseConfig config) async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final executor = await DatabaseProvider.createExecutor(config);
    _database = UniversalDatabase(
      executor,
      schemaVersion: config.schemaVersion,
    );

    return _database!;
  }

  static UniversalDatabase get database {
    final current = _database;
    if (current == null) {
      throw StateError(
        'UniversalDriftSqlite.initialize must be called before accessing database.',
      );
    }

    return current;
  }

  static bool get isInitialized => _database != null;

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
