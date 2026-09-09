import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
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
  final CatalogTransportRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final TrackingUnitsCacheRepository trackingUnits;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> addToWishlist(
    CatalogEntityRef catalogRef, {
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
    final itemId = catalogRef.rootId ?? catalogRef.id;
    final existing = await wishlist.findActiveByCatalogRef(catalogRef);
    final localRef = existing?.catalogRef ?? catalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        final existing = await wishlist.findActiveByCatalogRef(catalogRef);
        if (existing == null) {
          final item = WishlistItem(
            id: idGenerator(),
            catalogRef: catalogRef,
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
      eventsToEmit: [WishlistChanged(localRef)],
    );
  }

  Future<void> addLocalOnlyWishlistItem(
    CatalogImportSnapshot snapshot, {
    CatalogEntityRef? catalogRef,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final itemId = snapshot.id;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    final localRef = catalogRef ?? snapshot.toTransportItem().catalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        await catalogCache.upsertImportSnapshots([snapshot]);
        final existing = await wishlist.findActiveByCatalogRef(localRef);
        if (existing == null) {
          final wishlistItem = WishlistItem(
            id: idGenerator(),
            catalogRef: localRef,
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
      eventsToEmit: [WishlistChanged(localRef)],
    );
  }

  Future<WishlistItem> updateWishlistItem(
    WishlistItem item, {
    CatalogEntityRef? catalogRef,
    int? targetPriceCents,
    String? currency,
    String? notes,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final itemId = item.catalogRef.rootId ?? item.catalogRef.id;
    final updatedCatalogRef = catalogRef ?? item.catalogRef;
    final updated = WishlistItem(
      id: item.id,
      catalogRef: updatedCatalogRef,
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
        await syncQueue.enqueue(_syncChangeForCatalogItemId(itemId, now));
      },
      eventsToEmit: [WishlistChanged(updatedCatalogRef)],
    );
    return updated;
  }

  Future<void> removeFromWishlist({
    String? wishlistItemId,
    CatalogEntityRef? catalogRef,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final items = await _wishlistItemsForMutation(
      wishlistItemId: wishlistItemId,
      catalogRef: catalogRef,
    );
    final eventRef = items.isEmpty ? catalogRef : items.first.catalogRef;
    final localRef = items.isEmpty ? null : items.first.catalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: localRef,
      action: () async {
        final existing = await _wishlistItemsForMutation(
          wishlistItemId: wishlistItemId,
          catalogRef: catalogRef,
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
      eventsToEmit: [
        if (eventRef != null) WishlistChanged(eventRef),
      ],
    );
  }

  Future<void> toggleWishlist(
    CatalogEntityRef catalogRef,
  ) async {
    final existing = await wishlist.findActiveByCatalogRef(catalogRef);
    if (existing == null) {
      await addToWishlist(
        catalogRef,
      );
    } else {
      await removeFromWishlist(
        catalogRef: catalogRef,
        wishlistItemId: existing.id,
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<List<WishlistItem>> _wishlistItemsForMutation({
    String? wishlistItemId,
    CatalogEntityRef? catalogRef,
  }) async {
    if (wishlistItemId != null) {
      final item = await wishlist.findById(wishlistItemId);
      return item != null ? [item] : const [];
    }

    if (catalogRef != null) {
      final match = await wishlist.findActiveByCatalogRef(catalogRef);
      return match != null ? [match] : const [];
    }

    return const [];
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
