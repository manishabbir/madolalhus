import '../modules/business_module_template.dart';
import '../modules/business_pack.dart';

class ModuleRegistry {
  final List<BusinessModuleTemplate> templates;
  final List<BusinessPack> packs;

  const ModuleRegistry({
    required this.templates,
    this.packs = const [],
  });

  BusinessModuleTemplate? getTemplate(String id) {
    return templates.firstWhereOrNull((template) => template.id == id);
  }

  BusinessPack? getPack(String id) {
    return packs.firstWhereOrNull((pack) => pack.id == id);
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}
