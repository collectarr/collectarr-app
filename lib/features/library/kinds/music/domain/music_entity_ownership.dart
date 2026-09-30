import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

const musicReleaseEntityType = CatalogEntityTypeId('release');

bool isMusicReleaseRef(CatalogEntityRef? ref) {
  if (ref == null || ref.mediaKind != CatalogMediaKind.music) return false;
  if (ref.entityType != musicReleaseEntityType) return false;
  if (ref.id.trim().isEmpty) return false;
  return ref.rootId?.trim().isNotEmpty == true;
}

void requireMusicReleaseRef(
  CatalogEntityRef? ref, {
  String label = 'Music release reference',
}) {
  if (!isMusicReleaseRef(ref)) {
    throw StateError(
      '$label must identify a concrete Music release with a rootId',
    );
  }
}

/// Validates that a Music owned copy targets one concrete catalog item.
///
/// In the flattened catalog, the album edition is the catalog item itself.
/// Copies therefore point directly to the root item and never to a synthetic
/// release child.
void requireMusicOwnedCatalogItem({
  required CatalogEntityRef catalogRef,
  required CatalogEntityRef? targetRef,
}) {
  if (catalogRef.mediaKind != CatalogMediaKind.music ||
      !catalogRef.isKnown ||
      catalogRef.entityType != CatalogEntityTypeId.root ||
      targetRef != catalogRef) {
    throw StateError(
      'Music owned copies must target their concrete Music Catalog Item',
    );
  }
}

CatalogEntityRef musicReleaseRefForRoot(
  CatalogEntityRef root,
  String releaseId,
) {
  final rootRef = root.rootScope;
  if (rootRef.mediaKind != CatalogMediaKind.music || !rootRef.isKnown) {
    throw StateError('Music release target requires a known Music root');
  }
  final normalizedReleaseId = releaseId.trim();
  if (normalizedReleaseId.isEmpty) {
    throw StateError('Music release target requires a release id');
  }
  return CatalogEntityRef(
    kind: CatalogMediaKind.music,
    entityType: musicReleaseEntityType,
    id: normalizedReleaseId,
    rootId: rootRef.id,
  );
}
