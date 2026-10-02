import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_collection_item_update_payload.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor.dart';

final comicOwnedContributor = TypedOwnedKindContributor<ComicCollectionItem>(
  kind: CatalogMediaKind.comic,
  findById: (database, id) =>
      ComicOwnedRepository(database).findById(CollectionItemId(id)),
  upsert: (database, item) => ComicOwnedRepository(database).upsert(item),
  listActive: (database) => ComicOwnedRepository(database).listActive(),
  createItem: ({
    required payload,
    required resolvedCatalogRef,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! ComicCollectionItemCreatePayload) {
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
    if (payload is! ComicCollectionItemUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Owned update payload does not belong to comic');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: ComicCollectionItem.fromJson,
  summary: ComicCollectionItemProjection.toSummary,
  createPayload: ComicCollectionItemCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(locationId: locationId),
);
