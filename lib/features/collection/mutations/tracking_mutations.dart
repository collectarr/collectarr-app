import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_target.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/ownership/collection_items_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace_contributors.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

export 'package:collectarr_app/core/models/tracking_target.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class TrackingMutations {
  const TrackingMutations({
    required this.trackingRecords,
    required this.trackingUnits,
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
    this.collectionItems,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingStorageRepository trackingRecords;
  final TrackingUnitStorageRepository trackingUnits;
  final WatchSessionsRepository watchSessions;
  final CollectionItemsRepository? collectionItems;
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
  }) {
    final target = entry.collectionItemRef == null
        ? TrackingTarget.catalog(entry.catalogRef)
        : TrackingTarget.owned(entry.collectionItemRef!);
    final resolvedProgress = progress ?? entry.progress;
    return upsertTrackingState(
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
    );
  }

  Future<void> upsertTrackingState(
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
  }) async {
    final now = DateTime.now().toUtc();
    late CatalogEntityRef catalogRef;
    CollectionItemRef? targetCollectionItemRef;

    switch (target) {
      case CatalogTrackingTarget(:final ref):
        catalogRef = targetRef ?? ref;
      case CollectionItemTrackingTarget(:final collectionItemRef):
        targetCollectionItemRef = collectionItemRef;
        if (collectionItems != null) {
          final owned =
              await collectionItems!.findSummaryByRef(collectionItemRef);
          if (owned != null && owned.ref.kind != collectionItemRef.kind) {
            throw ArgumentError(
              'Owned tracking reference kind ${collectionItemRef.kind.apiValue} '
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
              'summary has no catalog target: ${collectionItemRef.key}',
            );
          }
        } else {
          throw ArgumentError(
            'Owned tracking requires a CatalogEntityRef when no owned '
            'repository is configured: ${collectionItemRef.key}',
          );
        }
    }

    final entryId = idGenerator();

    await mutationRunner.run(
      action: () async {
        final serialized = await trackingRecords.upsertMutation(
          id: entryId,
          catalogRef: catalogRef,
          collectionItemRef: targetCollectionItemRef,
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
          _syncChangeForTrackingState(serialized, 'upsert', now),
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
    TrackingStateRef ref, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await mutationRunner.run(
      action: () async {
        final serialized = await trackingRecords.markDeletedByRef(ref, now);
        if (serialized != null) {
          await syncQueue.enqueue(
            _syncChangeForTrackingState(serialized, 'delete', now),
          );
        }
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> syncOwnedTrackingState(
    CollectionItemRef collectionItemRef, {
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
  }) async {
    final now = DateTime.now().toUtc();
    final collectionItemSummary = catalogRef == null
        ? await collectionItems?.findSummaryByRef(collectionItemRef)
        : null;
    final baseCatalogRef = targetRef ??
        catalogRef ??
        collectionItemSummary?.catalogRef ??
        collectionItemSummary?.catalogRef;
    if (baseCatalogRef == null) {
      throw StateError(
        'Cannot resolve catalog reference for owned tracking target '
        '${collectionItemRef.id.value}',
      );
    }
    final resolvedCatalogRef = baseCatalogRef;
    final resolvedIsDigital = collectionItemSummary?.isDigital ?? isDigital;
    final trackingTopology =
        libraryTrackingTopologyForKind(resolvedCatalogRef.mediaKind);
    if (trackingTopology.usesCatalogTargetForOwnedTracking) {
      // Some kinds intentionally collapse an owned action into a catalog
      // lifecycle entry. The owning kind declares that policy in its
      // tracking topology; the generic mutation does not inspect the kind.
      return upsertTrackingState(
        TrackingTarget.catalog(resolvedCatalogRef),
        targetRef: resolvedCatalogRef,
        status: status,
        rating: rating,
        startedAt: startedAt,
        finishedAt: finishedAt,
        progressCurrent: progressCurrent,
        progressTotal: progressTotal,
        timesCompleted: timesCompleted,
        notes: notes,
        sourceType: sourceType ??
            (resolvedIsDigital == true
                ? TrackingSourceType.digital
                : TrackingSourceType.physical),
        kindPatch: kindPatch,
      );
    }
    final entryId = idGenerator();
    await mutationRunner.run(
      action: () async {
        final serialized = await trackingRecords.upsertMutation(
          id: entryId,
          catalogRef: resolvedCatalogRef,
          collectionItemRef: collectionItemRef,
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
          _syncChangeForTrackingState(serialized, 'upsert', now),
        );
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

  SyncChange _syncChangeForTrackingState(
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
