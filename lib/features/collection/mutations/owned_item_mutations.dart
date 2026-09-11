import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
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
    required this.trackingLifecycles,
    required this.syncQueue,
    required this.mutationRunner,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogDisplaySummaryRepository catalogSummaries;
  final TrackingLifecycleRepository trackingLifecycles;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final String? userId;
  final String? userEmail;
  final IdGenerator idGenerator;

  /// Creates a new copy directly from the persisted kind-owned aggregate.
  ///
  /// The generated registry performs the one composition-boundary dispatch
  /// and immediately turns the concrete aggregate into its owning kind's
  /// create payload. No common Owned model or catalog snapshot is involved.
  Future<OwnedItemRef?> duplicateItem(
    OwnedItemRef sourceRef, {
    CatalogEntityRef? targetRef,
    OwnedItemTrackingDraft? tracking,
  }) async {
    final payload = await ownedItems.createPayloadByRef(sourceRef);
    if (payload == null) return null;
    return addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: CatalogEntityRef(
          kind: sourceRef.kind,
          entityType: const CatalogEntityTypeId('owned_copy'),
          id: sourceRef.id.value,
        ),
        typedPayload: payload,
        targetRef: targetRef ?? payload.catalogRef,
        tracking: tracking,
      ),
    );
  }

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
        final persisted = await ownedItems.createOwned(
          kind: mediaKind,
          payload: command.typedPayload,
          resolvedCatalogRef: resolvedCatalogRef,
          id: newItemId,
          createdAt: now,
          existingIsDigital: command.typedPayload.isDigital ?? false,
          ownerUserId: userId,
          ownerLabel: userEmail,
        );
        await syncQueue.enqueue(
          ownedItems.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
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

        return persisted.ref;
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
        final persisted = await ownedItems.updateOwned(
          ref: command.ownedRef,
          payload: typedCommand.payload,
          updatedAt: now,
          fallbackOwnerUserId: userId,
          fallbackOwnerLabel: userEmail,
        );
        await syncQueue.enqueue(
          ownedItems.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
          ),
        );
        return persisted.ref;
      },
      eventsToEmit: [OwnedItemUpdated(command.ownedRef)],
    );

    return updated;
  }

  Future<void> removeItem(OwnedItemRef ref) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final persisted = await ownedItems.markDeletedByRef(ref, now);
        if (persisted == null) return;
        await syncQueue.enqueue(
          ownedItems.syncChangeForMutation(
            persisted,
            action: 'delete',
            changedAt: now,
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
