import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
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

final wishlistIdsProvider = FutureProvider<Set<String>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  final items = await cache.listActive();
  return {
    for (final item in items)
      if (!item.isDeleted) item.itemId,
  };
});
