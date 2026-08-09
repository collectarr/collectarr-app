import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

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
    required this.events,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingEntriesCacheRepository trackingEntries;
  final TrackingUnitsCacheRepository trackingUnits;
  final WatchSessionsCacheRepository watchSessions;
  final CatalogCacheRepository catalogCache;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final CollectionEventBus events;
  final IdGenerator idGenerator;

  Future<void> updateTrackingEntry(TrackingEntry entry) async {
    final now = DateTime.now().toUtc();
    final updated = entry.copyWith(updatedAt: now);
    await mutationRunner.run(
      action: () async {
        await trackingEntries.upsert(updated);
        await syncQueue.enqueue(_syncChangeForTrackingEntry(updated, 'upsert', now));
      },
      eventsToEmit: [const TrackingChanged()],
    );
  }

Map<String, int>? _normalizeEpisodeRatings(Map<Object, int>? ratings) {
  if (ratings == null) return null;
  return ratings.map((k, v) => MapEntry(k.toString(), v));
}

  Future<void> upsertTrackingEntry(
    Object target, {
    String? ownedItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
    bool allowEmpty = false,
    bool notify = true,
  }) async {
    if (target is TrackingEntry) {
      await updateTrackingEntry(target);
      return;
    }
    final itemId = target.toString();
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final existingEntries = await trackingEntries.findActiveByItemIds([itemId]);
        final existing = existingEntries.isEmpty ? null : existingEntries.first;
        final catalogItem = await catalogCache.findById(itemId);
        final catalogRef = catalogItem?.catalogRefForAnchor(
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            ) ??
            CatalogEntityRef(
              kind: 'comic',
              entityType: CatalogEntityType.work,
              id: itemId,
            );
        final entry = TrackingEntry(
          id: existing?.id ?? idGenerator(),
          catalogRef: catalogRef,
          ownedItemId: ownedItemId ?? existing?.ownedItemId,
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
          episodeRatings: _normalizeEpisodeRatings(episodeRatings) ?? existing?.episodeRatings,
          updatedAt: now,
        );
        await trackingEntries.upsert(entry);
        await syncQueue.enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [if (notify) const TrackingChanged()],
    );
  }

  Future<void> deleteTrackingEntry(TrackingEntry entry, {bool notify = true}) async {
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
      eventsToEmit: [if (notify) const TrackingChanged()],
    );
  }

  Future<void> removeTrackingEntry(TrackingEntry entry, {bool notify = true}) =>
      deleteTrackingEntry(entry, notify: notify);

  Future<void> syncOwnedTrackingEntry(
    OwnedItem item, {
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    Object? sourceType,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final existingEntries = await trackingEntries.findActiveByItemIds([item.itemId]);
        final existing = existingEntries.isEmpty
            ? null
            : existingEntries.firstWhere(
                (e) => e.ownedItemId == item.id,
                orElse: () => existingEntries.first,
              );
        final entry = TrackingEntry(
          id: existing?.id ?? idGenerator(),
          catalogRef: item.catalogRef,
          ownedItemId: item.id,
          editionId: editionId ?? item.editionId,
          variantId: variantId ?? item.variantId,
          bundleReleaseId: bundleReleaseId ?? item.bundleReleaseId,
          status: status ?? item.readStatus ?? existing?.status ?? MediaTrackingStatus.planned,
          rating: rating ?? item.rating ?? existing?.rating,
          notes: notes ?? item.personalNotes ?? existing?.notes,
          startedAt: startedAt ?? item.startedAt ?? existing?.startedAt,
          finishedAt: finishedAt ?? item.finishedAt ?? existing?.finishedAt,
          progressCurrent: progressCurrent ?? existing?.progressCurrent,
          progressTotal: progressTotal ?? existing?.progressTotal,
          seasonNumber: seasonNumber ?? existing?.seasonNumber,
          episodeNumber: episodeNumber ?? existing?.episodeNumber,
          episodeRatings: _normalizeEpisodeRatings(episodeRatings) ?? existing?.episodeRatings,
          sourceType: sourceType ??
              existing?.sourceType ??
              (item.isDigital == true
                  ? TrackingSourceType.digital.apiValue
                  : TrackingSourceType.physical.apiValue),
          updatedAt: now,
        );
        await trackingEntries.upsert(entry);
        await syncQueue.enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
      },
      eventsToEmit: [const TrackingChanged()],
    );
  }

  Future<void> addLocalOnlyTrackingEntry(
    CatalogItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? sourceType,
    Object? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    int? seasonNumber,
    int? episodeNumber,
    Map<Object, int>? episodeRatings,
    bool allowEmpty = false,
  }) async {
    final now = DateTime.now().toUtc();
    final isLocalItem = item.id.startsWith('tmdb-local:');
    await mutationRunner.run(
      action: () async {
        await catalogCache.upsertAll([item]);
        final normalizedAnchorType = resolvePersonalItemAnchorType(
          anchorType: anchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        );
        final entry = TrackingEntry(
          id: idGenerator(),
          catalogRef: item.catalogRefForAnchor(
            anchorType: normalizedAnchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
          ),
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
          episodeRatings: _normalizeEpisodeRatings(episodeRatings),
          updatedAt: now,
        );
        await trackingEntries.upsert(entry);
        if (!isLocalItem) {
          await syncQueue.enqueue(_syncChangeForTrackingEntry(entry, 'upsert', now));
        }
      },
      eventsToEmit: [const TrackingChanged()],
    );
  }

  Future<void> syncTrackingUnit(TrackingUnit unit) async {
    final now = DateTime.now().toUtc();
    final updated = unit.copyWith(updatedAt: now);
    await mutationRunner.run(
      action: () async {
        await trackingUnits.upsert(updated);
        await syncQueue.enqueue(_syncChangeForTrackingUnit(updated, 'upsert', now));
      },
      eventsToEmit: [const TrackingChanged()],
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
    await mutationRunner.run(
      action: () async {
        final unitId = 'ep:${seriesRef.id}:$seasonNumber:$episodeNumber';
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
          await syncQueue.enqueue(_syncChangeForTrackingUnit(unit, 'upsert', now));
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
      eventsToEmit: [const TrackingChanged()],
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

  SyncChange _syncChangeForTrackingUnit(TrackingUnit unit, String action, DateTime now) {
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
