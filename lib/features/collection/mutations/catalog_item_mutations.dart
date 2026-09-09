import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

/// Catalog snapshot mutations are kept separate from Owned mutations.
///
/// The input is an opaque import snapshot because catalog DTOs are transport
/// objects. Generic Owned code therefore never receives or returns a catalog
/// DTO merely to update catalog metadata.
final class CatalogItemMutations {
  const CatalogItemMutations({
    required this.catalogCache,
    required this.wishlist,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
  });

  final CatalogTransportRepository catalogCache;
  final WishlistItemsCacheRepository wishlist;
  final TrackingEntriesCacheRepository trackingEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;

  Future<void> updateSnapshot(
    CatalogImportSnapshot snapshot, {
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      origin: origin,
      action: () async {
        await catalogCache.upsertImportSnapshots([snapshot]);
        await syncQueue.enqueue(_syncChangeForSnapshot(snapshot, now));
      },
      eventsToEmit: [CatalogItemChanged(snapshot.id)],
    );
  }

  Future<void> updateSnapshots(
      Iterable<CatalogImportSnapshot> snapshots) async {
    final pending = snapshots.toList(growable: false);
    if (pending.isEmpty) return;

    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertImportSnapshots(pending);
        await syncQueue.enqueueAll([
          for (final snapshot in pending) _syncChangeForSnapshot(snapshot, now),
        ]);
      },
      eventsToEmit: [
        for (final snapshot in pending) CatalogItemChanged(snapshot.id),
      ],
    );
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogImportSnapshot snapshot,
  ) async {
    final now = DateTime.now().toUtc();
    final wishlistEntries = await wishlist.findActiveByItemIds([localItemId]);
    final trackingList =
        await trackingEntries.findActiveByItemIds([localItemId]);
    final targetRef = snapshot.toTransportItem().catalogRef;

    return mutationRunner.run(
      action: () async {
        await catalogCache.upsertImportSnapshots([snapshot]);
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

        for (final item in trackingList) {
          final updated = item.copyWith(
            catalogRef: _rebaseCatalogRef(item.catalogRef, targetRef),
            updatedAt: now,
          );
          await trackingEntries.upsert(updated);
          await syncQueue.enqueue(
            _syncChangeForTrackingEntry(updated, 'upsert', now),
          );
          count++;
        }

        await syncQueue.enqueue(
          _syncChangeForSnapshot(
            snapshot,
            now,
            entityType: 'library_item_snapshot',
          ),
        );
        return count;
      },
      eventsToEmit: [
        CatalogItemChanged(snapshot.id),
        for (final item in wishlistEntries) WishlistChanged(item.id),
        for (final item in trackingList) TrackingChanged(item.id),
      ],
    );
  }

  SyncChange _syncChangeForSnapshot(
      CatalogImportSnapshot snapshot, DateTime now,
      {String entityType = 'catalog_item'}) {
    final item = snapshot.toTransportItem();
    return SyncChange(
      id: 'catalog:${snapshot.id}:upsert:${now.millisecondsSinceEpoch}',
      entityType: entityType,
      entityId: snapshot.id,
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

  SyncChange _syncChangeForTrackingEntry(
    TrackingEntry entry,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'tracking_entry:${entry.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: entry.id,
      action: action,
      payload: trackingEntries.toSyncPayload(entry),
      clientChangedAt: now,
    );
  }

  CatalogEntityRef _rebaseCatalogRef(
    CatalogEntityRef current,
    CatalogEntityRef target,
  ) {
    if (current.entityType == CatalogEntityType.work ||
        current.rootId == null) {
      return target;
    }
    return current.copyWith(
      kind: target.kind,
      rootId: target.id,
    );
  }
}
