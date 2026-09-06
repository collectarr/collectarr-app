import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

class LibraryToolbarStatsCalculator {
  const LibraryToolbarStatsCalculator();

  LibraryToolbarCounts calculate({
    required List<LibraryProjectionItem> allItems,
    required int shownCount,
    required LibraryKindRuntime type,
  }) {
    var owned = 0;
    var wishlist = 0;
    var missingCover = 0;
    var missingMetadata = 0;
    var totalPricePaid = 0;
    var totalSellPrice = 0;
    String? currency;

    for (final item in allItems) {
      final dto = item.dto;

      if (item.source.isOwned) {
        owned += 1;
      }
      if (item.source.isWishlisted) {
        wishlist += 1;
      }
      if (dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty) {
        missingCover += 1;
      }
      final financial = type.stats.buildOwnedFinancialSummary(item.source);
      totalPricePaid += financial.pricePaidCents ?? 0;
      totalSellPrice += financial.sellPriceCents ?? 0;
      currency ??= financial.currency;
    }

    return LibraryToolbarCounts(
      shown: shownCount,
      total: allItems.length,
      owned: owned,
      wishlist: wishlist,
      missingCover: missingCover,
      missingMetadata: missingMetadata,
      totalPricePaidCents: totalPricePaid,
      totalSellPriceCents: totalSellPrice,
      priceCurrency: currency,
      collectionValue: type.value?.resolveCollectionValueSummary(
        allItems.map((item) => item.source),
      ),
    );
  }
}
