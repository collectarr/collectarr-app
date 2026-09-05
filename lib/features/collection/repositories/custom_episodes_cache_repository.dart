import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:drift/drift.dart';

/// Compatibility facade over the TV and Anime-owned custom-episode tables.
class CustomEpisodesCacheRepository {
  CustomEpisodesCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<CustomEpisode>> listByItemId(String itemId) async {
    final tvRows = await (_db.select(_db.tvCustomEpisodeRows)
          ..where(
            (row) => row.seriesId.equals(itemId) & row.deletedAt.isNull(),
          ))
        .get();
    final animeRows = await (_db.select(_db.animeCustomEpisodeRows)
          ..where(
            (row) => row.seriesId.equals(itemId) & row.deletedAt.isNull(),
          ))
        .get();
    final episodes = [
      ...tvRows.map(_fromTvRow),
      ...animeRows.map(_fromAnimeRow),
    ]..sort(_compareEpisodes);
    return episodes;
  }

  Future<Map<int, List<CustomEpisode>>> listByItemIdGrouped(
    String itemId,
  ) async {
    final episodes = await listByItemId(itemId);
    final grouped = <int, List<CustomEpisode>>{};
    for (final episode in episodes) {
      grouped.putIfAbsent(episode.seasonNumber, () => <CustomEpisode>[]).add(
            episode,
          );
    }
    return grouped;
  }

  Future<List<CustomEpisode>> listActive() async {
    final tvRows = await (_db.select(_db.tvCustomEpisodeRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final animeRows = await (_db.select(_db.animeCustomEpisodeRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final episodes = [
      ...tvRows.map(_fromTvRow),
      ...animeRows.map(_fromAnimeRow),
    ]..sort(_compareEpisodes);
    return episodes;
  }

  Future<CustomEpisode?> findById(String id) async {
    final tvRow = await (_db.select(_db.tvCustomEpisodeRows)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (tvRow != null) return _fromTvRow(tvRow);
    final animeRow = await (_db.select(_db.animeCustomEpisodeRows)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    return animeRow == null ? null : _fromAnimeRow(animeRow);
  }

  Future<void> upsert(CustomEpisode episode) async {
    await _db.transaction(() => _upsert(episode));
  }

  Future<void> upsertAll(List<CustomEpisode> episodes) async {
    if (episodes.isEmpty) return;
    await _db.transaction(() async {
      for (final episode in episodes) {
        await _upsert(episode);
      }
    });
  }

  Future<void> markDeleted(CustomEpisode episode, DateTime now) {
    return upsert(episode.copyWith(deletedAt: now, updatedAt: now));
  }

  Future<void> _upsert(CustomEpisode episode) {
    if (episode.seriesRef.kind == 'anime') {
      return _db
          .into(_db.animeCustomEpisodeRows)
          .insertOnConflictUpdate(_toAnimeCompanion(episode));
    }
    return _db
        .into(_db.tvCustomEpisodeRows)
        .insertOnConflictUpdate(_toTvCompanion(episode));
  }

  AnimeCustomEpisodeRowsCompanion _toAnimeCompanion(CustomEpisode episode) {
    return AnimeCustomEpisodeRowsCompanion.insert(
      id: episode.id,
      seriesId: episode.itemId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      description: Value(episode.overview),
      airDate: Value(_parseDate(episode.airDate)),
      runtimeMinutes: Value(episode.runtimeMinutes),
      stillImageUrl: Value(episode.stillImageUrl),
      localImagePath: Value(episode.localImagePath),
      thumbnailImageUrl: Value(episode.thumbnailImageUrl),
      updatedAt: episode.updatedAt,
      deletedAt: Value(episode.deletedAt),
    );
  }

  TvCustomEpisodeRowsCompanion _toTvCompanion(CustomEpisode episode) {
    return TvCustomEpisodeRowsCompanion.insert(
      id: episode.id,
      seriesId: episode.itemId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      description: Value(episode.overview),
      airDate: Value(_parseDate(episode.airDate)),
      runtimeMinutes: Value(episode.runtimeMinutes),
      stillImageUrl: Value(episode.stillImageUrl),
      localImagePath: Value(episode.localImagePath),
      thumbnailImageUrl: Value(episode.thumbnailImageUrl),
      updatedAt: episode.updatedAt,
      deletedAt: Value(episode.deletedAt),
    );
  }

  CustomEpisode _fromTvRow(TvCustomEpisodeRow row) {
    return CustomEpisode(
      id: row.id,
      seriesRef: CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: row.seriesId,
      ),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      overview: row.description,
      airDate: _formatDate(row.airDate),
      runtimeMinutes: row.runtimeMinutes,
      stillImageUrl: row.stillImageUrl,
      localImagePath: row.localImagePath,
      thumbnailImageUrl: row.thumbnailImageUrl,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CustomEpisode _fromAnimeRow(AnimeCustomEpisodeRow row) {
    return CustomEpisode(
      id: row.id,
      seriesRef: CatalogEntityRef(
        kind: 'anime',
        entityType: CatalogEntityType.work,
        id: row.seriesId,
      ),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      overview: row.description,
      airDate: _formatDate(row.airDate),
      runtimeMinutes: row.runtimeMinutes,
      stillImageUrl: row.stillImageUrl,
      localImagePath: row.localImagePath,
      thumbnailImageUrl: row.thumbnailImageUrl,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static int _compareEpisodes(CustomEpisode a, CustomEpisode b) {
    final item = a.itemId.compareTo(b.itemId);
    if (item != 0) return item;
    final season = a.seasonNumber.compareTo(b.seasonNumber);
    if (season != 0) return season;
    return a.episodeNumber.compareTo(b.episodeNumber);
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _formatDate(DateTime? value) => value?.toIso8601String();
