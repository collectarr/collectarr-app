import 'package:collectarr_app/core/models/money.dart' show OwnedCopyId;
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

/// Projects Music's typed owned model into structural collection summaries.
final class MusicOwnedItemProjection {
  const MusicOwnedItemProjection._();

  static MusicOwnedItem? fromDispatch(LibraryOwnedItemDispatch? dispatch) {
    final value = dispatch?.value;
    return value is MusicOwnedItem ? value : null;
  }

  static OwnedCopySummary toSummary(MusicOwnedItem item) {
    return OwnedCopySummary(
      ref: OwnedCopyRef(
        kind: item.catalogRef.mediaKind,
        itemId: item.catalogRef.rootScope.id,
        id: OwnedCopyId(item.id.value),
      ),
      catalogRef: item.catalogRef,
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
