import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:drift/drift.dart';

/// Anime-owned tracking-entry coordinates kept during the shared-table
/// migration.
final class AnimeTrackingEntryCodec implements TrackingEntryCodec {
  const AnimeTrackingEntryCodec();

  @override
  String get kind => 'anime';

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async {
    final values = ids?.toSet().toList(growable: false);
    if (values != null && values.isEmpty) return const {};
    final query = db.select(db.trackingEntriesCache)
      ..where((row) => row.kind.equals(kind));
    if (values != null) {
      query.where((row) => row.id.isIn(values));
    }
    final rows = await query.get();
    return {
      for (final row in rows)
        row.id: _AnimeTrackingEntryCoordinates(
          seasonNumber: row.seasonNumber,
          episodeNumber: row.episodeNumber,
          episodeRatings: _decodeEpisodeRatings(row.episodeRatings),
        ),
    };
  }

  @override
  Future<void> clearCoordinates(LocalDatabase db, String id) async {
    await (db.update(db.trackingEntriesCache)
          ..where((row) => row.id.equals(id)))
        .write(
      const TrackingEntriesCacheCompanion(
        seasonNumber: Value(null),
        episodeNumber: Value(null),
        episodeRatings: Value(null),
      ),
    );
  }

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingEntry entry) async {
    if (entry.catalogRef.kind != kind) {
      throw ArgumentError.value(
        entry.catalogRef.kind,
        'entry.catalogRef.kind',
        'Expected Anime tracking entry',
      );
    }
    await (db.update(db.trackingEntriesCache)
          ..where((row) => row.id.equals(entry.id)))
        .write(
      TrackingEntriesCacheCompanion(
        seasonNumber: Value(entry.seasonNumber),
        episodeNumber: Value(entry.episodeNumber),
        episodeRatings: Value(_encodeEpisodeRatings(entry.episodeRatings)),
      ),
    );
  }

  @override
  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    if (entry.catalogRef.kind != kind) {
      throw ArgumentError.value(
        entry.catalogRef.kind,
        'entry.catalogRef.kind',
        'Expected Anime tracking entry',
      );
    }
    return entry.toSyncPayload()
      ..addAll({
        'season_number': entry.seasonNumber,
        'episode_number': entry.episodeNumber,
        if (entry.episodeRatings.isNotEmpty)
          'episode_ratings': entry.episodeRatings,
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
    if (catalogRef.kind != kind) {
      throw ArgumentError.value(
        catalogRef.kind,
        'payload.catalog_ref.kind',
        'Expected Anime tracking entry',
      );
    }
    final seasonNumber = _int(payload['season_number']);
    final episodeNumber = _int(payload['episode_number']);
    return TrackingEntry(
      id: id,
      catalogRef: seasonNumber != null || episodeNumber != null
          ? catalogRef.copyWith(entityType: CatalogEntityType.episode)
          : catalogRef,
      ownedItemId: payload['owned_item_id'] as String?,
      editionId: payload['edition_id'] as String?,
      variantId: payload['variant_id'] as String?,
      bundleReleaseId: payload['bundle_release_id'] as String?,
      sourceType: payload['source_type'] as String?,
      status: payload['status'] as String?,
      rating: _int(payload['rating']),
      startedAt: _date(payload['started_at']),
      finishedAt: _date(payload['finished_at']),
      progressCurrent: _int(payload['progress_current']),
      progressTotal: _int(payload['progress_total']),
      timesCompleted: _int(payload['times_completed']),
      notes: payload['notes'] as String?,
      seasonNumber: seasonNumber,
      episodeNumber: _int(payload['episode_number']),
      episodeRatings: _decodeEpisodeRatingsValue(payload['episode_ratings']),
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  ) {
    final typed = coordinates is _AnimeTrackingEntryCoordinates
        ? coordinates
        : const _AnimeTrackingEntryCoordinates();
    return TrackingEntry(
      id: row.id,
      catalogRef: typed.hasEpisodeCoordinates
          ? row.catalogRef.copyWith(entityType: CatalogEntityType.episode)
          : row.catalogRef,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      seasonNumber: typed.seasonNumber,
      episodeNumber: typed.episodeNumber,
      episodeRatings: typed.episodeRatings,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogEntityRef _catalogRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException(
        'Anime tracking entry is missing catalog_ref',
      );
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }
}

final class _AnimeTrackingEntryCoordinates {
  const _AnimeTrackingEntryCoordinates({
    this.seasonNumber,
    this.episodeNumber,
    this.episodeRatings = const {},
  });

  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int> episodeRatings;

  bool get hasEpisodeCoordinates =>
      seasonNumber != null || episodeNumber != null;
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
