import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final owned = await ref.watch(collectionProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final trackingEntries = await ref.watch(trackingEntriesProvider.future);
  final auth = ref.watch(authControllerProvider);
  final db = ref.watch(localDatabaseProvider);
  final ids = {
    for (final item in owned) item.catalogRef.id,
    for (final item in wishlist) item.catalogRef.id,
    for (final item in trackingEntries) item.catalogRef.id,
  };
  final catalogItems = await LibraryCatalogRepository(db).findByIds(ids);
  final libraryCatalogItems = {
    for (final entry in catalogItems.entries)
      entry.key: typedCatalogItemFromCatalogItem(entry.value),
  };
  final locations = await LocationRepository(db).getAll();
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  ).listActiveByItemIds(ids);
  final itemImagesByOwnedItem =
      await ItemImageRepository(db).listForOwnedItemIds(
    owned.map((item) => item.id),
  );
  return ShelfState.from(
    ownedItems: owned,
    wishlistItems: wishlist,
    trackingEntries: trackingEntries,
    watchSessions: watchSessions,
    catalogItems: libraryCatalogItems,
    locations: locations,
    itemImagesByOwnedItem: itemImagesByOwnedItem,
    fallbackOwnerLabel: auth.email,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
    required this.ownedCount,
    required this.missingGradeCount,
    required this.wishlistCount,
    required this.pricedCount,
    required this.totalPaidCents,
    required this.primaryCurrency,
    required this.hasMixedCurrencies,
    this.totalQuantity = 0,
    this.missingMetadataCount = 0,
    this.gradeCounts = const {},
    this.conditionCounts = const {},
    this.readStatusCounts = const {},
    this.locationCounts = const {},
    this.seriesCounts = const {},
    this.soldCount = 0,
    this.totalSellCents,
    this.marketValuedCount = 0,
    this.totalMarketValueCents,
  });

  factory ShelfState.from({
    required List<OwnedItem> ownedItems,
    required List<WishlistItem> wishlistItems,
    List<TrackingEntry> trackingEntries = const [],
    List<WatchSession> watchSessions = const [],
    required Map<String, dynamic> catalogItems,
    List<StorageLocation> locations = const [],
    Map<String, List<ItemImage>> itemImagesByOwnedItem =
        const <String, List<ItemImage>>{},
    String? fallbackOwnerLabel,
  }) {
    final locationPathsById = {
      for (final location in locations)
        location.id: location.fullPath(locations),
    };
    final ownedByItemId = {
      for (final item in ownedItems)
        if (!item.isDeleted) item.catalogRef.id: item,
    };
    final wishlistByItemId = {
      for (final item in wishlistItems)
        if (!item.isDeleted) item.catalogRef.id: item,
    };
    final trackingByItemId = <String, TrackingEntry>{};
    for (final entry in trackingEntries) {
      if (entry.isDeleted ||
          trackingByItemId.containsKey(entry.catalogRef.id)) {
        continue;
      }
      trackingByItemId[entry.catalogRef.id] = entry;
    }
    final watchSessionsByItemId = <String, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      watchSessionsByItemId
          .putIfAbsent(session.itemId, () => <WatchSession>[])
          .add(session);
    }
    for (final sessions in watchSessionsByItemId.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    final ids = {
      ...ownedByItemId.keys,
      ...wishlistByItemId.keys,
      ...trackingByItemId.keys,
    };
    final entries = [
      for (final id in ids)
        ShelfEntry(
          itemId: id,
          catalogItem: () {
            return typedCatalogItemFromUnknown(catalogItems[id]);
          }(),
          ownedItem: ownedByItemId[id],
          trackingEntry: trackingByItemId[id],
          wishlistItem: wishlistByItemId[id],
          locationPath: locationPathsById[ownedByItemId[id]?.locationId],
          watchSessions: watchSessionsByItemId[id] ?? const <WatchSession>[],
          itemImages: itemImagesByOwnedItem[ownedByItemId[id]?.id] ??
              const <ItemImage>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
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
      missingGradeCount:
          ownedByItemId.values.where((item) => item.grade == null).length,
      wishlistCount: wishlistByItemId.length,
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
      missingMetadataCount:
          entries.where((entry) => entry.catalogItem == null).length,
      gradeCounts: _counts(activeOwned.map((item) => item.grade ?? 'Ungraded')),
      conditionCounts: _counts(
        activeOwned.map((item) => item.condition ?? 'Unknown'),
      ),
      readStatusCounts: _counts(
        entries.map((entry) => entry.tracking.statusLabel),
      ),
      locationCounts: _counts(
        entries
            .where((entry) => entry.isOwned)
            .map((entry) => entry.locationPath ?? 'No location'),
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
      marketValuedCount:
          activeOwned.where((item) => item.marketValueCents != null).length,
      totalMarketValueCents: hasMixedCurrencies
          ? null
          : activeOwned
              .where((item) => item.marketValueCents != null)
              .fold<int>(0, (total, item) => total + item.marketValueCents!),
    );
  }

  final List<ShelfEntry> entries;
  final int ownedCount;

  /// Aggregate projection for the Stats dashboard. Keep kind semantics in
  /// their contributors rather than exposing them as universal Shelf filters.
  final int missingGradeCount;
  final int wishlistCount;
  final int pricedCount;
  final int? totalPaidCents;
  final String? primaryCurrency;
  final bool hasMixedCurrencies;
  final int totalQuantity;
  final int missingMetadataCount;
  final Map<String, int> gradeCounts;
  final Map<String, int> conditionCounts;
  final Map<String, int> readStatusCounts;
  final Map<String, int> locationCounts;
  final Map<String, int> seriesCounts;
  final int soldCount;
  final int? totalSellCents;
  final int marketValuedCount;
  final int? totalMarketValueCents;

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
    super.trackingEntry,
    super.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.fallbackOwnerLabel,
  });

  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final String? fallbackOwnerLabel;

  String? get condition => ownedItem?.condition;
  String? get grade => ownedItem?.grade;
  int? get pricePaidCents => ownedItem?.pricePaidCents;
  int? get marketValueCents => ownedItem?.marketValueCents;
  String? get currency => ownedItem?.currency;
  String? get purchaseStore => ownedItem?.purchaseStore;
  DateTime? get purchaseDate => ownedItem?.purchaseDate;
  String? get personalNotes => ownedItem?.personalNotes;
  String? get tags => ownedItem?.tags;
  List<String> get tagList {
    final raw = ownedItem?.tags?.trim();
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  String? get ownerLabel => ownedItem?.ownerLabel ?? fallbackOwnerLabel;
  int get quantity => ownedItem?.quantity ?? (isOwned ? 1 : 0);
}
