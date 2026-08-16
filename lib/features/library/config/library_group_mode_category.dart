import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

typedef LibraryGroupModeCategoryBuilder = List<LibraryGroupModeCategory>
    Function(
  List<String> modes,
);

class LibraryGroupModeCategory {
  const LibraryGroupModeCategory(this.label, this.modes);

  final String label;
  final List<dynamic> modes;
}

List<LibraryGroupModeCategory> defaultLibraryGroupModeCategories(
  LibraryTypeConfig type,
  List<String> modes,
) {
  final fields = libraryKindRuntimeForType(type).fields;
  final categoriesMap = <String, List<String>>{};

  for (final mode in modes) {
    final groupDef = fields.findGroupDefinition(mode);
    final category = groupDef?.resolvedCategory ?? 'Personal';
    categoriesMap.putIfAbsent(category, () => []).add(mode);
  }

  return [
    for (final entry in categoriesMap.entries)
      LibraryGroupModeCategory(entry.key, entry.value),
  ];
}
