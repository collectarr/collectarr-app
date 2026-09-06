import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';

/// Compatibility boundary while Anime ownership callers leave the common cache.
final class AnimeOwnedItemLegacyAdapter {
  const AnimeOwnedItemLegacyAdapter._();

  static AnimeOwnedItem fromLegacy(OwnedItem item) {
    final details = item.details;
    if (item.catalogRef.mediaKind != CatalogMediaKind.anime ||
        details is! AnimeOwnedDetails) {
      throw ArgumentError.value(item, 'item', 'Expected an Anime owned item');
    }
    return AnimeOwnedItem(
      id: AnimeOwnedItemId(item.id),
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

  static AnimeOwnedItem? tryFromLegacy(OwnedItem? item) {
    if (item == null ||
        item.catalogRef.mediaKind != CatalogMediaKind.anime ||
        item.details is! AnimeOwnedDetails) {
      return null;
    }
    return fromLegacy(item);
  }

  static OwnedItem<AnimeOwnedDetails> toLegacy(AnimeOwnedItem item) {
    return OwnedItem<AnimeOwnedDetails>(
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
