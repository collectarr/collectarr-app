import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:drift/drift.dart';

import 'tv_tracking_lifecycle.dart';

/// TV-owned tracking-entry coordinates.
///
/// The universal tracking index stores only lifecycle and structural reference
/// data. TV episode coordinates live in [TvTrackingRows].
final class TvTrackingLifecycleCodec
    with TrackingLifecycleStorageSupport
    implements TrackingLifecycleCodec {
  const TvTrackingLifecycleCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<List<TrackingLifecycleStorageRecord>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  }) async {
    final query = db.select(db.tvTrackingRows);
    if (activeOnly) query.where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    final coordinates = await loadCoordinates(db, rows.map((row) => row.id));
    return [
      for (final row in rows)
        TrackingLifecycleStorageRecord(
          trackingLifecycleStorageRowFromColumns(
            id: row.id,
            catalogRefJson: row.catalogRefJson,
            ownedItemId: row.ownedItemId,
            sourceType: row.sourceType,
            status: row.status,
            rating: row.rating,
            startedAt: row.startedAt,
            finishedAt: row.finishedAt,
            progressCurrent: row.progressCurrent,
            progressTotal: row.progressTotal,
            timesCompleted: row.timesCompleted,
            notes: row.notes,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
          ),
          coordinates[row.id],
        ),
    ];
  }

  @override
  Future<void> deleteStorageRecord(
    LocalDatabase db,
    TrackingLifecycle entry,
    DateTime deletedAt,
  ) async {
    await (db.update(db.tvTrackingRows)
          ..where((row) => row.id.equals(entry.id)))
        .write(
      TvTrackingRowsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  @override
  TvTrackingLifecycle create({
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
    if (catalogRef.mediaKind != kind) {
      throw ArgumentError.value(
        catalogRef.mediaKind,
        'catalogRef.kind',
        'Expected TV tracking entry',
      );
    }
    return TvTrackingLifecycle(
      id: id,
      catalogRef: catalogRef,
      coordinates: TvTrackingCoordinates(),
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

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async {
    final values = ids?.toSet().toList(growable: false);
    if (values != null && values.isEmpty) return const {};
    final query = db.select(db.tvTrackingRows);
    if (values != null) {
      query.where((row) => row.id.isIn(values));
    }
    final rows = await query.get();
    return {
      for (final row in rows)
        row.id: TvTrackingCoordinates(
          seasonNumber: row.seasonNumber,
          episodeNumber: row.episodeNumber,
          episodeRatings: _decodeEpisodeRatings(row.episodeRatingsJson),
        ),
    };
  }

  @override
  @override
  Future<void> writeStorageRecord(
    LocalDatabase db,
    TrackingLifecycle entry,
  ) async {
    if (entry.catalogRef.mediaKind != kind) {
      throw ArgumentError.value(
        entry.catalogRef.mediaKind,
        'entry.catalogRef.kind',
        'Expected TV tracking entry',
      );
    }
    final typed = tvTrackingEntryFor(entry);
    await db.into(db.tvTrackingRows).insertOnConflictUpdate(
          TvTrackingRowsCompanion.insert(
            id: entry.id,
            catalogRefJson: jsonEncode(entry.catalogRef.toJson()),
            ownedItemId: Value(entry.ownedRef?.key),
            sourceType: Value(entry.sourceTypeApiValue),
            status: Value(entry.statusStorageValue),
            rating: Value(entry.rating),
            startedAt: Value(entry.startedAt),
            finishedAt: Value(entry.finishedAt),
            progressCurrent: Value(entry.progressCurrent),
            progressTotal: Value(entry.progressTotal),
            timesCompleted: Value(entry.timesCompleted),
            notes: Value(entry.notes),
            updatedAt: entry.updatedAt,
            deletedAt: Value(entry.deletedAt),
            seasonNumber: Value(typed.coordinates.seasonNumber),
            episodeNumber: Value(typed.coordinates.episodeNumber),
            episodeRatingsJson: Value(
                _encodeEpisodeRatings(typed.coordinates.episodeRatings) ??
                    '{}'),
          ),
        );
  }

  @override
  Map<String, dynamic> toSyncPayload(TrackingLifecycle entry) {
    if (entry.catalogRef.mediaKind != kind) {
      throw ArgumentError.value(
        entry.catalogRef.mediaKind,
        'entry.catalogRef.kind',
        'Expected TV tracking entry',
      );
    }
    final typed = tvTrackingEntryFor(entry);
    return entry.toSyncPayload()
      ..addAll({
        'season_number': typed.coordinates.seasonNumber,
        'episode_number': typed.coordinates.episodeNumber,
        if (typed.coordinates.episodeRatings.isNotEmpty)
          'episode_ratings': typed.coordinates.episodeRatings,
      });
  }

  @override
  TrackingLifecycle fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final catalogRef = _catalogRefFromPayload(payload);
    if (catalogRef.mediaKind != kind) {
      throw ArgumentError.value(
        catalogRef.mediaKind,
        'payload.catalog_ref.kind',
        'Expected TV tracking entry',
      );
    }
    final seasonNumber = _int(payload['season_number']);
    final episodeNumber = _int(payload['episode_number']);
    return TvTrackingLifecycle(
      id: id,
      catalogRef: seasonNumber != null || episodeNumber != null
          ? catalogRef.copyWith(
              entityType: const CatalogEntityTypeId('episode'))
          : catalogRef,
      coordinates: TvTrackingCoordinates(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeRatings: _decodeEpisodeRatingsValue(payload['episode_ratings']),
      ),
      ownedRef: ownedItemRefFromSerialized(payload['owned_ref']),
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
  TrackingLifecycle fromStorageRow(
    TrackingLifecycleStorageRow row,
    Object? coordinates,
  ) {
    final typed = coordinates is TvTrackingCoordinates
        ? coordinates
        : TvTrackingCoordinates();
    return TvTrackingLifecycle(
      id: row.id,
      catalogRef: typed.hasEpisodeCoordinates
          ? row.catalogRef
              .copyWith(entityType: const CatalogEntityTypeId('episode'))
          : row.catalogRef,
      ownedRef: row.ownedRef,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      coordinates: typed,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogEntityRef _catalogRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException('TV tracking entry is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }
}

Map<String, int> _decodeEpisodeRatings(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is num)
            entry.key as String: (entry.value as num).toInt(),
      };
    }
  } on Object {
    // Malformed ratings are non-critical; treat them as empty.
  }
  return const {};
}

Map<String, int> _decodeEpisodeRatingsValue(Object? raw) {
  if (raw is Map) {
    return {
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    };
  }
  return _decodeEpisodeRatings(raw?.toString());
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

String? _encodeEpisodeRatings(Map<String, int> ratings) {
  return ratings.isEmpty ? null : jsonEncode(ratings);
}
