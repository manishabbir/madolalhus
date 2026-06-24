import 'package:flutter/material.dart';
import 'package:universal_drift_sqlite/universal_drift_sqlite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UniversalDriftSqlite.initialize(
    DatabaseConfig(databaseName: 'example.sqlite'),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Drift SQLite Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const KeyValueScreen(),
    );
  }
}

class KeyValueScreen extends StatefulWidget {
  const KeyValueScreen({super.key});

  @override
  State<KeyValueScreen> createState() => _KeyValueScreenState();
}

class _KeyValueScreenState extends State<KeyValueScreen> {
  final _controller = TextEditingController(text: 'Hello from Drift');
  String? _value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await UniversalDriftSqlite.database.keyValue.upsert(
      'greeting',
      _controller.text,
    );

    setState(() {
      _value = _controller.text;
    });
  }

  Future<void> _load() async {
    final value = await UniversalDriftSqlite.database.keyValue.get('greeting');
    setState(() {
      _value = value?.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universal Drift SQLite')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _controller),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save value')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: const Text('Load value')),
            const SizedBox(height: 24),
            Text('Loaded value: ${_value ?? 'not loaded yet'}'),
          ],
        ),
      ),
    );
  }
}
