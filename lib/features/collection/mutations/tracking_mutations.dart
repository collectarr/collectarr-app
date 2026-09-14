import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_target.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/ownership/owned_items_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

export 'package:collectarr_app/core/models/tracking_target.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class TrackingMutations {
  const TrackingMutations({
    required this.trackingLifecycles,
    required this.trackingUnits,
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
    this.ownedItems,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingStorageRepository trackingLifecycles;
  final TrackingUnitStorageRepository trackingUnits;
  final WatchSessionsRepository watchSessions;
  final OwnedItemsRepository? ownedItems;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  /// Updates a mixed/global tracking projection without exposing the
  /// kind-owned lifecycle aggregate to the caller.
  Future<void> updateTrackingSummary(
    TrackingSummary entry, {
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    TrackingProgressSnapshot? progress,
    String? notes,
    MutationOrigin origin = MutationOrigin.user,
  }) {
    final target = entry.ownedRef == null
        ? TrackingTarget.catalog(entry.catalogRef)
        : TrackingTarget.owned(entry.ownedRef!);
    final resolvedProgress = progress ?? entry.progress;
    return upsertTrackingLifecycle(
      target,
      targetRef: entry.catalogRef,
      sourceType: entry.sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: resolvedProgress.current,
      progressTotal: resolvedProgress.total,
      timesCompleted: resolvedProgress.timesCompleted,
      notes: notes,
      origin: origin,
    );
  }

  Future<void> upsertTrackingLifecycle(
    TrackingTarget target, {
    CatalogEntityRef? targetRef,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingKindPatch? kindPatch,
    bool allowEmpty = false,
    bool notify = true,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    late CatalogEntityRef catalogRef;
    OwnedItemRef? targetOwnedRef;

    switch (target) {
      case CatalogTrackingTarget(:final ref):
        catalogRef = targetRef ?? ref;
      case OwnedItemTrackingTarget(:final ownedRef):
        targetOwnedRef = ownedRef;
        if (ownedItems != null) {
          final owned = await ownedItems!.findSummaryByRef(ownedRef);
          if (owned != null && owned.ref.kind != ownedRef.kind) {
            throw ArgumentError(
              'Owned tracking reference kind ${ownedRef.kind.apiValue} '
              'does not match persisted kind ${owned.ref.kind.apiValue}.',
            );
          }
          if (targetRef != null) {
            catalogRef = targetRef;
          } else if (owned?.catalogRef != null) {
            catalogRef = owned!.catalogRef!;
          } else {
            throw ArgumentError(
              'Owned tracking requires a CatalogEntityRef when the owned '
              'summary has no catalog target: ${ownedRef.key}',
            );
          }
        } else {
          throw ArgumentError(
            'Owned tracking requires a CatalogEntityRef when no owned '
            'repository is configured: ${ownedRef.key}',
          );
        }
    }

    final entryId = idGenerator();

    await mutationRunner.run(
      origin: origin,
      localRef: catalogRef,
      action: () async {
        final serialized = await trackingLifecycles.upsertMutation(
          id: entryId,
          catalogRef: catalogRef,
          ownedRef: targetOwnedRef,
          sourceType: sourceType,
          status: status,
          rating: rating,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          notes: notes,
          kindPatch: kindPatch,
          updatedAt: now,
        );
        await syncQueue.enqueue(
          _syncChangeForTrackingLifecycle(serialized, 'upsert', now),
        );
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  /// Deletes a tracking row selected from a structural Shelf summary.
  ///
  /// Mixed/global UI carries the structural kind/id ref only. The repository
  /// resolves the v1 row at the mutation boundary.
  Future<void> removeTrackingByRef(
    TrackingLifecycleRef ref, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final serialized = await trackingLifecycles.markDeletedByRef(ref, now);
        if (serialized != null) {
          await syncQueue.enqueue(
            _syncChangeForTrackingLifecycle(serialized, 'delete', now),
          );
        }
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> syncOwnedTrackingLifecycle(
    OwnedItemRef ownedRef, {
    CatalogEntityRef? catalogRef,
    bool? isDigital,
    CatalogEntityRef? targetRef,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingSourceType? sourceType,
    TrackingKindPatch? kindPatch,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final ownedSummary = catalogRef == null
        ? await ownedItems?.findSummaryByRef(ownedRef)
        : null;
    final baseCatalogRef = targetRef ?? catalogRef ?? ownedSummary?.catalogRef;
    if (baseCatalogRef == null) {
      throw StateError(
        'Cannot resolve catalog reference for owned tracking target '
        '${ownedRef.id.value}',
      );
    }
    final resolvedCatalogRef = baseCatalogRef;
    final resolvedIsDigital = ownedSummary?.isDigital ?? isDigital;
    final entryId = idGenerator();
    await mutationRunner.run(
      origin: origin,
      localRef: resolvedCatalogRef,
      action: () async {
        final serialized = await trackingLifecycles.upsertMutation(
          id: entryId,
          catalogRef: resolvedCatalogRef,
          ownedRef: ownedRef,
          status: status,
          rating: rating,
          notes: notes,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          sourceType: sourceType ??
              (resolvedIsDigital == true
                  ? TrackingSourceType.digital
                  : TrackingSourceType.physical),
          kindPatch: kindPatch,
          updatedAt: now,
        );
        await syncQueue.enqueue(
          _syncChangeForTrackingLifecycle(serialized, 'upsert', now),
        );
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> addLocalOnlyTrackingLifecycle(
    CatalogEntityRef catalogRef, {
    CatalogEntityRef? targetRef,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    TrackingKindPatch? kindPatch,
    bool allowEmpty = false,
    MutationOrigin origin = MutationOrigin.user,
  }) async {
    final now = DateTime.now().toUtc();
    final itemId = catalogRef.id;
    final isLocalItem = itemId.startsWith('tmdb-local:');
    final entryId = idGenerator();
    final resolvedCatalogRef = targetRef ?? catalogRef;
    await mutationRunner.run(
      origin: origin,
      localRef: resolvedCatalogRef,
      action: () async {
        final serialized = await trackingLifecycles.upsertMutation(
          id: entryId,
          catalogRef: resolvedCatalogRef,
          sourceType: sourceType,
          status: status,
          rating: rating,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          kindPatch: kindPatch,
          updatedAt: now,
        );
        if (!isLocalItem) {
          await syncQueue.enqueue(
            _syncChangeForTrackingLifecycle(serialized, 'upsert', now),
          );
        }
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> syncTrackingUnit(TrackingUnitSummary unit) async {
    final now = DateTime.now().toUtc();
    final updated = unit.copyWith(updatedAt: now);
    await mutationRunner.run(
      action: () async {
        await trackingUnits.upsert(updated);
        await syncQueue
            .enqueue(_syncChangeForTrackingUnit(updated, 'upsert', now));
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  SyncChange _syncChangeForTrackingLifecycle(
      TrackingStorageSyncRecord record, String action, DateTime now) {
    return SyncChange(
      id: 'tracking_entry:${record.ref.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'tracking_entry',
      entityId: record.ref.id,
      action: action,
      payload: record.payload,
      clientChangedAt: now,
    );
  }

  SyncChange _syncChangeForTrackingUnit(
      TrackingUnitSummary unit, String action, DateTime now) {
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
