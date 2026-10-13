import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_import.dart';

/// Orchestrates tracking-entry lifecycle across kind-entry persistence codecs.
///
/// Kind-entry tracking tables are composed here for queries and transactions.
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
    required LibraryEntryRef libraryEntryRef,
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
    _validateLibraryEntryRef(libraryEntryRef);
    return _codecForKind(libraryEntryRef.kind).create(
      id: id,
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

  Future<TrackingSummary?> findSummaryByRef(TrackingStateRef ref) async {
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
    TrackingStateRef ref,
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
    required LibraryEntryRef libraryEntryRef,
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
    bool replaceNullableFields = false,
  }) async {
    _validateLibraryEntryRef(libraryEntryRef);
    if (kindPatch != null && kindPatch.kind != libraryEntryRef.kind) {
      throw ArgumentError.value(
        kindPatch.kind,
        'kindPatch.kind',
        'Tracking patch kind must match catalog reference kind.',
      );
    }
    final codec = _codecForKind(libraryEntryRef.kind);
    final existing = await _findActiveEntry(
      libraryEntryRef: libraryEntryRef,
    );
    final entryId = existing?.id ?? id;
    final entry = existing == null
        ? codec.create(
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
            updatedAt: updatedAt,
          )
        : existing
            .copyWith(
              id: entryId,
              libraryEntryRef: libraryEntryRef,
              sourceType: replaceNullableFields
                  ? sourceType
                  : sourceType ?? existing.sourceType,
              status: replaceNullableFields
                  ? status
                  : status ?? existing.status ?? MediaTrackingStatus.planned,
              rating:
                  replaceNullableFields ? rating : rating ?? existing.rating,
              startedAt: replaceNullableFields
                  ? startedAt
                  : startedAt ?? existing.startedAt,
              finishedAt: replaceNullableFields
                  ? finishedAt
                  : finishedAt ?? existing.finishedAt,
              notes: replaceNullableFields ? notes : notes ?? existing.notes,
              updatedAt: updatedAt,
            )
            .copyWithProgress(
              TrackingProgressSnapshot(
                current: replaceNullableFields
                    ? progressCurrent
                    : progressCurrent ?? existing.progress.current,
                total: replaceNullableFields
                    ? progressTotal
                    : progressTotal ?? existing.progress.total,
                timesCompleted: replaceNullableFields
                    ? timesCompleted
                    : timesCompleted ?? existing.progress.timesCompleted,
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
    TrackingStateRef ref,
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

  Future<List<TrackingStorageRecord>>
      findActiveStorageRecordsByLibraryEntryRefs(
    Iterable<LibraryEntryRef> libraryEntryRefs,
  ) async {
    final wanted = libraryEntryRefs.toSet();
    if (wanted.isEmpty) return const [];
    return (await listActiveStorageRecords())
        .where((entry) => wanted.contains(entry.libraryEntryRef))
        .toList(growable: false);
  }

  Future<void> upsertStorageRecord(TrackingStorageRecord entry) async {
    final libraryEntryRef = _libraryEntryRefForRecord(entry);
    final codec = _codecForKind(libraryEntryRef.kind);
    await _db.transaction(() => codec.upsertToStorage(_db, entry));
  }

  Future<void> upsertStorageRecords(List<TrackingStorageRecord> entries) async {
    if (entries.isEmpty) return;
    await _db.transaction(() async {
      for (final entry in entries) {
        final libraryEntryRef = _libraryEntryRefForRecord(entry);
        await _codecForKind(libraryEntryRef.kind).upsertToStorage(_db, entry);
      }
    });
  }

  Future<TrackingStorageRecord?> _findActiveEntry({
    required LibraryEntryRef libraryEntryRef,
  }) async {
    final entries =
        await findActiveStorageRecordsByLibraryEntryRefs([libraryEntryRef]);
    for (final entry in entries) {
      if (entry.libraryEntryRef == libraryEntryRef) return entry;
    }
    return null;
  }

  TrackingStorageSyncRecord _syncRecord(
    TrackingStorageCodec codec,
    TrackingStorageRecord entry,
  ) {
    return TrackingStorageSyncRecord(
      ref: TrackingStateRef(
        kind: _libraryEntryRefForRecord(entry).kind,
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
        _libraryEntryRefForRecord(entry);
        await codec.upsertToStorage(_db, entry);
      }
    });
  }

  Future<TrackingStorageSyncRecord?> syncPayloadByRef(
    TrackingStateRef ref,
  ) async {
    final entry = await findStorageRecordByRef(ref);
    if (entry == null) return null;
    return TrackingStorageSyncRecord(
      ref: ref,
      payload: toSyncPayload(entry),
      isDeleted: entry.isDeleted,
    );
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
      _validateLibraryEntryRef(input.libraryEntryRef);
      final existing = (await findActiveStorageRecordsByLibraryEntryRefs([
        input.libraryEntryRef,
      ]))
          .firstOrNull;
      final entry = existing == null
          ? create(
              id: input.entryId,
              libraryEntryRef: input.libraryEntryRef,
              status: mediaTrackingStatusFromValue(input.status) ??
                  MediaTrackingStatus.planned,
              rating: input.rating,
              startedAt: input.startedAt,
              finishedAt: input.finishedAt,
              updatedAt: input.now,
            )
          : existing.copyWith(
              id: input.entryId,
              libraryEntryRef: input.libraryEntryRef,
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
          ref: TrackingStateRef(
            kind: _libraryEntryRefForRecord(entry).kind,
            id: entry.id,
          ),
          payload: toSyncPayload(entry),
        ),
    ];
  }

  Future<void> markStorageRecordDeleted(
    TrackingStorageRecord entry,
    DateTime deletedAt,
  ) {
    return _codecForKind(_libraryEntryRefForRecord(entry).kind)
        .markDeletedInStorage(_db, entry, deletedAt);
  }

  JsonMap toSyncPayload(TrackingStorageRecord entry) {
    return _codecForKind(_libraryEntryRefForRecord(entry).kind)
        .toSyncPayload(entry);
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

  void _validateLibraryEntryRef(LibraryEntryRef libraryEntryRef) {
    requireKnownLibraryEntryRef(libraryEntryRef, 'tracking.libraryEntryRef');
  }

  LibraryEntryRef _libraryEntryRefForRecord(TrackingStorageRecord entry) {
    final ref = entry.libraryEntryRef;
    _validateLibraryEntryRef(ref);
    return ref;
  }
}
