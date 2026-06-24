import '../enums/tenant_plan_status.dart';
export '../enums/tenant_plan_status.dart';

class TenantPlan {
  final String id;
  final String organizationId;
  final String planId;
  final List<String> customFeatures;
  final List<String> disabledFeatures;
  final TenantPlanStatus status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TenantPlan({
    required this.id,
    required this.organizationId,
    required this.planId,
    required this.customFeatures,
    required this.disabledFeatures,
    this.status = TenantPlanStatus.active,
    this.startsAt,
    this.endsAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TenantPlan.fromMap(Map<String, dynamic> map) {
    return TenantPlan(
      id: map['id'] as String? ?? '',
      organizationId: map['organization_id'] as String? ?? '',
      planId: map['plan_id'] as String? ?? '',
      customFeatures: (map['custom_features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      disabledFeatures: (map['disabled_features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: TenantPlanStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'active'),
        orElse: () => TenantPlanStatus.active,
      ),
      startsAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'] as String)
          : null,
      endsAt:
          map['ends_at'] != null ? DateTime.parse(map['ends_at'] as String) : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'plan_id': planId,
      'custom_features': customFeatures,
      'disabled_features': disabledFeatures,
      'status': status.name,
      'started_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TenantPlan copyWith({
    String? id,
    String? organizationId,
    String? planId,
    List<String>? customFeatures,
    List<String>? disabledFeatures,
    TenantPlanStatus? status,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantPlan(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      planId: planId ?? this.planId,
      customFeatures: customFeatures ?? this.customFeatures,
      disabledFeatures: disabledFeatures ?? this.disabledFeatures,
      status: status ?? this.status,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TenantPlanWithOrg {
  final String id;
  final String organizationId;
  final String organizationName;
  final String? organizationSlug;
  final String planId;
  final String planName;
  final List<String> customFeatures;
  final List<String> disabledFeatures;
  final TenantPlanStatus status;
  final DateTime? endsAt;

  const TenantPlanWithOrg({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    this.organizationSlug,
    required this.planId,
    required this.planName,
    required this.customFeatures,
    required this.disabledFeatures,
    this.status = TenantPlanStatus.active,
    this.endsAt,
  });

  factory TenantPlanWithOrg.fromMap(Map<String, dynamic> map) {
    final orgData = map['organizations'] as Map<String, dynamic>? ?? {};
    final planData = map['plans'] as Map<String, dynamic>? ?? {};

    return TenantPlanWithOrg(
      id: map['id'] as String? ?? '',
      organizationId: map['organization_id'] as String? ?? '',
      organizationName: orgData['name'] as String? ?? 'Unknown',
      organizationSlug: orgData['slug'] as String?,
      planId: map['plan_id'] as String? ?? '',
      planName: planData['name'] as String? ?? 'No Plan',
      customFeatures: (map['custom_features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      disabledFeatures: (map['disabled_features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: TenantPlanStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'active'),
        orElse: () => TenantPlanStatus.active,
      ),
      endsAt:
          map['ends_at'] != null ? DateTime.parse(map['ends_at'] as String) : null,
    );
  }
}

class TenantPlanWithFeatures {
  final String id;
  final String organizationId;
  final String planId;
  final String planName;
  final int priceCents;
  final TenantPlanStatus status;
  final List<String> featureFlags;
  final List<String> customFeatures;
  final List<String> disabledFeatures;

  const TenantPlanWithFeatures({
    required this.id,
    required this.organizationId,
    required this.planId,
    required this.planName,
    required this.priceCents,
    required this.status,
    required this.featureFlags,
    required this.customFeatures,
    required this.disabledFeatures,
  });

  bool get isPaid => priceCents > 0;
}
