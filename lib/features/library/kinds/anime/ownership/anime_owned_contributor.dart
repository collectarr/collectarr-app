import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor.dart';

final animeOwnedContributor = TypedOwnedKindContributor<AnimeOwnedItem>(
  kind: CatalogMediaKind.anime,
  findById: (database, id) =>
      AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id)),
  upsert: (database, item) => AnimeOwnedRepository(database).upsert(item),
  listActive: (database) => AnimeOwnedRepository(database).listActive(),
  createItem: ({
    required payload,
    required resolvedCatalogRef,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! AnimeOwnedItemCreatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    return payload.toOwnedItem(
      resolvedCatalogRef: resolvedCatalogRef,
      id: id,
      createdAt: createdAt,
      existingIsDigital: existingIsDigital,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
    );
  },
  updateItem: ({
    required existing,
    required payload,
    required updatedAt,
    required fallbackOwnerUserId,
    required fallbackOwnerLabel,
  }) {
    if (existing is! AnimeOwnedItem ||
        payload is! AnimeOwnedItemUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Owned update payload does not belong to anime');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: AnimeOwnedItem.fromJson,
  summary: AnimeOwnedItemProjection.toSummary,
  createPayload: AnimeOwnedItemCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(locationId: locationId),
);
