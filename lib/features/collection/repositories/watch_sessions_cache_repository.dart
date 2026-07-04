import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:drift/drift.dart';

class WatchSessionsCacheRepository {
  WatchSessionsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<WatchSession>> listActive() async {
    final rows = await (_db.select(_db.watchSessionsCache)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.watchedAt)]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<List<WatchSession>> listActiveByItemId(String itemId) async {
    final rows = await (_db.select(_db.watchSessionsCache)
          ..where(
            (tbl) => tbl.deletedAt.isNull() & tbl.itemId.equals(itemId),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.watchedAt)]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<List<WatchSession>> listActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids =
        itemIds.where((v) => v.isNotEmpty).toSet().toList(growable: false);
    if (ids.isEmpty) return const <WatchSession>[];
    final rows = await (_db.select(_db.watchSessionsCache)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.itemId.isIn(ids))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.watchedAt)]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<WatchSession?> findById(String id) async {
    final row = await (_db.select(_db.watchSessionsCache)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> upsert(WatchSession session) async {
    await _db
        .into(_db.watchSessionsCache)
        .insertOnConflictUpdate(_toCompanion(session));
  }

  Future<void> upsertAll(List<WatchSession> sessions) async {
    if (sessions.isEmpty) return;
    final companions = sessions.map(_toCompanion).toList(growable: false);
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.watchSessionsCache, companions);
    });
  }

  Future<void> markDeleted(WatchSession session, DateTime deletedAt) async {
    await (_db.update(_db.watchSessionsCache)
          ..where((tbl) => tbl.id.equals(session.id)))
        .write(
      WatchSessionsCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  WatchSessionsCacheCompanion _toCompanion(WatchSession session) {
    return WatchSessionsCacheCompanion(
      id: Value(session.id),
      itemId: Value(session.itemId),
      targetRefJson: Value(jsonEncode(session.targetRef.toJson())),
      trackingEntryId: Value(session.trackingEntryId),
      seasonNumber: Value(session.seasonNumber),
      episodeNumber: Value(session.episodeNumber),
      sourceType: Value(session.sourceTypeApiValue),
      seenWhere: Value(session.seenWhere),
      watchedAt: Value(session.watchedAt),
      rating: Value(session.rating),
      notes: Value(session.notes),
      updatedAt: Value(session.updatedAt),
      deletedAt: Value(session.deletedAt),
    );
  }

  WatchSession _toModel(WatchSessionsCacheData row) {
    return WatchSession(
      id: row.id,
      targetRef: row.targetRefJson == null
          ? CatalogEntityRef(
              kind: 'unknown',
              entityType: CatalogEntityType.work,
              id: row.itemId,
            )
          : CatalogEntityRef.fromJson(
              jsonDecode(row.targetRefJson!) as Map<String, dynamic>,
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
}
