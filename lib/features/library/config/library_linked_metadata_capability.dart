import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

abstract interface class LibraryLinkedMetadataCapability {
  const LibraryLinkedMetadataCapability();

  Iterable<String> candidatesForEntry(LibraryWorkspaceSource source);
}

class DefaultLibraryLinkedMetadataCapability
    extends LibraryLinkedMetadataCapability {
  const DefaultLibraryLinkedMetadataCapability();

  @override
  Iterable<String> candidatesForEntry(LibraryWorkspaceSource source) sync* {
    yield* _commonCandidates(source);
  }
}

class TypedLibraryLinkedMetadataCapability<TMetadata>
    extends LibraryLinkedMetadataCapability {
  const TypedLibraryLinkedMetadataCapability(
    this._metadataReader,
    this._metadataValues,
  );

  final TMetadata? Function(LibraryWorkspaceSource source) _metadataReader;
  final Iterable<String?> Function(TMetadata metadata) _metadataValues;

  @override
  Iterable<String> candidatesForEntry(LibraryWorkspaceSource source) sync* {
    yield* _commonCandidates(source);
    final metadata = _metadataReader(source);
    if (metadata != null) {
      yield* _nonEmptyStrings(_metadataValues(metadata));
    }
  }
}

Iterable<String> _commonCandidates(LibraryWorkspaceSource source) sync* {
  final summaryTitle = source.catalogSummary?.title;
  if (summaryTitle != null) {
    yield* _nonEmptyStrings([summaryTitle]);
  }
  yield* _nonEmptyStrings(source.catalogSearchTokens);
}

Iterable<String> _nonEmptyStrings(Iterable<String?> values) sync* {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      yield trimmed;
    }
  }
}
