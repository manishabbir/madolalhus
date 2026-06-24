import 'package:drift/drift.dart';

import '../database/key_value_items.dart';
import '../database/universal_database.dart';

part 'key_value_dao.g.dart';

@DriftAccessor(tables: [KeyValueItems])
class KeyValueDao extends DatabaseAccessor<UniversalDatabase>
    with _$KeyValueDaoMixin {
  KeyValueDao(super.database);

  Future<KeyValueItem?> get(String key) {
    return (select(
      keyValueItems,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
  }

  Future<bool> exists(String key) {
    return countForKey(key).then((count) => count > 0);
  }

  Future<List<KeyValueItem>> all() {
    return (select(
      keyValueItems,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAtMillis)])).get();
  }

  Stream<List<KeyValueItem>> watchAll() {
    return (select(
      keyValueItems,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAtMillis)])).watch();
  }

  Stream<KeyValueItem?> watch(String key) {
    return (select(
      keyValueItems,
    )..where((table) => table.key.equals(key))).watchSingleOrNull();
  }

  Future<int> count() {
    return keyValueItems.count().getSingle();
  }

  Future<int> countForKey(String key) {
    return keyValueItems
        .count(where: (table) => table.key.equals(key))
        .getSingle();
  }

  Future<void> upsert(String key, String? value) {
    final now = DateTime.now().millisecondsSinceEpoch;

    return into(keyValueItems).insertOnConflictUpdate(
      KeyValueItemsCompanion.insert(
        key: key,
        value: Value(value),
        createdAtMillis: now,
        updatedAtMillis: now,
      ),
    );
  }

  Future<void> remove(String key) {
    return (delete(
      keyValueItems,
    )..where((table) => table.key.equals(key))).go();
  }

  Future<void> clear() {
    return delete(keyValueItems).go();
  }
}
