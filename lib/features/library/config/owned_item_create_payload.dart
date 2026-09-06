import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';

/// Structural behavior contract for a kind-owned Owned create payload.
///
/// The payload implementation owns every personal-copy field and translates
/// it at the persistence boundary.
/// Generic collection code can invoke the behavior without reading any kind
/// field or inspecting the concrete payload.
abstract interface class OwnedItemCreatePayload {
  CatalogEntityRef get catalogRef;
  OwnedDetailsDraft get detailsDraft;

  OwnedItem toOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required CatalogItem? existingCatalog,
    required PersonalItemAnchor? anchor,
    required String? ownerUserId,
    required String? ownerLabel,
  });
}
