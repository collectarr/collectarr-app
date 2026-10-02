import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// Workspace identity for canonical catalog rows and App-owned collection rows.
///
/// The active workspace shape distinguishes a catalog item from a physical
/// collection item that points to it. `LibraryReleaseRef` remains only for
/// release-specific adapters that are still being removed.
sealed class LibraryEntityRef {
  const LibraryEntityRef({required this.catalogItemId});

  final String catalogItemId;

  String get id;
  LibraryEntityScope get scope;
}

final class LibraryCatalogItemNodeRef extends LibraryEntityRef {
  const LibraryCatalogItemNodeRef(
      {required super.catalogItemId, this.collectionItemRef});

  /// Distinguishes collection copies that share the same catalog item.
  ///
  /// The optional value is absent for catalog-only nodes. It lets the current
  /// workspace render and select every collection item as its own entry while the
  /// catalog target remains [catalogItemId].
  final CollectionItemRef? collectionItemRef;

  @override
  String get id => collectionItemRef?.key ?? catalogItemId;

  @override
  LibraryEntityScope get scope => LibraryEntityScope.catalogItem;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryCatalogItemNodeRef &&
            other.catalogItemId == catalogItemId &&
            other.collectionItemRef == collectionItemRef;
  }

  @override
  int get hashCode => Object.hash(catalogItemId, collectionItemRef);
}

final class LibraryReleaseRef extends LibraryEntityRef {
  const LibraryReleaseRef({
    required super.catalogItemId,
    required this.releaseId,
    required this.release,
  });

  final String releaseId;
  final LibraryWorkspaceReleaseSummary release;

  @override
  String get id => '$catalogItemId:release:$releaseId';

  @override
  LibraryEntityScope get scope => LibraryEntityScope.release;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryReleaseRef &&
            other.catalogItemId == catalogItemId &&
            other.releaseId == releaseId;
  }

  @override
  int get hashCode => Object.hash(catalogItemId, releaseId);
}

final class LibraryCollectionItemNodeRef extends LibraryEntityRef {
  const LibraryCollectionItemNodeRef({
    required super.catalogItemId,
    required this.collectionItemRef,
  });

  final CollectionItemRef collectionItemRef;

  @override
  String get id => collectionItemRef.key;

  @override
  LibraryEntityScope get scope => LibraryEntityScope.collectionItem;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryCollectionItemNodeRef &&
            other.catalogItemId == catalogItemId &&
            other.collectionItemRef == collectionItemRef;
  }

  @override
  int get hashCode => Object.hash(catalogItemId, collectionItemRef);
}
