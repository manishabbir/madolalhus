import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SyncOperation { insert, update, delete }

extension SyncOperationExtension on SyncOperation {
  int get value {
    switch (this) {
      case SyncOperation.insert:
        return 0;
      case SyncOperation.update:
        return 1;
      case SyncOperation.delete:
        return 2;
    }
  }

  static SyncOperation fromValue(int value) {
    switch (value) {
      case 0:
        return SyncOperation.insert;
      case 1:
        return SyncOperation.update;
      case 2:
        return SyncOperation.delete;
      default:
        return SyncOperation.insert;
    }
  }
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  Timer? _syncTimer;

  Future<void> initialize() async {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _scheduleSync();
      }
    });
  }

  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), () {
      syncPendingItems();
    });
  }

  Future<void> queueForSync({
    required String targetTable,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    final id = '${targetTable}_${DateTime.now().millisecondsSinceEpoch}_${data.hashCode}';
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('sync_queue') ?? [];
    items.add(jsonEncode({
      'id': id,
      'target_table': targetTable,
      'operation': operation.value,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList('sync_queue', items);
    _scheduleSync();
  }

  Future<List<Map<String, dynamic>>> _getPendingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('sync_queue') ?? [];
    return items.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  Future<void> _removeItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('sync_queue') ?? [];
    items.removeWhere((e) {
      final map = Map<String, dynamic>.from(jsonDecode(e));
      return map['id'] == id;
    });
    await prefs.setStringList('sync_queue', items);
  }

  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingItems = await _getPendingItems();
      for (final item in pendingItems) {
        try {
          final data = Map<String, dynamic>.from(jsonDecode(item['data']));
          await _performSync(item['target_table'], SyncOperationExtension.fromValue(item['operation']), data);
          await _removeItem(item['id']);
        } catch (e) {
          // Could implement retry logic here
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _performSync(
    String targetTable,
    SyncOperation operation,
    Map<String, dynamic> data,
  ) async {
    final supabase = Supabase.instance.client;
    switch (operation) {
      case SyncOperation.insert:
        await supabase.from(targetTable).insert(data);
        break;
      case SyncOperation.update:
        final id = data['id'];
        if (id != null) {
          await supabase.from(targetTable).update(data).eq('id', id);
        }
        break;
      case SyncOperation.delete:
        final id = data['id'];
        if (id != null) {
          await supabase.from(targetTable).delete().eq('id', id);
        }
        break;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRemoteData(String tableName) async {
    try {
      final response = await Supabase.instance.client.from(tableName).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}