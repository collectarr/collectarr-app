import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';

/// Projects the generic collection read model into Comic's typed owned model.
final class ComicOwnedItemProjection {
  const ComicOwnedItemProjection._();

  static ComicOwnedItem fromOwnedItem(OwnedItem item) {
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

  /// Returns a typed Comic copy only when the legacy value is actually Comic.
  ///
  /// Generic shelf/inspector capabilities can receive entries for other kinds
  /// while the common persistence bridge is still active, so those callers
  /// must not turn an unrelated owned item into a Comic value.
  static ComicOwnedItem? tryFromOwnedItem(OwnedItem? item) {
    if (item == null ||
        item.catalogRef.mediaKind != CatalogMediaKind.comic ||
        item.details is! ComicOwnedDetails) {
      return null;
    }
    return fromOwnedItem(item);
  }

  static OwnedItem<ComicOwnedDetails> toOwnedItem(ComicOwnedItem item) {
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
