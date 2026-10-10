import 'dart:async';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class LibraryEntryMutations {
  const LibraryEntryMutations({
    required this.libraryEntries,
    required this.wishlist,
    required this.catalogSummaries,
    required this.syncQueue,
    required this.mutationRunner,
    this.trackingMutations,
    this.userId,
    this.userEmail,
    this.idGenerator = _defaultIdGenerator,
  });

  final LibraryEntriesRepository libraryEntries;
  final WishlistItemsCacheRepository wishlist;
  final CatalogDisplaySummaryRepository catalogSummaries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final TrackingMutations? trackingMutations;
  final String? userId;
  final String? userEmail;
  final IdGenerator idGenerator;

  Future<void> updatePersonalData(LibraryEntryRef ref, JsonMap changes) async {
    if (changes.isEmpty) return;
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
        action: () async {
          final persisted = await libraryEntries
              .updatePersonalData(ref, changes, updatedAt: now);
          await syncQueue.enqueue(libraryEntries.syncChangeForMutation(
              persisted,
              action: 'upsert',
              changedAt: now));
        },
        eventsToEmit: [LibraryEntryUpdated(ref)]);
  }

  Future<void> unlinkFromCore(LibraryEntryRef ref) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final persisted =
            await libraryEntries.unlinkFromCore(ref, updatedAt: now);
        await syncQueue.enqueue(libraryEntries.syncChangeForMutation(
          persisted,
          action: 'upsert',
          changedAt: now,
        ));
      },
      eventsToEmit: [LibraryEntryUpdated(ref)],
    );
  }

  Future<void> linkToCore(
      LibraryEntryRef ref, CatalogItemRef catalogRef) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
        action: () async {
          final persisted =
              await libraryEntries.linkToCore(ref, catalogRef, updatedAt: now);
          await syncQueue.enqueue(libraryEntries.syncChangeForMutation(
              persisted,
              action: 'upsert',
              changedAt: now));
        },
        eventsToEmit: [LibraryEntryUpdated(ref)]);
  }

  /// Creates an independent duplicate of the complete local record.
  ///
  /// Catalog and personal fields are copied verbatim. Images and custom-field
  /// values receive new identities and point at the duplicate. The caller may
  /// also copy the current tracking summary; individual listening/watch/read
  /// sessions, loans, and folder membership stay attached to the source entry.
  Future<LibraryEntryRef?> duplicateItem(
    LibraryEntryRef sourceRef, {
    LibraryEntryTrackingDraft? tracking,
  }) async {
    if (await libraryEntries.payloadByRef(sourceRef) == null) return null;
    final now = DateTime.now().toUtc();
    final newId = idGenerator();
    final duplicateRef = LibraryEntryRef(
      kind: sourceRef.kind,
      id: LibraryEntryId(newId),
    );
    return mutationRunner.run(
      action: () async {
        final duplicated = await libraryEntries.duplicateRecord(
          sourceRef,
          newId: newId,
          createdAt: now,
        );
        if (duplicated == null) return null;

        final images = ItemImageRepository(libraryEntries.database);
        for (final image in await images.listForLibraryEntryRef(sourceRef)) {
          await images.add(
            ItemImage(
              id: idGenerator(),
              libraryEntryRef: duplicateRef,
              imageType: image.imageType,
              imageData: image.imageData,
              caption: image.caption,
              sortOrder: image.sortOrder,
              createdAt: now,
            ),
          );
        }

        final customFields = CustomFieldRepository(libraryEntries.database);
        final values = await customFields.listValuesForTarget(
          targetId: sourceRef.key,
          targetScope: CustomFieldTargetScope.libraryEntry,
        );
        await customFields.upsertValues([
          for (final value in values)
            CustomFieldValue(
              id: idGenerator(),
              targetId: duplicateRef.key,
              targetScope: CustomFieldTargetScope.libraryEntry,
              fieldDefinitionId: value.fieldDefinitionId,
              value: value.value,
              updatedAt: now,
            ),
        ]);

        final externalLinks = UserExternalLinksCacheRepository(
          libraryEntries.database,
        );
        final sourceLinks =
            await externalLinks.listByLibraryEntryRef(sourceRef);
        await externalLinks.replaceForLibraryEntry(
          duplicateRef,
          [
            for (final link in sourceLinks)
              link.copyWith(
                id: idGenerator(),
                libraryEntryRef: duplicateRef,
                createdAt: now,
                updatedAt: now,
              ),
          ],
        );

        await syncQueue.enqueue(
          await libraryEntries.syncChangeForCurrentEntry(
            duplicateRef,
            action: 'upsert',
            changedAt: now,
          ),
        );

        if (tracking != null && tracking.hasValues) {
          await trackingMutations?.syncEntryTrackingState(
            duplicateRef,
            sourceType: tracking.sourceType,
            status: tracking.status,
            rating: tracking.rating,
            startedAt: tracking.startedAt,
            finishedAt: tracking.finishedAt,
            notes: tracking.notes,
            progressCurrent: tracking.progressCurrent,
            progressTotal: tracking.progressTotal,
            timesCompleted: tracking.timesCompleted,
          );
        }
        return duplicateRef;
      },
      eventsToEmit: [LibraryEntryAdded(duplicateRef)],
    );
  }

  Future<LibraryEntryRef> addLibraryEntry(
    AddLibraryEntryCommand command, {
    bool enqueueSync = true,
  }) async {
    final now = DateTime.now().toUtc();
    final catalogRef = command.catalogRef;
    final wishlistTargetRef = catalogRef;

    final existingWishlist =
        await wishlist.findActiveByCatalogRef(wishlistTargetRef);
    final existingCatalog =
        (await catalogSummaries.findByRefs([catalogRef]))[catalogRef];
    final wishlistChanged = existingWishlist != null;
    final newItemId = idGenerator();

    final libraryEntryRef = await mutationRunner.run(
      action: () async {
        final resolvedCatalogRef = existingCatalog?.ref ?? catalogRef;
        if (resolvedCatalogRef.kind.isUnknown ||
            resolvedCatalogRef.id.trim().isEmpty) {
          throw StateError(
            'Collection items require a concrete Catalog Item reference; '
            'received ${resolvedCatalogRef.kind.apiValue}:'
            '${resolvedCatalogRef.id}',
          );
        }

        final mediaKind = catalogRef.kind;
        final persisted = await libraryEntries.createLibraryEntry(
          kind: mediaKind,
          payload: command.typedPayload,
          resolvedCatalogRef: resolvedCatalogRef,
          id: newItemId,
          createdAt: now,
          existingIsDigital: command.typedPayload.isDigital ?? false,
          ownerUserId: userId,
          ownerLabel: userEmail,
        );
        if (enqueueSync) {
          await syncQueue.enqueue(
            libraryEntries.syncChangeForMutation(
              persisted,
              action: 'upsert',
              changedAt: now,
            ),
          );
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
        LibraryEntryAdded(
          LibraryEntryRef(
            kind: catalogRef.kind,
            id: LibraryEntryId(newItemId),
          ),
        ),
        if (wishlistChanged) WishlistChanged(wishlistTargetRef),
      ],
    );

    return libraryEntryRef;
  }

  Future<LibraryEntryRef> updateLibraryEntry(
    LibraryEntryUpdateRequest command,
  ) async {
    final typedCommand = command is UpdateLibraryEntryCommand
        ? command
        : throw StateError(
            'Collection mutations require a kind-entry '
            'UpdateLibraryEntryCommand.',
          );
    final now = DateTime.now().toUtc();

    final updated = await mutationRunner.run(
      action: () async {
        final persisted = await libraryEntries.updateLibraryEntry(
          ref: command.libraryEntryRef,
          payload: typedCommand.payload,
          updatedAt: now,
          fallbackOwnerUserId: userId,
          fallbackOwnerLabel: userEmail,
        );
        await syncQueue.enqueue(
          libraryEntries.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
          ),
        );
        return persisted.ref;
      },
      eventsToEmit: [LibraryEntryUpdated(command.libraryEntryRef)],
    );

    return updated;
  }

  Future<void> updateCatalogData(
    LibraryEntryRef ref,
    JsonMap catalogData,
  ) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final persisted = await libraryEntries.updateCatalogData(
          ref: ref,
          catalogData: catalogData,
          updatedAt: now,
        );
        await syncQueue.enqueue(
          libraryEntries.syncChangeForMutation(
            persisted,
            action: 'upsert',
            changedAt: now,
          ),
        );
      },
      eventsToEmit: [LibraryEntryUpdated(ref)],
    );
  }

  Future<void> removeItem(LibraryEntryRef ref) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final persisted = await libraryEntries.markDeletedByRef(ref, now);
        if (persisted == null) return;
        await syncQueue.enqueue(
          libraryEntries.syncChangeForMutation(
            persisted,
            action: 'delete',
            changedAt: now,
          ),
        );
      },
      eventsToEmit: [LibraryEntryRemoved(ref)],
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
