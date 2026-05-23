import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryAddDefaults {
  const LibraryAddDefaults({
    this.condition,
    this.grade,
    this.purchaseDate,
    this.locationId,
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final String? locationId;
  final String? readStatus;
  final String? tags;
}

class LibraryAddOwnedDetails {
  const LibraryAddOwnedDetails({
    this.editionId,
    this.variantId,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.locationId,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.keyComic = false,
    this.keyReason,
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
  });

  final String? editionId;
  final String? variantId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? locationId;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
}

Future<void> addLibraryItemsToTarget({
  required CatalogCacheRepository catalog,
  required CollectionMutations mutations,
  required Iterable<LibraryMetadataItem> items,
  required LibraryAddTarget target,
  LibraryAddDefaults defaults = const LibraryAddDefaults(),
  Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId = const {},
}) async {
  final values = items.toList(growable: false);
  if (values.isEmpty) {
    return;
  }

  final catalogItems = [for (final item in values) item.toCatalogItem()];

  await catalog.upsertAll(catalogItems);
  for (final item in values) {
    final ownedDetails = ownedDetailsByItemId[item.id];
    switch (target) {
      case LibraryAddTarget.owned:
        final ownedItem = await mutations.addItem(
          item.id,
          editionId: ownedDetails?.editionId,
          variantId: ownedDetails?.variantId,
          condition: ownedDetails?.condition ?? defaults.condition,
          grade: ownedDetails?.grade ?? defaults.grade,
          purchaseDate: ownedDetails?.purchaseDate ?? defaults.purchaseDate,
          pricePaidCents: ownedDetails?.pricePaidCents,
          currency: ownedDetails?.currency,
          personalNotes: ownedDetails?.personalNotes,
          quantity: ownedDetails?.quantity ?? 1,
          locationId: ownedDetails?.locationId ?? defaults.locationId,
          coverPriceCents: ownedDetails?.coverPriceCents,
          rawOrSlabbed: ownedDetails?.rawOrSlabbed,
          gradingCompany: ownedDetails?.gradingCompany,
          graderNotes: ownedDetails?.graderNotes,
          signedBy: ownedDetails?.signedBy,
          keyComic: ownedDetails?.keyComic ?? false,
          keyReason: ownedDetails?.keyReason,
          rating: ownedDetails?.rating,
          readStatus: ownedDetails?.readStatus ?? defaults.readStatus,
          startedAt: ownedDetails?.startedAt,
          finishedAt: ownedDetails?.finishedAt,
          tags: ownedDetails?.tags ?? defaults.tags,
          soldAt: ownedDetails?.soldAt,
          sellPriceCents: ownedDetails?.sellPriceCents,
          soldTo: ownedDetails?.soldTo,
          syncTracking: false,
          notify: false,
        );
        await mutations.syncOwnedTrackingEntry(
          ownedItem,
          editionId: ownedDetails?.editionId,
          variantId: ownedDetails?.variantId,
          status: ownedDetails?.readStatus ?? defaults.readStatus,
          rating: ownedDetails?.rating,
          startedAt: ownedDetails?.startedAt,
          finishedAt: ownedDetails?.finishedAt,
        );
        break;
      case LibraryAddTarget.wishlist:
        await mutations.addToWishlist(item.id);
        break;
    }
  }
}
