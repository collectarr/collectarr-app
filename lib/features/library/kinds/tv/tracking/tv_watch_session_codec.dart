import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:drift/drift.dart';

final class TvWatchSessionCodec implements WatchSessionCodec {
  const TvWatchSessionCodec();

  @override
  String get kind => 'tv';

  @override
  Future<List<WatchSession>> listActive(
    LocalDatabase db, {
    Iterable<String>? itemIds,
  }) async {
    final ids = itemIds?.toSet().toList(growable: false);
    if (ids != null && ids.isEmpty) return const [];
    final query = db.select(db.tvWatchSessionRows)
      ..where((row) => row.deletedAt.isNull());
    if (ids != null) {
      query.where((row) => row.seriesId.isIn(ids));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<WatchSession?> findById(LocalDatabase db, String id) async {
    final row = await (db.select(db.tvWatchSessionRows)
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
        'Expected TV watch session',
      );
    }
    await db.into(db.tvWatchSessionRows).insertOnConflictUpdate(
          TvWatchSessionRowsCompanion.insert(
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

  WatchSession _fromRow(TvWatchSessionRow row) {
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
}
