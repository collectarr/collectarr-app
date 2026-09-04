import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:drift/drift.dart';

/// Persists TV-specific watch history, episode progress, and custom episodes.
///
/// The generic collection repositories remain available to older screens, but
/// TV's typed code uses this repository and never stores its graph through the
/// shared video persistence models.
final class TvTrackingRepository {
  TvTrackingRepository(this._db);

  final LocalDatabase _db;

  Future<List<TvWatchSession>> listWatchSessions(TvSeriesId seriesId) async {
    final rows = await (_db.select(_db.tvWatchSessionRows)
          ..where((table) => table.seriesId.equals(seriesId.value))
          ..orderBy([(table) => OrderingTerm.desc(table.watchedAt)]))
        .get();
    return rows
        .where((row) => row.deletedAt == null)
        .map<TvWatchSession>(_watchSessionFromRow)
        .toList(growable: false);
  }

  Future<void> upsertWatchSession(TvWatchSession session) async {
    await _db
        .into(_db.tvWatchSessionRows)
        .insertOnConflictUpdate(_watchSessionCompanion(session));
  }

  Future<void> markWatchSessionDeleted(
    TvWatchSession session,
    DateTime deletedAt,
  ) {
    return upsertWatchSession(
      TvWatchSession(
        id: session.id,
        seriesId: session.seriesId,
        targetRef: session.targetRef,
        watchedAt: session.watchedAt,
        updatedAt: deletedAt,
        episodeId: session.episodeId,
        trackingEntryId: session.trackingEntryId,
        seasonNumber: session.seasonNumber,
        episodeNumber: session.episodeNumber,
        sourceType: session.sourceType,
        seenWhere: session.seenWhere,
        rating: session.rating,
        notes: session.notes,
        deletedAt: deletedAt,
      ),
    );
  }

  Future<TvEpisodeProgress?> findEpisodeProgress({
    required TvSeriesId seriesId,
    required TvSeasonId seasonId,
    required TvEpisodeId episodeId,
  }) async {
    final row = await (_db.select(_db.tvEpisodeProgressRows)
          ..where(
            (table) =>
                table.seriesId.equals(seriesId.value) &
                table.seasonId.equals(seasonId.value) &
                table.episodeId.equals(episodeId.value),
          ))
        .getSingleOrNull();
    return row == null || row.deletedAt != null
        ? null
        : _episodeProgressFromRow(row);
  }

