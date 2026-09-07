import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:drift/drift.dart';

import 'tv_tracking_entry.dart';

/// TV-owned tracking-entry coordinates.
///
/// The universal tracking index stores only lifecycle and structural reference
/// data. TV episode coordinates live in [TvTrackingRows].
final class TvTrackingEntryCodec implements TrackingEntryCodec {
  const TvTrackingEntryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

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
  Future<void> clearCoordinates(LocalDatabase db, String id) async {
    await (db.update(db.tvTrackingRows)..where((row) => row.id.equals(id)))
        .write(
      const TvTrackingRowsCompanion(
        seasonNumber: Value(null),
        episodeNumber: Value(null),
        episodeRatingsJson: Value('{}'),
      ),
    );
  }

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingEntry entry) async {
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
            seasonNumber: Value(typed.coordinates.seasonNumber),
            episodeNumber: Value(typed.coordinates.episodeNumber),
            episodeRatingsJson: Value(
                _encodeEpisodeRatings(typed.coordinates.episodeRatings) ??
                    '{}'),
          ),
        );
  }

  @override
  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
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
  TrackingEntry fromSyncPayload({
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
    return TvTrackingEntry(
      id: id,
      catalogRef: seasonNumber != null || episodeNumber != null
          ? catalogRef.copyWith(entityType: CatalogEntityType.episode)
          : catalogRef,
      coordinates: TvTrackingCoordinates(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeRatings: _decodeEpisodeRatingsValue(payload['episode_ratings']),
      ),
      ownedItemId: payload['owned_item_id'] as String?,
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
  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  ) {
    final typed = coordinates is TvTrackingCoordinates
        ? coordinates
        : TvTrackingCoordinates();
    return TvTrackingEntry(
      id: row.id,
      catalogRef: typed.hasEpisodeCoordinates
          ? row.catalogRef.copyWith(entityType: CatalogEntityType.episode)
          : row.catalogRef,
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
