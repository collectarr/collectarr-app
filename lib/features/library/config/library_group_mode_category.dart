import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

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
  LibraryKindRuntime type,
  List<String> modes,
) {
  final fields = type.fields;
  final categoriesMap = <String, List<String>>{};

  for (final mode in modes) {
    final groupDef = fields.findGroupDefinition(fields.decodeGroupId(mode));
    final category = groupDef?.resolvedCategory ?? 'Personal';
    categoriesMap.putIfAbsent(category, () => []).add(mode);
  }

  return [
    for (final entry in categoriesMap.entries)
      LibraryGroupModeCategory(entry.key, entry.value),
  ];
}

List<LibraryGroupModeCategory> libraryGroupModeCategories(
  LibraryKindRuntime type,
  List<String> modes,
) {
  return type.capabilities.groupModeCategoriesBuilder?.call(modes) ??
      defaultLibraryGroupModeCategories(type, modes);
}
