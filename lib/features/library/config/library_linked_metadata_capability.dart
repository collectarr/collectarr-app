import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

abstract interface class LibraryLinkedMetadataCapability {
  const LibraryLinkedMetadataCapability();

  Iterable<String> candidatesForEntry(ShelfEntry source);
}

class DefaultLibraryLinkedMetadataCapability
    extends LibraryLinkedMetadataCapability {
  const DefaultLibraryLinkedMetadataCapability();

  @override
  Iterable<String> candidatesForEntry(ShelfEntry source) sync* {
    yield* _commonCandidates(source);
  }
}

class TypedLibraryLinkedMetadataCapability<
        TMetadata extends LibraryKindMetadataRuntime>
    extends LibraryLinkedMetadataCapability {
  const TypedLibraryLinkedMetadataCapability(this._metadataValues);

  final Iterable<String?> Function(TMetadata metadata) _metadataValues;

  @override
  Iterable<String> candidatesForEntry(ShelfEntry source) sync* {
    yield* _commonCandidates(source);
    final metadata = source.catalogItem?.kindMetadata;
    if (metadata is TMetadata) {
      yield* _nonEmptyStrings(_metadataValues(metadata));
    }
  }
}

Iterable<String> _commonCandidates(ShelfEntry source) sync* {
  final item = source.catalogItem;
  if (item == null) return;
  yield* _nonEmptyStrings([
    item.title,
    ...(item.searchAliases ?? const <String>[]),
  ]);
}

Iterable<String> _nonEmptyStrings(Iterable<String?> values) sync* {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      yield trimmed;
    }
  }
}
