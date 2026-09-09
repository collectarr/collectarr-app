import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// Resolves a library UI reference directly to the structural catalog target
/// used by global features such as Wishlist.
///
/// This intentionally does not pass through [PersonalItemAnchor]. Owned and
/// tracking flows still have their own legacy selection contracts until their
/// typed migrations land; Wishlist only needs the target reference.
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
