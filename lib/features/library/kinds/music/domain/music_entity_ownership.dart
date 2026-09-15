import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

const musicReleaseEntityType = CatalogEntityTypeId('release');

/// Returns whether [ref] identifies one concrete Music release.
///
/// Music's collection anchor may remain the release-group root for structural
/// collection lookups, but an owned copy must also retain this exact release
/// target. A release target needs its root so it cannot be accidentally moved
/// between release groups.
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

/// Validates the two references that make up a Music owned copy.
///
/// [catalogRef] is the structural collection anchor and may be either the
/// root or a nested Music target. [releaseRef] is the canonical ownership
/// relationship and must point into the same root.
void requireMusicOwnedReleaseLink({
  required CatalogEntityRef catalogRef,
  required CatalogEntityRef? releaseRef,
}) {
  if (catalogRef.mediaKind != CatalogMediaKind.music || !catalogRef.isKnown) {
    throw StateError('Music owned copy requires a known Music catalogRef');
  }
  requireMusicReleaseRef(releaseRef, label: 'Music owned copy targetRef');
  final rootId = catalogRef.rootScope.id;
  if (releaseRef!.rootScope.id != rootId) {
    throw StateError(
      'Music owned copy targetRef must belong to catalogRef root "$rootId"',
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
