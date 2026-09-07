import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// Resolves a library UI reference directly to the structural catalog target
/// used by global features such as Wishlist.
///
/// This intentionally does not pass through [PersonalItemAnchor]. Owned and
/// tracking flows still have their own legacy selection contracts until their
/// typed migrations land; Wishlist only needs the target reference.
CatalogEntityRef catalogRefForLibrarySelection(
  CatalogItemDto item, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final bundleId = _normalized(bundleReleaseId);
  if (bundleId != null) {
    return CatalogEntityRef(
      kind: item.kind,
      entityType: CatalogEntityType.bundleRelease,
      id: bundleId,
      rootId: item.id,
    );
  }

  final variant = _normalized(variantId);
  if (variant != null) {
    return CatalogEntityRef(
      kind: item.kind,
      entityType: CatalogEntityType.release,
      id: variant,
      rootId: item.id,
    );
  }

  final edition = _normalized(editionId);
  if (edition != null) {
    return CatalogEntityRef(
      kind: item.kind,
      entityType: CatalogEntityType.edition,
      id: edition,
      rootId: item.id,
    );
  }

  return item.catalogRef;
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
