import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

/// Catalog transport mutations are kept separate from Owned mutations.
final class CatalogItemMutations {
  const CatalogItemMutations({
    required this.catalogTransport,
    required this.wishlist,
    required this.trackingLifecycles,
    required this.syncQueue,
    required this.mutationRunner,
  });

  final CatalogTransportRepository catalogTransport;
  final WishlistItemsCacheRepository wishlist;
  final TrackingLifecycleRepository trackingLifecycles;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;

  Future<void> updateItem(
    CatalogSearchCandidate item, {
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      origin: origin,
      action: () async {
        await catalogTransport.upsertSearchCandidates([item]);
        await syncQueue.enqueue(_syncChangeForItem(item, now));
      },
      eventsToEmit: [CatalogItemChanged(item.catalogRef)],
    );
  }

  Future<void> updateItems(Iterable<CatalogSearchCandidate> items) async {
    final pending = items.toList(growable: false);
    if (pending.isEmpty) return;

    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await catalogTransport.upsertSearchCandidates(pending);
        await syncQueue.enqueueAll([
          for (final item in pending) _syncChangeForItem(item, now),
        ]);
      },
      eventsToEmit: [
        for (final item in pending) CatalogItemChanged(item.catalogRef),
      ],
    );
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    CatalogEntityRef localCatalogRef,
    CatalogSearchCandidate item,
  ) async {
    final now = DateTime.now().toUtc();
    if (localCatalogRef.kind != item.mediaKind) {
      throw ArgumentError.value(
        localCatalogRef,
        'localCatalogRef',
        'Local catalog reference kind must match the promoted item.',
      );
    }
    final localRef = localCatalogRef;
    final wishlistEntries = await wishlist.findActiveByCatalogRefs([localRef]);
    final targetRef = item.catalogRef;
    final trackingUpdates = <TrackingLifecycleSyncRecord>[];

    return mutationRunner.run(
      action: () async {
        await catalogTransport.upsertSearchCandidates([item]);
        var count = 0;

        for (final item in wishlistEntries) {
          final updated = item.copyWith(
            catalogRef: _rebaseCatalogRef(item.catalogRef, targetRef),
            updatedAt: now,
          );
          await wishlist.upsert(updated);
          await syncQueue.enqueue(
            _syncChangeForWishlistItem(updated, 'upsert', now),
          );
          count++;
        }

        trackingUpdates.addAll(
          await trackingLifecycles.rebaseCatalogRef(
            current: localRef,
            target: targetRef,
            updatedAt: now,
          ),
        );
        for (final update in trackingUpdates) {
          await syncQueue.enqueue(
            _syncChangeForTrackingPayload(update, 'upsert', now),
          );
          count++;
        }

        await syncQueue.enqueue(
          _syncChangeForItem(
            item,
            now,
            entityType: 'library_item_snapshot',
          ),
        );
        return count;
      },
      eventsToEmit: [
        CatalogItemChanged(item.catalogRef),
        for (final item in wishlistEntries) WishlistChanged(item.catalogRef),
        const TrackingChanged(),
      ],
    );
  }

  SyncChange _syncChangeForItem(CatalogSearchCandidate item, DateTime now,
      {String entityType = 'catalog_item'}) {
    return SyncChange(
      id: 'catalog:${item.id}:upsert:${now.millisecondsSinceEpoch}',
      entityType: entityType,
      entityId: item.id,
      action: 'upsert',
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForWishlistItem(
    WishlistItem item,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'wishlist:${item.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'wishlist_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  CatalogEntityRef _rebaseCatalogRef(
    CatalogEntityRef current,
    CatalogEntityRef target,
  ) {
    if (current.rootScope == current || current.rootId == null) {
      return target;
    }
    return current.copyWith(
      kind: target.kind,
      rootId: target.id,
    );
  }

  SyncChange _syncChangeForTrackingPayload(
    TrackingLifecycleSyncRecord entry,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'tracking_entry:${entry.ref.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: entry.ref.id,
      action: action,
      payload: entry.payload,
      clientChangedAt: now,
    );
  }
}
