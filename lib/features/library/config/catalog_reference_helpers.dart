import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// Resolves a library UI reference directly to the structural catalog target
/// used by global features such as Wishlist.
///
/// This intentionally works directly with structural catalog targets. Owned
/// and tracking flows retain v1 field names only at persistence boundaries.
CatalogEntityRef catalogRefForLibrarySelection(
  CatalogEntityRef itemRef, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final bundleId = _normalized(bundleReleaseId);
  if (bundleId != null) {
    return CatalogEntityRef(
      kind: itemRef.kind,
      entityType: const CatalogEntityTypeId('bundle_release'),
      id: bundleId,
      rootId: itemRef.id,
    );
  }

  final edition = _normalized(editionId);
  final variant = _normalized(variantId);
  if (variant != null) {
    return CatalogEntityRef(
      kind: itemRef.kind,
      entityType: const CatalogEntityTypeId('release'),
      id: variant,
      rootId: itemRef.id,
      parentId: edition,
    );
  }

  if (edition != null) {
    return CatalogEntityRef(
      kind: itemRef.kind,
      entityType: const CatalogEntityTypeId('edition'),
      id: edition,
      rootId: itemRef.id,
    );
  }

  return itemRef;
}

/// Builds a typed Owned target from the structural selection values used by
/// the edit UI. The owning kind supplies [kind]; the returned reference is
/// the only value that crosses into the typed Owned update payload.
CatalogEntityRef? catalogRefForOwnedSelection(
  CatalogMediaKind kind, {
  required String anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final normalizedType = anchorType.trim().toLowerCase();
  return switch (normalizedType) {
    'edition' => editionId == null || editionId.trim().isEmpty
        ? null
        : CatalogEntityRef(
            kind: kind,
            entityType: const CatalogEntityTypeId('edition'),
            id: editionId,
          ),
    'variant' => variantId == null || variantId.trim().isEmpty
        ? null
        : CatalogEntityRef(
            kind: kind,
            entityType: const CatalogEntityTypeId('release'),
            id: variantId,
            parentId: editionId,
          ),
    'bundle_release' =>
      bundleReleaseId == null || bundleReleaseId.trim().isEmpty
          ? null
          : CatalogEntityRef(
              kind: kind,
              entityType: const CatalogEntityTypeId('bundle_release'),
              id: bundleReleaseId,
            ),
    _ => null,
  };
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Returns the edition component of a structural catalog target.
String? catalogRefEditionId(CatalogEntityRef? ref) {
  return switch (ref?.entityType.apiValue) {
    'edition' => ref?.id,
    'release' => ref?.parentId,
    _ => null,
  };
}

/// Returns the physical-release component of a structural catalog target.
String? catalogRefVariantId(CatalogEntityRef? ref) {
  return ref?.entityType.apiValue == 'release' ? ref?.id : null;
}

/// Returns the bundle-release component of a structural catalog target.
String? catalogRefBundleReleaseId(CatalogEntityRef? ref) {
  return ref?.entityType.apiValue == 'bundle_release' ? ref?.id : null;
}
