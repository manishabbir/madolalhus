enum BillingInterval { monthly, yearly }

class Plan {
  final String id;
  final String name;
  final String? description;
  final int priceCents;
  final BillingInterval billingInterval;
  final List<String> featureFlags;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Plan({
    required this.id,
    required this.name,
    this.description,
    required this.priceCents,
    required this.billingInterval,
    required this.featureFlags,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      priceCents: (map['price_cents'] as int?) ?? 0,
      billingInterval: BillingInterval.values.firstWhere(
        (e) => e.name == (map['billing_interval'] as String? ?? 'monthly'),
        orElse: () => BillingInterval.monthly,
      ),
      featureFlags: (map['feature_flags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: (map['is_active'] as bool?) ?? true,
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
      'name': name,
      'description': description,
      'price_cents': priceCents,
      'billing_interval': billingInterval.name,
      'feature_flags': featureFlags,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Plan copyWith({
    String? id,
    String? name,
    String? description,
    int? priceCents,
    BillingInterval? billingInterval,
    List<String>? featureFlags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      billingInterval: billingInterval ?? this.billingInterval,
      featureFlags: featureFlags ?? this.featureFlags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice {
    if (priceCents == 0) return 'Free';
    final dollars = priceCents / 100;
    return '\$${dollars.toStringAsFixed(2)}/${billingInterval.name}';
  }
}