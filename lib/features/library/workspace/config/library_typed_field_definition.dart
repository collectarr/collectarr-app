abstract interface class LibraryWorkspaceDto {
  const LibraryWorkspaceDto();
}

class LibraryFieldId<TValue> {
  const LibraryFieldId(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibraryFieldId<TValue> && other.value == value;
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
  });

  final LibraryFieldId<TValue> id;
  final String label;
  final LibraryFieldValueGetter<TDto, TValue> getValue;
}

class LibraryColumnDefinition<TDto, TValue> {
  const LibraryColumnDefinition({
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

class LibrarySortDefinition<TDto, TValue> {
  const LibrarySortDefinition({
    required this.id,
    required this.label,
    required this.compare,
    this.defaultAscending = true,
  });

  final LibraryFieldId<TValue> id;
  final String label;
  final int Function(TDto left, TDto right) compare;
  final bool defaultAscending;
}
