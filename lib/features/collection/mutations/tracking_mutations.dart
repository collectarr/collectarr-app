import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_target.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

export 'package:collectarr_app/core/models/tracking_target.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

/// Structural hook for kind-owned tracking fields during mutation.
///
/// Collection owns persistence and mutation mechanics. A kind may enrich the
/// common lifecycle entry before it is stored, without making the
/// collection API depend on that kind's semantic fields.
typedef TrackingEntryCustomizer = TrackingEntry Function(
  TrackingEntry entry,
);

final class TrackingMutations {
  const TrackingMutations({
    required this.trackingEntries,
    required this.trackingUnits,
    required this.watchSessions,
    required this.catalogCache,
    required this.syncQueue,
    required this.mutationRunner,
    this.ownedItems,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingEntriesCacheRepository trackingEntries;
  final TrackingUnitsCacheRepository trackingUnits;
  final WatchSessionsRepository watchSessions;
  final LibraryCatalogRepository catalogCache;
  final OwnedItemsCacheRepository? ownedItems;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> updateTrackingEntry(
    TrackingEntry entry, {
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = entry.copyWith(updatedAt: now);
    await mutationRunner.run(
      origin: origin,
      localRef: updated.catalogRef,
      action: () async {
        await trackingEntries.upsert(updated);
        await syncQueue
            .enqueue(_syncChangeForTrackingEntry(updated, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(updated.id)],
    );
  }

  Future<void> upsertTrackingEntry(
    TrackingTarget target, {
    String? ownedItemId,
    PersonalItemAnchor? anchor,
    bool replaceAnchor = false,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingEntryCustomizer? customizeEntry,
    bool allowEmpty = false,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    late final CatalogEntityRef catalogRef;
    String? targetOwnedItemId = ownedItemId;

    switch (target) {
      case CatalogTrackingTarget(:final ref):
        catalogRef = ref;
      case OwnedItemTrackingTarget(:final ownedItemId):
        targetOwnedItemId = ownedItemId;
        if (ownedItems != null) {
          final owned = await ownedItems!.findById(ownedItemId);
          if (owned != null) {
            catalogRef = owned.catalogRef;
          } else {
            final cat = await catalogCache.findById(ownedItemId);
            if (cat != null) {
              catalogRef = cat.catalogRefForPersonalAnchor(anchor);
            } else {
              throw ArgumentError(
                  'Owned item not found for tracking target: $ownedItemId');
            }
          }
        } else {
          final cat = await catalogCache.findById(ownedItemId);
          if (cat != null) {
            catalogRef = cat.catalogRefForPersonalAnchor(anchor);
          } else {
            throw ArgumentError(
                'Cannot resolve valid CatalogEntityRef for tracking target: $ownedItemId');
          }
        }
    }

    final existingEntries =
        await trackingEntries.findActiveByItemIds([catalogRef.id]);
    final existing = existingEntries.isEmpty ? null : existingEntries.first;
    final entryId = existing?.id ?? idGenerator();

    await mutationRunner.run(
      origin: origin,
      localRef: catalogRef,
      action: () async {
        final existingCatalog = await catalogCache.findById(catalogRef.id);
        if (existingCatalog == null) {
          await catalogCache.upsertMetadataItems([
            typedCatalogItemFromMap({
              'id': catalogRef.id,
              'kind': catalogRef.kind,
              'title': catalogRef.id,
            }),
          ]);
        }
        final baseEntry = existing?.copyWith(
              id: entryId,
              catalogRef: catalogRef,
              ownedItemId: targetOwnedItemId ?? existing.ownedItemId,
              editionId: replaceAnchor
                  ? anchor?.editionId
                  : anchor?.editionId ?? existing.editionId,
              variantId: replaceAnchor
                  ? anchor?.variantId
                  : anchor?.variantId ?? existing.variantId,
              bundleReleaseId: replaceAnchor
                  ? anchor?.bundleReleaseId
                  : anchor?.bundleReleaseId ?? existing.bundleReleaseId,
              sourceType: sourceType ?? existing.sourceType,
              status: status ?? existing.status ?? MediaTrackingStatus.planned,
              rating: rating ?? existing.rating,
              startedAt: startedAt ?? existing.startedAt,
              finishedAt: finishedAt ?? existing.finishedAt,
              progressCurrent: progressCurrent ?? existing.progressCurrent,
              progressTotal: progressTotal ?? existing.progressTotal,
              timesCompleted: timesCompleted ?? existing.timesCompleted,
              notes: notes ?? existing.notes,
              updatedAt: now,
            ) ??
            TrackingEntry(
              id: entryId,
              catalogRef: catalogRef,
              ownedItemId: targetOwnedItemId,
              editionId: anchor?.editionId,
              variantId: anchor?.variantId,
              bundleReleaseId: anchor?.bundleReleaseId,
              sourceType: sourceType,
              status: status ?? MediaTrackingStatus.planned,
              rating: rating,
              startedAt: startedAt,
              finishedAt: finishedAt,
              progressCurrent: progressCurrent,
              progressTotal: progressTotal,
              timesCompleted: timesCompleted,
              notes: notes,
              updatedAt: now,
            );
        final entry = customizeEntry?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(entryId)],
    );
  }

  Future<void> deleteTrackingEntry(
    TrackingEntry entry, {
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      origin: origin,
      localRef: entry.catalogRef,
      action: () async {
        await trackingEntries.markDeleted(entry, now);
        await syncQueue.enqueue(
          _syncChangeForTrackingEntry(
            entry.copyWith(updatedAt: now, deletedAt: now),
            'delete',
            now,
          ),
        );
      },
      eventsToEmit: [TrackingChanged(entry.id)],
    );
  }

  Future<void> removeTrackingEntry(TrackingEntry entry, {bool notify = true}) =>
      deleteTrackingEntry(entry, notify: notify);

  Future<void> syncOwnedTrackingEntry(
    OwnedItem item, {
    PersonalItemAnchor? anchor,
    bool replaceAnchor = false,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingSourceType? sourceType,
    TrackingEntryCustomizer? customizeEntry,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final existingEntries =
        await trackingEntries.findActiveByItemIds([item.itemId]);
    final existing = existingEntries.isEmpty
        ? null
        : existingEntries.firstWhere(
            (e) => e.ownedItemId == item.id,
            orElse: () => existingEntries.first,
          );
    final entryId = existing?.id ?? idGenerator();
    final inheritedEditionId =
        existing?.anchor?.editionId ?? item.anchor?.editionId;
    final inheritedVariantId =
        existing?.anchor?.variantId ?? item.anchor?.variantId;
    final inheritedBundleReleaseId =
        existing?.anchor?.bundleReleaseId ?? item.anchor?.bundleReleaseId;

    await mutationRunner.run(
      origin: origin,
      localRef: item.catalogRef,
      action: () async {
        final baseEntry = existing?.copyWith(
              id: entryId,
              catalogRef: item.catalogRef,
              ownedItemId: item.id,
              editionId: replaceAnchor
                  ? anchor?.editionId
                  : anchor?.editionId ?? inheritedEditionId,
              variantId: replaceAnchor
                  ? anchor?.variantId
                  : anchor?.variantId ?? inheritedVariantId,
              bundleReleaseId: replaceAnchor
                  ? anchor?.bundleReleaseId
                  : anchor?.bundleReleaseId ?? inheritedBundleReleaseId,
              status: status ?? existing.status ?? MediaTrackingStatus.planned,
              rating: rating ?? existing.rating,
              notes: notes ?? existing.notes,
              startedAt: startedAt ?? existing.startedAt,
              finishedAt: finishedAt ?? existing.finishedAt,
              progressCurrent: progressCurrent ?? existing.progressCurrent,
              progressTotal: progressTotal ?? existing.progressTotal,
              sourceType: sourceType ??
                  existing.sourceType ??
                  (item.isDigital == true
                      ? TrackingSourceType.digital
                      : TrackingSourceType.physical),
              updatedAt: now,
            ) ??
            TrackingEntry(
              id: entryId,
              catalogRef: item.catalogRef,
              ownedItemId: item.id,
              editionId: replaceAnchor
                  ? anchor?.editionId
                  : anchor?.editionId ?? inheritedEditionId,
              variantId: replaceAnchor
                  ? anchor?.variantId
                  : anchor?.variantId ?? inheritedVariantId,
              bundleReleaseId: replaceAnchor
                  ? anchor?.bundleReleaseId
                  : anchor?.bundleReleaseId ?? inheritedBundleReleaseId,
              status: status ?? MediaTrackingStatus.planned,
              rating: rating,
              notes: notes,
              startedAt: startedAt,
              finishedAt: finishedAt,
              progressCurrent: progressCurrent,
              progressTotal: progressTotal,
              sourceType: sourceType ??
                  (item.isDigital == true
                      ? TrackingSourceType.digital
                      : TrackingSourceType.physical),
              updatedAt: now,
            );
        final entry = customizeEntry?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(entryId)],
    );
  }

  Future<void> addLocalOnlyTrackingEntry(
    CatalogItem item, {
    PersonalItemAnchor? anchor,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    TrackingEntryCustomizer? customizeEntry,
    bool allowEmpty = false,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final metadataItem = typedCatalogItemFromCatalogItem(item);
    final itemId = metadataItem.id;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    final entryId = idGenerator();
    final catalogRef = metadataItem.catalogRefForPersonalAnchor(anchor);
    await mutationRunner.run(
      origin: origin,
      localRef: catalogRef,
      action: () async {
        await catalogCache.upsertAll([item]);
        final baseEntry = TrackingEntry(
          id: entryId,
          catalogRef: catalogRef,
          editionId: anchor?.editionId,
          variantId: anchor?.variantId,
          bundleReleaseId: anchor?.bundleReleaseId,
          sourceType: sourceType,
          status: status,
          rating: rating,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          updatedAt: now,
        );
        final entry = customizeEntry?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        if (!isLocalItem) {
          await syncQueue
              .enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
        }
      },
      eventsToEmit: [TrackingChanged(entryId)],
    );
  }

  Future<void> syncTrackingUnit(TrackingUnit unit) async {
    final now = DateTime.now().toUtc();
    final updated = unit.copyWith(updatedAt: now);
    await mutationRunner.run(
      action: () async {
        await trackingUnits.upsert(updated);
        await syncQueue
            .enqueue(_syncChangeForTrackingUnit(updated, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(updated.id)],
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

  SyncChange _syncChangeForTrackingUnit(
      TrackingUnit unit, String action, DateTime now) {
    return SyncChange(
      id: 'tracking_unit:${unit.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_unit',
      entityId: unit.id,
      action: action,
      payload: unit.toSyncPayload(),
      clientChangedAt: now,
    );
  }
}
