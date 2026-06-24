import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/feature_registry.dart';
import '../services/locale_state.dart';
import '../services/organization_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final OrganizationService _orgService = OrganizationService();
  final FeatureRegistry _featureRegistry = FeatureRegistry();

  String? _currentOrganizationId;
  String _currentRole = 'unknown';
  bool _forceSignedOut = false;

  String? get currentOrganizationId => _currentOrganizationId;
  String get currentRole => _currentRole;

  /// Returns true only if there is a valid session and we haven't
  /// been force-signed-out (used when network signOut fails).
  bool get isAuthenticated => !_forceSignedOut && currentSession != null;

  /// Clears the local authenticated state without contacting the server.
  /// Used when the Supabase signOut API call fails due to network error,
  /// preventing LoginPage from detecting a stale session and redirecting
  /// back to the suspension check.
  void forceSignOut() {
    _forceSignedOut = true;
    clearCurrentOrganization();
    _featureRegistry.clearTenant();
  }

  void setCurrentOrganization(String orgId, {String role = 'unknown'}) {
    _currentOrganizationId = orgId;
    _currentRole = role;
  }

  void clearCurrentOrganization() {
    _currentOrganizationId = null;
    _currentRole = 'unknown';
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    clearCurrentOrganization();
    _featureRegistry.clearTenant();
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _supabase.auth.signUp(email: email, password: password);
  }

  Future<Organization> createOrganizationAfterSignUp({
    required String name,
    required String businessType,
    required String language,
    List<String> features = const [],
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase.rpc(
      'create_organization',
      params: {
        'org_name': name,
        'biz_types': businessType,
        'features': features,
        'p_language': language,
      },
    );

    final org = Organization.fromMap(response as Map<String, dynamic>);
    setCurrentOrganization(org.id, role: org.role);
    _featureRegistry.setTenant(org.id, org.businessTypes, org.tenantFeatures);
    await LocaleState().setLocale(Locale(org.language));
    return org;
  }

  Future<List<Organization>> loadUserOrganizations() async {
    final orgs = await _orgService.getUserOrganizations();

    if (orgs.length == 1 && _currentOrganizationId == null) {
      final org = orgs.first;
      setCurrentOrganization(org.id, role: org.role);
      _featureRegistry.setTenant(org.id, org.businessTypes, org.tenantFeatures);
      await LocaleState().setLocale(Locale(org.language));
    }

    return orgs;
  }

  Future<void> resetPassword({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<UserResponse?> updatePassword({required String newPassword}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } finally {
      clearCurrentOrganization();
      _featureRegistry.clearTenant();
    }
  }

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
