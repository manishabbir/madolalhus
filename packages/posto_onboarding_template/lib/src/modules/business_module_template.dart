import 'package:flutter/material.dart';

class BusinessModuleTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> featureIds;

  const BusinessModuleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.featureIds = const [],
  });
}

class DefaultBusinessModules {
  static const restaurant = BusinessModuleTemplate(
    id: 'restaurant',
    name: 'Restaurant & Cafe',
    description: 'Food, beverages, desserts',
    icon: Icons.restaurant,
    featureIds: ['TABLE_MANAGEMENT', 'KITCHEN_DISPLAY', 'WAITER_APP'],
  );

  static const retail = BusinessModuleTemplate(
    id: 'retail',
    name: 'Retail & Fashion',
    description: 'Clothing, accessories, footwear',
    icon: Icons.shopping_cart,
  );

  static const grocery = BusinessModuleTemplate(
    id: 'grocery',
    name: 'Grocery & Supermarket',
    description: 'Food items, vegetables, household',
    icon: Icons.local_grocery_store,
  );

  static const pharmacy = BusinessModuleTemplate(
    id: 'pharmacy',
    name: 'Health & Beauty / Pharmacy',
    description: 'Medicine, supplements, cosmetics',
    icon: Icons.medical_services,
  );

  static const general = BusinessModuleTemplate(
    id: 'general',
    name: 'General / Other',
    description: 'Mixed items, gifts, services',
    icon: Icons.store,
  );

  static List<BusinessModuleTemplate> all() {
    return const [restaurant, retail, grocery, pharmacy, general];
  }
}
