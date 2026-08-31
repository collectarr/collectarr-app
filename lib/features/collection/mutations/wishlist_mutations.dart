import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
  final CatalogCacheRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final TrackingUnitsCacheRepository trackingUnits;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> addToWishlist(
    String itemId, {
    String? fallbackKind,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final catalogItem = await catalogCache.findById(itemId);
        final existing = await wishlist.findActiveByItemAnchor(
          itemId,
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        );
        if (existing == null) {
          final normalizedAnchorType = resolvePersonalItemAnchorType(
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
          );
          final item = WishlistItem(
            id: idGenerator(),
            catalogRef: _catalogRefForItem(
              itemId,
              catalogItem,
              fallbackKind: fallbackKind,
              anchorType: normalizedAnchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            ),
            anchorType: normalizedAnchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
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
    dynamic item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final itemId =
        item is LibraryMetadataItem ? item.id : (item as CatalogItem).id;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([item]);
        final existing = await wishlist.findActiveByItemAnchor(
          itemId,
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        );
        if (existing == null) {
          final normalizedAnchorType = resolvePersonalItemAnchorType(
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
          );
          final wishlistItem = WishlistItem(
            id: idGenerator(),
            catalogRef: _catalogRefForItem(
              itemId,
              item,
              anchorType: normalizedAnchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            ),
            anchorType: normalizedAnchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
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
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    int? targetPriceCents,
    String? currency,
    String? notes,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final normalizedAnchorType = resolvePersonalItemAnchorType(
      anchorType: anchorType ?? item.anchorType,
      editionId: editionId ?? item.editionId,
      variantId: variantId ?? item.variantId,
      bundleReleaseId: bundleReleaseId ?? item.bundleReleaseId,
    );
    final updated = WishlistItem(
      id: item.id,
      catalogRef: item.catalogRef,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      targetPriceCents: targetPriceCents,
      currency: currency,
      notes: notes,
      createdAt: item.createdAt,
      updatedAt: now,
      deletedAt: item.deletedAt,
    );
    await mutationRunner.run(
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
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final existing = await _wishlistItemsForMutation(
          itemId,
          wishlistItemId: wishlistItemId,
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
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
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) async {
    final existing = await wishlist.findActiveByItemAnchor(
      itemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      await addToWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    } else {
      await removeFromWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<List<WishlistItem>> _wishlistItemsForMutation(
    String itemId, {
    String? wishlistItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) async {
    if (wishlistItemId != null) {
      final item = await wishlist.findById(wishlistItemId);
      return item != null ? [item] : const [];
    }

    final normalizedAnchorType = resolvePersonalItemAnchorType(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    final isSpecificAnchor = normalizedAnchorType != null ||
        editionId != null ||
        variantId != null ||
        bundleReleaseId != null;

    if (isSpecificAnchor) {
      final match = await wishlist.findActiveByItemAnchor(
        itemId,
        anchorType: normalizedAnchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      return match != null ? [match] : const [];
    }

    return await wishlist.findActiveByItemIds([itemId]);
  }

  CatalogEntityRef _catalogRefForItem(
    String itemId,
    dynamic item, {
    String? fallbackKind,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    if (item is CatalogItem) {
      return item.catalogRefForAnchor(
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
    if (item is LibraryMetadataItem) {
      return item.catalogRefForAnchor(
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
    final resolvedKind = fallbackKind?.trim();
    if (resolvedKind == null || resolvedKind.isEmpty) {
      throw StateError(
        'Cannot resolve CatalogEntityRef for item "$itemId": no catalog item found and no fallback kind provided.',
      );
    }
    return CatalogEntityRef(
      kind: resolvedKind,
      entityType: CatalogEntityType.work,
      id: itemId,
    );
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
