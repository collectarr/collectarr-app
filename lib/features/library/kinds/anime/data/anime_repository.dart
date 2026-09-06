import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:drift/drift.dart';

final class AnimeRepository
    implements ReadRepository<AnimeMediaId, AnimeMedia> {
  AnimeRepository(this._db, {AnimeRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final AnimeRemoteSource? _remote;

  @override
  Future<AnimeMedia?> findById(AnimeMediaId id) => getMedia(id);

  Future<AnimeMedia?> getMedia(AnimeMediaId id) async {
    final row = await (_db.select(_db.animeMediaRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) return _hydrateMedia(row);

    final remote = _remote;
    if (remote == null) return null;
    final media = await remote.fetchMedia(id);
    await updateMedia(media);
    return media;
  }

  Future<List<AnimeMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.animeMediaRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) => table.title.like(pattern) | table.sortTitle.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.sortTitle),
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);
    final rows = await select.get();
    return [for (final row in rows) await _hydrateMedia(row)];
  }

  Future<List<AnimeEpisode>> episodesFor(AnimeMediaId mediaId) async {
    final rows = await (_db.select(_db.animeEpisodeRows)
          ..where((table) => table.seriesId.equals(mediaId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.episodeNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows.map(AnimeLocalMapper.fromEpisodeRow).toList(growable: false);
  }

  Future<AnimeEpisode?> getEpisode(
    AnimeMediaId mediaId,
    AnimeEpisodeId episodeId,
  ) async {
    final row = await (_db.select(_db.animeEpisodeRows)
          ..where(
            (table) =>
                table.seriesId.equals(mediaId.value) &
                table.id.equals(episodeId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : AnimeLocalMapper.fromEpisodeRow(row);
  }

  Future<List<AnimeRelease>> releasesFor(AnimeMediaId mediaId) async {
    final rows = await (_db.select(_db.animeReleaseRows)
          ..where((table) => table.seriesId.equals(mediaId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.releaseDate),
            (table) => OrderingTerm.asc(table.title),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows.map(AnimeLocalMapper.fromReleaseRow).toList(growable: false);
  }

  Future<AnimeRelease?> getRelease(
    AnimeMediaId mediaId,
    AnimeReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.animeReleaseRows)
          ..where(
            (table) =>
                table.seriesId.equals(mediaId.value) &
                table.id.equals(releaseId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : AnimeLocalMapper.fromReleaseRow(row);
  }

  Future<void> updateMedia(AnimeMedia media) async {
    if (media.id.value.trim().isEmpty) {
      throw StateError('Cannot update AnimeMedia without an id');
    }

    await _db.transaction(() async {
      await _deleteMediaGraph(media.id);
      await _db
          .into(_db.animeMediaRows)
          .insertOnConflictUpdate(AnimeLocalMapper.toMediaRow(media));
      for (final episode in media.episodes) {
        await _db.into(_db.animeEpisodeRows).insertOnConflictUpdate(
              AnimeLocalMapper.toEpisodeRow(episode),
            );
      }
      for (final release in media.releases) {
        await _db.into(_db.animeReleaseRows).insertOnConflictUpdate(
              AnimeLocalMapper.toReleaseRow(media.id, release),
            );
      }
    });
  }

  Future<void> updateEpisode(AnimeMediaId mediaId, AnimeEpisode episode) {
    if (episode.seriesId != mediaId) {
      throw StateError('Anime episode does not belong to the supplied media');
    }
    return _db.into(_db.animeEpisodeRows).insertOnConflictUpdate(
          AnimeLocalMapper.toEpisodeRow(episode),
        );
  }

  Future<void> updateRelease(AnimeMediaId mediaId, AnimeRelease release) {
    return _db.into(_db.animeReleaseRows).insertOnConflictUpdate(
          AnimeLocalMapper.toReleaseRow(mediaId, release),
        );
  }

  Future<AnimeTracking?> getTracking(String trackingId) async {
    final row = await (_db.select(_db.animeTrackingRows)
          ..where(
            (table) => table.id.equals(trackingId) & table.deletedAt.isNull(),
          ))
        .getSingleOrNull();
    return row == null ? null : AnimeLocalMapper.fromTrackingRow(row);
  }

  Future<void> updateTracking(AnimeTracking tracking) {
    return _db.into(_db.animeTrackingRows).insertOnConflictUpdate(
          AnimeLocalMapper.toTrackingRow(tracking),
        );
  }

  Future<void> markTrackingDeleted(String trackingId, DateTime deletedAt) {
    return (_db.update(_db.animeTrackingRows)
          ..where((table) => table.id.equals(trackingId)))
        .write(
      AnimeTrackingRowsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<AnimeMedia> _hydrateMedia(AnimeMediaRow row) async {
    return AnimeLocalMapper.fromMediaRow(
      row,
      episodes: await episodesFor(AnimeMediaId(row.id)),
      releases: await releasesFor(AnimeMediaId(row.id)),
    );
  }

  Future<void> _deleteMediaGraph(AnimeMediaId mediaId) async {
    await (_db.delete(_db.animeEpisodeRows)
          ..where((table) => table.seriesId.equals(mediaId.value)))
        .go();
    await (_db.delete(_db.animeReleaseRows)
          ..where((table) => table.seriesId.equals(mediaId.value)))
        .go();
  }
}
