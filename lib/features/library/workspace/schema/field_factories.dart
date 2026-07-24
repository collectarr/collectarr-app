import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

LibraryFieldDefinition<TDto, String?> textField<TDto>({
  required String id,
  required String label,
  required String? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TDto, String?>(
    id: LibraryFieldId<String?>(id),
    label: label,
    getValue: getValue,
  );
}

LibraryFieldDefinition<TDto, num?> numberField<TDto>({
  required String id,
  required String label,
  required num? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TDto, num?>(
    id: LibraryFieldId<num?>(id),
    label: label,
    getValue: getValue,
  );
}

LibraryFieldDefinition<TDto, DateTime?> dateField<TDto>({
  required String id,
  required String label,
  required DateTime? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TDto, DateTime?>(
    id: LibraryFieldId<DateTime?>(id),
    label: label,
    getValue: getValue,
  );
}

LibraryFieldDefinition<TDto, int?> moneyField<TDto>({
  required String id,
  required String label,
  required int? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TDto, int?>(
    id: LibraryFieldId<int?>(id),
    label: label,
    getValue: getValue,
  );
}

LibraryColumnDefinition<TDto, V> columnFromField<TDto, V>(
  LibraryFieldDefinition<TDto, V> field, {
  Widget Function(TDto dto)? cellValue,
  String group = 'Main',
  double? defaultWidth,
  double? minWidth,
  double? maxWidth,
  bool sortable = true,
  bool groupable = true,
  bool isNumeric = false,
}) {
  return LibraryColumnDefinition<TDto, V>(
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

LibrarySortDefinition<TDto> sortFromField<TDto, V extends Comparable<Object>>(
  LibraryFieldDefinition<TDto, V?> field, {
  String group = 'Main',
  bool defaultAscending = true,
  int Function(V a, V b)? customCompare,
}) {
  return LibrarySortDefinition<TDto>(
    id: field.id.value,
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

LibraryGroupDefinition<TDto, V> groupFromField<TDto, V>(
  LibraryFieldDefinition<TDto, V> field, {
  String? sidebarTitle,
  IconData? icon,
  bool supportsBucketManagement = false,
}) {
  return LibraryGroupDefinition<TDto, V>(
    id: field.id,
    label: field.label,
    getValue: field.getValue,
    sidebarTitle: sidebarTitle,
    icon: icon,
    supportsBucketManagement: supportsBucketManagement,
  );
}
