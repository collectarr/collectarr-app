import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class WishlistMutations {
  const WishlistMutations({
    required this.wishlist,
    required this.catalogCache,
    required this.trackingEntries,
    required this.trackingUnits,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final WishlistItemsCacheRepository wishlist;
  final LibraryCatalogRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final TrackingUnitsCacheRepository trackingUnits;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> addToWishlist(
    CatalogEntityRef catalogRef, {
    PersonalItemAnchor? anchor,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    if (!catalogRef.isKnown ||
        catalogRef.mediaKind == CatalogMediaKind.unknown) {
      throw StateError(
        'Cannot add wishlist item without a registered catalog kind: '
        '${catalogRef.id}',
      );
    }
    final now = DateTime.now().toUtc();
    final itemId = catalogRef.id;
    final catalogItem = await catalogCache.findById(itemId);
    final existing = await wishlist.findActiveByItemAnchorValue(itemId, anchor);
    final resolvedCatalogRef =
        catalogItem?.catalogRefForPersonalAnchor(anchor) ?? catalogRef;
    final localRef = existing?.catalogRef ?? resolvedCatalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        final existing =
            await wishlist.findActiveByItemAnchorValue(itemId, anchor);
        if (existing == null) {
          final item = WishlistItem(
            id: idGenerator(),
            catalogRef: resolvedCatalogRef,
            anchor: anchor,
            createdAt: now,
            updatedAt: now,
          );
          await wishlist.upsert(item);
          if (!itemId.startsWith('tmdb-local:')) {
            await syncQueue
                .enqueue(_syncChangeForWishlistItem(item, 'upsert', now));
            await syncQueue.enqueue(_syncChangeForCatalogItemId(itemId, now));
          }
        }
      },
      eventsToEmit: [WishlistChanged(itemId)],
    );
  }

  Future<void> addLocalOnlyWishlistItem(
    CatalogItem item, {
    PersonalItemAnchor? anchor,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final metadataItem = item;
    final itemId = metadataItem.id;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    final localRef = metadataItem.catalogRefForPersonalAnchor(anchor);
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        await catalogCache.upsertAll([item]);
        final existing =
            await wishlist.findActiveByItemAnchorValue(itemId, anchor);
        if (existing == null) {
          final wishlistItem = WishlistItem(
            id: idGenerator(),
            catalogRef: localRef,
            anchor: anchor,
            createdAt: now,
            updatedAt: now,
          );
          await wishlist.upsert(wishlistItem);
          if (!isLocalItem) {
            await syncQueue.enqueue(
                _syncChangeForWishlistItem(wishlistItem, 'upsert', now));
          }
        }
      },
      eventsToEmit: [WishlistChanged(itemId)],
    );
  }

  Future<WishlistItem> updateWishlistItem(
    WishlistItem item, {
    required PersonalItemAnchor? anchor,
    int? targetPriceCents,
    String? currency,
    String? notes,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = WishlistItem(
      id: item.id,
      catalogRef: item.catalogRef,
      anchor: anchor,
      targetPriceCents: targetPriceCents,
      currency: currency,
      notes: notes,
      createdAt: item.createdAt,
      updatedAt: now,
      deletedAt: item.deletedAt,
    );
    await mutationRunner.run(
      origin: origin,
      localRef: item.catalogRef,
      action: () async {
        await wishlist.upsert(updated);
        await syncQueue
            .enqueue(_syncChangeForWishlistItem(updated, 'upsert', now));
        await syncQueue.enqueue(_syncChangeForCatalogItemId(item.itemId, now));
      },
      eventsToEmit: [WishlistChanged(item.itemId)],
    );
    return updated;
  }

  Future<void> removeFromWishlist(
    String itemId, {
    String? wishlistItemId,
    PersonalItemAnchor? anchor,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final items = await _wishlistItemsForMutation(
      itemId,
      wishlistItemId: wishlistItemId,
      anchor: anchor,
    );
    final localRef = items.isEmpty ? null : items.first.catalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        final existing = await _wishlistItemsForMutation(
          itemId,
          wishlistItemId: wishlistItemId,
          anchor: anchor,
        );
        for (final item in existing) {
          await wishlist.markDeleted(item, now);
          await syncQueue.enqueue(
            _syncChangeForWishlistItem(
              item.copyWith(updatedAt: now, deletedAt: now),
              'delete',
              now,
            ),
          );
        }
      },
      eventsToEmit: [WishlistChanged(itemId)],
    );
  }

  Future<void> toggleWishlist(
    CatalogEntityRef catalogRef, {
    PersonalItemAnchor? anchor,
  }) async {
    final itemId = catalogRef.id;
    final existing = await wishlist.findActiveByItemAnchorValue(itemId, anchor);
    if (existing == null) {
      await addToWishlist(
        catalogRef,
        anchor: anchor,
      );
    } else {
      await removeFromWishlist(
        itemId,
        anchor: anchor,
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<List<WishlistItem>> _wishlistItemsForMutation(
    String itemId, {
    String? wishlistItemId,
    PersonalItemAnchor? anchor,
  }) async {
    if (wishlistItemId != null) {
      final item = await wishlist.findById(wishlistItemId);
      return item != null ? [item] : const [];
    }

    if (anchor != null) {
      final match = await wishlist.findActiveByItemAnchorValue(itemId, anchor);
      return match != null ? [match] : const [];
    }

    return await wishlist.findActiveByItemIds([itemId]);
  }

  SyncChange _syncChangeForWishlistItem(
      WishlistItem item, String action, DateTime now) {
    return SyncChange(
      id: 'wishlist:${item.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'wishlist_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForCatalogItemId(String itemId, DateTime now) {
    return SyncChange(
      id: 'catalog:$itemId:upsert:${now.millisecondsSinceEpoch}',
      entityType: 'catalog_item',
      entityId: itemId,
      action: 'upsert',
      payload: {'id': itemId},
      clientChangedAt: now,
    );
  }
}
