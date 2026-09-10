import 'package:collectarr_app/core/models/money.dart' show OwnedItemId;
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';

/// Projects Movie's typed owned model into structural collection summaries.
final class MovieOwnedItemProjection {
  const MovieOwnedItemProjection._();

  static MovieOwnedItem? tryFromTyped(Object? item) {
    return item is MovieOwnedItem ? item : null;
  }

  static OwnedItemSummary toSummary(MovieOwnedItem item) {
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
