import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:drift/drift.dart';

import 'manga_tracking_state.dart';

/// Manga-entry lifecycle tracking mapping. Chapter progress uses typed
/// tracking units, so this entry carries only lifecycle fields.
final class MangaTrackingStateCodec
    with TrackingStorageCodecSupport
    implements TrackingStorageCodec {
  const MangaTrackingStateCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Future<List<TrackingStorageRead>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  }) async {
    final query = db.select(db.mangaTrackingRows);
    if (activeOnly) query.where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    return [
      for (final row in rows)
        TrackingStorageRead(
          trackingStorageRowFromColumns(
            id: row.id,
                        libraryEntryRefKey: row.libraryEntryRefKey,
            sourceType: row.sourceType,
            status: row.status,
            rating: row.rating,
            startedAt: row.startedAt,
            finishedAt: row.finishedAt,
            progress: TrackingProgressSnapshot(
              current: row.progressCurrent,
              total: row.progressTotal,
              timesCompleted: row.timesCompleted,
            ),
            notes: row.notes,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
          ),
          null,
        ),
    ];
  }

  @override
  Future<void> writeStorageRecord(
      LocalDatabase db, TrackingStorageRecord entry) async {
    validateTrackingEntryKind(entry.libraryEntryRef);
    await db.into(db.mangaTrackingRows).insertOnConflictUpdate(
          MangaTrackingRowsCompanion.insert(
            id: entry.id,
                        libraryEntryRefKey: entry.libraryEntryRef.key,
            sourceType: Value(entry.sourceTypeApiValue),
            status: Value(entry.statusStorageValue),
            rating: Value(entry.rating),
            startedAt: Value(entry.startedAt),
            finishedAt: Value(entry.finishedAt),
            progressCurrent: Value(entry.progress.current),
            progressTotal: Value(entry.progress.total),
            timesCompleted: Value(entry.progress.timesCompleted),
            notes: Value(entry.notes),
            updatedAt: entry.updatedAt,
            deletedAt: Value(entry.deletedAt),
          ),
        );
  }

  @override
  Future<void> deleteStorageRecord(
      LocalDatabase db, TrackingStorageRecord entry, DateTime deletedAt) async {
    validateTrackingEntryKind(entry.libraryEntryRef);
    await (db.update(db.mangaTrackingRows)
          ..where((row) => row.id.equals(entry.id)))
        .write(MangaTrackingRowsCompanion(
      deletedAt: Value(deletedAt),
      updatedAt: Value(deletedAt),
    ));
  }

  @override
  MangaTrackingState create({
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
    validateTrackingEntryKind(libraryEntryRef);
    return MangaTrackingState(
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

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async =>
      const {};

  @override
  Map<String, dynamic> toSyncPayload(TrackingStorageRecord entry) {
    validateTrackingEntryKind(entry.libraryEntryRef);
    return entry.toSyncPayload()
      ..addAll({
        'progress_current': entry.progress.current,
        'progress_total': entry.progress.total,
        'times_completed': entry.progress.timesCompleted,
      });
  }

  @override
  TrackingStorageRecord fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final libraryEntryRef = trackingLibraryEntryRefFromPayload(payload, kind);
    return MangaTrackingState(
      id: id,
      libraryEntryRef: libraryEntryRef,
      sourceType: payload['source_type'] as String?,
      status: payload['status'] as String?,
      rating: _int(payload['rating']),
      startedAt: _date(payload['started_at']),
      finishedAt: _date(payload['finished_at']),
      progressCurrent: _int(payload['progress_current']),
      progressTotal: _int(payload['progress_total']),
      timesCompleted: _int(payload['times_completed']),
      notes: payload['notes'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  TrackingStorageRecord fromStorageRow(
    TrackingStorageRow row,
    Object? coordinates,
  ) {
    validateTrackingEntryKind(row.libraryEntryRef);
    return MangaTrackingState(
      id: row.id,
      libraryEntryRef: row.libraryEntryRef,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progress.current,
      progressTotal: row.progress.total,
      timesCompleted: row.progress.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
