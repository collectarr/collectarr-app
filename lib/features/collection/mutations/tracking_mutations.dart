import 'dart:async';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class TrackingMutations {
  const TrackingMutations({
    required this.trackingRecords,
    required this.trackingUnits,
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
    this.libraryEntries,
    this.idGenerator = _defaultIdGenerator,
  });

  final TrackingStorageRepository trackingRecords;
  final TrackingUnitStorageRepository trackingUnits;
  final WatchSessionsRepository watchSessions;
  final LibraryEntriesRepository? libraryEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  /// Updates a mixed/global tracking projection without exposing the
  /// kind-entry lifecycle aggregate to the caller.
  Future<void> updateTrackingSummary(
    TrackingSummary entry, {
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    TrackingProgressSnapshot? progress,
    String? notes,
  }) {
    final target = entry.libraryEntryRef;
    final resolvedProgress = progress ?? entry.progress;
    return upsertTrackingState(
      target,
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
    LibraryEntryRef libraryEntryRef, {
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
    bool replaceNullableFields = false,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = await libraryEntries?.findSummaryByRef(libraryEntryRef);
    if (libraryEntries != null && entry == null) {
      throw StateError('Library entry not found: ${libraryEntryRef.key}');
    }
    final entryId = idGenerator();

    await mutationRunner.run(
      action: () async {
        final serialized = await trackingRecords.upsertMutation(
          id: entryId,
          libraryEntryRef: libraryEntryRef,
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
          replaceNullableFields: replaceNullableFields,
        );
        await syncQueue.enqueue(
          _syncChangeForTrackingState(serialized, 'upsert', now),
        );
      },
      eventsToEmit: notify ? const [TrackingChanged()] : const [],
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
      eventsToEmit: notify ? const [TrackingChanged()] : const [],
    );
  }

  Future<void> syncEntryTrackingState(
    LibraryEntryRef libraryEntryRef, {
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
    bool replaceNullableFields = false,
  }) async {
    final now = DateTime.now().toUtc();
    final libraryEntrySummary =
        await libraryEntries?.findSummaryByRef(libraryEntryRef);
    if (libraryEntries != null && libraryEntrySummary == null) {
      throw StateError(
        'Cannot attach tracking to missing library entry ${libraryEntryRef.key}.',
      );
    }
    final entryId = idGenerator();
    await mutationRunner.run(
      action: () async {
        final serialized = await trackingRecords.upsertMutation(
          id: entryId,
          libraryEntryRef: libraryEntryRef,
          status: status,
          rating: rating,
          notes: notes,
          startedAt: startedAt,
          finishedAt: finishedAt,
          progressCurrent: progressCurrent,
          progressTotal: progressTotal,
          timesCompleted: timesCompleted,
          sourceType: sourceType ??
              (libraryEntrySummary?.isDigital == true
                  ? TrackingSourceType.digital
                  : TrackingSourceType.physical),
          kindPatch: kindPatch,
          updatedAt: now,
          replaceNullableFields: replaceNullableFields,
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
