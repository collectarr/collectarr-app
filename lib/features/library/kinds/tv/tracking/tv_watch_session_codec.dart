import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:drift/drift.dart';

final class TvWatchSessionCodec implements WatchSessionCodec {
  const TvWatchSessionCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  WatchSession create(WatchSessionCreateRequest request) {
    if (request.targetRef.mediaKind != kind) {
      throw ArgumentError.value(
        request.targetRef.mediaKind,
        'request.targetRef.kind',
        'Expected TV watch session',
      );
    }
    final coordinates = _coordinatesForTarget(request.targetRef);
    return TvWatchSession(
      id: request.id,
      seriesId: TvSeriesId(
        request.targetRef.rootId ?? request.targetRef.id,
      ),
      episodeId: request.targetRef.entityType.apiValue == 'episode'
          ? TvEpisodeId(request.targetRef.id)
          : null,
      targetRef: request.targetRef,
      trackingEntryId: request.trackingEntryId,
      seasonNumber: coordinates.seasonNumber,
      episodeNumber: coordinates.episodeNumber,
      sourceType: request.sourceType,
      seenWhere: request.seenWhere,
      watchedAt: request.watchedAt ?? request.updatedAt,
      rating: request.rating,
      notes: request.notes,
      updatedAt: request.updatedAt,
    );
  }

  @override
  bool matchesCatalogScope(WatchSession session, CatalogEntityRef scope) {
    if (session.targetRef.mediaKind != kind || scope.mediaKind != kind) {
      return false;
    }
    final target = session.targetRef;
    if (target == scope) return true;

    final scopeId = scope.id;
    final targetRootId = target.rootId ?? target.id;
    if (targetRootId != (scope.rootId ?? scopeId)) return false;

    return switch (scope.entityType.apiValue) {
      'work' => true,
      'season' =>
        target.parentId == scopeId || target.id.startsWith('$scopeId:episode:'),
      'episode' => target.id == scopeId || target.parentId == scopeId,
      _ => target.rootId == scopeId,
    };
  }

  @override
  Future<List<WatchSession>> listActive(
    LocalDatabase db, {
    CatalogEntityRef? catalogRef,
  }) async {
    final query = db.select(db.tvWatchSessionRows)
      ..where((row) => row.deletedAt.isNull());
    if (catalogRef != null) {
      if (catalogRef.mediaKind != kind) return const [];
      query.where((row) => row.seriesId.equals(catalogRef.id));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<WatchSession?> findByRef(
    LocalDatabase db,
    WatchSessionRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final row = await (db.select(db.tvWatchSessionRows)
          ..where((item) => item.id.equals(ref.id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(LocalDatabase db, WatchSession session) async {
    if (session is! TvWatchSession || session.targetRef.mediaKind != kind) {
      throw ArgumentError.value(
        session.targetRef.mediaKind,
        'session.targetRef.kind',
        'Expected TV watch session',
      );
    }
    await db.into(db.tvWatchSessionRows).insertOnConflictUpdate(
          TvWatchSessionRowsCompanion.insert(
            id: session.id,
            seriesId: session.targetRef.rootId ?? session.targetRef.id,
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
    final typed = session as TvWatchSession;
    return typed.toSyncPayload()
      ..addAll({
        'season_number': typed.seasonNumber,
        'episode_number': typed.episodeNumber,
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
    if (targetRef.mediaKind != kind) {
      throw ArgumentError.value(
        targetRef.mediaKind,
        'payload.catalog_ref.kind',
        'Expected TV watch session',
      );
    }
    return TvWatchSession(
      id: id,
      seriesId: TvSeriesId(targetRef.rootId ?? targetRef.id),
      episodeId: targetRef.entityType.apiValue == 'episode'
          ? TvEpisodeId(targetRef.id)
          : null,
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

  TvWatchSession _fromRow(TvWatchSessionRow row) {
    final targetRef = _targetRef(
      row.targetRefJson,
      itemId: row.seriesId,
    );
    return TvWatchSession(
      id: row.id,
      seriesId: TvSeriesId(row.seriesId),
      episodeId: targetRef.entityType.apiValue == 'episode'
          ? TvEpisodeId(targetRef.id)
          : null,
      targetRef: targetRef,
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
    if (rawJson == null || rawJson.isEmpty) {
      throw StateError('TV watch session $itemId is missing target_ref.');
    }
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw FormatException('TV watch session $itemId has invalid target_ref.');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(decoded));
  }

  void _validateKind(WatchSession session) {
    if (session is! TvWatchSession || session.targetRef.mediaKind != kind) {
      throw ArgumentError.value(
        session.targetRef.mediaKind,
        'session.targetRef.kind',
        'Expected TV watch session',
      );
    }
  }

  CatalogEntityRef _targetRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['target_ref'] ?? payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException('TV watch session is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }

  _TvWatchCoordinates _coordinatesForTarget(CatalogEntityRef target) {
    final season = _numberAfter(target.id, ':season:');
    final episode = _numberAfter(target.id, ':episode:');
    return _TvWatchCoordinates(
      seasonNumber: season,
      episodeNumber: episode,
    );
  }

  int? _numberAfter(String value, String marker) {
    final markerIndex = value.indexOf(marker);
    if (markerIndex < 0) return null;
    final start = markerIndex + marker.length;
    final end = value.indexOf(':', start);
    return int.tryParse(value.substring(start, end < 0 ? value.length : end));
  }
}

final class _TvWatchCoordinates {
  const _TvWatchCoordinates({this.seasonNumber, this.episodeNumber});

  final int? seasonNumber;
  final int? episodeNumber;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
