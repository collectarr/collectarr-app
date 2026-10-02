import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';

/// Projects BoardGame's typed owned model into structural collection summaries.
final class BoardGameCollectionItemProjection {
  const BoardGameCollectionItemProjection._();

  static BoardGameCollectionItem? fromDispatch(
      LibraryCollectionItemDispatch? dispatch) {
    final value = dispatch?.value;
    return value is BoardGameCollectionItem ? value : null;
  }

  static CollectionItemSummary toSummary(BoardGameCollectionItem item) {
    return CollectionItemSummary(
      ref: CollectionItemRef(
        kind: item.catalogRef.mediaKind,
        id: CollectionItemId(item.id.value),
      ),
      catalogRef: item.catalogRef,
      isDigital: item.isDigital,
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
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      locationLabel: item.locationId,
      notes: item.personalNotes,
      hasNotes: item.personalNotes?.trim().isNotEmpty == true,
    );
  }
}
