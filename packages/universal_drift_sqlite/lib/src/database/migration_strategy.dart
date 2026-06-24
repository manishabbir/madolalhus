import 'package:drift/drift.dart';

MigrationStrategy createMigrationStrategy(GeneratedDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {}
    },
    beforeOpen: (_) async {
      await database.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
