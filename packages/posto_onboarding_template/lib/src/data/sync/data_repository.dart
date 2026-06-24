import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> create(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}

class SupabaseRepository<T> implements Repository<T> {
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  
  SupabaseRepository({
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  });

  @override
  Future<List<T>> getAll() async {
    final response = await Supabase.instance.client.from(tableName).select();
    return response.map((e) => fromJson(e)).toList();
  }

  @override
  Future<T?> getById(String id) async {
    final response = await Supabase.instance.client.from(tableName).select().eq('id', id);
    if (response.isEmpty) return null;
    return fromJson(response.first);
  }

  @override
  Future<void> create(T item) async {
    final data = toJson(item);
    final hasConnection = await _hasConnection();
    
    if (hasConnection) {
      await Supabase.instance.client.from(tableName).insert(data);
    } else {
      await SyncService().queueForSync(
        targetTable: tableName,
        operation: SyncOperation.insert,
        data: data,
      );
    }
  }

  @override
  Future<void> update(T item) async {
    final data = toJson(item);
    final id = data['id'];
    final hasConnection = await _hasConnection();
    
    if (hasConnection) {
      await Supabase.instance.client.from(tableName).update(data).eq('id', id);
    } else {
      await SyncService().queueForSync(
        targetTable: tableName,
        operation: SyncOperation.update,
        data: data,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    final hasConnection = await _hasConnection();
    
    if (hasConnection) {
      await Supabase.instance.client.from(tableName).delete().eq('id', id);
    } else {
      await SyncService().queueForSync(
        targetTable: tableName,
        operation: SyncOperation.delete,
        data: {'id': id},
      );
    }
  }

  Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}