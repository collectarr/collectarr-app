import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_target.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_unit_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
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
typedef TrackingLifecycleCustomizer = TrackingLifecycle Function(
  TrackingLifecycle entry,
);

final class TrackingMutations {
  const TrackingMutations({
    required this.trackingEntries,
    required this.trackingUnits,
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
    this.ownedItems,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingLifecycleRepository trackingEntries;
  final TrackingUnitRepository trackingUnits;
  final WatchSessionsRepository watchSessions;
  final OwnedItemsRepository? ownedItems;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<void> updateTrackingLifecycle(
    TrackingLifecycle entry, {
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
            .enqueue(_syncChangeForTrackingLifecycle(updated, 'upsert', now));
      },
      eventsToEmit: const [TrackingChanged()],
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
    TrackingLifecycleCustomizer? customizeLifecycle,
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

    final existingEntries =
        await trackingEntries.findActiveByCatalogRoots([catalogRef]);
    final existing = existingEntries.isEmpty ? null : existingEntries.first;
    final entryId = existing?.id ?? idGenerator();

    await mutationRunner.run(
      origin: origin,
      localRef: catalogRef,
      action: () async {
        final baseEntry = existing?.copyWith(
              id: entryId,
              catalogRef: catalogRef,
              ownedRef: targetOwnedRef ?? existing.ownedRef,
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
            trackingEntries.create(
              id: entryId,
              catalogRef: catalogRef,
              ownedRef: targetOwnedRef,
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
        final entry = customizeLifecycle?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingLifecycle(entry, 'upsert', now));
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> deleteTrackingLifecycle(
    TrackingLifecycle entry, {
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
          _syncChangeForTrackingLifecycle(
            entry.copyWith(updatedAt: now, deletedAt: now),
            'delete',
            now,
          ),
        );
      },
      eventsToEmit: const [TrackingChanged()],
    );
  }

  Future<void> removeTrackingLifecycle(TrackingLifecycle entry,
          {bool notify = true}) =>
      deleteTrackingLifecycle(entry, notify: notify);

  /// Deletes a tracking row selected from a structural Shelf summary.
  ///
  /// Mixed/global UI carries the structural kind/id ref only. The repository
  /// resolves the v1 row at the mutation boundary.
  Future<void> removeTrackingByRef(
    TrackingLifecycleRef ref, {
    bool notify = true,
  }) async {
    final entry = await trackingEntries.findByRef(ref);
    if (entry == null || entry.isDeleted) return;
    await removeTrackingLifecycle(entry, notify: notify);
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
    TrackingLifecycleCustomizer? customizeLifecycle,
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
    final typedOwned = await ownedItems?.findTypedByRef(ownedRef);
    final resolvedIsDigital = typedOwned == null
        ? isDigital
        : collectarrTypedOwnedItemIsDigital(typedOwned.$2);
    final existingEntries =
        await trackingEntries.findActiveByCatalogRoots([resolvedCatalogRef]);
    final existing = existingEntries.isEmpty
        ? null
        : existingEntries.firstWhere(
            (e) => e.ownedRef == ownedRef,
            orElse: () => existingEntries.first,
          );
    final entryId = existing?.id ?? idGenerator();
    await mutationRunner.run(
      origin: origin,
      localRef: resolvedCatalogRef,
      action: () async {
        final baseEntry = existing?.copyWith(
              id: entryId,
              catalogRef: resolvedCatalogRef,
              ownedRef: ownedRef,
              status: status ?? existing.status ?? MediaTrackingStatus.planned,
              rating: rating ?? existing.rating,
              notes: notes ?? existing.notes,
              startedAt: startedAt ?? existing.startedAt,
              finishedAt: finishedAt ?? existing.finishedAt,
              progressCurrent: progressCurrent ?? existing.progressCurrent,
              progressTotal: progressTotal ?? existing.progressTotal,
              sourceType: sourceType ??
                  existing.sourceType ??
                  (resolvedIsDigital == true
                      ? TrackingSourceType.digital
                      : TrackingSourceType.physical),
              updatedAt: now,
            ) ??
            trackingEntries.create(
              id: entryId,
              catalogRef: resolvedCatalogRef,
              ownedRef: ownedRef,
              status: status ?? MediaTrackingStatus.planned,
              rating: rating,
              notes: notes,
              startedAt: startedAt,
              finishedAt: finishedAt,
              progressCurrent: progressCurrent,
              progressTotal: progressTotal,
              sourceType: sourceType ??
                  (resolvedIsDigital == true
                      ? TrackingSourceType.digital
                      : TrackingSourceType.physical),
              updatedAt: now,
            );
        final entry = customizeLifecycle?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        await syncQueue
            .enqueue(_syncChangeForTrackingLifecycle(entry, 'upsert', now));
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
    TrackingLifecycleCustomizer? customizeLifecycle,
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
        final baseEntry = trackingEntries.create(
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
          updatedAt: now,
        );
        final entry = customizeLifecycle?.call(baseEntry) ?? baseEntry;
        await trackingEntries.upsert(entry);
        if (!isLocalItem) {
          await syncQueue
              .enqueue(_syncChangeForTrackingLifecycle(entry, 'upsert', now));
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
      TrackingLifecycle entry, String action, DateTime now) {
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
