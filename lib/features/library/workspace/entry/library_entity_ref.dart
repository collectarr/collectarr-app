import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// Workspace identity for a canonical Catalog Item or its independently
/// editable local record.
sealed class LibraryEntityRef {
  const LibraryEntityRef({required this.catalogItemId});

  final String catalogItemId;

  String get id;
  LibraryEntityScope get scope;
}

final class LibraryCatalogItemNodeRef extends LibraryEntityRef {
  const LibraryCatalogItemNodeRef(
      {required super.catalogItemId, this.libraryEntryRef});

  /// Identifies the local editable record when one has been attached to the
  /// canonical catalog item. It is absent for catalog-only nodes.
  final LibraryEntryRef? libraryEntryRef;

  @override
  String get id => libraryEntryRef?.key ?? catalogItemId;

  @override
  LibraryEntityScope get scope => LibraryEntityScope.catalogItem;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryCatalogItemNodeRef &&
            other.catalogItemId == catalogItemId &&
            other.libraryEntryRef == libraryEntryRef;
  }

  @override
  int get hashCode => Object.hash(catalogItemId, libraryEntryRef);
}

final class LibraryEntryNodeRef extends LibraryEntityRef {
  const LibraryEntryNodeRef({
    required super.catalogItemId,
    required this.libraryEntryRef,
  });

  final LibraryEntryRef libraryEntryRef;

  @override
  String get id => libraryEntryRef.key;

  @override
  LibraryEntityScope get scope => LibraryEntityScope.libraryEntry;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryEntryNodeRef &&
            other.catalogItemId == catalogItemId &&
            other.libraryEntryRef == libraryEntryRef;
  }

  @override
  int get hashCode => Object.hash(catalogItemId, libraryEntryRef);
}
