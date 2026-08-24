import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';

class LibraryToolbarStatsCalculator {
  const LibraryToolbarStatsCalculator();

  LibraryToolbarCounts calculate({
    required List<LibraryProjectionItem> allItems,
    required int shownCount,
  }) {
    var owned = 0;
    var wishlist = 0;
    var missingCover = 0;
    var missingMetadata = 0;
    var totalPricePaid = 0;
    var totalCoverPrice = 0;
    var totalSellPrice = 0;
    String? currency;

    for (final item in allItems) {
      final dto = item.dto;
      final ownedItem = item.source.ownedItem;

      if (item.source.isOwned) {
        owned += 1;
      }
      if (item.source.isWishlisted) {
        wishlist += 1;
      }
      if (dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty) {
        missingCover += 1;
      }
      if (ownedItem != null) {
        totalPricePaid += ownedItem.pricePaidCents ?? 0;
        totalCoverPrice += ownedItem.coverPriceCents ?? 0;
        totalSellPrice += ownedItem.sellPriceCents ?? 0;
        currency ??= ownedItem.currency;
      }
    }

    return LibraryToolbarCounts(
      shown: shownCount,
      total: allItems.length,
      owned: owned,
      wishlist: wishlist,
      missingCover: missingCover,
      missingMetadata: missingMetadata,
      totalPricePaidCents: totalPricePaid,
      totalCoverPriceCents: totalCoverPrice,
      totalSellPriceCents: totalSellPrice,
      priceCurrency: currency,
    );
  }
}
