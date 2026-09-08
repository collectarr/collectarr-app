import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
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
    required this.catalogSummaries,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogTransportRepository catalogCache;
  final CatalogDisplaySummaryRepository catalogSummaries;
  final TrackingEntriesCacheRepository trackingEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final String? userId;
  final String? userEmail;
  final IdGenerator idGenerator;

  Future<OwnedItemRef> addOwnedItem(
    AddOwnedItemCommand command,
  ) async {
    final now = DateTime.now().toUtc();
    final catalogRef = command.catalogRef;
    final anchor = command.anchor;
    final wishlistTargetRef = command.targetRef ?? catalogRef;

    final existingWishlist =
        await wishlist.findActiveByCatalogRef(wishlistTargetRef);
    final wishlistChanged = existingWishlist != null;
    final newItemId = idGenerator();

    final ownedRef = await mutationRunner.run(
      action: () async {
        final existingCatalog =
            (await catalogSummaries.findByIds([catalogRef.id]))[catalogRef.id];

        final resolvedCatalogRef = _catalogRefForItem(
          catalogRef,
          existingCatalog?.ref,
          targetRef: command.targetRef,
          anchor: anchor,
        );

        final mediaKind = catalogMediaKindFromApiValue(catalogRef.kind);
        final typedPayload = command.typedPayload;
        final typedOwnedItem = typedPayload.toOwnedItem(
          resolvedCatalogRef: resolvedCatalogRef,
          id: newItemId,
          createdAt: now,
          existingIsDigital: typedPayload.isDigital ?? false,
          anchor: anchor,
          ownerUserId: userId,
          ownerLabel: userEmail,
        );
        final ownedRef = collectarrTypedOwnedItemRef(typedOwnedItem);

        await ownedItems.upsertTyped(mediaKind, typedOwnedItem);
        await syncQueue.enqueue(
          _syncChangeForTypedOwnedItem(
            mediaKind,
            typedOwnedItem,
            newItemId,
            'upsert',
            now,
          ),
        );

        if (existingCatalog != null) {
          await syncQueue.enqueue(_syncChangeForCatalogRef(
            existingCatalog.ref,
            now,
          ));
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

        return ownedRef;
      },
      eventsToEmit: [
        OwnedItemAdded(newItemId),
        if (wishlistChanged) WishlistChanged(wishlistTargetRef.id),
      ],
    );

    return ownedRef;
  }

  Future<OwnedItemRef> updateOwnedItem(
    OwnedItemUpdateRequest command,
  ) async {
    final typedCommand = command is UpdateOwnedItemCommand
        ? command
        : throw StateError(
            'Collection mutations require a kind-owned '
            'UpdateOwnedItemCommand.',
          );
    final now = DateTime.now().toUtc();

    final updated = await mutationRunner.run(
      action: () async {
        final typedExistingResult =
            await ownedItems.findTypedById(command.ownedRef.id.value);
        if (typedExistingResult == null) {
          throw StateError('OwnedItem not found: ${command.ownedRef.key}');
        }

        final typedPayload = typedCommand.payload;
        final mediaKind = typedExistingResult.$1;
        final typedExisting = typedExistingResult.$2;
        if (command.ownedRef.kind != mediaKind) {
          throw StateError(
            'Owned update reference kind ${command.ownedRef.kind.apiValue} '
            'does not match persisted kind ${mediaKind.apiValue}.',
          );
        }
        if (!typedPayload.canApplyTo(typedExisting)) {
          throw StateError(
            'Owned update payload does not belong to '
            '${mediaKind.apiValue}: ${command.ownedRef.key}',
          );
        }
        final typedUpdatedItem = typedPayload.applyTo(
          typedExisting,
          updatedAt: now,
          fallbackOwnerUserId: userId,
          fallbackOwnerLabel: userEmail,
        );
        final updatedRef =
            collectarrTypedOwnedItemRef(typedUpdatedItem as Object);

        await ownedItems.upsertTyped(mediaKind, typedUpdatedItem);
        await syncQueue.enqueue(
          _syncChangeForTypedOwnedItem(
            mediaKind,
            typedUpdatedItem,
            command.ownedRef.id.value,
            'upsert',
            now,
          ),
        );
        return updatedRef;
      },
      eventsToEmit: [OwnedItemUpdated(command.ownedRef.id.value)],
    );

    return updated;
  }

  Future<void> updateCatalogSnapshot(
    CatalogItemDto item, {
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
    Iterable<CatalogItemDto> items,
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

  Future<void> removeItem(OwnedItemRef ref) async {
    final now = DateTime.now().toUtc();
    final typedExisting = await ownedItems.findTypedById(ref.id.value);
    if (typedExisting == null) return;
    await mutationRunner.run(
      action: () async {
        await ownedItems.markDeletedByRef(ref, now);
        await syncQueue.enqueue(
          _syncChangeForTypedOwnedItem(
            typedExisting.$1,
            typedExisting.$2,
            ref.id.value,
            'delete',
            now,
          ),
        );
      },
      eventsToEmit: [OwnedItemRemoved(ref.id.value)],
    );
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItemDto targetCatalogItem,
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
            catalogRef: _rebaseCatalogRef(
              item.catalogRef,
              targetMetadata.catalogRef,
            ),
            updatedAt: now,
          );
          await wishlist.upsert(updated);
          await syncQueue
              .enqueue(_syncChangeForWishlistItem(updated, 'upsert', now));
          count++;
        }

        for (final item in trackingList) {
          final updated = item.copyWith(
            catalogRef: _rebaseCatalogRef(
              item.catalogRef,
              targetMetadata.catalogRef,
            ),
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
    CatalogEntityRef? existingRef, {
    CatalogEntityRef? targetRef,
    PersonalItemAnchor? anchor,
  }) {
    if (targetRef != null && targetRef.isKnown) {
      return targetRef;
    }
    if (existingRef != null) {
      return _catalogRefForAnchor(existingRef, anchor);
    }
    if (!catalogRef.isKnown) {
      throw StateError(
        'Cannot resolve CatalogEntityRef without a complete catalog reference: '
        '${catalogRef.id}',
      );
    }
    return catalogRef;
  }

  CatalogEntityRef _catalogRefForAnchor(
    CatalogEntityRef baseRef,
    PersonalItemAnchor? anchor,
  ) {
    if (anchor == null || anchor.type == PersonalItemAnchorType.item) {
      return baseRef.copyWith(
        entityType: CatalogEntityType.work,
        id: baseRef.rootId ?? baseRef.id,
        rootId: null,
      );
    }
    if (anchor.type == PersonalItemAnchorType.bundleRelease &&
        anchor.bundleReleaseId != null) {
      return baseRef.copyWith(
        entityType: CatalogEntityType.bundleRelease,
        id: anchor.bundleReleaseId,
        rootId: baseRef.rootId ?? baseRef.id,
      );
    }
    if (anchor.type == PersonalItemAnchorType.variant &&
        anchor.variantId != null) {
      return baseRef.copyWith(
        entityType: CatalogEntityType.release,
        id: anchor.variantId,
        rootId: baseRef.rootId ?? baseRef.id,
      );
    }
    if (anchor.type == PersonalItemAnchorType.edition &&
        anchor.editionId != null) {
      return baseRef.copyWith(
        entityType: CatalogEntityType.edition,
        id: anchor.editionId,
        rootId: baseRef.rootId ?? baseRef.id,
      );
    }
    return baseRef.copyWith(
      entityType: CatalogEntityType.work,
      id: baseRef.rootId ?? baseRef.id,
      rootId: null,
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

  SyncChange _syncChangeForTypedOwnedItem(
    CatalogMediaKind kind,
    Object item,
    String id,
    String action,
    DateTime now,
  ) {
    final serialized = ownedItems.syncPayloadForTyped(kind, item);
    return SyncChange(
      id: 'owned_item:$id:$action:${now.millisecondsSinceEpoch}',
      entityType: 'owned_item',
      entityId: id,
      action: action,
      payload: serialized.payload,
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

  SyncChange _syncChangeForCatalogItem(CatalogItemDto item, DateTime now) {
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

  SyncChange _syncChangeForCatalogRef(
    CatalogEntityRef ref,
    DateTime now,
  ) {
    return SyncChange(
      id: 'catalog:${ref.id}:upsert:${now.millisecondsSinceEpoch}',
      entityType: 'catalog_item',
      entityId: ref.id,
      action: 'upsert',
      payload: {'id': ref.id, 'kind': ref.kind},
      clientChangedAt: now,
    );
  }
}
