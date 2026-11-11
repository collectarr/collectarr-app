import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// A value an entry can be filtered by, with the name of its field. Values of
/// no particular field, such as search tokens, have no name.
typedef LibraryLinkedMetadataValue = ({String? field, String value});

abstract interface class LibraryLinkedMetadataCapability {
  const LibraryLinkedMetadataCapability();

  /// The entry's values, those of named fields first.
  Iterable<LibraryLinkedMetadataValue> valuesForEntry(
      LibraryWorkspaceContext source);
}

class TypedLibraryLinkedMetadataCapability<TMetadata>
    extends LibraryLinkedMetadataCapability {
  const TypedLibraryLinkedMetadataCapability(
    this._metadataReader,
    this._metadataValues,
  );

  final TMetadata? Function(LibraryWorkspaceContext source) _metadataReader;

  /// The metadata's values as (field name, value).
  final Iterable<(String, String?)> Function(TMetadata metadata)
      _metadataValues;

  @override
  Iterable<LibraryLinkedMetadataValue> valuesForEntry(
      LibraryWorkspaceContext source) sync* {
    final metadata = _metadataReader(source);
    if (metadata != null) {
      for (final (field, value) in _metadataValues(metadata)) {
        final trimmed = value?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          yield (field: field, value: trimmed);
        }
      }
    }
    yield* _commonValues(source);
  }
}

Iterable<LibraryLinkedMetadataValue> _commonValues(
    LibraryWorkspaceContext source) sync* {
  final summaryTitle = source.catalogSummary?.primaryLabel.trim();
  if (summaryTitle != null && summaryTitle.isNotEmpty) {
    yield (field: 'Title', value: summaryTitle);
  }
  for (final token in source.catalogSearchTokens) {
    final trimmed = token.trim();
    if (trimmed.isNotEmpty) yield (field: null, value: trimmed);
  }
}
