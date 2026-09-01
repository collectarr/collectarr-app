import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';

export 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
export 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';

abstract interface class LibraryWorkspaceDto {
  const LibraryWorkspaceDto();

  String get title;
  String? get coverImageUrl;
}

enum LibraryGroupPresentation { inlineHeaders, folderGrid }

extension LibraryGroupPresentationLabels on LibraryGroupPresentation {
  String get label {
    return switch (this) {
      LibraryGroupPresentation.inlineHeaders => 'Inline headers',
      LibraryGroupPresentation.folderGrid => 'Folder grid',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryGroupPresentation.inlineHeaders => Icons.segment_outlined,
      LibraryGroupPresentation.folderGrid => Icons.folder_open_outlined,
    };
  }
}

class LibraryCellValue {
  const LibraryCellValue._(this.value);

  factory LibraryCellValue.empty() => const LibraryCellValue._(null);
  factory LibraryCellValue.text(String value) => LibraryCellValue._(value);
  factory LibraryCellValue.number(num value) => LibraryCellValue._(value);
  factory LibraryCellValue.boolean(bool value) => LibraryCellValue._(value);
  factory LibraryCellValue.list(List<Object?> value) =>
      LibraryCellValue._(value);

  final Object? value;

  bool get isEmpty => value == null;
}

enum LibraryFieldScope {
  media,
  release,
  copy,
  derived,
  provenance,
}

typedef LibraryFieldValueGetter<TDto extends LibraryWorkspaceDto, TValue>
    = TValue Function(
  LibraryProjectionContext<TDto> context,
);

class LibraryFieldDefinition<TKind, TDto extends LibraryWorkspaceDto, TValue> {
  const LibraryFieldDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.scope = LibraryFieldScope.media,
    this.cellValue,
    this.sortable = true,
    this.groupable = true,
  });

  final LibraryFieldId<TKind, TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final LibraryFieldScope scope;
  final LibraryCellValue Function(TValue value)? cellValue;
  final bool sortable;
  final bool groupable;
}

class LibraryGroupDefinition<TKind, TDto extends LibraryWorkspaceDto, TValue> {
  const LibraryGroupDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.sidebarTitle,
    this.icon,
    this.presentation = LibraryGroupPresentation.inlineHeaders,
    this.supportsBucketManagement = false,
    this.supportsJump = false,
    this.sequenceValue,
    this.bucketManagerListLabel,
    this.drilldownChildId,
    this.folderSetLabel,
    this.subgroupKey,
    this.category,
  });

  final LibraryGroupId<TKind, TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final String? sidebarTitle;
  final IconData? icon;
  final LibraryGroupPresentation presentation;
  final bool supportsBucketManagement;
  final bool supportsJump;
  final String? Function(LibraryProjectionContext<TDto> context)? sequenceValue;
  final String? bucketManagerListLabel;
  final String? drilldownChildId;
  final String? folderSetLabel;
  final String? Function(LibraryProjectionContext<TDto> context)? subgroupKey;
  final String? category;

  String get resolvedSidebarTitle => sidebarTitle ?? label;
  String get resolvedCategory => category ?? 'Main';

  String get resolvedBucketManagerListLabel =>
      bucketManagerListLabel ?? '$label list';

  LibraryGroupDefinition<TKind, TDto, TValue> copyWith({
    LibraryGroupId<TKind, TValue>? id,
    String? label,
    LibraryFieldValueGetter<TDto, TValue>? getValue,
    String? sidebarTitle,
    IconData? icon,
    LibraryGroupPresentation? presentation,
    bool? supportsBucketManagement,
    bool? supportsJump,
    String? Function(LibraryProjectionContext<TDto> context)? sequenceValue,
    String? bucketManagerListLabel,
    String? drilldownChildId,
    String? folderSetLabel,
    String? Function(LibraryProjectionContext<TDto> context)? subgroupKey,
    String? category,
  }) {
    return LibraryGroupDefinition<TKind, TDto, TValue>(
      id: id ?? this.id,
      label: label ?? this.label,
      getValue: getValue ?? this.getValue,
      sidebarTitle: sidebarTitle ?? this.sidebarTitle,
      icon: icon ?? this.icon,
      presentation: presentation ?? this.presentation,
      supportsBucketManagement:
          supportsBucketManagement ?? this.supportsBucketManagement,
      supportsJump: supportsJump ?? this.supportsJump,
      sequenceValue: sequenceValue ?? this.sequenceValue,
      bucketManagerListLabel:
          bucketManagerListLabel ?? this.bucketManagerListLabel,
      drilldownChildId: drilldownChildId ?? this.drilldownChildId,
      folderSetLabel: folderSetLabel ?? this.folderSetLabel,
      subgroupKey: subgroupKey ?? this.subgroupKey,
      category: category ?? this.category,
    );
  }
}

typedef LibrarySortComparator<TDto extends LibraryWorkspaceDto> = int Function(
  LibraryProjectionContext<TDto> left,
  LibraryProjectionContext<TDto> right,
);

class LibrarySortDefinition<TKind, TDto extends LibraryWorkspaceDto> {
  const LibrarySortDefinition({
    required this.id,
    required this.label,
    required this.compare,
    this.group = 'Main',
    this.defaultAscending = true,
  });

  final LibrarySortId<TKind> id;
  final String label;
  final LibrarySortComparator<TDto> compare;
  final String group;
  final bool defaultAscending;
}

typedef LibraryColumnCellBuilder<TDto extends LibraryWorkspaceDto> = Widget
    Function(
  LibraryProjectionContext<TDto> context,
);

class LibraryColumnDefinition<TKind, TDto extends LibraryWorkspaceDto, TValue> {
  const LibraryColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.cellValue,
    this.group = 'Main',
    this.displayName,
    this.sortable = true,
    this.groupable = true,
    this.isNumeric = false,
    this.sortId,
    this.defaultWidth,
    this.minWidth,
    this.maxWidth,
  });

  final LibraryFieldId<TKind, TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final LibraryColumnCellBuilder<TDto>? cellValue;
  final String group;
  final String? displayName;
  final bool sortable;
  final bool groupable;
  final bool isNumeric;
  final LibrarySortId<TKind>? sortId;
  final double? defaultWidth;
  final double? minWidth;
  final double? maxWidth;

  String get resolvedDisplayName => displayName ?? label;
}
