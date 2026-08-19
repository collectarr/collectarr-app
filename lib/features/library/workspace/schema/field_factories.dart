import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

LibraryFieldDefinition<TKind, TDto, String?>
    textField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryFieldId<TKind, String?> id,
  required String label,
  required String? Function(TDto dto) getValue,
  LibraryFieldScope scope = LibraryFieldScope.media,
}) {
  return LibraryFieldDefinition<TKind, TDto, String?>(
    id: id,
    label: label,
    getValue: (context) => getValue(context.dto),
    scope: scope,
  );
}

LibraryFieldDefinition<TKind, TDto, num?>
    numberField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryFieldId<TKind, num?> id,
  required String label,
  required num? Function(TDto dto) getValue,
  LibraryFieldScope scope = LibraryFieldScope.media,
}) {
  return LibraryFieldDefinition<TKind, TDto, num?>(
    id: id,
    label: label,
    getValue: (context) => getValue(context.dto),
    scope: scope,
  );
}

LibraryFieldDefinition<TKind, TDto, DateTime?>
    dateField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryFieldId<TKind, DateTime?> id,
  required String label,
  required DateTime? Function(TDto dto) getValue,
  LibraryFieldScope scope = LibraryFieldScope.media,
}) {
  return LibraryFieldDefinition<TKind, TDto, DateTime?>(
    id: id,
    label: label,
    getValue: (context) => getValue(context.dto),
    scope: scope,
  );
}

LibraryFieldDefinition<TKind, TDto, int?>
    moneyField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryFieldId<TKind, int?> id,
  required String label,
  required int? Function(TDto dto) getValue,
  LibraryFieldScope scope = LibraryFieldScope.media,
}) {
  return LibraryFieldDefinition<TKind, TDto, int?>(
    id: id,
    label: label,
    getValue: (context) => getValue(context.dto),
    scope: scope,
  );
}

LibraryColumnDefinition<TKind, TDto, V>
    columnFromField<TKind, TDto extends LibraryWorkspaceDto, V>(
  LibraryFieldDefinition<TKind, TDto, V> field, {
  Widget Function(LibraryProjectionContext<TDto> context)? cellValue,
  String group = 'Main',
  double? defaultWidth,
  double? minWidth,
  double? maxWidth,
  bool sortable = true,
  bool groupable = true,
  bool isNumeric = false,
}) {
  return LibraryColumnDefinition<TKind, TDto, V>(
    id: field.id,
    label: field.label,
    getValue: field.getValue,
    cellValue: cellValue,
    group: group,
    defaultWidth: defaultWidth,
    minWidth: minWidth,
    maxWidth: maxWidth,
    sortable: sortable,
    groupable: groupable,
    isNumeric: isNumeric,
  );
}

LibrarySortDefinition<TKind, TDto> sortFromField<TKind,
    TDto extends LibraryWorkspaceDto, V extends Comparable<Object>>(
  LibraryFieldDefinition<TKind, TDto, V?> field, {
  String group = 'Main',
  bool defaultAscending = true,
  int Function(V a, V b)? customCompare,
}) {
  return LibrarySortDefinition<TKind, TDto>(
    id: LibrarySortId<TKind>(field.id.value),
    label: field.label,
    group: group,
    defaultAscending: defaultAscending,
    compare: (left, right) {
      final a = field.getValue(left);
      final b = field.getValue(right);
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      if (customCompare != null) return customCompare(a, b);
      return a.compareTo(b);
    },
  );
}

LibraryGroupDefinition<TKind, TDto, V>
    groupFromField<TKind, TDto extends LibraryWorkspaceDto, V>(
  LibraryFieldDefinition<TKind, TDto, V> field, {
  String? sidebarTitle,
  String? category,
  IconData? icon,
  LibraryGroupPresentation presentation = LibraryGroupPresentation.folderGrid,
  bool supportsBucketManagement = false,
  String? drilldownChildId,
  String? folderSetLabel,
  String? Function(LibraryProjectionContext<TDto> context)? subgroupKey,
}) {
  return LibraryGroupDefinition<TKind, TDto, V>(
    id: LibraryGroupId<TKind, V>(field.id.value),
    label: field.label,
    getValue: field.getValue,
    sidebarTitle: sidebarTitle,
    category: category,
    icon: icon,
    presentation: presentation,
    supportsBucketManagement: supportsBucketManagement,
    drilldownChildId: drilldownChildId,
    folderSetLabel: folderSetLabel,
    subgroupKey: subgroupKey,
  );
}
