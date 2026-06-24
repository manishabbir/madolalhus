import 'package:drift/drift.dart';

import '../dao/key_value_dao.dart';
import 'key_value_items.dart';
import 'migration_strategy.dart';

part 'universal_database.g.dart';

@DriftDatabase(tables: [KeyValueItems])
class UniversalDatabase extends _$UniversalDatabase {
  UniversalDatabase(super.executor, {required this._schemaVersion});

  final int _schemaVersion;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => createMigrationStrategy(this);

  KeyValueDao get keyValue => KeyValueDao(this);
}
