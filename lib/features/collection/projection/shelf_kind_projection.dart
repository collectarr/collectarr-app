import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

extension ShelfKindProjection on ShelfState {
  ShelfState forKind(CatalogMediaKind kind) {
    final shelf = this;
    final entries = shelf.entries
        .where((entry) => entry.mediaKind == kind)
        .toList(growable: false);
    final owned = entries
        .where((entry) => entry.isEntry && entry.libraryEntrySummary != null)
        .map((entry) => entry.libraryEntrySummary!)
        .toList(growable: false);
    final paid = owned
        .where(
            (entry) => entry.pricePaidCents != null && entry.currency != null)
        .toList(growable: false);
    final currencies = paid.map((entry) => entry.currency!).toSet();
    final mixedCurrencies = currencies.length > 1;
    final active = owned.where((entry) => !entry.isDeleted).toList();
    final kindKey = kind.apiValue;
    final locationCounts = <String, int>{};
    for (final entry in entries.where((entry) => entry.isEntry)) {
      final label = entry.locationPath ?? 'No location';
      locationCounts.update(label, (count) => count + 1, ifAbsent: () => 1);
    }
    return ShelfState(
      entries: entries,
      entryCount: active.length,
      wishlistCount: entries.where((entry) => entry.isWishlisted).length,
      pricedCount: paid.length,
      totalPaidCents: mixedCurrencies
          ? null
          : paid.fold<int>(0, (total, entry) => total + entry.pricePaidCents!),
      primaryCurrency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: mixedCurrencies,
      wishlistItemCountByKind: {
        kindKey: entries.where((entry) => entry.isWishlisted).length,
      },
      missingMetadataCount:
          entries.where((entry) => entry.catalogSummary == null).length,
      locationCounts: locationCounts,
      soldCount: active.where((entry) => entry.soldAt != null).length,
      totalSellCents: mixedCurrencies
          ? null
          : active
              .where((entry) => entry.sellPriceCents != null)
              .fold<int>(0, (total, entry) => total + entry.sellPriceCents!),
      marketValuedCount:
          active.where((entry) => entry.marketValueCents != null).length,
      totalMarketValueCents: mixedCurrencies
          ? null
          : active
              .where((entry) => entry.marketValueCents != null)
              .fold<int>(0, (total, entry) => total + entry.marketValueCents!),
      libraryEntryCountByKind: {kindKey: active.length},
    );
  }
}
