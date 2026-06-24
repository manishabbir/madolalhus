import 'package:drift/drift.dart';

class KeyValueItems extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
