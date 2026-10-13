import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Semantic fields stored on every local library entry.
abstract final class LibraryEntryFieldMetadata {
  static const location = LibraryKindFieldMetadata(
    id: 'library_entry.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location_path',
    filterable: true,
    editable: true,
  );

  static const tag = LibraryKindFieldMetadata(
    id: 'library_entry.tag',
    label: 'Tag',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'tags[]',
    filterable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'library_entry.condition',
    label: 'Condition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'condition',
    filterable: true,
    editable: true,
  );

  static const all = <LibraryKindFieldMetadata>[location, tag, condition];
}
