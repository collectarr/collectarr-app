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
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:uuid/uuid.dart';

export 'package:collectarr_app/core/models/tracking_target.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

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
  final WatchSessionsCacheRepository watchSessions;
  final CatalogCacheRepository catalogCache;
  final OwnedItemsCacheRepository? ownedItems;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> updateTrackingEntry(TrackingEntry entry) async {
    final now = DateTime.now().toUtc();
    final updated = entry.copyWith(updatedAt: now);
    await mutationRunner.run(
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
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    Map<String, int>? episodeRatings,
    bool allowEmpty = false,
    bool notify = true,
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
              catalogRef = cat.catalogRefForAnchor(
                anchorType: anchorType,
                editionId: editionId,
                variantId: variantId,
                bundleReleaseId: bundleReleaseId,
              );
            } else {
              throw ArgumentError(
                  'Owned item not found for tracking target: $ownedItemId');
            }
          }
        } else {
          final cat = await catalogCache.findById(ownedItemId);
          if (cat != null) {
            catalogRef = cat.catalogRefForAnchor(
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            );
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
      action: () async {
        final existingCatalog = await catalogCache.findById(catalogRef.id);
        if (existingCatalog == null) {
          await catalogCache.upsertMetadataItems([
            LibraryMetadataItem.fromMetadataMap({
              'id': catalogRef.id,
              'kind': catalogRef.kind,
              'title': catalogRef.id,
            }),
          ]);
        }
        final entry = TrackingEntry(
          id: entryId,
          catalogRef: catalogRef,
          ownedItemId: targetOwnedItemId ?? existing?.ownedItemId,
          editionId: editionId ?? existing?.editionId,
          variantId: variantId ?? existing?.variantId,
          bundleReleaseId: bundleReleaseId ?? existing?.bundleReleaseId,
          sourceType: sourceType ?? existing?.sourceType,
          status: status ?? existing?.status ?? MediaTrackingStatus.planned,
          rating: rating ?? existing?.rating,
          startedAt: startedAt ?? existing?.startedAt,
          finishedAt: finishedAt ?? existing?.finishedAt,
          progressCurrent: progressCurrent ?? existing?.progressCurrent,
          progressTotal: progressTotal ?? existing?.progressTotal,
          timesCompleted: timesCompleted ?? existing?.timesCompleted,
          notes: notes ?? existing?.notes,
          seasonNumber: seasonNumber ?? existing?.seasonNumber,
          episodeNumber: episodeNumber ?? existing?.episodeNumber,
          episodeRatings: episodeRatings ?? existing?.episodeRatings,
          updatedAt: now,
        );
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(entryId)],
    );
  }

  Future<void> deleteTrackingEntry(TrackingEntry entry,
      {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
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
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingSourceType? sourceType,
    int? seasonNumber,
    int? episodeNumber,
    Map<String, int>? episodeRatings,
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

    await mutationRunner.run(
      action: () async {
        final entry = TrackingEntry(
          id: entryId,
          catalogRef: item.catalogRef,
          ownedItemId: item.id,
          editionId: editionId ?? item.editionId,
          variantId: variantId ?? item.variantId,
          bundleReleaseId: bundleReleaseId ?? item.bundleReleaseId,
          status: status ??
              mediaTrackingStatusFromValue(item.readStatus) ??
              existing?.status ??
              MediaTrackingStatus.planned,
          rating: rating ?? item.rating ?? existing?.rating,
          notes: notes ?? item.personalNotes ?? existing?.notes,
          startedAt: startedAt ?? item.startedAt ?? existing?.startedAt,
          finishedAt: finishedAt ?? item.finishedAt ?? existing?.finishedAt,
          progressCurrent: progressCurrent ?? existing?.progressCurrent,
          progressTotal: progressTotal ?? existing?.progressTotal,
          seasonNumber: seasonNumber ?? existing?.seasonNumber,
          episodeNumber: episodeNumber ?? existing?.episodeNumber,
          episodeRatings: episodeRatings ?? existing?.episodeRatings,
          sourceType: sourceType ??
              existing?.sourceType ??
              (item.isDigital == true
                  ? TrackingSourceType.digital
                  : TrackingSourceType.physical),
          updatedAt: now,
        );
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [TrackingChanged(entryId)],
    );
  }

  Future<void> addLocalOnlyTrackingEntry(
    dynamic item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    int? seasonNumber,
    int? episodeNumber,
    Map<String, int>? episodeRatings,
    bool allowEmpty = false,
  }) async {
    final now = DateTime.now().toUtc();
    final itemId =
        item is LibraryMetadataItem ? item.id : (item as CatalogItem).id;
    final itemKind =
        item is LibraryMetadataItem ? item.kind : (item as CatalogItem).kind;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    final entryId = idGenerator();
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([item]);
        final normalizedAnchorType = resolvePersonalItemAnchorType(
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        );
        final catalogRef = item is CatalogItem
            ? item.catalogRefForAnchor(
                anchorType: normalizedAnchorType,
                editionId: editionId,
                variantId: variantId,
                bundleReleaseId: bundleReleaseId,
              )
            : CatalogEntityRef(
                kind: itemKind,
                entityType: normalizedAnchorType == 'edition'
                    ? CatalogEntityType.edition
                    : (normalizedAnchorType == 'variant'
                        ? CatalogEntityType.release
                        : (normalizedAnchorType == 'bundle_release'
                            ? CatalogEntityType.bundleRelease
                            : CatalogEntityType.work)),
                id: variantId ?? editionId ?? bundleReleaseId ?? itemId,
              );
        final entry = TrackingEntry(
          id: entryId,
          catalogRef: catalogRef,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
          sourceType: sourceType,
          status: status,
          rating: rating,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          episodeRatings: episodeRatings,
          updatedAt: now,
        );
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

  Future<void> setTrackingEpisodeCompleted(
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    required int episodeNumber,
    bool isCompleted = true,
    bool? completed,
  }) async {
    final resolvedIsCompleted = completed ?? isCompleted;
    final now = DateTime.now().toUtc();
    final unitId = 'ep:${seriesRef.id}:$seasonNumber:$episodeNumber';
    await mutationRunner.run(
      action: () async {
        final existing = await trackingUnits.findById(unitId);
        if (resolvedIsCompleted) {
          final unit = TrackingUnit(
            id: unitId,
            targetRef: seriesRef,
            unitType: TrackingUnitType.episode,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            completedAt: now,
            updatedAt: now,
          );
          await trackingUnits.upsert(unit);
          await syncQueue
              .enqueue(_syncChangeForTrackingUnit(unit, 'upsert', now));
        } else if (existing != null) {
          await trackingUnits.markDeleted(existing, now);
          await syncQueue.enqueue(
            _syncChangeForTrackingUnit(
              existing.copyWith(updatedAt: now, deletedAt: now),
              'delete',
              now,
            ),
          );
        }
      },
      eventsToEmit: [TrackingChanged(unitId)],
    );
  }

  Future<void> setSeasonEpisodesCompleted(
    CatalogEntityRef seriesRef, {
    required int seasonNumber,
    int? episodeCount,
    Iterable<int>? episodeNumbers,
    bool isCompleted = true,
    bool? completed,
  }) async {
    final resolvedIsCompleted = completed ?? isCompleted;
    final eps = episodeNumbers ??
        (episodeCount != null
            ? List.generate(episodeCount, (i) => i + 1)
            : const <int>[]);
    for (final ep in eps) {
      await setTrackingEpisodeCompleted(
        seriesRef,
        seasonNumber: seasonNumber,
        episodeNumber: ep,
        isCompleted: resolvedIsCompleted,
      );
    }
  }

  SyncChange _syncChangeForTrackingEntry(
      TrackingEntry entry, String action, DateTime now) {
    return SyncChange(
      id: 'tracking_entry:${entry.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: entry.id,
      action: action,
      payload: entry.toSyncPayload(),
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
