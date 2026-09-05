import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';

/// TV-owned episode progress mutations.
///
/// Episode coordinates and the generated tracking-unit identity belong to TV;
/// the collection layer only provides persistence, sync, and event mechanics.
final class TvTrackingUnitMutations {
  const TvTrackingUnitMutations({
    required this.trackingUnits,
    required this.syncQueue,
    required this.mutationRunner,
  });

  final TrackingUnitsCacheRepository trackingUnits;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;

  Future<void> setEpisodeCompleted(
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
      localRef: seriesRef,
      action: () async {
        final existing = await trackingUnits.findById(unitId);
        if (resolvedIsCompleted) {
          final unit = TvTrackingUnit(
            id: unitId,
            targetRef: seriesRef,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            completedAt: now,
            updatedAt: now,
          );
          await trackingUnits.upsert(unit);
          await syncQueue.enqueue(_syncChangeForUnit(unit, 'upsert', now));
        } else if (existing != null) {
          await trackingUnits.markDeleted(existing, now);
          await syncQueue.enqueue(
            _syncChangeForUnit(
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
    final episodes = episodeNumbers ??
        (episodeCount != null
            ? List.generate(episodeCount, (index) => index + 1)
            : const <int>[]);
    for (final episodeNumber in episodes) {
      await setEpisodeCompleted(
        seriesRef,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        isCompleted: resolvedIsCompleted,
      );
    }
  }

  SyncChange _syncChangeForUnit(
    TrackingUnit unit,
    String action,
    DateTime now,
  ) {
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
