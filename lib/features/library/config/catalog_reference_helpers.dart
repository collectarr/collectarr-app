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

String? _normalized(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