  Future<List<TvEpisodeProgress>> listEpisodeProgress(
    TvSeriesId seriesId,
  ) async {
    final rows = await (_db.select(_db.tvEpisodeProgressRows)
          ..where((table) => table.seriesId.equals(seriesId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.seasonNumber),
            (table) => OrderingTerm.asc(table.episodeNumber),
          ]))
        .get();
    return rows
        .where((row) => row.deletedAt == null)
        .map<TvEpisodeProgress>(_episodeProgressFromRow)
        .toList(growable: false);
  }

  Future<void> upsertEpisodeProgress(TvEpisodeProgress progress) async {
    await _db
        .into(_db.tvEpisodeProgressRows)
        .insertOnConflictUpdate(_episodeProgressCompanion(progress));
  }

  Future<List<TvCustomEpisode>> listCustomEpisodes(
    TvSeriesId seriesId,
  ) async {
    final rows = await (_db.select(_db.tvCustomEpisodeRows)
          ..where((table) => table.seriesId.equals(seriesId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.seasonNumber),
            (table) => OrderingTerm.asc(table.episodeNumber),
          ]))
        .get();
    return rows
        .where((row) => row.deletedAt == null)
        .map<TvCustomEpisode>(_customEpisodeFromRow)
        .toList(growable: false);
  }

  Future<void> upsertCustomEpisode(TvCustomEpisode episode) async {
    await _db
        .into(_db.tvCustomEpisodeRows)
        .insertOnConflictUpdate(_customEpisodeCompanion(episode));
  }

  Future<void> markCustomEpisodeDeleted(
    TvCustomEpisode episode,
    DateTime deletedAt,
  ) {
    return upsertCustomEpisode(
      TvCustomEpisode(
        id: episode.id,
        seriesId: episode.seriesId,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
        title: episode.title,
        updatedAt: deletedAt,
        description: episode.description,
        airDate: episode.airDate,
        runtimeMinutes: episode.runtimeMinutes,
        stillImageUrl: episode.stillImageUrl,
        localImagePath: episode.localImagePath,
        thumbnailImageUrl: episode.thumbnailImageUrl,
        deletedAt: deletedAt,
      ),
    );
  }

  TvWatchSessionRowsCompanion _watchSessionCompanion(
    TvWatchSession session,
  ) {
    return TvWatchSessionRowsCompanion.insert(
      id: session.id,
      seriesId: session.seriesId.value,
      episodeId: Value(session.episodeId?.value),
      targetRefJson: Value(jsonEncode(session.targetRef.toJson())),
      trackingEntryId: Value(session.trackingEntryId),
      seasonNumber: Value(session.seasonNumber),
      episodeNumber: Value(session.episodeNumber),
      sourceType: Value(session.sourceType?.apiValue),
      seenWhere: Value(session.seenWhere),
      watchedAt: session.watchedAt,
      rating: Value(session.rating),
      notes: Value(session.notes),
      updatedAt: session.updatedAt,
      deletedAt: Value(session.deletedAt),
    );
  }

  TvEpisodeProgressRowsCompanion _episodeProgressCompanion(
    TvEpisodeProgress progress,
  ) {
    return TvEpisodeProgressRowsCompanion.insert(
      seriesId: progress.seriesId.value,
      seasonId: progress.seasonId.value,
      episodeId: progress.episodeId.value,
      seasonNumber: Value(progress.seasonNumber),
      episodeNumber: Value(progress.episodeNumber),
      watchedCount: Value(progress.watchedCount),
      completed: Value(progress.completed),
      lastWatchedAt: Value(progress.lastWatchedAt),
      rating: Value(progress.rating),
      notes: Value(progress.notes),
      updatedAt: progress.updatedAt,
      deletedAt: Value(progress.deletedAt),
      rawPayloadJson: Value(jsonEncode(progress.rawPayload)),
    );
  }

  TvCustomEpisodeRowsCompanion _customEpisodeCompanion(
    TvCustomEpisode episode,
  ) {
    return TvCustomEpisodeRowsCompanion.insert(
      id: episode.id.value,
      seriesId: episode.seriesId.value,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      description: Value(episode.description),
      airDate: Value(episode.airDate),
      runtimeMinutes: Value(episode.runtimeMinutes),
      stillImageUrl: Value(episode.stillImageUrl),
      localImagePath: Value(episode.localImagePath),
      thumbnailImageUrl: Value(episode.thumbnailImageUrl),
      updatedAt: episode.updatedAt,
      deletedAt: Value(episode.deletedAt),
    );
  }

  TvWatchSession _watchSessionFromRow(TvWatchSessionRow row) {
    final targetRef = row.targetRefJson;
    return TvWatchSession(
      id: row.id,
      seriesId: TvSeriesId(row.seriesId),
      episodeId: row.episodeId == null ? null : TvEpisodeId(row.episodeId!),
      targetRef: targetRef == null
          ? CatalogEntityRef(
              kind: 'tv',
              entityType: CatalogEntityType.work,
              id: row.seriesId,
            )
          : CatalogEntityRef.fromJson(
              jsonDecode(targetRef) as Map<String, dynamic>,
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

  TvEpisodeProgress _episodeProgressFromRow(TvEpisodeProgressRow row) {
    return TvEpisodeProgress(
      seriesId: TvSeriesId(row.seriesId),
      seasonId: TvSeasonId(row.seasonId),
      episodeId: TvEpisodeId(row.episodeId),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      watchedCount: row.watchedCount,
      completed: row.completed,
      lastWatchedAt: row.lastWatchedAt,
      rating: row.rating,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      rawPayload: _jsonMap(row.rawPayloadJson),
    );
  }

  TvCustomEpisode _customEpisodeFromRow(TvCustomEpisodeRow row) {
    return TvCustomEpisode(
      id: TvEpisodeId(row.id),
      seriesId: TvSeriesId(row.seriesId),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      description: row.description,
      airDate: row.airDate,
      runtimeMinutes: row.runtimeMinutes,
      stillImageUrl: row.stillImageUrl,
      localImagePath: row.localImagePath,
      thumbnailImageUrl: row.thumbnailImageUrl,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}

Map<String, dynamic> _jsonMap(String value) {
  final decoded = jsonDecode(value);
  return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
}
