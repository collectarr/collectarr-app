import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_details_codecs.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
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
    this.typedOwnedItems,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsCacheRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final LibraryCatalogRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final CollectarrOwnedItemPersistence? typedOwnedItems;
  final String? userId;
  final String? userEmail;
  final IdGenerator idGenerator;

  Future<OwnedItem> addOwnedItem(
    AddOwnedItemCommand command,
  ) async {
    final now = DateTime.now().toUtc();
    final catalogRef = command.catalogRef;
    final anchor = command.anchor;

    final existingWishlist =
        await wishlist.findActiveByItemAnchorValue(catalogRef.id, anchor);
    final wishlistChanged = existingWishlist != null;
    final newItemId = idGenerator();

    final ownedItem = await mutationRunner.run(
      action: () async {
        final existingCatalog = await catalogCache.findById(catalogRef.id);
        if (existingCatalog == null) {
          await catalogCache.upsertMetadataItems([
            CatalogItem.fromJson({
              'id': catalogRef.id,
              'kind': catalogRef.kind,
              'title': catalogRef.id,
            }),
          ]);
        }

        final resolvedCatalogRef = _catalogRefForItem(
          catalogRef,
          existingCatalog,
          anchor: anchor,
        );

        final mediaKind = catalogMediaKindFromApiValue(catalogRef.kind);
        final typedPayload = command.typedPayload;
        final details = typedPayload.detailsDraft.toDetails();
        if (mediaKind != CatalogMediaKind.unknown) {
          collectarrOwnedDetailsCodecForKind(mediaKind).validate(details);
        }

        final ownedItem = typedPayload.toOwnedItem(
          resolvedCatalogRef: resolvedCatalogRef,
          id: newItemId,
          createdAt: now,
          existingCatalog: existingCatalog,
          anchor: anchor,
          ownerUserId: userId,
          ownerLabel: userEmail,
        );

        await ownedItems.upsert(ownedItem);
        await typedOwnedItems?.upsert(ownedItem);
        await syncQueue
            .enqueue(_syncChangeForOwnedItem(ownedItem, 'upsert', now));

        if (existingCatalog != null) {
          await syncQueue
              .enqueue(_syncChangeForCatalogItem(existingCatalog, now));
        }

        if (existingWishlist != null) {
          await wishlist.markDeleted(existingWishlist, now);
          await syncQueue.enqueue(
            _syncChangeForWishlistItem(
              existingWishlist.copyWith(updatedAt: now, deletedAt: now),
              'delete',
              now,
            ),
          );
        }

        return ownedItem;
      },
      eventsToEmit: [
        OwnedItemAdded(newItemId),
        if (wishlistChanged) WishlistChanged(catalogRef.id),
      ],
    );

    return ownedItem;
  }

  Future<OwnedItem> updateOwnedItem(
    OwnedItemUpdateRequest command,
  ) async {
    final now = DateTime.now().toUtc();

    final updated = await mutationRunner.run(
      action: () async {
        final existing = await ownedItems.findById(command.ownedItemId);
        if (existing == null) {
          throw StateError('OwnedItem not found: ${command.ownedItemId}');
        }

        final typedPayload =
            command is UpdateOwnedItemCommand ? command.payload : null;
        final updatedItem =
            typedPayload != null && typedPayload.canApplyTo(existing)
                ? typedPayload.applyTo(
                    existing,
                    updatedAt: now,
                    fallbackOwnerUserId: userId,
                    fallbackOwnerLabel: userEmail,
                  )
                : _applyOwnedPatch(
                    existing,
                    command as OwnedItemPatchCommand,
                    updatedAt: now,
                  );

        await ownedItems.upsert(updatedItem);
        await typedOwnedItems?.upsert(updatedItem);
        await syncQueue
            .enqueue(_syncChangeForOwnedItem(updatedItem, 'upsert', now));
        return updatedItem;
      },
      eventsToEmit: [OwnedItemUpdated(command.ownedItemId)],
    );

    return updated;
  }

  OwnedItem _applyOwnedPatch(
    OwnedItem existing,
    OwnedItemPatchCommand command, {
    required DateTime updatedAt,
  }) {
    final mediaKind = catalogMediaKindFromApiValue(existing.catalogRef.kind);
    final detailsCodec = collectarrOwnedDetailsCodecForKind(mediaKind);
    final resolvedDetails = command.details.when(
      unchanged: () => existing.details,
      set: (draft) {
        final details = draft.toDetails();
        detailsCodec.validate(details);
        return details;
      },
      clear: () => detailsCodec.defaultDetails(),
    );

    return OwnedItem(
      id: existing.id,
      catalogRef: existing.catalogRef,
      createdAt: existing.createdAt ?? updatedAt,
      isDigital: command.isDigital.when(
        unchanged: () => existing.isDigital,
        set: (v) => v,
        clear: () => null,
      ),
      anchor: command.anchor.when(
        unchanged: () => existing.anchor,
        set: (value) => value,
        clear: () => null,
      ),
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
      // Tracking state is owned by TrackingMutations. Preserve the read-model
      // values while this collection update changes copy fields.
      rating: existing.rating,
      readStatus: existing.readStatus,
      startedAt: existing.startedAt,
      finishedAt: existing.finishedAt,
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
      updatedAt: updatedAt,
      deletedAt: existing.deletedAt,
    );
  }

  Future<void> updateCatalogSnapshot(
    CatalogItem item, {
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final metadataItem = item;
    final itemId = metadataItem.id;
    await mutationRunner.run(
      origin: origin,
      action: () async {
        await catalogCache.upsertAll([item]);
        await syncQueue.enqueue(_syncChangeForCatalogItem(item, now));
      },
      eventsToEmit: [CatalogItemChanged(itemId)],
    );
  }

  Future<void> updateCatalogSnapshots(
    Iterable<CatalogItem> items,
  ) async {
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
        for (final item in pendingItems) CatalogItemChanged(item.id),
      ],
    );
  }

  Future<void> removeItem(OwnedItem item) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        await ownedItems.markDeleted(item, now);
        await typedOwnedItems?.upsert(
          item.copyWith(updatedAt: now, deletedAt: now),
        );
        await syncQueue.enqueue(
          _syncChangeForOwnedItem(
            item.copyWith(updatedAt: now, deletedAt: now),
            'delete',
            now,
          ),
        );
      },
      eventsToEmit: [OwnedItemRemoved(item.id)],
    );
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItem targetCatalogItem,
  ) async {
    final targetMetadata = targetCatalogItem;
    final now = DateTime.now().toUtc();
    final wishlistEntries = await wishlist.findActiveByItemIds([localItemId]);
    final trackingList =
        await trackingEntries.findActiveByItemIds([localItemId]);

    return await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([targetMetadata]);
        var count = 0;

        for (final item in wishlistEntries) {
          final updated = item.copyWith(
            catalogRef: targetMetadata.catalogRefForPersonalAnchor(item.anchor),
            updatedAt: now,
          );
          await wishlist.upsert(updated);
          await syncQueue
              .enqueue(_syncChangeForWishlistItem(updated, 'upsert', now));
          count++;
        }

        for (final item in trackingList) {
          final updated = item.copyWith(
            catalogRef: targetMetadata.catalogRefForPersonalAnchor(item.anchor),
            updatedAt: now,
          );
          await trackingEntries.upsert(updated);
          await syncQueue
              .enqueue(_syncChangeForTrackingEntry(updated, 'upsert', now));
          count++;
        }

        await syncQueue.enqueue(
          SyncChange(
            id: 'catalog_snapshot:${targetMetadata.id}:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'library_item_snapshot',
            entityId: targetMetadata.id,
            action: 'upsert',
            payload: targetMetadata.toSyncPayload(),
            clientChangedAt: now,
          ),
        );

        return count;
      },
      eventsToEmit: [
        CatalogItemChanged(targetMetadata.id),
        for (final item in wishlistEntries) WishlistChanged(item.id),
        for (final item in trackingList) TrackingChanged(item.id),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  CatalogEntityRef _catalogRefForItem(
    CatalogEntityRef catalogRef,
    CatalogItem? item, {
    PersonalItemAnchor? anchor,
  }) {
    if (item != null) {
      return item.catalogRefForPersonalAnchor(anchor);
    }
    if (!catalogRef.isKnown) {
      throw StateError(
        'Cannot resolve CatalogEntityRef without a complete catalog reference: '
        '${catalogRef.id}',
      );
    }
    return catalogRef;
  }

  SyncChange _syncChangeForOwnedItem(
      OwnedItem item, String action, DateTime now) {
    return SyncChange(
      id: 'owned_item:${item.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'owned_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: now,
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

  SyncChange _syncChangeForTrackingEntry(
      TrackingEntry entry, String action, DateTime now) {
    return SyncChange(
      id: 'tracking_entry:${entry.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: entry.id,
      action: action,
      payload: trackingEntries.toSyncPayload(entry),
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForCatalogItem(CatalogItem item, DateTime now) {
    final metadataItem = item;
    final itemId = metadataItem.id;
    final payload = metadataItem.toSyncPayload();
    return SyncChange(
      id: 'catalog:$itemId:upsert:${now.millisecondsSinceEpoch}',
      entityType: 'catalog_item',
      entityId: itemId,
      action: 'upsert',
      payload: payload,
      clientChangedAt: now,
    );
  }
}
