// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_value_dao.dart';

// ignore_for_file: type=lint
mixin _$KeyValueDaoMixin on DatabaseAccessor<UniversalDatabase> {
  $KeyValueItemsTable get keyValueItems => attachedDatabase.keyValueItems;
  KeyValueDaoManager get managers => KeyValueDaoManager(this);
}

class KeyValueDaoManager {
  final _$KeyValueDaoMixin _db;
  KeyValueDaoManager(this._db);
  $$KeyValueItemsTableTableManager get keyValueItems =>
      $$KeyValueItemsTableTableManager(_db.attachedDatabase, _db.keyValueItems);
}
