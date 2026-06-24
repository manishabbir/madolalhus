import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTenantPlanDataSource {
  final SupabaseClient _client;

  SupabaseTenantPlanDataSource(this._client);

  Future<List<Map<String, dynamic>>> getAllTenantPlans({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    final response = await _client.rpc(
      'get_all_tenant_plans',
      params: {
        'p_limit': limit,
        'p_offset': offset,
        'p_search': search,
      },
    );

    final raw = response;
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (raw is Map) {
      return [Map<String, dynamic>.from(raw)];
    }
    return [];
  }

  Future<Map<String, dynamic>?> getTenantPlanByOrgId(String orgId) async {
    final response = await _client
        .from('tenant_plans')
        .select()
        .eq('organization_id', orgId)
        .limit(1);
    final list = (response as List);
    if (list.isEmpty) return null;
    return Map<String, dynamic>.from(list.first as Map);
  }

  Future<void> assignPlanToTenant({
    required String orgId,
    required String planId,
  }) async {
    await _client.from('tenant_plans').upsert({
      'organization_id': orgId,
      'plan_id': planId,
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
    }, onConflict: 'organization_id');
  }

  Future<void> customizeTenantPlan({
    required String orgId,
    required List<String> customFeatures,
    required List<String> disabledFeatures,
  }) async {
    await _client.from('tenant_plans').update({
      'custom_features': customFeatures,
      'disabled_features': disabledFeatures,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('organization_id', orgId);
  }

  Future<void> disableTenantPlan(String orgId) async {
    await _client.from('tenant_plans').update({
      'status': 'suspended',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('organization_id', orgId);
  }

  Future<void> enableTenantPlan(String orgId) async {
    await _client.from('tenant_plans').update({
      'status': 'active',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('organization_id', orgId);
  }

  Future<void> removeTenantPlan(String orgId) async {
    await _client.from('tenant_plans').delete().eq('organization_id', orgId);
  }

  Future<void> setTenantPlanExpiry(String orgId, DateTime? endsAt) async {
    await _client.from('tenant_plans').update({
      'ends_at': endsAt?.toIso8601String(),
      'status': endsAt == null ? 'active' : 'suspended',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('organization_id', orgId);
  }

  Future<Map<String, dynamic>?> hasPaidPlan(String orgId) async {
    final response = await _client
        .from('tenant_plans')
        .select('''
      plans!inner (
        price_cents
      )
    ''')
        .eq('organization_id', orgId)
        .eq('status', 'active')
        .limit(1);
    final list = response as List;
    if (list.isEmpty) return null;
    final raw = list.first as Map<String, dynamic>;
    final plans = raw['plans'] as Map<String, dynamic>;
    return {'price_cents': (plans['price_cents'] as int?) ?? 0};
  }

  Future<Map<String, dynamic>?> getTenantPlanWithFeatures(String orgId) async {
    final response = await _client
        .from('tenant_plans')
        .select('''
      *,
      plans!inner (
        id,
        name,
        price_cents,
        feature_flags
      )
    ''')
        .eq('organization_id', orgId)
        .limit(1);
    final list = response as List;
    if (list.isEmpty) return null;
    return Map<String, dynamic>.from(list.first as Map);
  }
}
