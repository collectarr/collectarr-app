import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class OwnedItemMutations {
  const OwnedItemMutations({
    required this.ownedItems,
    required this.wishlist,
    required this.catalogCache,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
    required this.events,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsCacheRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogCacheRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final CollectionEventBus events;
  final String? userId;
  final String? userEmail;
  final IdGenerator idGenerator;

  Future<OwnedItem> addOwnedItem(
    AddOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final common = command.common;
    final catalogRef = command.catalogRef;

    final ({OwnedItem ownedItem, bool wishlistChanged}) result =
        await mutationRunner.run(
      action: () async {
        final existingCatalog = await catalogCache.findById(catalogRef.id);
        if (existingCatalog == null) {
          await catalogCache.upsertAll([
            CatalogItem(
              id: catalogRef.id,
              kind: catalogRef.kind,
              title: catalogRef.id,
            ),
          ]);
        }

        final resolvedIsDigital = common.isDigital ??
            (existingCatalog?.physicalFormat == 'digital' ||
                existingCatalog?.physicalFormatLabel?.toLowerCase() == 'digital');
        final normalizedAnchorType = resolvePersonalItemAnchorType(
          anchorType: null,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
        );
        final resolvedCatalogRef = _catalogRefForItem(
          catalogRef.id,
          existingCatalog,
          fallbackKind: catalogRef.kind,
          anchorType: normalizedAnchorType,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
        );

        final newItemId = idGenerator();
        final ownedItem = OwnedItem(
          id: newItemId,
          catalogRef: resolvedCatalogRef,
          createdAt: now,
          isDigital: resolvedIsDigital,
          anchorType: normalizedAnchorType,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
          details: command.details.toDetails(),
          condition: common.condition,
          grade: common.grade,
          purchaseDate: common.purchaseDate,
          pricePaidCents: common.pricePaidCents,
          currency: common.currency,
          personalNotes: common.personalNotes,
          quantity: common.quantity,
          locationId: common.locationId,
          purchaseStore: common.purchaseStore,
          collectionStatus: common.collectionStatus,
          tags: common.tags,
          rating: common.rating,
          readStatus: common.readStatus,
          startedAt: common.startedAt,
          finishedAt: common.finishedAt,
          ownerUserId: userId,
          ownerLabel: userEmail,
          updatedAt: now,
        );

        await ownedItems.upsert(ownedItem);
        await syncQueue.enqueue(_syncChangeForOwnedItem(ownedItem, 'upsert', now));

        if (existingCatalog != null) {
          await syncQueue.enqueue(_syncChangeForCatalogItem(existingCatalog, now));
        }

        final wishlistItems = await wishlist.findActiveByItemAnchor(
          catalogRef.id,
          anchorType: normalizedAnchorType,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
        );
        if (wishlistItems != null) {
          await wishlist.markDeleted(wishlistItems, now);
          await syncQueue.enqueue(
            _syncChangeForWishlistItem(
              wishlistItems.copyWith(updatedAt: now, deletedAt: now),
              'delete',
              now,
            ),
          );
        }

        return (
          ownedItem: ownedItem,
          wishlistChanged: wishlistItems != null,
        );
      },
      eventsToEmit: [
        OwnedItemChanged(catalogRef.id),
        if (notify) const WishlistChanged(),
      ],
    );

    return result.ownedItem;
  }

  Future<OwnedItem> updateOwnedItem(
    UpdateOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();

    final updated = await mutationRunner.run(
      action: () async {
        final existing = await ownedItems.findById(command.ownedItemId);
        if (existing == null) {
          throw StateError('OwnedItem not found: ${command.ownedItemId}');
        }

        final resolvedDetails = command.details.when(
          unchanged: () => existing.typedDetails,
          set: (draft) => draft.toDetails(),
          clear: () => const GenericOwnedDetails(),
        );

        final updatedItem = OwnedItem(
          id: existing.id,
          catalogRef: existing.catalogRef,
          createdAt: existing.createdAt ?? now,
          isDigital: command.isDigital.when(
            unchanged: () => existing.isDigital,
            set: (v) => v,
            clear: () => null,
          ),
          anchorType: existing.anchorType,
          editionId: existing.editionId,
          variantId: existing.variantId,
          bundleReleaseId: existing.bundleReleaseId,
          details: resolvedDetails,
          condition: command.condition.when(
            unchanged: () => existing.condition,
            set: (v) => v,
            clear: () => null,
          ),
          grade: command.grade.when(
            unchanged: () => existing.grade,
            set: (v) => v,
            clear: () => null,
          ),
          purchaseDate: command.purchaseDate.when(
            unchanged: () => existing.purchaseDate,
            set: (v) => v,
            clear: () => null,
          ),
          pricePaidCents: command.pricePaidCents.when(
            unchanged: () => existing.pricePaidCents,
            set: (v) => v,
            clear: () => null,
          ),
          currency: command.currency.when(
            unchanged: () => existing.currency,
            set: (v) => v,
            clear: () => null,
          ),
          personalNotes: command.personalNotes.when(
            unchanged: () => existing.personalNotes,
            set: (v) => v,
            clear: () => null,
          ),
          quantity: command.quantity.when(
            unchanged: () => existing.quantity,
            set: (v) => v,
            clear: () => 1,
          ),
          locationId: command.locationId.when(
            unchanged: () => existing.locationId,
            set: (v) => v,
            clear: () => null,
          ),
          purchaseStore: command.purchaseStore.when(
            unchanged: () => existing.purchaseStore,
            set: (v) => v,
            clear: () => null,
          ),
          collectionStatus: command.collectionStatus.when(
            unchanged: () => existing.collectionStatus,
            set: (v) => v,
            clear: () => null,
          ),
          tags: command.tags.when(
            unchanged: () => existing.tags,
            set: (v) => v,
            clear: () => null,
          ),
          rating: command.rating.when(
            unchanged: () => existing.rating,
            set: (v) => v,
            clear: () => null,
          ),
          readStatus: command.readStatus.when(
            unchanged: () => existing.readStatus,
            set: (v) => v,
            clear: () => null,
          ),
          startedAt: command.startedAt.when(
            unchanged: () => existing.startedAt,
            set: (v) => v,
            clear: () => null,
          ),
          finishedAt: command.finishedAt.when(
            unchanged: () => existing.finishedAt,
            set: (v) => v,
            clear: () => null,
          ),
          soldAt: command.soldAt.when(
            unchanged: () => existing.soldAt,
            set: (v) => v,
            clear: () => null,
          ),
          sellPriceCents: command.sellPriceCents.when(
            unchanged: () => existing.sellPriceCents,
            set: (v) => v,
            clear: () => null,
          ),
          soldTo: command.soldTo.when(
            unchanged: () => existing.soldTo,
            set: (v) => v,
            clear: () => null,
          ),
          marketValueCents: command.marketValueCents.when(
            unchanged: () => existing.marketValueCents,
            set: (v) => v,
            clear: () => null,
          ),
          ownerUserId: existing.ownerUserId ?? userId,
          ownerLabel: existing.ownerLabel ?? userEmail,
          indexNumber: command.indexNumber.when(
            unchanged: () => existing.indexNumber,
            set: (v) => v,
            clear: () => null,
          ),
          updatedAt: now,
          deletedAt: existing.deletedAt,
        );

        await ownedItems.upsert(updatedItem);
        await syncQueue.enqueue(_syncChangeForOwnedItem(updatedItem, 'upsert', now));
        return updatedItem;
      },
      eventsToEmit: [OwnedItemChanged(command.ownedItemId)],
    );

    return updated;
  }

  Future<void> updateCatalogSnapshot(
    CatalogItem item, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([item]);
        await syncQueue.enqueue(_syncChangeForCatalogItem(item, now));
      },
      eventsToEmit: [OwnedItemChanged(item.id)],
    );
  }

  Future<void> updateCatalogSnapshots(
    Iterable<CatalogItem> items, {
    bool notify = true,
  }) async {
    final pendingItems = items.toList(growable: false);
    if (pendingItems.isEmpty) return;

    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll(pendingItems);
        await syncQueue.enqueueAll([
          for (final item in pendingItems) _syncChangeForCatalogItem(item, now),
        ]);
      },
      eventsToEmit: [
        for (final item in pendingItems) OwnedItemChanged(item.id),
      ],
    );
  }

  Future<void> removeItem(OwnedItem item, {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await ownedItems.markDeleted(item, now);
        await syncQueue.enqueue(
          _syncChangeForOwnedItem(
            item.copyWith(updatedAt: now, deletedAt: now),
            'delete',
            now,
          ),
        );
      },
      eventsToEmit: [OwnedItemChanged(item.itemId)],
    );
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItem targetCatalogItem,
  ) async {
    final now = DateTime.now().toUtc();
    return await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([targetCatalogItem]);
        var count = 0;

        final wishlistEntries = await wishlist.findActiveByItemIds([localItemId]);
        for (final item in wishlistEntries) {
          final updated = item.copyWith(
            catalogRef: targetCatalogItem.catalogRefForAnchor(
              anchorType: item.anchorType,
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
            updatedAt: now,
          );
          await wishlist.upsert(updated);
          await syncQueue.enqueue(_syncChangeForWishlistItem(updated, 'upsert', now));
          count++;
        }

        final trackingList = await trackingEntries.findActiveByItemIds([localItemId]);
        for (final item in trackingList) {
          final updated = item.copyWith(
            catalogRef: targetCatalogItem.catalogRefForAnchor(
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
            updatedAt: now,
          );
          await trackingEntries.upsert(updated);
          await syncQueue.enqueue(_syncChangeForTrackingEntry(updated, 'upsert', now));
          count++;
        }

        await syncQueue.enqueue(
          SyncChange(
            id: 'catalog_snapshot:${targetCatalogItem.id}:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'library_item_snapshot',
            entityId: targetCatalogItem.id,
            action: 'upsert',
            payload: targetCatalogItem.toSyncPayload(),
            clientChangedAt: now,
          ),
        );

        return count;
      },
      eventsToEmit: [
        OwnedItemChanged(targetCatalogItem.id),
        const WishlistChanged(),
        const TrackingChanged(),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  CatalogEntityRef _catalogRefForItem(
    String itemId,
    CatalogItem? item, {
    String? fallbackKind,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    if (item != null) {
      return item.catalogRefForAnchor(
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
    return CatalogEntityRef(
      kind: fallbackKind ?? 'comic',
      entityType: CatalogEntityType.work,
      id: itemId,
    );
  }

  SyncChange _syncChangeForOwnedItem(OwnedItem item, String action, DateTime now) {
    return SyncChange(
      id: 'owned_item:${item.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'owned_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForWishlistItem(WishlistItem item, String action, DateTime now) {
    return SyncChange(
      id: 'wishlist:${item.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'wishlist_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForTrackingEntry(TrackingEntry entry, String action, DateTime now) {
    return SyncChange(
      id: 'tracking_entry:${entry.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: entry.id,
      action: action,
      payload: entry.toSyncPayload(),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForCatalogItem(CatalogItem item, DateTime now) {
    return SyncChange(
      id: 'catalog:${item.id}:upsert:${now.millisecondsSinceEpoch}',
      entityType: 'catalog_item',
      entityId: item.id,
      action: 'upsert',
      payload: item.toSyncPayload(),
      clientChangedAt: now,
    );
  }
}
