import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePlanDataSource {
  final SupabaseClient _client;

  SupabasePlanDataSource(this._client);

  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final response = await _client
        .from('plans')
        .select()
        .order('name', ascending: true);
    return _toMapList(response);
  }

  Future<List<Map<String, dynamic>>> getActivePlans() async {
    final response = await _client
        .from('plans')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);
    return _toMapList(response);
  }

  Future<Map<String, dynamic>?> getPlanById(String id) async {
    final response = await _client
        .from('plans')
        .select()
        .eq('id', id)
        .limit(1);
    final list = _toMapList(response);
    return list.isEmpty ? null : list.first;
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> data) async {
    final response = await _client
        .from('plans')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updatePlan(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('plans')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> deletePlan(String id) async {
    await _client.from('plans').delete().eq('id', id);
  }

  Future<void> activatePlan(String id) async {
    await _client.from('plans').update({
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deactivatePlan(String id) async {
    await _client.from('plans').update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static List<Map<String, dynamic>> _toMapList(dynamic response) {
    final list = response as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
