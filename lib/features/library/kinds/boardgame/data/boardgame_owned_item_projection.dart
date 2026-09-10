import 'package:collectarr_app/core/models/money.dart' show OwnedItemId;
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';

/// Projects BoardGame's typed owned model into structural collection summaries.
final class BoardGameOwnedItemProjection {
  const BoardGameOwnedItemProjection._();

  static BoardGameOwnedItem? tryFromTyped(Object? item) {
    return item is BoardGameOwnedItem ? item : null;
  }

  static OwnedItemSummary toSummary(BoardGameOwnedItem item) {
    return OwnedItemSummary(
      ref: OwnedItemRef(
        kind: item.catalogRef.mediaKind,
        id: OwnedItemId(item.id.value),
      ),
      catalogRef: item.catalogRef,
      targetRef: item.targetRef,
      isDigital: item.isDigital,
      collectionValue: item.grade,
      title: item.itemId,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      purchaseDate: item.purchaseDate,
      purchaseStore: item.purchaseStore,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      soldAt: item.soldAt,
      soldTo: item.soldTo,
      sellPriceCents: item.sellPriceCents,
      marketValueCents: item.marketValueCents,
      quantity: item.quantity,
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      locationLabel: item.locationId,
      notes: item.personalNotes,
      hasNotes: item.personalNotes?.trim().isNotEmpty == true,
    );
  }
}
