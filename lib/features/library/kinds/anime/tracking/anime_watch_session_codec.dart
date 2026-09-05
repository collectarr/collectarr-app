import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:drift/drift.dart';

final class AnimeWatchSessionCodec implements WatchSessionCodec {
  const AnimeWatchSessionCodec();

  @override
  String get kind => 'anime';

  @override
  Future<List<WatchSession>> listActive(
    LocalDatabase db, {
    Iterable<String>? itemIds,
  }) async {
    final ids = itemIds?.toSet().toList(growable: false);
    if (ids != null && ids.isEmpty) return const [];
    final query = db.select(db.animeWatchSessionRows)
      ..where((row) => row.deletedAt.isNull());
    if (ids != null) {
      query.where((row) => row.seriesId.isIn(ids));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<WatchSession?> findById(LocalDatabase db, String id) async {
    final row = await (db.select(db.animeWatchSessionRows)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(LocalDatabase db, WatchSession session) async {
    if (session.targetRef.kind != kind) {
      throw ArgumentError.value(
        session.targetRef.kind,
        'session.targetRef.kind',
        'Expected Anime watch session',
      );
    }
    await db.into(db.animeWatchSessionRows).insertOnConflictUpdate(
          AnimeWatchSessionRowsCompanion.insert(
            id: session.id,
            seriesId: session.itemId,
            targetRefJson: Value(jsonEncode(session.targetRef.toJson())),
            trackingEntryId: Value(session.trackingEntryId),
            seasonNumber: Value(session.seasonNumber),
            episodeNumber: Value(session.episodeNumber),
            sourceType: Value(session.sourceTypeApiValue),
            seenWhere: Value(session.seenWhere),
            watchedAt: session.watchedAt,
            rating: Value(session.rating),
            notes: Value(session.notes),
            updatedAt: session.updatedAt,
            deletedAt: Value(session.deletedAt),
          ),
        );
  }

  @override
  Map<String, dynamic> toSyncPayload(WatchSession session) {
    _validateKind(session);
    return session.toSyncPayload()
      ..addAll({
        'season_number': session.seasonNumber,
        'episode_number': session.episodeNumber,
      });
  }

  @override
  WatchSession fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final targetRef = _targetRefFromPayload(payload);
    if (targetRef.kind != kind) {
      throw ArgumentError.value(
        targetRef.kind,
        'payload.catalog_ref.kind',
        'Expected Anime watch session',
      );
    }
    return WatchSession(
      id: id,
      targetRef: targetRef,
      trackingEntryId: payload['tracking_entry_id'] as String?,
      seasonNumber: _int(payload['season_number']),
      episodeNumber: _int(payload['episode_number']),
      sourceType: payload['source_type'] as String?,
      seenWhere: payload['seen_where'] as String?,
      watchedAt: DateTime.parse(payload['watched_at'] as String),
      rating: _int(payload['rating']),
      notes: payload['notes'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  WatchSession _fromRow(AnimeWatchSessionRow row) {
    return WatchSession(
      id: row.id,
      targetRef: _targetRef(
        row.targetRefJson,
        itemId: row.seriesId,
      ),
      trackingEntryId: row.trackingEntryId,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      sourceType: trackingSourceTypeFromValue(row.sourceType),
      seenWhere: row.seenWhere,
      watchedAt: row.watchedAt,
      rating: row.rating,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogEntityRef _targetRef(String? rawJson, {required String itemId}) {
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map) {
          return CatalogEntityRef.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      } on Object {
        // Fall through to the typed owner fallback for malformed legacy data.
      }
    }
    return CatalogEntityRef(
      kind: kind,
      entityType: CatalogEntityType.work,
      id: itemId,
    );
  }

  void _validateKind(WatchSession session) {
    if (session.targetRef.kind != kind) {
      throw ArgumentError.value(
        session.targetRef.kind,
        'session.targetRef.kind',
        'Expected Anime watch session',
      );
    }
  }

  CatalogEntityRef _targetRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['target_ref'] ?? payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException(
        'Anime watch session is missing catalog_ref',
      );
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
