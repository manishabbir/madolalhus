import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/exceptions/app_exception.dart';

class SuperAdminService {
  final SupabaseClient _supabase;

  SuperAdminService(this._supabase);

  Future<bool> isSuperAdmin() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await _supabase
          .from('super_admins')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> grantSuperAdmin(String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw PermissionException('Not authenticated');

    await _supabase.from('super_admins').insert({
      'user_id': userId,
    });
  }

  Future<void> revokeSuperAdmin(String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw PermissionException('Not authenticated');

    await _supabase.from('super_admins').delete().eq('user_id', userId);
  }
}