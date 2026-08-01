import 'package:flutter/material.dart';

abstract interface class LibraryWorkspaceDto {
  const LibraryWorkspaceDto();

  String get title;
  String? get seriesTitle;
  String? get itemNumber;
  String? get publisher;
  DateTime? get releaseDate;
  bool get isOwned;
  bool get isWishlisted;
  bool get isTracked;

  String? get condition;
  String? get locationPath;
  int? get rating;
  int? get pricePaidCents;
  DateTime? get addedAt;
  DateTime get updatedAt;
  String? get tags;
  String? get collectionStatus;
  String? get notes;

  String? get variant;
  String? get barcode;
  String? get grade;
  String? get country;
  String? get language;
  String? get currency;
  String? get referenceFormatLabel;
  String? get format;
  String? get coverImageUrl;
  int? get marketValueCents;
  String? get creator;
  String? get synopsis;
  String? get audienceRating;
  String? get ageRating;
  String? get editionLabel;
}




typedef LibraryWorkspaceDtoBuilder<TDto extends LibraryWorkspaceDto> = TDto Function(
  dynamic entry,
);

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

class LibraryFieldId<TValue> {
  const LibraryFieldId(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibraryFieldId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
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

typedef LibraryFieldValueGetter<TDto, TValue> = TValue Function(TDto dto);

class LibraryFieldDefinition<TDto, TValue> {
  const LibraryFieldDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.cellValue,
    this.sortable = true,
    this.groupable = true,
  });

  final LibraryFieldId<TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final LibraryCellValue Function(TValue value)? cellValue;
  final bool sortable;
  final bool groupable;
}

class LibraryGroupDefinition<TDto, TValue> {
  const LibraryGroupDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.sidebarTitle,
    this.icon,
    this.presentation = LibraryGroupPresentation.inlineHeaders,
    this.supportsBucketManagement = false,
    this.bucketManagerListLabel,
    this.drilldownChildId,
    this.folderSetLabel,
    this.subgroupKey,
  });

  final LibraryFieldId<TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final String? sidebarTitle;
  final IconData? icon;
  final LibraryGroupPresentation presentation;
  final bool supportsBucketManagement;
  final String? bucketManagerListLabel;
  final String? drilldownChildId;
  final String? folderSetLabel;
  final String? Function(TDto dto)? subgroupKey;

  String get resolvedSidebarTitle => sidebarTitle ?? label;

  String get resolvedBucketManagerListLabel =>
      bucketManagerListLabel ?? '$label list';

  LibraryGroupDefinition<TDto, TValue> copyWith({
    LibraryFieldId<TValue>? id,
    String? label,
    LibraryFieldValueGetter<TDto, TValue>? getValue,
    String? sidebarTitle,
    IconData? icon,
    LibraryGroupPresentation? presentation,
    bool? supportsBucketManagement,
    String? bucketManagerListLabel,
    String? drilldownChildId,
    String? folderSetLabel,
    String? Function(TDto dto)? subgroupKey,
  }) {
    return LibraryGroupDefinition<TDto, TValue>(
      id: id ?? this.id,
      label: label ?? this.label,
      getValue: getValue ?? this.getValue,
      sidebarTitle: sidebarTitle ?? this.sidebarTitle,
      icon: icon ?? this.icon,
      presentation: presentation ?? this.presentation,
      supportsBucketManagement: supportsBucketManagement ?? this.supportsBucketManagement,
      bucketManagerListLabel: bucketManagerListLabel ?? this.bucketManagerListLabel,
      drilldownChildId: drilldownChildId ?? this.drilldownChildId,
      folderSetLabel: folderSetLabel ?? this.folderSetLabel,
      subgroupKey: subgroupKey ?? this.subgroupKey,
    );
  }
}

class LibrarySortId {
  const LibrarySortId(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    if (other is LibrarySortId) return other.value == value;
    if (other is String) return other == value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef LibrarySortComparator<TDto> = int Function(TDto left, TDto right);

class LibrarySortDefinition<TDto> {
  const LibrarySortDefinition({
    required this.id,
    required this.label,
    required this.compare,
    this.group = 'Main',
    this.defaultAscending = true,
  });

  final LibrarySortId id;
  final String label;
  final LibrarySortComparator<TDto> compare;
  final String group;
  final bool defaultAscending;
}

typedef LibraryColumnCellBuilder<TDto> = Widget Function(TDto dto);

class LibraryColumnDefinition<TDto, TValue> {
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

  final LibraryFieldId<TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
  final LibraryColumnCellBuilder<TDto>? cellValue;
  final String group;
  final String? displayName;
  final bool sortable;
  final bool groupable;
  final bool isNumeric;
  final LibrarySortId? sortId;
  final double? defaultWidth;
  final double? minWidth;
  final double? maxWidth;

  String get resolvedDisplayName => displayName ?? label;
}
