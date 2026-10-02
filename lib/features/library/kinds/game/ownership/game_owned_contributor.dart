import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_collection_item_update_payload.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor.dart';

final gameOwnedContributor = TypedOwnedKindContributor<GameCollectionItem>(
  kind: CatalogMediaKind.game,
  findById: (database, id) =>
      GameOwnedRepository(database).findById(CollectionItemId(id)),
  upsert: (database, item) => GameOwnedRepository(database).upsert(item),
  listActive: (database) => GameOwnedRepository(database).listActive(),
  createItem: ({
    required payload,
    required resolvedCatalogRef,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! GameCollectionItemCreatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    return payload.toCollectionItem(
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
    if (payload is! GameCollectionItemUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Owned update payload does not belong to game');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: GameCollectionItem.fromJson,
  summary: GameCollectionItemProjection.toSummary,
  createPayload: GameCollectionItemCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(locationId: locationId),
);
