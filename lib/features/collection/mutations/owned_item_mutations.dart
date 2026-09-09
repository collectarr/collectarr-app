import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
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
    final wishlistTargetRef = command.targetRef ?? catalogRef;
    final catalogLookupRef = _catalogWorkRef(command.targetRef ?? catalogRef);

    final existingWishlist =
        await wishlist.findActiveByCatalogRef(wishlistTargetRef);
    final existingCatalog = (await catalogSummaries
        .findByRefs([catalogLookupRef]))[catalogLookupRef];
    final wishlistChanged = existingWishlist != null;
    final newItemId = idGenerator();

    final ownedRef = await mutationRunner.run(
      action: () async {
        final resolvedCatalogRef = _catalogRefForItem(
          catalogRef,
          existingCatalog?.ref,
          targetRef: command.targetRef,
        );

        final mediaKind = catalogRef.mediaKind;
        final typedPayload = command.typedPayload;
        final typedOwnedItem = typedPayload.toOwnedItem(
          resolvedCatalogRef: resolvedCatalogRef,
          id: newItemId,
          createdAt: now,
          existingIsDigital: typedPayload.isDigital ?? false,
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
        OwnedItemAdded(
          OwnedItemRef(
            kind: catalogRef.mediaKind,
            id: OwnedItemId(newItemId),
          ),
        ),
        if (wishlistChanged) WishlistChanged(wishlistTargetRef),
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
            await ownedItems.findTypedByRef(command.ownedRef);
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
      eventsToEmit: [OwnedItemUpdated(command.ownedRef)],
    );

    return updated;
  }

  Future<void> removeItem(OwnedItemRef ref) async {
    final now = DateTime.now().toUtc();
    final typedExisting = await ownedItems.findTypedByRef(ref);
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
      eventsToEmit: [OwnedItemRemoved(ref)],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  CatalogEntityRef _catalogRefForItem(
    CatalogEntityRef catalogRef,
    CatalogEntityRef? existingRef, {
    CatalogEntityRef? targetRef,
  }) {
    if (targetRef != null && targetRef.isKnown) {
      return targetRef;
    }
    if (existingRef != null) {
      return existingRef;
    }
    if (!catalogRef.isKnown) {
      throw StateError(
        'Cannot resolve CatalogEntityRef without a complete catalog reference: '
        '${catalogRef.id}',
      );
    }
    return catalogRef;
  }

  CatalogEntityRef _catalogWorkRef(CatalogEntityRef ref) {
    if (ref.entityType == const CatalogEntityTypeId('owned_copy') ||
        ref.entityType == const CatalogEntityTypeId('copy') ||
        ref.entityType == const CatalogEntityTypeId('tracking_entry')) {
      return ref.copyWith(
        entityType: const CatalogEntityTypeId('work'),
        id: ref.rootId ?? ref.id,
        rootId: null,
        parentId: null,
      );
    }
    return ref;
  }

  SyncChange _syncChangeForTypedOwnedItem(
    CatalogMediaKind kind,
    Object item,
    String id,
    String action,
    DateTime now,
  ) {
    return ownedItems.syncChangeForTyped(
      kind,
      item,
      id: id,
      action: action,
      changedAt: now,
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
      payload: {'id': ref.id, 'kind': ref.kind.apiValue},
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
}
