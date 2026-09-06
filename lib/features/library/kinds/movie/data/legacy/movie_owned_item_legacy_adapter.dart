import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';

/// Compatibility boundary while Movie ownership callers leave the common cache.
final class MovieOwnedItemLegacyAdapter {
  const MovieOwnedItemLegacyAdapter._();

  static MovieOwnedItem fromLegacy(OwnedItem item) {
    final details = item.details;
    if (item.catalogRef.mediaKind != CatalogMediaKind.movie ||
        details is! MovieOwnedDetails) {
      throw ArgumentError.value(item, 'item', 'Expected a Movie owned item');
    }
    return MovieOwnedItem(
      id: MovieOwnedItemId(item.id),
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

  static MovieOwnedItem? tryFromLegacy(OwnedItem? item) {
    if (item == null ||
        item.catalogRef.mediaKind != CatalogMediaKind.movie ||
        item.details is! MovieOwnedDetails) {
      return null;
    }
    return fromLegacy(item);
  }

  static OwnedItem<MovieOwnedDetails> toLegacy(MovieOwnedItem item) {
    return OwnedItem<MovieOwnedDetails>(
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
