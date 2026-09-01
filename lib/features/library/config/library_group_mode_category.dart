import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'library_group_mode_category_models.dart';

export 'library_group_mode_category_models.dart';

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
  return type.presentation.groupModeCategoriesBuilder?.call(modes) ??
      defaultLibraryGroupModeCategories(type, modes);
}
