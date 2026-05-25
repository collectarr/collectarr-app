import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionProvider = FutureProvider<List<OwnedItem>>((ref) async {
  final cache = OwnedItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});

final collectionByCatalogItemProvider = Provider<Map<String, OwnedItem>>((ref) {
  final collection = ref.watch(collectionProvider);
  return collection.maybeWhen(
    data: (items) => {
      for (final item in items)
        if (!item.isDeleted) item.itemId: item,
    },
    orElse: () => const {},
  );
});

final trackingEntriesProvider = FutureProvider<List<TrackingEntry>>((ref) async {
  final cache = TrackingEntriesCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});

final trackingEntriesByCatalogItemProvider =
    Provider<Map<String, List<TrackingEntry>>>((ref) {
  final tracking = ref.watch(trackingEntriesProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <String, List<TrackingEntry>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.itemId, () => <TrackingEntry>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const {},
  );
});

final wishlistByCatalogItemProvider =
    Provider<Map<String, List<WishlistItem>>>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.maybeWhen(
    data: (items) {
      final grouped = <String, List<WishlistItem>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.itemId, () => <WishlistItem>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const {},
  );
});

final wishlistIdsProvider = FutureProvider<Set<String>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  final items = await cache.listActive();
  return {
    for (final item in items)
      if (!item.isDeleted) item.itemId,
  };
});

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});
