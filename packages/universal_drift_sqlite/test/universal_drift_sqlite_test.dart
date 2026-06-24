import 'package:test/test.dart';
import 'package:universal_drift_sqlite/universal_drift_sqlite.dart';

void main() {
  tearDown(UniversalDriftSqlite.close);

  test('rejects an empty database name', () {
    expect(() => DatabaseConfig(databaseName: ' '), throwsArgumentError);
  });

  test('rejects schema versions below one', () {
    expect(
      () => DatabaseConfig(databaseName: 'app.sqlite', schemaVersion: 0),
      throwsArgumentError,
    );
  });

  test('initializes an in-memory database and stores key values', () async {
    final database = await UniversalDriftSqlite.initialize(
      DatabaseConfig(databaseName: 'test.sqlite', inMemory: true),
    );

    await database.keyValue.upsert('theme', 'dark');

    expect(await database.keyValue.exists('theme'), isTrue);
    final item = await database.keyValue.get('theme');
    expect(item, isA<KeyValueItem>());
    expect(item?.value, 'dark');
    expect(await database.keyValue.count(), 1);

    await database.keyValue.remove('theme');

    expect(await database.keyValue.exists('theme'), isFalse);
    expect(await database.keyValue.count(), 0);
  });
}
