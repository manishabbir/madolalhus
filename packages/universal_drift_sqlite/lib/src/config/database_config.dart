class DatabaseConfig {
  DatabaseConfig({
    required this.databaseName,
    this.databaseDirectory,
    this.customDatabasePath,
    this.schemaVersion = 1,
    this.logStatements = false,
    this.inMemory = false,
  }) {
    if (databaseName.trim().isEmpty) {
      throw ArgumentError.value(
        databaseName,
        'databaseName',
        'Cannot be empty.',
      );
    }

    if (schemaVersion < 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Must be >= 1.',
      );
    }
  }

  final String databaseName;
  final String? databaseDirectory;
  final String? customDatabasePath;
  final int schemaVersion;
  final bool logStatements;
  final bool inMemory;

  String get effectiveDatabaseName {
    if (inMemory) {
      return ':memory:';
    }

    if (customDatabasePath != null) {
      return customDatabasePath!;
    }

    return databaseName.trim();
  }
}
