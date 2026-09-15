import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:drift/drift.dart';

import 'music_tracking_state.dart';

/// Music-owned lifecycle tracking mapping. Track/disc state remains in the
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
              catalogRefJson: row.catalogRefJson,
              ownedRefKey: row.ownedRefKey,
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
            catalogRefJson: jsonEncode(typed.catalogRef.toJson()),
            ownedRefKey: const Value(null),
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
    _validateMusicRelease(catalogRef);
    if (ownedRef != null) {
      throw StateError('Music tracking cannot be attached to an owned copy.');
    }
    return MusicTrackingState(
      id: id,
      catalogRef: catalogRef,
      releaseId: catalogRef.id,
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
        'release_id': typed.releaseId,
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
    final catalogRef = _catalogRefFromPayload(payload);
    _validateMusicRelease(catalogRef);
    final ownedRef = ownedItemRefFromSerialized(payload['owned_ref']);
    if (ownedRef != null) {
      throw StateError('Music tracking cannot be attached to an owned copy.');
    }
    final releaseId = _releaseIdFromPayload(payload, catalogRef);
    return MusicTrackingState(
      id: id,
      catalogRef: catalogRef,
      releaseId: releaseId,
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
      catalogRef: validated.catalogRef,
      releaseId: validated.catalogRef.id,
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

  CatalogEntityRef _catalogRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException(
          'Music tracking entry is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }

  MusicTrackingState _typedEntry(TrackingStorageRecord entry) {
    if (entry is! MusicTrackingState) {
      throw ArgumentError.value(
        entry,
        'entry',
        'Expected MusicTrackingState',
      );
    }
    _validateMusicRelease(entry.catalogRef);
    if (entry.ownedRef != null) {
      throw StateError('Music tracking cannot be attached to an owned copy.');
    }
    if (entry.releaseId != entry.catalogRef.id) {
      throw StateError(
        'Music tracking releaseId must match catalogRef.id.',
      );
    }
    return entry;
  }

  TrackingStorageRow _validatedStorageRow(TrackingStorageRow row) {
    _validateMusicRelease(row.catalogRef);
    if (row.ownedRef != null) {
      throw StateError('Music tracking cannot be attached to an owned copy.');
    }
    return row;
  }

  void _validateMusicRelease(CatalogEntityRef ref) {
    if (ref.mediaKind != kind) {
      throw ArgumentError.value(
        ref.mediaKind,
        'catalogRef.kind',
        'Expected Music tracking entry',
      );
    }
    requireMusicReleaseRef(ref, label: 'Music tracking catalogRef');
  }

  String _releaseIdFromPayload(
    Map<String, dynamic> payload,
    CatalogEntityRef catalogRef,
  ) {
    final raw = payload['release_id'];
    final releaseId =
        raw is String && raw.trim().isNotEmpty ? raw.trim() : catalogRef.id;
    if (releaseId != catalogRef.id) {
      throw FormatException(
        'Music tracking release_id must match catalog_ref.id',
      );
    }
    return releaseId;
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
