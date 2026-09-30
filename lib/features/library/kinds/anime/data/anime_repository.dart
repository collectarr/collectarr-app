import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:drift/drift.dart';

final class AnimeRepository
    implements ReadRepository<AnimeMediaId, AnimeMedia> {
  AnimeRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<AnimeMedia?> findById(AnimeMediaId id) => getMedia(id);

  Future<AnimeMedia?> getMedia(AnimeMediaId id) async {
    final item = await CatalogItemCacheRepository(_db).find(
      CatalogItemRef(kind: CatalogMediaKind.anime, id: id.value),
    );
    return item == null
        ? null
        : AnimeMedia.fromJson(catalogTransportPayloadFor(item));
  }

  Future<List<AnimeMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final items = await CatalogItemCacheRepository(_db)
        .findAll(kind: CatalogMediaKind.anime);
    final media = [
      for (final item in items)
        AnimeMedia.fromJson(catalogTransportPayloadFor(item)),
    ];
    final matches = normalizedQuery.isEmpty
        ? media
        : media.where((item) {
            final query = normalizedQuery.toLowerCase();
            return item.title.toLowerCase().contains(query) ||
                (item.sortTitle?.toLowerCase().contains(query) ?? false);
          }).toList(growable: false);
    matches.sort((left, right) {
      final sortTitle = (left.sortTitle ?? '').compareTo(right.sortTitle ?? '');
      if (sortTitle != 0) return sortTitle;
      final title = left.title.compareTo(right.title);
      return title != 0 ? title : left.id.value.compareTo(right.id.value);
    });
    return matches;
  }

  Future<List<AnimeEpisode>> episodesFor(AnimeMediaId mediaId) async {
    final media = await getMedia(mediaId);
    if (media == null) return const <AnimeEpisode>[];
    final episodes = media.episodes.toList();
    episodes.sort((left, right) {
      final number =
          (left.episodeNumber ?? 0).compareTo(right.episodeNumber ?? 0);
      return number != 0 ? number : left.id.value.compareTo(right.id.value);
    });
    return episodes;
  }

  Future<AnimeEpisode?> getEpisode(
    AnimeMediaId mediaId,
    AnimeEpisodeId episodeId,
  ) async {
    final episodes = await episodesFor(mediaId);
    for (final episode in episodes) {
      if (episode.id == episodeId) return episode;
    }
    return null;
  }

  Future<List<AnimeRelease>> releasesFor(AnimeMediaId mediaId) async {
    final media = await getMedia(mediaId);
    if (media == null) return const <AnimeRelease>[];
    final releases = media.releases.toList();
    releases.sort((left, right) {
      final date = (left.releaseDate ?? DateTime(0))
          .compareTo(right.releaseDate ?? DateTime(0));
      if (date != 0) return date;
      final title = left.title.compareTo(right.title);
      return title != 0 ? title : left.id.value.compareTo(right.id.value);
    });
    return releases;
  }

  Future<AnimeRelease?> getRelease(
    AnimeMediaId mediaId,
    AnimeReleaseId releaseId,
  ) async {
    final releases = await releasesFor(mediaId);
    for (final release in releases) {
      if (release.id == releaseId) return release;
    }
    return null;
  }

  Future<void> updateMedia(AnimeMedia media) async {
    if (media.id.value.trim().isEmpty) {
      throw StateError('Cannot update AnimeMedia without an id');
    }

    final item = CatalogItemDto.fromJson({
      ...media.toJson(),
      'id': media.id.value,
      'kind': CatalogMediaKind.anime.apiValue,
    }).withKindMetadata(media);
    await CatalogItemCacheRepository(_db).upsert(item);
  }

  Future<void> updateEpisode(AnimeMediaId mediaId, AnimeEpisode episode) async {
    if (episode.seriesId != mediaId) {
      throw StateError('Anime episode does not belong to the supplied media');
    }
    final media = await getMedia(mediaId);
    if (media == null) {
      throw StateError(
          'Cannot update an episode without its Anime Catalog Item');
    }
    final episodes = media.episodes.toList();
    final index = episodes.indexWhere((entry) => entry.id == episode.id);
    if (index == -1) {
      episodes.add(episode);
    } else {
      episodes[index] = episode;
    }
    await updateMedia(_withEpisodes(media, episodes));
  }

  Future<void> updateRelease(AnimeMediaId mediaId, AnimeRelease release) async {
    final media = await getMedia(mediaId);
    if (media == null) {
      throw StateError(
          'Cannot update a release without its Anime Catalog Item');
    }
    final releases = media.releases.toList();
    final index = releases.indexWhere((entry) => entry.id == release.id);
    final next = release.seriesId == mediaId
        ? release
        : AnimeRelease(
            id: release.id,
            title: release.title,
            seriesId: mediaId,
            coverImageKey: release.coverImageKey,
            coverImageUrl: release.coverImageUrl,
            description: release.description,
            format: release.format,
            language: release.language,
            regionCode: release.regionCode,
            releaseDate: release.releaseDate,
            publisher: release.publisher,
            distributor: release.distributor,
            barcode: release.barcode,
            mediaCount: release.mediaCount,
            audioTracks: release.audioTracks,
            subtitles: release.subtitles,
            media: release.media,
            episodeMappings: release.episodeMappings,
            rawPayload: release.rawPayload,
          );
    if (index == -1) {
      releases.add(next);
    } else {
      releases[index] = next;
    }
    await updateMedia(_withReleases(media, releases));
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

  Future<void> upsertCustomEpisode(AnimeCustomEpisode episode) {
    return _db.into(_db.animeCustomEpisodeRows).insertOnConflictUpdate(
          AnimeCustomEpisodeRowsCompanion.insert(
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
          ),
        );
  }

  Future<AnimeCustomEpisode?> findCustomEpisodeById(AnimeEpisodeId id) async {
    final row = await (_db.select(_db.animeCustomEpisodeRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    return AnimeCustomEpisode(
      id: AnimeEpisodeId(row.id),
      seriesId: AnimeMediaId(row.seriesId),
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

  AnimeMedia _withEpisodes(AnimeMedia media, List<AnimeEpisode> episodes) =>
      AnimeMedia.fromJson({
        ...media.toJson(),
        'episodes': [for (final episode in episodes) episode.toJson()],
      });

  AnimeMedia _withReleases(AnimeMedia media, List<AnimeRelease> releases) =>
      AnimeMedia.fromJson({
        ...media.toJson(),
        'releases': [for (final release in releases) release.toJson()],
      });
}
