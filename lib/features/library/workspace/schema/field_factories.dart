import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

LibraryFieldDefinition<TKind, TDto, String?>
    textField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryKindFieldMetadata metadata,
  required LibraryFieldId<TKind, String?> id,
  required String? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TKind, TDto, String?>(
    metadata: metadata,
    id: id,
    getValue: (context) => getValue(context.dto),
  );
}

LibraryFieldDefinition<TKind, TDto, num?>
    numberField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryKindFieldMetadata metadata,
  required LibraryFieldId<TKind, num?> id,
  required num? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TKind, TDto, num?>(
    metadata: metadata,
    id: id,
    getValue: (context) => getValue(context.dto),
  );
}

LibraryFieldDefinition<TKind, TDto, DateTime?>
    dateField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryKindFieldMetadata metadata,
  required LibraryFieldId<TKind, DateTime?> id,
  required DateTime? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TKind, TDto, DateTime?>(
    metadata: metadata,
    id: id,
    getValue: (context) => getValue(context.dto),
  );
}

LibraryFieldDefinition<TKind, TDto, int?>
    moneyField<TKind, TDto extends LibraryWorkspaceDto>({
  required LibraryKindFieldMetadata metadata,
  required LibraryFieldId<TKind, int?> id,
  required int? Function(TDto dto) getValue,
}) {
  return LibraryFieldDefinition<TKind, TDto, int?>(
    metadata: metadata,
    id: id,
    getValue: (context) => getValue(context.dto),
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
  bool allowSortInteraction = true,
  bool allowGroupInteraction = true,
  bool isNumeric = false,
}) {
  return LibraryColumnDefinition<TKind, TDto, V>(
    metadata: field.metadata,
    id: field.id,
    getValue: field.getValue,
    cellValue: cellValue,
    group: group,
    defaultWidth: defaultWidth,
    minWidth: minWidth,
    maxWidth: maxWidth,
    allowSortInteraction: allowSortInteraction,
    allowGroupInteraction: allowGroupInteraction,
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
  if (!field.metadata.sortable) {
    throw ArgumentError.value(
      field.id.value,
      'field',
      'Field metadata does not allow sorting.',
    );
  }
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
  bool supportsJump = false,
  String? Function(LibraryProjectionContext<TDto> context)? sequenceValue,
  String? drilldownChildId,
  String? folderSetLabel,
  String? Function(LibraryProjectionContext<TDto> context)? subgroupKey,
  CatalogTransportBucketValueMutator? bucketValueMutator,
  LibraryEntryGroupBucketValueMutator? entryBucketValueMutator,
}) {
  if (!field.metadata.groupable) {
    throw ArgumentError.value(
      field.id.value,
      'field',
      'Field metadata does not allow grouping.',
    );
  }
  return LibraryGroupDefinition<TKind, TDto, V>(
    id: LibraryGroupId<TKind, V>(field.id.value),
    label: field.label,
    getValue: field.getValue,
    sidebarTitle: sidebarTitle,
    category: category,
    icon: icon,
    presentation: presentation,
    supportsBucketManagement: supportsBucketManagement,
    supportsJump: supportsJump,
    sequenceValue: sequenceValue,
    drilldownChildId: drilldownChildId,
    folderSetLabel: folderSetLabel,
    subgroupKey: subgroupKey,
    bucketValueMutator: bucketValueMutator,
    entryBucketValueMutator: entryBucketValueMutator,
  );
}
