import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;
  final Uuid _uuid = const Uuid();

  Future<void> addItem(
    String itemId, {
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
  }) async {
    final now = DateTime.now().toUtc();
    final ownedItem = OwnedItem(
      id: _uuid.v4(),
      itemId: itemId,
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      updatedAt: now,
    );
    await _ownedCache().upsert(ownedItem);
    final wishlistItem = await _wishlistCache().findActiveByItemId(itemId);
    if (wishlistItem != null) {
      await _wishlistCache().markDeleted(wishlistItem, now);
      ref.invalidate(wishlistIdsProvider);
    }
    ref.invalidate(collectionProvider);
  }

  Future<void> updateItem(
    OwnedItem item, {
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = item.copyWith(
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      updatedAt: now,
    );
    await _ownedCache().upsert(updated);
    ref.invalidate(collectionProvider);
  }

  Future<void> removeItem(OwnedItem item) async {
    final now = DateTime.now().toUtc();
    await _ownedCache().markDeleted(item, now);
    ref.invalidate(collectionProvider);
  }

  Future<void> addToWishlist(String itemId) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing == null) {
      await _wishlistCache().upsert(
        WishlistItem(
          id: _uuid.v4(),
          itemId: itemId,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    ref.invalidate(wishlistIdsProvider);
  }

  Future<void> removeFromWishlist(String itemId) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing != null) {
      await _wishlistCache().markDeleted(existing, now);
    }
    ref.invalidate(wishlistIdsProvider);
  }

  Future<void> toggleWishlist(String itemId) async {
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing == null) {
      await addToWishlist(itemId);
    } else {
      await removeFromWishlist(itemId);
    }
  }

  OwnedItemsCacheRepository _ownedCache() {
    return OwnedItemsCacheRepository(ref.read(localDatabaseProvider));
  }

  WishlistItemsCacheRepository _wishlistCache() {
    return WishlistItemsCacheRepository(ref.read(localDatabaseProvider));
  }
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});
