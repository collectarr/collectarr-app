import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:drift/drift.dart';

/// Compatibility facade over the TV and Anime-owned watch-session tables.
///
/// Callers still consume the shared interaction model, while persistence is
/// routed by the catalog kind and never lands in a generic table.
class WatchSessionsCacheRepository {
  WatchSessionsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<WatchSession>> listActive() async {
    final tvRows = await (_db.select(_db.tvWatchSessionRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final animeRows = await (_db.select(_db.animeWatchSessionRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final sessions = [
      ...tvRows.map(_fromTvRow),
      ...animeRows.map(_fromAnimeRow),
    ]..sort(_compareSessions);
    return sessions;
  }

  Future<List<WatchSession>> listActiveByItemId(String itemId) async {
    final sessions = await listActiveByItemIds([itemId]);
    return sessions;
  }

  Future<List<WatchSession>> listActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids = itemIds
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <WatchSession>[];
    final tvRows = await (_db.select(_db.tvWatchSessionRows)
          ..where(
            (row) => row.deletedAt.isNull() & row.seriesId.isIn(ids),
          ))
        .get();
    final animeRows = await (_db.select(_db.animeWatchSessionRows)
          ..where(
            (row) => row.deletedAt.isNull() & row.seriesId.isIn(ids),
          ))
        .get();
    final sessions = [
      ...tvRows.map(_fromTvRow),
      ...animeRows.map(_fromAnimeRow),
    ]..sort(_compareSessions);
    return sessions;
  }

  Future<WatchSession?> findById(String id) async {
    final tvRow = await (_db.select(_db.tvWatchSessionRows)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (tvRow != null) return _fromTvRow(tvRow);
    final animeRow = await (_db.select(_db.animeWatchSessionRows)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    return animeRow == null ? null : _fromAnimeRow(animeRow);
  }

  Future<void> upsert(WatchSession session) async {
    await _db.transaction(() => _upsert(session));
  }

  Future<void> upsertAll(List<WatchSession> sessions) async {
    if (sessions.isEmpty) return;
    await _db.transaction(() async {
      for (final session in sessions) {
        await _upsert(session);
      }
    });
  }

  Future<void> markDeleted(WatchSession session, DateTime deletedAt) {
    return upsert(session.copyWith(deletedAt: deletedAt, updatedAt: deletedAt));
  }

  Future<void> _upsert(WatchSession session) {
    if (session.targetRef.kind == 'anime') {
      return _db
          .into(_db.animeWatchSessionRows)
          .insertOnConflictUpdate(_toAnimeCompanion(session));
    }
    return _db
        .into(_db.tvWatchSessionRows)
        .insertOnConflictUpdate(_toTvCompanion(session));
  }

  AnimeWatchSessionRowsCompanion _toAnimeCompanion(WatchSession session) {
    return AnimeWatchSessionRowsCompanion.insert(
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
    );
  }

  TvWatchSessionRowsCompanion _toTvCompanion(WatchSession session) {
    return TvWatchSessionRowsCompanion.insert(
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
    );
  }

  WatchSession _fromTvRow(TvWatchSessionRow row) {
    return WatchSession(
      id: row.id,
      targetRef: _targetRef(
        row.targetRefJson,
        kind: 'tv',
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

  WatchSession _fromAnimeRow(AnimeWatchSessionRow row) {
    return WatchSession(
      id: row.id,
      targetRef: _targetRef(
        row.targetRefJson,
        kind: 'anime',
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

  CatalogEntityRef _targetRef(
    String? rawJson, {
    required String kind,
    required String itemId,
  }) {
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map) {
          return CatalogEntityRef.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      } on Object {
        // Use the typed owner fallback below for malformed legacy data.
      }
    }
    return CatalogEntityRef(
      kind: kind,
      entityType: CatalogEntityType.work,
      id: itemId,
    );
  }

  static int _compareSessions(WatchSession a, WatchSession b) {
    return b.watchedAt.compareTo(a.watchedAt);
  }
}
