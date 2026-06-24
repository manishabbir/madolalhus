enum SyncBehavior { none, localFirst, lanFirst, cloudFirst, hybrid }

class Feature {
  final String id;
  final String name;
  final String description;
  final List<String> businessTypesSupported;
  final List<String> dependencies;
  final Map<String, List<String>> permissionRules;
  final SyncBehavior syncBehavior;
  bool enabled;

  Feature({
    required this.id,
    required this.name,
    required this.description,
    required this.businessTypesSupported,
    required this.dependencies,
    required this.permissionRules,
    required this.syncBehavior,
    this.enabled = false,
  });
}

class BusinessTemplate {
  final String id;
  final String name;
  final List<String> featureIds;

  const BusinessTemplate({
    required this.id,
    required this.name,
    required this.featureIds,
  });
}

class FeatureRegistry {
  static final FeatureRegistry _instance = FeatureRegistry._internal();
  factory FeatureRegistry() => _instance;
  FeatureRegistry._internal();

  final Map<String, Feature> _features = {};
  final Map<String, BusinessTemplate> _templates = {};
  final Set<String> _tenantEnabledFeatures = {};

  void initialize() {
    _registerCoreFeatures();
    _registerTemplates();
  }

  void registerFeature(Feature feature) {
    _features[feature.id] = feature;
  }

  void enableFeature(String featureId) {
    _tenantEnabledFeatures.add(featureId);
    _features[featureId]?.enabled = true;
  }

  void clearTenant() {
    _tenantEnabledFeatures.clear();
    for (final feature in _features.values) {
      feature.enabled = false;
    }
  }

  void setTenant(String tenantId, List<String> businessTypes, [List<String> tenantFeatures = const []]) {
    clearTenant();
    _enableFeaturesForBusinessTypes(businessTypes);
    for (final featureId in tenantFeatures) {
      enableFeature(featureId);
    }
  }

  void _enableFeaturesForBusinessTypes(List<String> businessTypes) {
    for (final bizType in businessTypes) {
      final template = _templates[bizType];
      if (template == null) continue;
      for (final featureId in template.featureIds) {
        enableFeature(featureId);
      }
    }
  }

  bool isFeatureEnabled(String featureId) => _tenantEnabledFeatures.contains(featureId);

  bool canAccessFeature(String featureId, String userRole) {
    final feature = _features[featureId];
    if (feature == null || !feature.enabled) return false;
    final roles = feature.permissionRules['roles'] ?? const ['admin', 'manager', 'cashier'];
    return roles.contains(userRole);
  }

  List<Feature> getEnabledFeatures() => _features.values.where((feature) => feature.enabled).toList();

  static final List<Feature> _coreFeatures = [
    Feature(
      id: 'SECURE_AUTHENTICATION',
      name: 'Secure Authentication',
      description: 'User login and session management',
      businessTypesSupported: ['all'],
      dependencies: [],
      permissionRules: {'roles': ['admin', 'manager', 'cashier', 'waiter', 'kitchen', 'viewer']},
      syncBehavior: SyncBehavior.localFirst,
    ),
    Feature(
      id: 'INVENTORY_MANAGEMENT',
      name: 'Inventory Management',
      description: 'Product catalog and stock tracking',
      businessTypesSupported: ['all'],
      dependencies: [],
      permissionRules: {'roles': ['admin', 'manager']},
      syncBehavior: SyncBehavior.hybrid,
    ),
    Feature(
      id: 'POS_REGISTER',
      name: 'POS Register',
      description: 'Product selection, cart, payments, discounts, and tax',
      businessTypesSupported: ['all'],
      dependencies: ['INVENTORY_MANAGEMENT'],
      permissionRules: {'roles': ['admin', 'manager', 'cashier']},
      syncBehavior: SyncBehavior.hybrid,
    ),
    Feature(
      id: 'CUSTOMER_MANAGEMENT',
      name: 'Customer Management',
      description: 'Customer profiles and store credit',
      businessTypesSupported: ['all'],
      dependencies: [],
      permissionRules: {'roles': ['admin', 'manager', 'cashier']},
      syncBehavior: SyncBehavior.hybrid,
    ),
  ];

  static final List<BusinessTemplate> _coreTemplates = [
    BusinessTemplate(
      id: 'restaurant',
      name: 'Restaurant & Cafe',
      featureIds: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER', 'CUSTOMER_MANAGEMENT'],
    ),
    BusinessTemplate(
      id: 'retail',
      name: 'Retail & Fashion',
      featureIds: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER', 'CUSTOMER_MANAGEMENT'],
    ),
    BusinessTemplate(
      id: 'grocery',
      name: 'Grocery & Supermarket',
      featureIds: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER'],
    ),
    BusinessTemplate(
      id: 'pharmacy',
      name: 'Health & Beauty / Pharmacy',
      featureIds: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER'],
    ),
    BusinessTemplate(
      id: 'general',
      name: 'General / Other',
      featureIds: ['SECURE_AUTHENTICATION', 'INVENTORY_MANAGEMENT', 'POS_REGISTER', 'CUSTOMER_MANAGEMENT'],
    ),
  ];

  void _registerCoreFeatures() {
    for (final feature in _coreFeatures) {
      _features[feature.id] = feature;
    }
  }

  void _registerTemplates() {
    for (final template in _coreTemplates) {
      _templates[template.id] = template;
    }
  }
}
