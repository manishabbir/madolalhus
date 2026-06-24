import 'package:supabase_flutter/supabase_flutter.dart';

class Organization {
  final String id;
  final String name;
  final String slug;
  final String role;
  final List<String> businessTypes;
  final List<String> tenantFeatures;
  final String language;

  Organization({
    required this.id,
    required this.name,
    required this.slug,
    required this.role,
    this.businessTypes = const ['general'],
    this.tenantFeatures = const [],
    this.language = 'en',
  });

  factory Organization.fromMap(Map<String, dynamic> map) {
    final businessTypeStr = map['business_type'] as String? ?? 'general';
    final types = businessTypeStr.isEmpty
        ? ['general']
        : businessTypeStr.split(',').map((value) => value.trim()).toList();

    final featuresDynamic = map['tenant_features'];
    final features = switch (featuresDynamic) {
      final List<dynamic> list => list.map((value) => value.toString()).toList(),
      final String value when value.isNotEmpty => value.split(',').map((value) => value.trim()).toList(),
      _ => <String>[],
    };

    return Organization(
      id: map['id'] as String? ?? map['organization_id'] as String? ?? '',
      name: map['name'] as String? ?? map['organization_name'] as String? ?? 'Unknown',
      slug: map['slug'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      businessTypes: types,
      tenantFeatures: features,
      language: map['language'] as String? ?? 'en',
    );
  }
}

class OrganizationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Organization>> getUserOrganizations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('organization_members')
        .select('''
          organization_id,
          role,
          organizations!inner (
            id,
            name,
            slug,
            business_type,
            tenant_features,
            language
          )
        ''')
        .eq('user_id', user.id);

    return (response as List<dynamic>).map((item) {
      final orgMap = item as Map<String, dynamic>;
      final orgData = orgMap['organizations'] as Map<String, dynamic>;
      return Organization(
        id: orgData['id'] as String,
        name: orgData['name'] as String,
        slug: orgData['slug'] as String,
        role: orgMap['role'] as String? ?? 'member',
        businessTypes: (orgData['business_type'] as String? ?? 'general')
            .split(',')
            .map((value) => value.trim())
            .toList(),
        tenantFeatures: (orgData['tenant_features'] as List<dynamic>?)
                ?.map((value) => value.toString())
                .toList() ??
            [],
        language: orgData['language'] as String? ?? 'en',
      );
    }).toList();
  }
}
