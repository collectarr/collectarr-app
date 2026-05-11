import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
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
    await _enqueueOwnedItem(ownedItem, 'upsert', now);
    final wishlistItem = await _wishlistCache().findActiveByItemId(itemId);
    if (wishlistItem != null) {
      await _wishlistCache().markDeleted(wishlistItem, now);
      await _enqueueWishlistItem(
        wishlistItem.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
      ref.invalidate(wishlistIdsProvider);
    }
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
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
    await _enqueueOwnedItem(updated, 'upsert', now);
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(collectionProvider);
  }

  Future<void> removeItem(OwnedItem item) async {
    final now = DateTime.now().toUtc();
    await _ownedCache().markDeleted(item, now);
    await _enqueueOwnedItem(
        item.copyWith(updatedAt: now, deletedAt: now), 'delete', now);
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(collectionProvider);
  }

  Future<void> addToWishlist(String itemId) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing == null) {
      final item = WishlistItem(
        id: _uuid.v4(),
        itemId: itemId,
        createdAt: now,
        updatedAt: now,
      );
      await _wishlistCache().upsert(item);
      await _enqueueWishlistItem(item, 'upsert', now);
    }
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(wishlistIdsProvider);
  }

  Future<void> removeFromWishlist(String itemId) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing != null) {
      await _wishlistCache().markDeleted(existing, now);
      await _enqueueWishlistItem(
        existing.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
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

  SyncQueueRepository _syncQueue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }

  Future<void> _enqueueOwnedItem(
      OwnedItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'owned_item',
        entityId: item.id,
        action: action,
        payload: _ownedPayload(item),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueWishlistItem(
      WishlistItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'wishlist_item',
        entityId: item.id,
        action: action,
        payload: _wishlistPayload(item),
        clientChangedAt: changedAt,
      ),
    );
  }

  Map<String, dynamic> _ownedPayload(OwnedItem item) {
    return {
      'item_id': item.itemId,
      'edition_id': item.editionId,
      'variant_id': item.variantId,
      'condition': item.condition,
      'grade': item.grade,
      'purchase_date': item.purchaseDate?.toUtc().toIso8601String(),
      'price_paid_cents': item.pricePaidCents,
      'currency': item.currency,
      'personal_notes': item.personalNotes,
    };
  }

  Map<String, dynamic> _wishlistPayload(WishlistItem item) {
    return {
      'item_id': item.itemId,
      'edition_id': item.editionId,
      'variant_id': item.variantId,
      'target_price_cents': item.targetPriceCents,
      'currency': item.currency,
      'notes': item.notes,
      'created_at': item.createdAt.toUtc().toIso8601String(),
    };
  }
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});
