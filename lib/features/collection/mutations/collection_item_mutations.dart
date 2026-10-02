import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/ownership/collection_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CollectionItemMutations {
  const CollectionItemMutations({
    required this.collectionItems,
    required this.wishlist,
    required this.catalogSummaries,
    required this.syncQueue,
    required this.mutationRunner,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final CollectionItemsRepository collectionItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogDisplaySummaryRepository catalogSummaries;
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
  Future<CollectionItemRef?> duplicateItem(
    CollectionItemRef sourceRef, {
    CollectionItemTrackingDraft? tracking,
  }) async {
    final payload = await collectionItems.createPayloadByRef(sourceRef);
    if (payload == null) return null;
    return addCollectionItem(
      AddCollectionItemCommand(
        catalogRef: payload.catalogRef,
        typedPayload: payload,
        tracking: tracking,
      ),
    );
  }

  Future<CollectionItemRef> addCollectionItem(
    AddCollectionItemCommand command,
  ) async {
    final now = DateTime.now().toUtc();
    final catalogRef = command.catalogRef;
    final wishlistTargetRef = catalogRef.toCatalogItemRef();

    final existingWishlist =
        await wishlist.findActiveByCatalogRef(wishlistTargetRef);
    final existingCatalog =
        (await catalogSummaries.findByRefs([catalogRef]))[catalogRef];
    final wishlistChanged = existingWishlist != null;
    final newItemId = idGenerator();

    final collectionItemRef = await mutationRunner.run(
      action: () async {
        final resolvedCatalogRef = existingCatalog?.ref ?? catalogRef;
        if (resolvedCatalogRef.entityType != CatalogEntityTypeId.catalogItem ||
            !resolvedCatalogRef.isKnown) {
          throw StateError(
            'Collection items require a concrete Catalog Item reference; '
            'received ${resolvedCatalogRef.entityType.apiValue}:'
            '${resolvedCatalogRef.id}',
          );
        }

        final mediaKind = catalogRef.mediaKind;
        final persisted = await collectionItems.createCollectionItem(
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
          collectionItems.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
          ),
        );

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
        CollectionItemAdded(
          CollectionItemRef(
            kind: catalogRef.mediaKind,
            id: CollectionItemId(newItemId),
          ),
        ),
        if (wishlistChanged) WishlistChanged(wishlistTargetRef),
      ],
    );

    return collectionItemRef;
  }

  Future<CollectionItemRef> updateCollectionItem(
    CollectionItemUpdateRequest command,
  ) async {
    final typedCommand = command is UpdateCollectionItemCommand
        ? command
        : throw StateError(
            'Collection mutations require a kind-owned '
            'UpdateCollectionItemCommand.',
          );
    final now = DateTime.now().toUtc();

    final updated = await mutationRunner.run(
      action: () async {
        final persisted = await collectionItems.updateCollectionItem(
          ref: command.collectionItemRef,
          payload: typedCommand.payload,
          updatedAt: now,
          fallbackOwnerUserId: userId,
          fallbackOwnerLabel: userEmail,
        );
        await syncQueue.enqueue(
          collectionItems.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
          ),
        );
        return persisted.ref;
      },
      eventsToEmit: [CollectionItemUpdated(command.collectionItemRef)],
    );

    return updated;
  }

  Future<void> removeItem(CollectionItemRef ref) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final persisted = await collectionItems.markDeletedByRef(ref, now);
        if (persisted == null) return;
        await syncQueue.enqueue(
          collectionItems.syncChangeForMutation(
            persisted,
            action: 'delete',
            changedAt: now,
          ),
        );
      },
      eventsToEmit: [CollectionItemRemoved(ref)],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

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
