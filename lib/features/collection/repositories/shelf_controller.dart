import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/library_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final owned = await ref.watch(collectionProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final ids = {
    for (final item in owned) item.itemId,
    for (final item in wishlist) item.itemId,
  };
  final catalogItems =
      await CatalogCacheRepository(ref.watch(localDatabaseProvider))
          .findByIds(ids);
  return ShelfState.from(
    ownedItems: owned,
    wishlistItems: wishlist,
    catalogItems: catalogItems,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
    required this.ownedCount,
    required this.wishlistCount,
    required this.missingGradeCount,
    required this.pricedCount,
    required this.totalPaidCents,
    required this.primaryCurrency,
    required this.hasMixedCurrencies,
    this.totalQuantity = 0,
    this.keyComicCount = 0,
    this.missingMetadataCount = 0,
    this.gradeCounts = const {},
    this.conditionCounts = const {},
    this.readStatusCounts = const {},
    this.storageBoxCounts = const {},
    this.seriesCounts = const {},
    this.soldCount = 0,
    this.totalSellCents,
  });

  factory ShelfState.from({
    required List<OwnedItem> ownedItems,
    required List<WishlistItem> wishlistItems,
    required Map<String, CatalogItem> catalogItems,
  }) {
    final ownedByItemId = {
      for (final item in ownedItems)
        if (!item.isDeleted) item.itemId: item,
    };
    final wishlistByItemId = {
      for (final item in wishlistItems)
        if (!item.isDeleted) item.itemId: item,
    };
    final ids = {
      ...ownedByItemId.keys,
      ...wishlistByItemId.keys,
    };
    final entries = [
      for (final id in ids)
        ShelfEntry(
          itemId: id,
          catalogItem: catalogItems[id],
          ownedItem: ownedByItemId[id],
          wishlistItem: wishlistByItemId[id],
        ),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final pricedOwned = ownedItems
        .where((item) => item.pricePaidCents != null && item.currency != null)
        .toList(growable: false);
    final currencies = {
      for (final item in pricedOwned) item.currency!,
    };
    final hasMixedCurrencies = currencies.length > 1;
    final activeOwned = ownedByItemId.values.toList(growable: false);
    return ShelfState(
      entries: entries,
      ownedCount: ownedByItemId.length,
      wishlistCount: wishlistByItemId.length,
      missingGradeCount:
          ownedByItemId.values.where((item) => item.grade == null).length,
      pricedCount: pricedOwned.length,
      totalPaidCents: hasMixedCurrencies
          ? null
          : pricedOwned.fold<int>(
              0,
              (total, item) => total + (item.pricePaidCents ?? 0),
            ),
      primaryCurrency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: hasMixedCurrencies,
      totalQuantity: activeOwned.fold<int>(
        0,
        (total, item) => total + item.quantity,
      ),
      keyComicCount: activeOwned.where((item) => item.keyComic).length,
      missingMetadataCount:
          entries.where((entry) => entry.catalogItem == null).length,
      gradeCounts: _counts(activeOwned.map((item) => item.grade ?? 'Ungraded')),
      conditionCounts: _counts(
        activeOwned.map((item) => item.condition ?? 'Unknown'),
      ),
      readStatusCounts: _counts(
        activeOwned.map((item) => item.readStatus ?? 'Unknown'),
      ),
      storageBoxCounts: _counts(
        activeOwned.map((item) => item.storageBox ?? 'No box'),
      ),
      seriesCounts: _counts(
        entries
            .map((entry) => entry.catalogItem?.title)
            .whereType<String>()
            .where((title) => title.trim().isNotEmpty),
      ),
      soldCount: activeOwned.where((item) => item.isSold).length,
      totalSellCents: hasMixedCurrencies
          ? null
          : activeOwned
              .where((item) => item.sellPriceCents != null)
              .fold<int>(0, (total, item) => total + item.sellPriceCents!),
    );
  }

  final List<ShelfEntry> entries;
  final int ownedCount;
  final int wishlistCount;
  final int missingGradeCount;
  final int pricedCount;
  final int? totalPaidCents;
  final String? primaryCurrency;
  final bool hasMixedCurrencies;
  final int totalQuantity;
  final int keyComicCount;
  final int missingMetadataCount;
  final Map<String, int> gradeCounts;
  final Map<String, int> conditionCounts;
  final Map<String, int> readStatusCounts;
  final Map<String, int> storageBoxCounts;
  final Map<String, int> seriesCounts;
  final int soldCount;
  final int? totalSellCents;

  static Map<String, int> _counts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }
}

class ShelfEntry extends LibraryEntry {
  const ShelfEntry({
    required super.itemId,
    super.catalogItem,
    super.ownedItem,
    super.wishlistItem,
  });
}
