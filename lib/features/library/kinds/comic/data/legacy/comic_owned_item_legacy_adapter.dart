import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';

/// Compatibility boundary while global collection persistence is migrated.
///
/// The adapter is the only Comic-owned code that translates the old common
/// aggregate. New Comic code should consume [ComicOwnedItem] directly.
final class ComicOwnedItemLegacyAdapter {
  const ComicOwnedItemLegacyAdapter._();

  static ComicOwnedItem fromLegacy(OwnedItem item) {
    final details = item.details;
    if (item.catalogRef.mediaKind != CatalogMediaKind.comic ||
        details is! ComicOwnedDetails) {
      throw ArgumentError.value(item, 'item', 'Expected a Comic owned item');
    }
    return ComicOwnedItem(
      id: ComicOwnedItemId(item.id),
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
      reading: ComicReadingState(
        rating: item.rating,
        status: item.readStatus,
        startedAt: item.startedAt,
        finishedAt: item.finishedAt,
      ),
    );
  }

  static OwnedItem<ComicOwnedDetails> toLegacy(ComicOwnedItem item) {
    return OwnedItem<ComicOwnedDetails>(
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
      rating: item.reading.rating,
      readStatus: item.reading.status,
      startedAt: item.reading.startedAt,
      finishedAt: item.reading.finishedAt,
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
