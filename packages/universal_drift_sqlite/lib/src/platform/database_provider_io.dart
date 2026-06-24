import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' hide DatabaseConfig;

import '../config/database_config.dart';
import 'database_path_provider.dart';

class DatabaseProvider {
  static Future<QueryExecutor> createExecutor(DatabaseConfig config) async {
    if (config.inMemory) {
      return NativeDatabase.memory(
        logStatements: config.logStatements,
        setup: _applyPragmas,
      );
    }

    final path = await resolveDatabasePath(config);
    final file = File(path);
    final parent = file.parent;

    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(
      file,
      logStatements: config.logStatements,
      setup: _applyPragmas,
    );
  }

  static Future<String> resolvePath(DatabaseConfig config) {
    return resolveDatabasePath(config);
  }
}

void _applyPragmas(Database database) {
  database.execute('PRAGMA foreign_keys = ON');
  database.execute('PRAGMA journal_mode = WAL');
}
