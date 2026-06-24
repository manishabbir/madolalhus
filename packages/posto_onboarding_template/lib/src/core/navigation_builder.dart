import 'package:flutter/material.dart';

class NavigationItem {
  final String route;
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.route,
    required this.icon,
    required this.label,
  });
}

typedef BusinessPackInfo = ({
  String id,
  List<NavigationItem> Function(String userRole) buildNavItems,
});

class NavigationBuilder {
  static List<NavigationItem> buildNavigation({
    required List<BusinessPackInfo> packs,
    required String businessType,
    required String userRole,
  }) {
    BusinessPackInfo? pack;
    for (final item in packs) {
      if (item.id == businessType) {
        pack = item;
        break;
      }
    }
    pack ??= (
      id: '',
      buildNavItems: (String _) => const <NavigationItem>[],
    );

    return pack.buildNavItems(userRole);
  }
}
