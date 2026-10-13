import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:drift/drift.dart';

/// Persists TV-specific watch history and custom episode records.
///
/// The repository stores TV-specific episode activity beside its owning local
/// library entry. Episode coordinates remain contained details, not separate
/// collection identities.
final class TvTrackingRepository {
  TvTrackingRepository(this._db);

  final LocalDatabase _db;

  Future<List<TvWatchSession>> listWatchSessions(
    LibraryEntryRef libraryEntryRef,
  ) async {
    final rows = await (_db.select(_db.tvWatchSessionRows)
          ..where(
              (table) => table.libraryEntryId.equals(libraryEntryRef.id.value))
          ..orderBy([(table) => OrderingTerm.desc(table.watchedAt)]))
        .get();
    return rows
        .where((row) => row.deletedAt == null)
        .map<TvWatchSession>(_watchSessionFromRow)
        .toList(growable: false);
  }

  Future<void> upsertWatchSession(TvWatchSession session) async {
    if (session.libraryEntryRef.kind != CatalogMediaKind.tv) {
      throw ArgumentError(
        'TV watch session must target its explicit local library entry.',
      );
    }
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
        libraryEntryRef: session.libraryEntryRef,
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

  Future<List<TvCustomEpisode>> listCustomEpisodes(
    LibraryEntryRef libraryEntryRef,
  ) async {
    _validateEntryRef(libraryEntryRef, 'custom episode');
    final rows = await (_db.select(_db.tvCustomEpisodeRows)
          ..where(
              (table) => table.libraryEntryId.equals(libraryEntryRef.id.value))
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
    _validateEntryRef(episode.libraryEntryRef, 'custom episode');
    await _db
        .into(_db.tvCustomEpisodeRows)
        .insertOnConflictUpdate(_customEpisodeCompanion(episode));
  }

  Future<TvCustomEpisode?> findCustomEpisodeById(TvEpisodeId id) async {
    final row = await (_db.select(_db.tvCustomEpisodeRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : _customEpisodeFromRow(row);
  }

  Future<void> markCustomEpisodeDeleted(
    TvCustomEpisode episode,
    DateTime deletedAt,
  ) {
    return upsertCustomEpisode(
      TvCustomEpisode(
        id: episode.id,
        libraryEntryRef: episode.libraryEntryRef,
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
      libraryEntryId: session.libraryEntryRef.id.value,
      libraryEntryRefKey: session.libraryEntryRef.key,
      episodeId: Value(session.episodeId?.value),
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

  TvCustomEpisodeRowsCompanion _customEpisodeCompanion(
    TvCustomEpisode episode,
  ) {
    return TvCustomEpisodeRowsCompanion.insert(
      id: episode.id.value,
      libraryEntryId: episode.libraryEntryRef.id.value,
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
    final libraryEntryRef = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
    if (libraryEntryRef.kind != CatalogMediaKind.tv ||
        libraryEntryRef.id.value != row.libraryEntryId) {
      throw FormatException(
        'TV watch session ${row.id} has a mismatched local entry reference.',
      );
    }
    return TvWatchSession(
      id: row.id,
      libraryEntryRef: libraryEntryRef,
      episodeId: row.episodeId == null ? null : TvEpisodeId(row.episodeId!),
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

  TvCustomEpisode _customEpisodeFromRow(TvCustomEpisodeRow row) {
    return TvCustomEpisode(
      id: TvEpisodeId(row.id),
      libraryEntryRef: LibraryEntryRef(
        kind: CatalogMediaKind.tv,
        id: LibraryEntryId(row.libraryEntryId),
      ),
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

  void _validateEntryRef(LibraryEntryRef ref, String recordType) {
    if (ref.kind != CatalogMediaKind.tv) {
      throw ArgumentError.value(
        ref.kind,
        'libraryEntryRef.kind',
        'TV $recordType must belong to a TV library entry.',
      );
    }
  }
}
