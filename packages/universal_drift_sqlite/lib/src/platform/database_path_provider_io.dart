import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/database_config.dart';

Future<String> resolveDatabasePath(DatabaseConfig config) async {
  if (config.customDatabasePath != null) {
    return p.normalize(config.customDatabasePath!);
  }

  final directory = config.databaseDirectory != null
      ? config.databaseDirectory!
      : (await getApplicationDocumentsDirectory()).path;

  return p.normalize(p.join(directory, config.effectiveDatabaseName));
}
