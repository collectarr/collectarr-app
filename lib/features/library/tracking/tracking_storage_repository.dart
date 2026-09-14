import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_import.dart';

/// Orchestrates tracking-entry lifecycle across kind-owned persistence codecs.
///
/// Kind-owned tracking tables are composed here for queries and transactions.
/// Mixed feature code receives structural summaries; concrete entries stay
/// inside the owning codec boundary.
class TrackingStorageRepository {
  TrackingStorageRepository(
    this._db, {
    Iterable<TrackingStorageCodec> codecs = const [],
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingStorageCodec> _codecs;

  TrackingStorageRecord create({
    required String id,
    required CatalogEntityRef catalogRef,
    OwnedItemRef? ownedRef,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    return _codecForKind(catalogRef.mediaKind).create(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Future<List<TrackingSummary>> listActiveSummaries() async {
    final summaries = <TrackingSummary>[];
    for (final codec in _codecs.values) {
      for (final record in await codec.readStorageRecords(
        _db,
        activeOnly: true,
      )) {
        summaries.add(codec.summaryFromStorageRow(record.row));
      }
    }
    summaries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return summaries;
  }

  Future<TrackingSummary?> findSummaryByRef(TrackingLifecycleRef ref) async {
    for (final codec in _codecs.values) {
      if (codec.kind != ref.kind) continue;
      for (final record in await codec.readStorageRecords(
        _db,
        activeOnly: false,
      )) {
        if (record.row.id == ref.id) {
          return codec.summaryFromStorageRow(record.row);
        }
      }
    }
    return null;
  }

  Future<List<TrackingStorageRecord>> listActiveStorageRecords() async {
    return _list(activeOnly: true);
  }

  Future<List<TrackingStorageRecord>> listAllStorageRecords() async {
    return _list(activeOnly: false);
  }

  Future<List<TrackingStorageRecord>> _list({required bool activeOnly}) async {
    final entries = <TrackingStorageRecord>[];
    for (final codec in _codecs.values) {
      entries.addAll(
        await codec.listFromStorage(_db, activeOnly: activeOnly),
      );
    }
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  Future<TrackingStorageRecord?> findStorageRecordByRef(
    TrackingLifecycleRef ref,
  ) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
  }

  /// Applies a structural lifecycle mutation inside the owning kind codec.
  ///
  /// The caller supplies only the universal lifecycle state and an opaque
  /// kind patch. The repository resolves the concrete aggregate, applies the
  /// patch at the codec boundary, persists it, and returns a serialized sync
  /// record. Collection/edit orchestration never has to reconstruct a common
  /// tracking aggregate.
  Future<TrackingStorageSyncRecord> upsertMutation({
    required String id,
    required CatalogEntityRef catalogRef,
    OwnedItemRef? ownedRef,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    TrackingKindPatch? kindPatch,
    required DateTime updatedAt,
  }) async {
    if (kindPatch != null && kindPatch.kind != catalogRef.mediaKind) {
      throw ArgumentError.value(
        kindPatch.kind,
        'kindPatch.kind',
        'Tracking patch kind must match catalog reference kind.',
      );
    }
    final codec = _codecForKind(catalogRef.mediaKind);
    final existing = await _findActiveEntry(
      catalogRef: catalogRef,
      ownedRef: ownedRef,
    );
    final entryId = existing?.id ?? id;
    final entry = existing == null
        ? codec.create(
            id: entryId,
            catalogRef: catalogRef,
            ownedRef: ownedRef,
            sourceType: sourceType,
            status: status,
            rating: rating,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal,
            timesCompleted: timesCompleted,
            notes: notes,
            updatedAt: updatedAt,
          )
        : existing
            .copyWith(
              id: entryId,
              catalogRef: catalogRef,
              ownedRef: ownedRef ?? existing.ownedRef,
              sourceType: sourceType ?? existing.sourceType,
              status: status ?? existing.status ?? MediaTrackingStatus.planned,
              rating: rating ?? existing.rating,
              startedAt: startedAt ?? existing.startedAt,
              finishedAt: finishedAt ?? existing.finishedAt,
              notes: notes ?? existing.notes,
              updatedAt: updatedAt,
            )
            .copyWithProgress(
              TrackingProgressSnapshot(
                current: progressCurrent ?? existing.progress.current,
                total: progressTotal ?? existing.progress.total,
                timesCompleted:
                    timesCompleted ?? existing.progress.timesCompleted,
              ),
            );
    final withPatch =
        kindPatch == null ? entry : codec.applyKindPatch(entry, kindPatch);
    await _db.transaction(() => codec.upsertToStorage(_db, withPatch));
    return _syncRecord(codec, withPatch);
  }

  /// Deletes a lifecycle by structural kind/id reference and returns only the
  /// serialized result needed by sync orchestration.
  Future<TrackingStorageSyncRecord?> markDeletedByRef(
    TrackingLifecycleRef ref,
    DateTime deletedAt,
  ) async {
    final entry = await findStorageRecordByRef(ref);
    if (entry == null || entry.isDeleted) return null;
    final codec = _codecForKind(ref.kind);
    final deleted = entry.copyWith(
      updatedAt: deletedAt,
      deletedAt: deletedAt,
    );
    await _db.transaction(
      () => codec.markDeletedInStorage(_db, deleted, deletedAt),
    );
    return _syncRecord(codec, deleted);
  }

  Future<List<TrackingStorageRecord>> findActiveStorageRecordsByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = catalogRefs.toSet();
    if (wanted.isEmpty) return const [];
    return (await listActiveStorageRecords())
        .where((entry) => wanted.contains(entry.catalogRef))
        .toList(growable: false);
  }

  Future<List<TrackingStorageRecord>> findActiveStorageRecordsByCatalogRoots(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = {
      for (final ref in catalogRefs) ref.rootScope,
    };
    if (wanted.isEmpty) return const [];
    return (await listActiveStorageRecords())
        .where((entry) => wanted.contains(entry.catalogRef.rootScope))
        .toList(growable: false);
  }

  Future<void> upsertStorageRecord(TrackingStorageRecord entry) async {
    final codec = _codecForKind(entry.catalogRef.mediaKind);
    await _db.transaction(() => codec.upsertToStorage(_db, entry));
  }

  Future<void> upsertStorageRecords(List<TrackingStorageRecord> entries) async {
    if (entries.isEmpty) return;
    await _db.transaction(() async {
      for (final entry in entries) {
        await _codecForKind(entry.catalogRef.mediaKind)
            .upsertToStorage(_db, entry);
      }
    });
  }

  Future<TrackingStorageRecord?> _findActiveEntry({
    required CatalogEntityRef catalogRef,
    required OwnedItemRef? ownedRef,
  }) async {
    final entries = await findActiveStorageRecordsByCatalogRoots([catalogRef]);
    if (entries.isEmpty) return null;
    return entries.firstWhere(
      (entry) => entry.ownedRef == ownedRef,
      orElse: () => entries.first,
    );
  }

  TrackingStorageSyncRecord _syncRecord(
    TrackingStorageCodec codec,
    TrackingStorageRecord entry,
  ) {
    return TrackingStorageSyncRecord(
      ref: TrackingLifecycleRef(
        kind: entry.catalogRef.mediaKind,
        id: entry.id,
      ),
      payload: codec.toSyncPayload(entry),
      isDeleted: entry.isDeleted,
    );
  }

  /// Decodes and persists sync payloads inside the owning kind codec.
  ///
  /// The generic sync feature never receives the concrete lifecycle returned
  /// by a codec. The only cross-feature value is the serialized input itself.
  Future<void> upsertSyncPayloads(
    Iterable<TrackingStorageSyncInput> inputs,
  ) async {
    final values = inputs.toList(growable: false);
    if (values.isEmpty) return;
    await _db.transaction(() async {
      for (final input in values) {
        final codec = _codecForKind(input.ref.kind);
        final entry = codec.fromSyncPayload(
          payload: input.payload,
          id: input.ref.id,
          updatedAt: input.updatedAt,
          deletedAt: input.deletedAt,
        );
        await codec.upsertToStorage(_db, entry);
      }
    });
  }

  Future<TrackingStorageSyncRecord?> syncPayloadByRef(
    TrackingLifecycleRef ref,
  ) async {
    final entry = await findStorageRecordByRef(ref);
    if (entry == null) return null;
    return TrackingStorageSyncRecord(
      ref: ref,
      payload: toSyncPayload(entry),
      isDeleted: entry.isDeleted,
    );
  }

  /// Rebases tracking targets while keeping the concrete lifecycle private to
  /// this repository/codec boundary.
  Future<List<TrackingStorageSyncRecord>> rebaseCatalogRef({
    required CatalogEntityRef current,
    required CatalogEntityRef target,
    required DateTime updatedAt,
  }) async {
    final entries = await findActiveStorageRecordsByCatalogRefs([current]);
    if (entries.isEmpty) return const [];
    final records = <TrackingStorageSyncRecord>[];
    await _db.transaction(() async {
      for (final entry in entries) {
        final updated = entry.copyWith(
          catalogRef: _rebaseRef(entry.catalogRef, target),
          updatedAt: updatedAt,
        );
        final codec = _codecForKind(updated.catalogRef.mediaKind);
        await codec.upsertToStorage(_db, updated);
        records.add(
          TrackingStorageSyncRecord(
            ref: TrackingLifecycleRef(
              kind: updated.catalogRef.mediaKind,
              id: updated.id,
            ),
            payload: codec.toSyncPayload(updated),
            isDeleted: updated.isDeleted,
          ),
        );
      }
    });
    return records;
  }

  /// Applies schema-v1 import values and returns only a structural sync
  /// record. The concrete lifecycle is reconstructed and persisted inside
  /// this repository, never exposed to the generic import host.
  Future<List<TrackingStorageImportResult>> upsertImportedAll(
    Iterable<TrackingStorageImport> imports,
  ) async {
    final values = imports.toList(growable: false);
    if (values.isEmpty) return const [];

    final entries = <TrackingStorageRecord>[];
    for (final input in values) {
      final existingEntries =
          await findActiveStorageRecordsByCatalogRoots([input.catalogRef]);
      TrackingStorageRecord? existing;
      if (existingEntries.isNotEmpty) {
        existing = existingEntries.firstWhere(
          (entry) => entry.ownedRef == input.ownedRef,
          orElse: () => existingEntries.first,
        );
      }
      final entry = existing == null
          ? create(
              id: input.entryId,
              catalogRef: input.catalogRef,
              ownedRef: input.ownedRef,
              status: mediaTrackingStatusFromValue(input.status) ??
                  MediaTrackingStatus.planned,
              rating: input.rating,
              startedAt: input.startedAt,
              finishedAt: input.finishedAt,
              updatedAt: input.now,
            )
          : existing.copyWith(
              id: input.entryId,
              catalogRef: input.catalogRef,
              ownedRef: input.ownedRef,
              status:
                  mediaTrackingStatusFromValue(input.status) ?? existing.status,
              rating: input.rating ?? existing.rating,
              startedAt: input.startedAt ?? existing.startedAt,
              finishedAt: input.finishedAt ?? existing.finishedAt,
              updatedAt: input.now,
            );
      entries.add(entry);
    }

    await upsertStorageRecords(entries);
    return [
      for (final entry in entries)
        TrackingStorageImportResult(
          ref: TrackingLifecycleRef(
            kind: entry.catalogRef.mediaKind,
            id: entry.id,
          ),
          catalogRef: entry.catalogRef,
          payload: toSyncPayload(entry),
        ),
    ];
  }

  Future<void> markStorageRecordDeleted(
    TrackingStorageRecord entry,
    DateTime deletedAt,
  ) {
    return _codecForKind(entry.catalogRef.mediaKind)
        .markDeletedInStorage(_db, entry, deletedAt);
  }

  Map<String, dynamic> toSyncPayload(TrackingStorageRecord entry) {
    return _codecForKind(entry.catalogRef.mediaKind).toSyncPayload(entry);
  }

  TrackingStorageCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No tracking-entry codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }

  CatalogEntityRef _rebaseRef(
    CatalogEntityRef current,
    CatalogEntityRef target,
  ) {
    if (current.rootScope == current || current.rootId == null) {
      return target;
    }
    return current.copyWith(
      kind: target.kind,
      rootId: target.id,
    );
  }
}
