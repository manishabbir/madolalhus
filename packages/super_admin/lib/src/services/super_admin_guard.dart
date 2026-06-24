import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/exceptions/app_exception.dart';

class SuperAdminGuard {
  final SupabaseClient _client;

  SuperAdminGuard(this._client);

  Future<void> ensureSuperAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) throw PermissionException('Not authenticated');

    final response = await _client
        .from('super_admins')
        .select('id')
        .eq('user_id', user.id)
        .limit(1);

    if ((response as List).isEmpty) {
      throw PermissionException('Super admin access required');
    }
  }
}
