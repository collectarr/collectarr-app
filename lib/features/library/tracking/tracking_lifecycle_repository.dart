import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_import.dart';

/// Orchestrates tracking-entry lifecycle across kind-owned persistence codecs.
///
/// Kind-owned tracking tables are composed here for queries and transactions.
/// Mixed feature code receives structural summaries; concrete entries stay
/// inside the owning codec boundary.
class TrackingLifecycleRepository {
  TrackingLifecycleRepository(
    this._db, {
    Iterable<TrackingLifecycleCodec> codecs = const [],
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingLifecycleCodec> _codecs;

  TrackingRecord create({
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

  Future<List<TrackingRecord>> listActive() async {
    return _list(activeOnly: true);
  }

  Future<List<TrackingRecord>> listAll() async {
    return _list(activeOnly: false);
  }

  Future<List<TrackingRecord>> _list({required bool activeOnly}) async {
    final entries = <TrackingRecord>[];
    for (final codec in _codecs.values) {
      entries.addAll(
        await codec.listFromStorage(_db, activeOnly: activeOnly),
      );
    }
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  Future<TrackingRecord?> findByRef(TrackingLifecycleRef ref) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
  }

  Future<List<TrackingRecord>> findActiveByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = catalogRefs.toSet();
    if (wanted.isEmpty) return const [];
    return (await listActive())
        .where((entry) => wanted.contains(entry.catalogRef))
        .toList(growable: false);
  }

  Future<List<TrackingRecord>> findActiveByCatalogRoots(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = {
      for (final ref in catalogRefs) ref.rootScope,
    };
    if (wanted.isEmpty) return const [];
    return (await listActive())
        .where((entry) => wanted.contains(entry.catalogRef.rootScope))
        .toList(growable: false);
  }

  Future<void> upsert(TrackingRecord entry) async {
    final codec = _codecForKind(entry.catalogRef.mediaKind);
    await _db.transaction(() => codec.upsertToStorage(_db, entry));
  }

  Future<void> upsertAll(List<TrackingRecord> entries) async {
    if (entries.isEmpty) return;
    await _db.transaction(() async {
      for (final entry in entries) {
        await _codecForKind(entry.catalogRef.mediaKind)
            .upsertToStorage(_db, entry);
      }
    });
  }

  /// Decodes and persists sync payloads inside the owning kind codec.
  ///
  /// The generic sync feature never receives the concrete lifecycle returned
  /// by a codec. The only cross-feature value is the serialized input itself.
  Future<void> upsertSyncPayloads(
    Iterable<TrackingLifecycleSyncInput> inputs,
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

  Future<TrackingLifecycleSyncRecord?> syncPayloadByRef(
    TrackingLifecycleRef ref,
  ) async {
    final entry = await findByRef(ref);
    if (entry == null) return null;
    return TrackingLifecycleSyncRecord(
      ref: ref,
      payload: toSyncPayload(entry),
      isDeleted: entry.isDeleted,
    );
  }

  /// Rebases tracking targets while keeping the concrete lifecycle private to
  /// this repository/codec boundary.
  Future<List<TrackingLifecycleSyncRecord>> rebaseCatalogRef({
    required CatalogEntityRef current,
    required CatalogEntityRef target,
    required DateTime updatedAt,
  }) async {
    final entries = await findActiveByCatalogRefs([current]);
    if (entries.isEmpty) return const [];
    final records = <TrackingLifecycleSyncRecord>[];
    await _db.transaction(() async {
      for (final entry in entries) {
        final updated = entry.copyWith(
          catalogRef: _rebaseRef(entry.catalogRef, target),
          updatedAt: updatedAt,
        );
        final codec = _codecForKind(updated.catalogRef.mediaKind);
        await codec.upsertToStorage(_db, updated);
        records.add(
          TrackingLifecycleSyncRecord(
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
  Future<List<TrackingLifecycleImportResult>> upsertImportedAll(
    Iterable<TrackingLifecycleImport> imports,
  ) async {
    final values = imports.toList(growable: false);
    if (values.isEmpty) return const [];

    final entries = <TrackingRecord>[];
    for (final input in values) {
      final existingEntries =
          await findActiveByCatalogRoots([input.catalogRef]);
      TrackingRecord? existing;
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

    await upsertAll(entries);
    return [
      for (final entry in entries)
        TrackingLifecycleImportResult(
          ref: TrackingLifecycleRef(
            kind: entry.catalogRef.mediaKind,
            id: entry.id,
          ),
          catalogRef: entry.catalogRef,
          payload: toSyncPayload(entry),
        ),
    ];
  }

  Future<void> markDeleted(TrackingRecord entry, DateTime deletedAt) {
    return _codecForKind(entry.catalogRef.mediaKind)
        .markDeletedInStorage(_db, entry, deletedAt);
  }

  Map<String, dynamic> toSyncPayload(TrackingRecord entry) {
    return _codecForKind(entry.catalogRef.mediaKind).toSyncPayload(entry);
  }

  TrackingLifecycleCodec _codecForKind(CatalogMediaKind kind) {
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
