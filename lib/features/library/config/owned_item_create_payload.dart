import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';

/// Structural behavior contract for a kind-owned Owned create payload.
///
/// The payload implementation owns every personal-copy field and translates
/// it to the transitional common cache value at the legacy persistence edge.
/// Generic collection code can invoke the behavior without reading any kind
/// field or inspecting the concrete payload.
abstract interface class OwnedItemCreatePayload {
  CatalogEntityRef get catalogRef;

  OwnedItem toLegacyOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required CatalogItem? existingCatalog,
    required PersonalItemAnchor? anchor,
    required String? ownerUserId,
    required String? ownerLabel,
  });
}
