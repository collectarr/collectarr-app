import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';

/// Projects the generic collection read model into BoardGame's typed model.
final class BoardGameOwnedItemProjection {
  const BoardGameOwnedItemProjection._();

  static BoardGameOwnedItem fromOwnedItem(OwnedItem item) {
    final details = item.details;
    if (item.catalogRef.mediaKind != CatalogMediaKind.boardgame ||
        details is! BoardgameOwnedDetails) {
      throw ArgumentError.value(
          item, 'item', 'Expected a BoardGame owned item');
    }
    return BoardGameOwnedItem(
      id: BoardGameOwnedItemId(item.id),
      catalogRef: item.catalogRef,
      createdAt: item.createdAt,
      isDigital: item.isDigital,
      anchor: item.anchor,
      condition: item.condition,
      grade: item.grade,
      purchaseDate: item.purchaseDate,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      personalNotes: item.personalNotes,
      quantity: item.quantity,
      indexNumber: item.indexNumber,
      tags: item.tags,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      soldAt: item.soldAt,
      sellPriceCents: item.sellPriceCents,
      soldTo: item.soldTo,
      ownerUserId: item.ownerUserId,
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      purchaseStore: item.purchaseStore,
      collectionStatus: item.collectionStatus,
      marketValueCents: item.marketValueCents,
      details: details,
    );
  }

  static BoardGameOwnedItem? tryFromOwnedItem(OwnedItem? item) {
    if (item == null ||
        item.catalogRef.mediaKind != CatalogMediaKind.boardgame ||
        item.details is! BoardgameOwnedDetails) {
      return null;
    }
    return fromOwnedItem(item);
  }

  static OwnedItem<BoardgameOwnedDetails> toOwnedItem(BoardGameOwnedItem item) {
    return OwnedItem<BoardgameOwnedDetails>(
      id: item.id.value,
      catalogRef: item.catalogRef,
      createdAt: item.createdAt,
      isDigital: item.isDigital,
      anchor: item.anchor,
      condition: item.condition,
      grade: item.grade,
      purchaseDate: item.purchaseDate,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      personalNotes: item.personalNotes,
      quantity: item.quantity,
      indexNumber: item.indexNumber,
      tags: item.tags,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      soldAt: item.soldAt,
      sellPriceCents: item.sellPriceCents,
      soldTo: item.soldTo,
      ownerUserId: item.ownerUserId,
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      purchaseStore: item.purchaseStore,
      collectionStatus: item.collectionStatus,
      marketValueCents: item.marketValueCents,
      details: item.details,
    );
  }
}
