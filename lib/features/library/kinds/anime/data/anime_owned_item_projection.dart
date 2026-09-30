import 'package:collectarr_app/core/models/money.dart' show OwnedCopyId;
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

/// Projects Anime's typed owned model into structural collection summaries.
final class AnimeOwnedItemProjection {
  const AnimeOwnedItemProjection._();

  static AnimeOwnedItem? fromDispatch(LibraryOwnedItemDispatch? dispatch) {
    final value = dispatch?.value;
    return value is AnimeOwnedItem ? value : null;
  }

  static OwnedCopySummary toSummary(AnimeOwnedItem item) {
    return OwnedCopySummary(
      ref: OwnedCopyRef(
        kind: item.catalogRef.mediaKind,
        itemId: item.catalogRef.rootScope.id,
        id: OwnedCopyId(item.id.value),
      ),
      catalogRef: item.catalogRef,
      targetRef: item.targetRef,
      isDigital: item.isDigital,
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
