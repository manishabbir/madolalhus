import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuditLogService {
  final SupabaseClient _client;

  AuditLogService(this._client);

  Future<void> log({
    required String action,
    required String targetType,
    String? targetId,
    Map<String, dynamic>? changes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      await _client.from('audit_logs').insert({
        'actor_id': user?.id,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'changes': changes ?? {},
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[AuditLog] Failed to write audit log: $e');
    }
  }
}
