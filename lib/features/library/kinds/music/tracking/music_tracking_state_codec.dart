import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:drift/drift.dart';

import 'music_tracking_state.dart';

/// Music-entry lifecycle tracking mapping. Track/disc state remains in the
/// Music vertical and is not inferred by the sync host.
final class MusicTrackingStateCodec
    with TrackingStorageCodecSupport
    implements TrackingStorageCodec {
  const MusicTrackingStateCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<List<TrackingStorageRead>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  }) async {
    final query = db.select(db.musicTrackingRows);
    if (activeOnly) query.where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    return [
      for (final row in rows)
        TrackingStorageRead(
          _validatedStorageRow(
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
          ),
          null,
        ),
    ];
  }

  @override
  Future<void> writeStorageRecord(
      LocalDatabase db, TrackingStorageRecord entry) async {
    final typed = _typedEntry(entry);
    await db.into(db.musicTrackingRows).insertOnConflictUpdate(
          MusicTrackingRowsCompanion.insert(
            id: entry.id,
            libraryEntryRefKey: typed.libraryEntryRef.key,
            sourceType: Value(typed.sourceTypeApiValue),
            status: Value(typed.statusStorageValue),
            rating: Value(typed.rating),
            startedAt: Value(typed.startedAt),
            finishedAt: Value(typed.finishedAt),
            progressCurrent: Value(typed.progress.current),
            progressTotal: Value(typed.progress.total),
            timesCompleted: Value(typed.progress.timesCompleted),
            notes: Value(typed.notes),
            updatedAt: typed.updatedAt,
            deletedAt: Value(typed.deletedAt),
          ),
        );
  }

  @override
  Future<void> deleteStorageRecord(
      LocalDatabase db, TrackingStorageRecord entry, DateTime deletedAt) async {
    _typedEntry(entry);
    await (db.update(db.musicTrackingRows)
          ..where((row) => row.id.equals(entry.id)))
        .write(MusicTrackingRowsCompanion(
      deletedAt: Value(deletedAt),
      updatedAt: Value(deletedAt),
    ));
  }

  @override
  MusicTrackingState create({
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
    _validateMusicEntry(libraryEntryRef);
    return MusicTrackingState(
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
    final typed = _typedEntry(entry);
    return typed.toSyncPayload()
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
    final libraryEntryRef = libraryEntryRefFromSerialized(
      payload['library_entry_ref'],
    );
    if (libraryEntryRef == null || libraryEntryRef.kind != kind) {
      throw const FormatException(
        'Music tracking requires a Music library_entry_ref.',
      );
    }
    return MusicTrackingState(
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
    final validated = _validatedStorageRow(row);
    return MusicTrackingState(
      id: validated.id,
      libraryEntryRef: validated.libraryEntryRef,
      sourceType: validated.sourceType,
      status: validated.status,
      rating: validated.rating,
      startedAt: validated.startedAt,
      finishedAt: validated.finishedAt,
      progressCurrent: validated.progress.current,
      progressTotal: validated.progress.total,
      timesCompleted: validated.progress.timesCompleted,
      notes: validated.notes,
      updatedAt: validated.updatedAt,
      deletedAt: validated.deletedAt,
    );
  }

  @override
  TrackingSummary summaryFromStorageRow(TrackingStorageRow row) {
    _validatedStorageRow(row);
    return super.summaryFromStorageRow(row);
  }

  MusicTrackingState _typedEntry(TrackingStorageRecord entry) {
    if (entry is! MusicTrackingState) {
      throw ArgumentError.value(
        entry,
        'entry',
        'Expected MusicTrackingState',
      );
    }
    final libraryEntryRef = entry.libraryEntryRef;
    if (libraryEntryRef.kind != kind) {
      throw StateError('Music tracking requires a Music library entry owner.');
    }
    return entry;
  }

  TrackingStorageRow _validatedStorageRow(TrackingStorageRow row) {
    final libraryEntryRef = row.libraryEntryRef;
    if (libraryEntryRef.kind != kind) {
      throw StateError('Music tracking requires a Music library entry owner.');
    }
    return row;
  }

  void _validateMusicEntry(LibraryEntryRef ref) {
    if (ref.kind != kind) {
      throw ArgumentError.value(
        ref.kind,
        'libraryEntryRef.kind',
        'Music tracking requires a Music library entry',
      );
    }
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
