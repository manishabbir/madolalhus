import 'package:flutter/material.dart';
import '../core/navigation_builder.dart';

abstract class BusinessPack {
  String get id;
  String get name;
  String get description;

  List<NavigationItem> buildNavigationItems({required String userRole}) {
    return const [];
  }

  List<Widget> buildDashboardCards(BuildContext context, String userRole) {
    return const [];
  }

  Widget? buildPosFeature(BuildContext context, String userRole) {
    return null;
  }

  void registerRoutes(Map<String, WidgetBuilder> registry) {}
}
