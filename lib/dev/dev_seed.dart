/// Development seed data for the local database.
///
/// Populates the typed local catalog projections, OwnedItemsCache,
/// TrackingEntriesCache, PickListValues, SerialAuthority, and
/// CustomFieldDefinitions/Values with rich entries for every library kind.
///
/// Usage: call `seedLocalDatabase(db)` from main.dart or a debug menu.
/// Safe to call multiple times – uses deterministic IDs (idempotent via upsert).
library;

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/dev/seeds/anime_seeds.dart';
import 'package:collectarr_app/dev/seeds/boardgame_seeds.dart';
import 'package:collectarr_app/dev/seeds/book_seeds.dart';
import 'package:collectarr_app/dev/seeds/comic_seeds.dart';
import 'package:collectarr_app/dev/seeds/custom_field_seeds.dart';
import 'package:collectarr_app/dev/seeds/game_seeds.dart';
import 'package:collectarr_app/dev/seeds/manga_seeds.dart';
import 'package:collectarr_app/dev/seeds/movie_seeds.dart';
import 'package:collectarr_app/dev/seeds/music_seeds.dart';
import 'package:collectarr_app/dev/seeds/pick_list_seeds.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/tv_seeds.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

export 'package:collectarr_app/dev/seeds/anime_seeds.dart';
export 'package:collectarr_app/dev/seeds/boardgame_seeds.dart';
export 'package:collectarr_app/dev/seeds/book_seeds.dart';
export 'package:collectarr_app/dev/seeds/comic_seeds.dart';
export 'package:collectarr_app/dev/seeds/custom_field_seeds.dart';
export 'package:collectarr_app/dev/seeds/game_seeds.dart';
export 'package:collectarr_app/dev/seeds/manga_seeds.dart';
export 'package:collectarr_app/dev/seeds/movie_seeds.dart';
export 'package:collectarr_app/dev/seeds/music_seeds.dart';
export 'package:collectarr_app/dev/seeds/pick_list_seeds.dart';
export 'package:collectarr_app/dev/seeds/seed_helpers.dart';
export 'package:collectarr_app/dev/seeds/tv_seeds.dart';

/// Expected cardinality of the checked-in development fixture set.
///
/// Keeping this manifest next to the seed entry point makes omissions in an
/// individual kind script fail before anything is written to the database.
const devSeedCatalogCounts = <String, int>{
  'movie': 15,
  'tv': 15,
  'anime': 15,
  'manga': 15,
  'book': 15,
  'music': 15,
  'game': 15,
  'boardgame': 15,
  'comic': 15,
};

/// Minimum typed graph coverage expected from the fixture set.
///
/// Some fixtures intentionally contain multiple editions/tracks, so these
/// are lower bounds rather than exact totals.
const devSeedTypedGraphMinimumCounts = <String, int>{
  'comic.media': 15,
  'comic.release': 15,
  'manga.media': 15,
  'book.media': 15,
  'book.release': 15,
  'game.media': 15,
  'game.release': 15,
  'boardgame.media': 15,
  'boardgame.edition': 15,
  'movie.media': 15,
  'movie.release': 15,
  'tv.series': 15,
  'tv.season': 15,
  'tv.episode': 30,
  'tv.release': 15,
  'tv.release_media': 15,
  'anime.media': 15,
  'anime.episode': 30,
  'anime.release': 15,
  'music.release': 15,
  'music.media': 15,
  'music.track': 15,
};

/// Minimum rows expected in each kind-owned physical-copy details table.
///
/// Every kind is measured from its complete kind-owned copy table.
const devSeedTypedOwnedMinimumCounts = <String, int>{
  'comic.owned': 15,
  'manga.owned': 15,
  'book.owned': 15,
  'game.owned': 15,
  'boardgame.owned': 15,
  'movie.owned': 15,
  'tv.owned': 15,
  'anime.owned': 15,
  'music.owned': 15,
};

/// Minimum typed tracking rows expected from episodic fixtures.
const devSeedTypedTrackingMinimumCounts = <String, int>{
  'tv.episode_progress': 30,
  'anime.tracking': 30,
};

/// Minimum kind-owned coordinate rows expected from the typed tracking-unit
/// fixture. These rows exercise the per-kind tracking-unit codecs in addition
/// to the TV/Anime progress repositories above.
const devSeedTypedTrackingUnitMinimumCounts = <String, int>{
  'comic.issue_units': 15,
  'manga.chapter_units': 15,
  'book.chapter_units': 15,
  'tv.episode_units': 30,
  'anime.episode_units': 30,
};

/// Minimum coverage for the universal development fixtures that support the
/// typed library views and settings screens.
const devSeedAuxiliaryMinimumCounts = <String, int>{
  'images.front_cover': 135,
  'images.back_cover': 68,
  'images.detail_photo': 45,
  'custom_field.definitions': 9,
  'custom_field.values': 9,
  'pick_list.values': 1,
};

/// Counts the typed catalog graph written by the development seed.
///
/// This is intentionally a composition-root helper: the seed verifier may
/// enumerate kind tables, while runtime catalog code must continue to use the
/// owning kind repository/codec instead of inspecting these tables.
Future<Map<String, int>> devSeedTypedGraphCounts(LocalDatabase db) async {
  return {
    'comic.media': (await db.select(db.comicMediaRows).get()).length,
    'comic.release': (await db.select(db.comicReleaseRows).get()).length,
    'manga.media': (await db.select(db.mangaMediaRows).get()).length,
    'book.media': (await db.select(db.bookMediaRows).get()).length,
    'book.release': (await db.select(db.bookReleaseRows).get()).length,
    'game.media': (await db.select(db.gameMediaRows).get()).length,
    'game.release': (await db.select(db.gameReleaseRows).get()).length,
    'boardgame.media': (await db.select(db.boardGameMediaRows).get()).length,
    'boardgame.edition':
        (await db.select(db.boardGameEditionRows).get()).length,
    'movie.media': (await db.select(db.movieMediaRows).get()).length,
    'movie.release': (await db.select(db.movieReleaseRows).get()).length,
    'tv.series': (await db.select(db.tvSeriesRows).get()).length,
    'tv.season': (await db.select(db.tvSeasonRows).get()).length,
    'tv.episode': (await db.select(db.tvEpisodeRows).get()).length,
    'tv.release': (await db.select(db.tvReleaseRows).get()).length,
    'tv.release_media': (await db.select(db.tvReleaseMediaRows).get()).length,
    'anime.media': (await db.select(db.animeMediaRows).get()).length,
    'anime.episode': (await db.select(db.animeEpisodeRows).get()).length,
    'anime.release': (await db.select(db.animeReleaseRows).get()).length,
    'music.release': (await db.select(db.musicReleaseRows).get()).length,
    'music.media': (await db.select(db.musicMediaRows).get()).length,
    'music.track': (await db.select(db.musicTrackRows).get()).length,
  };
}

/// Returns relationship errors in the typed rows written by the development
/// fixture. Only deterministic seed rows are inspected so a developer can
/// run this against a database that also contains real local data.
Future<List<String>> devSeedTypedGraphIntegrityIssues(LocalDatabase db) async {
  final issues = <String>[];
  bool isSeed(String id) => id.startsWith('seed-');

  final comicMedia = await db.select(db.comicMediaRows).get();
  final comicMediaIds = comicMedia.map((row) => row.id).toSet();
  final comicReleases = await db.select(db.comicReleaseRows).get();
  for (final row in comicReleases.where((row) => isSeed(row.mediaId))) {
    if (!comicMediaIds.contains(row.mediaId)) {
      issues.add('comic release ${row.id} has missing media ${row.mediaId}');
    }
  }

  final mangaMedia = await db.select(db.mangaMediaRows).get();
  for (final row in mangaMedia.where((row) => isSeed(row.id))) {
    if (row.chaptersJson == '[]') {
      issues.add('manga media ${row.id} has no persisted chapters');
    }
  }

  final bookMedia = await db.select(db.bookMediaRows).get();
  final bookMediaIds = bookMedia.map((row) => row.id).toSet();
  final bookReleases = await db.select(db.bookReleaseRows).get();
  for (final row in bookReleases.where((row) => isSeed(row.mediaId))) {
    if (!bookMediaIds.contains(row.mediaId)) {
      issues.add('book release ${row.id} has missing media ${row.mediaId}');
    }
    if (row.workId != row.mediaId) {
      issues.add(
        'book release ${row.id} points to work ${row.workId}, '
        'expected ${row.mediaId}',
      );
    }
  }

  final gameMedia = await db.select(db.gameMediaRows).get();
  final gameMediaIds = gameMedia.map((row) => row.id).toSet();
  final gameReleases = await db.select(db.gameReleaseRows).get();
  for (final row in gameReleases.where((row) => isSeed(row.mediaId))) {
    if (!gameMediaIds.contains(row.mediaId)) {
      issues.add('game release ${row.id} has missing media ${row.mediaId}');
    }
    if (row.workId != row.mediaId) {
      issues.add(
        'game release ${row.id} points to work ${row.workId}, '
        'expected ${row.mediaId}',
      );
    }
  }

  final boardGameMedia = await db.select(db.boardGameMediaRows).get();
  final boardGameMediaIds = boardGameMedia.map((row) => row.id).toSet();
  final boardGameEditions = await db.select(db.boardGameEditionRows).get();
  for (final row in boardGameEditions.where((row) => isSeed(row.mediaId))) {
    if (!boardGameMediaIds.contains(row.mediaId)) {
      issues.add(
        'boardgame edition ${row.id} has missing media ${row.mediaId}',
      );
    }
    if (row.workId != row.mediaId) {
      issues.add(
        'boardgame edition ${row.id} points to work ${row.workId}, '
        'expected ${row.mediaId}',
      );
    }
  }

  final movieMedia = await db.select(db.movieMediaRows).get();
  final movieMediaIds = movieMedia.map((row) => row.id).toSet();
  final movieReleases = await db.select(db.movieReleaseRows).get();
  for (final row in movieReleases.where((row) => isSeed(row.mediaId))) {
    if (!movieMediaIds.contains(row.mediaId)) {
      issues.add('movie release ${row.id} has missing media ${row.mediaId}');
    }
    if (row.workId != row.mediaId) {
      issues.add(
        'movie release ${row.id} points to work ${row.workId}, '
        'expected ${row.mediaId}',
      );
    }
    if (row.mediaJson == '[]') {
      issues.add('movie release ${row.id} has no persisted media');
    }
  }

  final tvSeries = await db.select(db.tvSeriesRows).get();
  final tvSeriesIds = tvSeries.map((row) => row.id).toSet();
  final tvSeasons = await db.select(db.tvSeasonRows).get();
  final tvSeasonIds = tvSeasons.map((row) => row.id).toSet();
  for (final row in tvSeasons.where((row) => isSeed(row.seriesId))) {
    if (!tvSeriesIds.contains(row.seriesId)) {
      issues.add('tv season ${row.id} has missing series ${row.seriesId}');
    }
  }
  final tvEpisodes = await db.select(db.tvEpisodeRows).get();
  final tvEpisodeIds = tvEpisodes.map((row) => row.id).toSet();
  for (final row in tvEpisodes.where((row) => isSeed(row.seriesId))) {
    if (!tvSeriesIds.contains(row.seriesId)) {
      issues.add('tv episode ${row.id} has missing series ${row.seriesId}');
    }
    if (!tvSeasonIds.contains(row.seasonId)) {
      issues.add('tv episode ${row.id} has missing season ${row.seasonId}');
    }
  }
  final tvReleases = await db.select(db.tvReleaseRows).get();
  final tvReleaseIds = tvReleases.map((row) => row.id).toSet();
  for (final row in tvReleases.where((row) => isSeed(row.seriesId))) {
    if (!tvSeriesIds.contains(row.seriesId)) {
      issues.add('tv release ${row.id} has missing series ${row.seriesId}');
    }
  }
  final tvReleaseMedia = await db.select(db.tvReleaseMediaRows).get();
  final tvReleaseMediaIds = tvReleaseMedia.map((row) => row.id).toSet();
  for (final row in tvReleaseMedia.where((row) => isSeed(row.releaseId))) {
    if (!tvReleaseIds.contains(row.releaseId)) {
      issues.add(
        'tv release media ${row.id} has missing release ${row.releaseId}',
      );
    }
  }
  final tvReleaseEpisodeMaps =
      await db.select(db.tvReleaseEpisodeMapRows).get();
  for (final row
      in tvReleaseEpisodeMaps.where((row) => isSeed(row.releaseId))) {
    if (!tvReleaseIds.contains(row.releaseId)) {
      issues.add(
        'tv release episode map ${row.id} has missing release ${row.releaseId}',
      );
    }
    if (!tvReleaseMediaIds.contains(row.mediaId)) {
      issues.add(
        'tv release episode map ${row.id} has missing media ${row.mediaId}',
      );
    }
    if (!tvEpisodeIds.contains(row.episodeId)) {
      issues.add(
        'tv release episode map ${row.id} has missing episode ${row.episodeId}',
      );
    }
  }

  final animeMedia = await db.select(db.animeMediaRows).get();
  final animeMediaIds = animeMedia.map((row) => row.id).toSet();
  final animeEpisodes = await db.select(db.animeEpisodeRows).get();
  for (final row in animeEpisodes.where((row) => isSeed(row.seriesId))) {
    if (!animeMediaIds.contains(row.seriesId)) {
      issues.add(
        'anime episode ${row.id} has missing media ${row.seriesId}',
      );
    }
  }
  final animeReleases = await db.select(db.animeReleaseRows).get();
  for (final row in animeReleases.where((row) => isSeed(row.seriesId))) {
    if (!animeMediaIds.contains(row.seriesId)) {
      issues.add(
        'anime release ${row.id} has missing media ${row.seriesId}',
      );
    }
  }

  final musicReleases = await db.select(db.musicReleaseRows).get();
  final musicReleaseIds = musicReleases.map((row) => row.id).toSet();
  final musicMedia = await db.select(db.musicMediaRows).get();
  final musicMediaIds = musicMedia.map((row) => row.id).toSet();
  for (final row in musicMedia.where((row) => isSeed(row.releaseId))) {
    if (!musicReleaseIds.contains(row.releaseId)) {
      issues.add(
        'music media ${row.id} has missing release ${row.releaseId}',
      );
    }
  }
  final musicTracks = await db.select(db.musicTrackRows).get();
  for (final row in musicTracks.where((row) => isSeed(row.mediaId))) {
    if (!musicMediaIds.contains(row.mediaId)) {
      issues.add('music track ${row.id} has missing media ${row.mediaId}');
    }
  }

  return issues;
}

/// Returns ownership relationship errors in the kind-owned tables written by
/// the development fixture. Only deterministic seed rows are inspected so a
/// developer can run this against a database that also contains local data.
///
/// The common ownership cache and every kind-owned table must agree on the
/// same copy IDs. Counts alone are not enough: a wrongly typed row can keep
/// the totals green while disconnecting one catalog kind from its copy data.
Future<List<String>> devSeedTypedOwnedIntegrityIssues(LocalDatabase db) async {
  final issues = <String>[];
  final ownedRows = await db.select(db.ownedItemsCache).get();
  final ownedById = <String, OwnedItemsCacheData>{
    for (final row in ownedRows) row.id: row,
  };
  final expectedByKind = <String, Set<String>>{};
  for (final row in ownedRows.where((row) => row.id.startsWith('seed-'))) {
    expectedByKind.putIfAbsent(row.kind, () => <String>{}).add(row.id);
  }

  void checkTypedRows(
    String table,
    String kind,
    Iterable<String> rawIds,
  ) {
    final typedIds = rawIds.where((id) => id.startsWith('seed-')).toSet();
    final expectedIds = expectedByKind[kind] ?? const <String>{};
    for (final id in typedIds) {
      final owned = ownedById[id];
      if (owned == null) {
        issues.add('$table row $id has no common owned cache row');
        continue;
      }
      if (owned.kind != kind) {
        issues.add(
          '$table row $id belongs to kind ${owned.kind}, expected $kind',
        );
      }
      if (!owned.itemId.startsWith('seed-$kind-')) {
        issues.add(
          '$table row $id points to ${owned.itemId}, expected a $kind seed',
        );
      }
    }
    for (final id in expectedIds) {
      if (!typedIds.contains(id)) {
        issues.add('$table is missing seed owned row $id');
      }
    }
  }

  final comicRows = await db.select(db.comicOwnedItemsRows).get();
  checkTypedRows('comic_owned_items', 'comic', comicRows.map((row) => row.id));
  final mangaRows = await db.select(db.mangaOwnedItemsRows).get();
  checkTypedRows('manga_owned_items', 'manga', mangaRows.map((row) => row.id));
  final bookRows = await db.select(db.bookOwnedItemsRows).get();
  checkTypedRows('book_owned_items', 'book', bookRows.map((row) => row.id));
  final gameRows = await db.select(db.gameOwnedDetailsRows).get();
  checkTypedRows(
      'game_owned_details', 'game', gameRows.map((row) => row.ownedItemId));
  final boardGameRows = await db.select(db.boardGameOwnedDetailsRows).get();
  checkTypedRows('boardgame_owned_details', 'boardgame',
      boardGameRows.map((row) => row.ownedItemId));
  final movieRows = await db.select(db.movieOwnedItemsRows).get();
  checkTypedRows('movie_owned_items', 'movie', movieRows.map((row) => row.id));
  final tvRows = await db.select(db.tvOwnedItemsRows).get();
  checkTypedRows('tv_owned_items', 'tv', tvRows.map((row) => row.id));
  final animeRows = await db.select(db.animeOwnedItemsRows).get();
  checkTypedRows('anime_owned_items', 'anime', animeRows.map((row) => row.id));
  final musicRows = await db.select(db.musicOwnedItemsRows).get();
  checkTypedRows('music_owned_items', 'music', musicRows.map((row) => row.id));
  final gameOwnedRows = await db.select(db.gameOwnedItemsRows).get();
  checkTypedRows(
      'game_owned_items', 'game', gameOwnedRows.map((row) => row.id));
  final boardGameOwnedRows = await db.select(db.boardGameOwnedItemsRows).get();
  checkTypedRows('boardgame_owned_items', 'boardgame',
      boardGameOwnedRows.map((row) => row.id));

  return issues;
}

/// Counts kind-owned ownership rows written by the development seed.
Future<Map<String, int>> devSeedTypedOwnedCounts(LocalDatabase db) async {
  return {
    'comic.owned': (await db.select(db.comicOwnedItemsRows).get()).length,
    'manga.owned': (await db.select(db.mangaOwnedItemsRows).get()).length,
    'book.owned': (await db.select(db.bookOwnedItemsRows).get()).length,
    'game.owned': (await db.select(db.gameOwnedItemsRows).get()).length,
    'boardgame.owned':
        (await db.select(db.boardGameOwnedItemsRows).get()).length,
    'movie.owned': (await db.select(db.movieOwnedItemsRows).get()).length,
    'tv.owned': (await db.select(db.tvOwnedItemsRows).get()).length,
    'anime.owned': (await db.select(db.animeOwnedItemsRows).get()).length,
    'music.owned': (await db.select(db.musicOwnedItemsRows).get()).length,
  };
}

/// Counts kind-owned tracking rows written by the development seed.
Future<Map<String, int>> devSeedTypedTrackingCounts(LocalDatabase db) async {
  return {
    'tv.episode_progress':
        (await db.select(db.tvEpisodeProgressRows).get()).length,
    'anime.tracking': (await db.select(db.animeTrackingRows).get()).length,
  };
}

/// Counts kind-owned tracking-unit coordinate rows written by the seed.
Future<Map<String, int>> devSeedTypedTrackingUnitCounts(
  LocalDatabase db,
) async {
  return {
    'comic.issue_units':
        (await db.select(db.comicTrackingUnitRows).get()).length,
    'manga.chapter_units':
        (await db.select(db.mangaTrackingUnitRows).get()).length,
    'book.chapter_units':
        (await db.select(db.bookTrackingUnitRows).get()).length,
    'tv.episode_units': (await db.select(db.tvTrackingUnitRows).get()).length,
    'anime.episode_units':
        (await db.select(db.animeTrackingUnitRows).get()).length,
  };
}

/// Counts universal seed fixtures that are not owned by one catalog kind.
Future<Map<String, int>> devSeedAuxiliaryCounts(LocalDatabase db) async {
  final images = await db.select(db.itemImagesCache).get();
  final customFieldDefinitions =
      await db.select(db.customFieldDefinitionsCache).get();
  final customFieldValues = await db.select(db.customFieldValuesCache).get();
  final pickListValues = await db.select(db.pickListValuesCache).get();
  return {
    'images.front_cover':
        images.where((row) => row.imageType == 'front_cover').length,
    'images.back_cover':
        images.where((row) => row.imageType == 'back_cover').length,
    'images.detail_photo':
        images.where((row) => row.imageType == 'detail_photo').length,
    'custom_field.definitions': customFieldDefinitions.length,
    'custom_field.values': customFieldValues.length,
    'pick_list.values': pickListValues.length,
  };
}

/// Summary returned after validating the complete development fixture graph.
///
/// The CLI seed script and the Flutter seed test intentionally call the same
/// verifier. Keeping the checks here prevents a new kind-owned table or seed
/// invariant from being added to one entry point and forgotten by the other.
final class DevSeedVerificationReport {
  const DevSeedVerificationReport({
    required this.catalogCount,
    required this.seededCatalogCount,
    required this.ownedCount,
    required this.trackingCount,
    required this.imageCount,
    required this.typedGraphCounts,
    required this.typedOwnedCounts,
    required this.typedTrackingCounts,
    required this.typedTrackingUnitCounts,
    required this.auxiliaryCounts,
  });

  final int catalogCount;
  final int seededCatalogCount;
  final int ownedCount;
  final int trackingCount;
  final int imageCount;
  final Map<String, int> typedGraphCounts;
  final Map<String, int> typedOwnedCounts;
  final Map<String, int> typedTrackingCounts;
  final Map<String, int> typedTrackingUnitCounts;
  final Map<String, int> auxiliaryCounts;
}

/// Verifies the complete persisted development fixture graph.
///
/// This is deliberately a composition-root/dev helper. It may enumerate all
/// kind-owned tables to verify the fixture, while runtime library code must
/// continue to use the owning kind repositories and codecs.
Future<DevSeedVerificationReport> verifyDevSeedDatabase(
    LocalDatabase db) async {
  final catalogRows = await LibraryCatalogRepository(db).findAll();
  final ownedRows = await db.select(db.ownedItemsCache).get();
  final trackingRows = await db.select(db.trackingEntriesCache).get();
  final imageRows = await db.select(db.itemImagesCache).get();
  final typedGraphCounts = await devSeedTypedGraphCounts(db);
  final typedOwnedCounts = await devSeedTypedOwnedCounts(db);
  final typedTrackingCounts = await devSeedTypedTrackingCounts(db);
  final typedTrackingUnitCounts = await devSeedTypedTrackingUnitCounts(db);
  final auxiliaryCounts = await devSeedAuxiliaryCounts(db);
  final issues = <String>[];

  void require(bool condition, String message) {
    if (!condition) issues.add(message);
  }

  final expectedSeedCount =
      devSeedCatalogCounts.values.fold<int>(0, (total, count) => total + count);
  final seededCatalogRows = catalogRows
      .where((row) => row.id.startsWith('seed-'))
      .toList(growable: false);
  final seededOwnedRows = ownedRows
      .where((row) => row.itemId.startsWith('seed-'))
      .toList(growable: false);
  final seededTrackingRows = trackingRows
      .where((row) => row.itemId.startsWith('seed-'))
      .toList(growable: false);

  require(
    seededCatalogRows.length == expectedSeedCount,
    'expected $expectedSeedCount seed catalog rows, found '
    '${seededCatalogRows.length}',
  );
  require(
    seededOwnedRows.length == expectedSeedCount,
    'expected $expectedSeedCount seed owned rows, found '
    '${seededOwnedRows.length}',
  );
  require(
    seededTrackingRows.length == expectedSeedCount,
    'expected $expectedSeedCount seed tracking rows, found '
    '${seededTrackingRows.length}',
  );
  require(
    seededCatalogRows.map((row) => row.id).toSet().length ==
        seededCatalogRows.length,
    'seed catalog IDs are not unique',
  );
  require(
    seededOwnedRows.map((row) => row.id).toSet().length ==
        seededOwnedRows.length,
    'seed owned IDs are not unique',
  );
  require(
    seededTrackingRows.map((row) => row.id).toSet().length ==
        seededTrackingRows.length,
    'seed tracking IDs are not unique',
  );

  for (final entry in devSeedCatalogCounts.entries) {
    final catalogCount =
        seededCatalogRows.where((row) => row.kind == entry.key).length;
    final ownedCount = seededOwnedRows
        .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
        .length;
    final trackingCount = seededTrackingRows
        .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
        .length;
    require(
      catalogCount == entry.value,
      '${entry.key}: expected ${entry.value} catalog rows, found $catalogCount',
    );
    require(
      ownedCount == entry.value,
      '${entry.key}: expected ${entry.value} owned rows, found $ownedCount',
    );
    require(
      trackingCount == entry.value,
      '${entry.key}: expected ${entry.value} tracking rows, found $trackingCount',
    );
  }

  final catalogById = {
    for (final row in seededCatalogRows) row.id: row,
  };
  final ownedById = {
    for (final row in seededOwnedRows) row.id: row,
  };
  for (final row in seededCatalogRows) {
    final kind = catalogMediaKindFromApiValue(row.kind);
    require(row.title.trim().isNotEmpty, 'catalog ${row.id} has no title');
    require(
        kind != CatalogMediaKind.unknown, 'catalog ${row.id} has unknown kind');
    require(
      row.coverImageUrl?.trim().isNotEmpty == true &&
          row.thumbnailImageUrl?.trim().isNotEmpty == true,
      'catalog ${row.id} is missing cover image URLs',
    );
    final barcode = row.barcode;
    require(barcode != null && barcode.trim().isNotEmpty,
        'catalog ${row.id} is missing a barcode');
    if (barcode != null && barcode.trim().isNotEmpty) {
      require(
        resolveLibraryBarcodeForKind(kind, barcode) != null,
        'catalog ${row.id} has a barcode rejected by ${row.kind}',
      );
    }
    if (row.kind == 'movie' || row.kind == 'tv' || row.kind == 'anime') {
      require(
        row.payload['runtime_minutes'] is int && row.payload['nr_discs'] is int,
        'video catalog ${row.id} is missing runtime/disc seed metadata',
      );
    }
    if (row.kind == 'music') {
      require(
        row.payload['track_count'] is int &&
            (row.payload['tracks'] as List?)?.isNotEmpty == true,
        'music catalog ${row.id} is missing track seed metadata',
      );
    }
  }
  for (final row in seededOwnedRows) {
    final catalog = catalogById[row.itemId];
    require(
        catalog != null, 'owned ${row.id} references missing ${row.itemId}');
    require(
      row.kind == catalog?.kind,
      'owned ${row.id} kind ${row.kind} does not match catalog ${row.itemId}',
    );
    require(
      row.rating == null &&
          row.readStatus == null &&
          row.startedAt == null &&
          row.finishedAt == null,
      'owned ${row.id} still stores denormalized tracking state',
    );
  }
  for (final row in seededTrackingRows) {
    require(
      row.ownedItemId != null && ownedById.containsKey(row.ownedItemId),
      'tracking ${row.id} references missing owned item',
    );
    require(
      row.status != null && row.rating != null && row.startedAt != null,
      'tracking ${row.id} is missing typed status/rating/start data',
    );
  }

  for (final entry in devSeedTypedGraphMinimumCounts.entries) {
    require(
      (typedGraphCounts[entry.key] ?? 0) >= entry.value,
      'typed graph ${entry.key}: expected at least ${entry.value}, found '
      '${typedGraphCounts[entry.key] ?? 0}',
    );
  }
  for (final entry in devSeedTypedOwnedMinimumCounts.entries) {
    require(
      (typedOwnedCounts[entry.key] ?? 0) >= entry.value,
      'typed owned ${entry.key}: expected at least ${entry.value}, found '
      '${typedOwnedCounts[entry.key] ?? 0}',
    );
  }
  for (final entry in devSeedTypedTrackingMinimumCounts.entries) {
    require(
      (typedTrackingCounts[entry.key] ?? 0) >= entry.value,
      'typed tracking ${entry.key}: expected at least ${entry.value}, found '
      '${typedTrackingCounts[entry.key] ?? 0}',
    );
  }
  for (final entry in devSeedTypedTrackingUnitMinimumCounts.entries) {
    require(
      (typedTrackingUnitCounts[entry.key] ?? 0) >= entry.value,
      'typed tracking units ${entry.key}: expected at least ${entry.value}, '
      'found ${typedTrackingUnitCounts[entry.key] ?? 0}',
    );
  }
  for (final entry in devSeedAuxiliaryMinimumCounts.entries) {
    require(
      (auxiliaryCounts[entry.key] ?? 0) >= entry.value,
      'auxiliary ${entry.key}: expected at least ${entry.value}, found '
      '${auxiliaryCounts[entry.key] ?? 0}',
    );
  }

  final graphIssues = await devSeedTypedGraphIntegrityIssues(db);
  final ownedIssues = await devSeedTypedOwnedIntegrityIssues(db);
  issues.addAll(graphIssues);
  issues.addAll(ownedIssues);

  final comicTrackingUnits = (await db.select(db.comicTrackingUnitRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    comicTrackingUnits
        .every((row) => row.issueNumber?.trim().isNotEmpty == true),
    'comic seed tracking units are missing issue coordinates',
  );
  final mangaTrackingUnits = (await db.select(db.mangaTrackingUnitRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    mangaTrackingUnits
        .every((row) => row.chapterNumber != null && row.chapterNumber! > 0),
    'manga seed tracking units are missing chapter coordinates',
  );
  final bookTrackingUnits = (await db.select(db.bookTrackingUnitRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    bookTrackingUnits
        .every((row) => row.volumeNumber != null && row.volumeNumber! > 0),
    'book seed tracking units are missing volume coordinates',
  );
  final tvTrackingUnits = (await db.select(db.tvTrackingUnitRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    tvTrackingUnits.every(
      (row) =>
          row.seasonNumber != null &&
          row.seasonNumber! > 0 &&
          row.episodeNumber != null &&
          row.episodeNumber! > 0,
    ),
    'tv seed tracking units are missing season/episode coordinates',
  );
  final animeTrackingUnits = (await db.select(db.animeTrackingUnitRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    animeTrackingUnits.every(
      (row) =>
          row.seasonNumber != null &&
          row.seasonNumber! > 0 &&
          row.episodeNumber != null &&
          row.episodeNumber! > 0,
    ),
    'anime seed tracking units are missing season/episode coordinates',
  );

  final bookReleases = (await db.select(db.bookReleaseRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    bookReleases.every(
      (row) =>
          row.workId?.startsWith('seed-book-') == true &&
          row.displayTitle?.trim().isNotEmpty == true &&
          row.isbn?.trim().isNotEmpty == true,
    ),
    'book seed editions are missing typed edition metadata',
  );
  final boardGameEditions = (await db.select(db.boardGameEditionRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    boardGameEditions.every(
      (row) =>
          row.workId?.startsWith('seed-boardgame-') == true &&
          row.editionTitle?.trim().isNotEmpty == true &&
          row.minPlayers != null &&
          row.maxPlayers != null &&
          row.playingTimeMinutes != null,
    ),
    'boardgame seed editions are missing typed edition metadata',
  );
  final tvReleases = (await db.select(db.tvReleaseRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    tvReleases.every(
      (row) =>
          row.seriesId.startsWith('seed-tv-') &&
          row.title.trim().isNotEmpty &&
          row.episodeCount == 2,
    ),
    'tv seed releases are missing series/episode metadata',
  );
  final musicTracks = (await db.select(db.musicTrackRows).get())
      .where((row) => row.id.startsWith('seed-'));
  require(
    musicTracks.every(
      (row) => row.mediaId.startsWith('seed-music-') && row.durationMs != null,
    ),
    'music seed tracks are missing media/duration metadata',
  );

  final seedImages = imageRows
      .where((row) => ownedById.containsKey(row.ownedItemId))
      .toList(growable: false);
  for (final entry in devSeedAuxiliaryMinimumCounts.entries.where(
    (entry) => entry.key.startsWith('images.'),
  )) {
    final imageType = entry.key.substring('images.'.length);
    final count = seedImages.where((row) => row.imageType == imageType).length;
    require(
      count >= entry.value,
      '$imageType seed images: expected at least ${entry.value}, found $count',
    );
  }

  final customFieldValues = await db.select(db.customFieldValuesCache).get();
  final ownedIds = ownedRows.map((row) => row.id).toSet();
  require(
    customFieldValues
        .where((row) => row.targetId.startsWith('seed-'))
        .every((row) => ownedIds.contains(row.targetId)),
    'a seed custom-field value targets a missing owned item',
  );

  if (issues.isNotEmpty) {
    throw StateError(
      'Development seed verification failed:\n'
      '${issues.map((issue) => '- $issue').join('\n')}',
    );
  }

  return DevSeedVerificationReport(
    catalogCount: catalogRows.length,
    seededCatalogCount: seededCatalogRows.length,
    ownedCount: ownedRows.length,
    trackingCount: trackingRows.length,
    imageCount: imageRows.length,
    typedGraphCounts: typedGraphCounts,
    typedOwnedCounts: typedOwnedCounts,
    typedTrackingCounts: typedTrackingCounts,
    typedTrackingUnitCounts: typedTrackingUnitCounts,
    auxiliaryCounts: auxiliaryCounts,
  );
}

/// Returns `true` if all typed local catalog graphs are empty.
Future<bool> _isDatabaseEmpty(LocalDatabase db) async {
  return (await LibraryCatalogRepository(db).findAll()).isEmpty;
}

/// Seeds the local database with rich dev data if it is empty.
///
/// Call from app startup or a debug menu. Skips seeding if data already exists.
Future<void> seedLocalDatabase(LocalDatabase db, {bool force = false}) async {
  if (!force && !await _isDatabaseEmpty(db)) return;

  final catalogRepo = LibraryCatalogRepository(db);
  final comicOwnedRepo = ComicOwnedRepository(db);
  final animeOwnedRepo = AnimeOwnedRepository(db);
  final movieOwnedRepo = MovieOwnedRepository(db);
  final tvOwnedRepo = TvOwnedRepository(db);
  final musicOwnedRepo = MusicOwnedRepository(db);
  final gameOwnedRepo = GameOwnedRepository(db);
  final boardGameOwnedRepo = BoardGameOwnedRepository(db);
  final bookOwnedRepo = BookOwnedRepository(db);
  final mangaOwnedRepo = MangaOwnedRepository(db);
  final ownedRepo = OwnedItemsCacheRepository(db);
  final trackingRepo = TrackingEntriesCacheRepository(
    db,
    codecs: collectarrTrackingEntryCodecs,
  );
  final trackingUnitsRepo = TrackingUnitsCacheRepository(
    db,
    codecs: collectarrTrackingUnitCodecs,
  );
  final imagesRepo = ItemImagesCacheRepository(db);
  final pickListRepo = PickListRepository(db);
  final customFieldRepo = CustomFieldRepository(db);

  // --- Catalog Items ---
  final allItems = <CatalogItem>[
    ...movieSeedCatalogItems().map(enrichSeedItem).map(enrichMovieSeedItem),
    ...tvSeedCatalogItems().map(enrichSeedItem).map(enrichTvSeedItem),
    ...animeSeedCatalogItems().map(enrichSeedItem).map(enrichAnimeSeedItem),
    ...mangaSeedCatalogItems().map(enrichSeedItem).map(enrichMangaSeedItem),
    ...bookSeedCatalogItems().map(enrichSeedItem).map(enrichBookSeedItem),
    ...musicSeedCatalogItems().map(enrichSeedItem).map(enrichMusicSeedItem),
    ...gameSeedCatalogItems().map(enrichSeedItem).map(enrichGameSeedItem),
    ...boardgameSeedCatalogItems()
        .map(enrichSeedItem)
        .map(enrichBoardgameSeedItem),
    ...comicSeedCatalogItems().map(enrichSeedItem).map(enrichComicSeedItem),
  ];

  final now = DateTime.now().toUtc();

  // --- Owned Items ---
  final ownedItems = <OwnedItem>[
    ...movieSeedOwnedItems(now),
    ...bookSeedOwnedItems(now),
    ...musicSeedOwnedItems(now),
    ...gameSeedOwnedItems(now),
    ...boardgameSeedOwnedItems(now),
    ...comicSeedOwnedItems(now),
    ...tvSeedOwnedItems(now),
    ...animeSeedOwnedItems(now),
    ...mangaSeedOwnedItems(now),
  ];

  // --- Tracking Entries ---
  final trackingEntries = <TrackingEntry>[
    ...movieSeedTrackingEntries(now),
    ...bookSeedTrackingEntries(now),
    ...gameSeedTrackingEntries(now),
    ...musicSeedTrackingEntries(now),
    ...comicSeedTrackingEntries(now),
    ...boardgameSeedTrackingEntries(now),
    ...tvSeedTrackingEntries(now),
    ...animeSeedTrackingEntries(now),
    ...mangaSeedTrackingEntries(now),
  ];
  final trackingUnits = <TrackingUnit>[
    ...comicSeedTrackingUnits(allItems, now),
    ...mangaSeedTrackingUnits(allItems, now),
    ...bookSeedTrackingUnits(allItems, now),
    ...tvSeedTrackingUnits(allItems, now),
    ...animeSeedTrackingUnits(allItems, now),
  ];

  _validateSeedFixtures(
    catalogItems: allItems,
    ownedItems: ownedItems,
    trackingEntries: trackingEntries,
  );
  validateSeedCatalogQuality(allItems);
  validateSeedOwnedQuality(ownedItems);
  validateSeedTrackingQuality(trackingEntries);
  _validateSeedTrackingUnits(trackingUnits, allItems);

  // upsertAll also auto-populates SerialAuthority & PickLists from catalog data
  await catalogRepo.upsertAll(allItems);
  await ownedRepo.upsertAll(ownedItems);
  await _seedKindOwnedDetails(db, ownedItems);
  await _seedKindTracking(db, allItems, now);
  await trackingUnitsRepo.upsertAll(trackingUnits);
  await comicOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.comic)
        .map(ComicOwnedItemProjection.fromOwnedItem),
  );
  await movieOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.movie)
        .map(MovieOwnedItemProjection.fromOwnedItem),
  );
  await animeOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.anime)
        .map(AnimeOwnedItemProjection.fromOwnedItem),
  );
  await tvOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.tv)
        .map(TvOwnedItemProjection.fromOwnedItem),
  );
  await musicOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.music)
        .map(MusicOwnedItemProjection.fromOwnedItem),
  );
  await gameOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.game)
        .map(GameOwnedItemProjection.fromOwnedItem),
  );
  await boardGameOwnedRepo.upsertAll(
    ownedItems
        .where(
            (item) => item.catalogRef.mediaKind == CatalogMediaKind.boardgame)
        .map(BoardGameOwnedItemProjection.fromOwnedItem),
  );
  await bookOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.book)
        .map(BookOwnedItemProjection.fromOwnedItem),
  );
  await mangaOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.manga)
        .map(MangaOwnedItemProjection.fromOwnedItem),
  );

  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, ownedItems);

  await trackingRepo.upsertAll(trackingEntries);

  // --- Pick Lists (supplement with extra values) ---
  await seedPickLists(pickListRepo);

  // --- Custom Fields ---
  await seedCustomFields(customFieldRepo);
}

void _validateSeedTrackingUnits(
  Iterable<TrackingUnit> units,
  Iterable<CatalogItem> catalogItems,
) {
  final catalogById = {
    for (final item in catalogItems) item.id: item,
  };
  final ids = <String>{};
  for (final unit in units) {
    if (!ids.add(unit.id)) {
      throw StateError('Duplicate seed tracking-unit id: ${unit.id}');
    }
    final catalog = catalogById[unit.targetRef.id];
    if (catalog == null) {
      throw StateError(
        'Seed tracking unit ${unit.id} references missing catalog '
        '${unit.targetRef.id}',
      );
    }
    if (unit.targetRef.kind != catalog.kind ||
        unit.targetRef.entityType != CatalogEntityType.work) {
      throw StateError(
        'Seed tracking unit ${unit.id} has invalid catalog reference '
        '${unit.targetRef.toJson()}',
      );
    }
    if (!{
      'comic',
      'manga',
      'book',
      'tv',
      'anime',
    }.contains(unit.targetRef.kind)) {
      throw StateError(
        'Seed tracking unit ${unit.id} has no typed coordinate codec for '
        '${unit.targetRef.kind}',
      );
    }
  }
}

Future<void> _seedKindOwnedDetails(
  LocalDatabase db,
  Iterable<OwnedItem> items,
) async {
  final anime = AnimeRepository(db);
  final boardgame = BoardGameRepository(db);
  final book = BookRepository(db);
  final game = GameRepository(db);
  final manga = MangaRepository(db);
  final movie = MovieRepository(db);
  final music = MusicRepository(db);
  final tv = TvRepository(db);

  for (final item in items) {
    switch (item.catalogRef.mediaKind) {
      case CatalogMediaKind.anime:
        final details = item.details;
        if (details is AnimeOwnedDetails) {
          await anime.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.boardgame:
        final details = item.details;
        if (details is BoardgameOwnedDetails) {
          await boardgame.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.book:
        final details = item.details;
        if (details is BookOwnedDetails) {
          await book.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.game:
        final details = item.details;
        if (details is GameOwnedDetails) {
          await game.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.manga:
        final details = item.details;
        if (details is MangaOwnedDetails) {
          await manga.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.movie:
        final details = item.details;
        if (details is MovieOwnedDetails) {
          await movie.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.music:
        final details = item.details;
        if (details is MusicOwnedDetails) {
          await music.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.tv:
        final details = item.details;
        if (details is TvOwnedDetails) {
          await tv.updateOwnedDetails(item.id, details);
        }
      case CatalogMediaKind.comic || CatalogMediaKind.unknown:
        // Comic's typed owned repository persists its complete details graph
        // below; unknown kinds are rejected by the fixture validator.
        break;
    }
  }
}

Future<void> _seedKindTracking(
  LocalDatabase db,
  Iterable<CatalogItem> items,
  DateTime now,
) async {
  final tvRepository = TvRepository(db);
  final tvTrackingRepository = TvTrackingRepository(db);
  final animeRepository = AnimeRepository(db);

  for (final item in items) {
    switch (item.catalogRef.mediaKind) {
      case CatalogMediaKind.tv:
        final seriesId = TvSeriesId(item.id);
        final seasons = await tvRepository.seasonsFor(seriesId);
        for (final season in seasons) {
          for (final episode in season.episodes) {
            final completed = episode.episodeNumber == 1;
            await tvTrackingRepository.upsertEpisodeProgress(
              TvEpisodeProgress(
                seriesId: seriesId,
                seasonId: TvSeasonId(season.id),
                episodeId: TvEpisodeId(episode.id),
                seasonNumber: season.seasonNumber,
                episodeNumber: episode.episodeNumber,
                watchedCount: completed ? 2 : 1,
                completed: completed,
                lastWatchedAt: now.subtract(
                  Duration(days: episode.episodeNumber?.toInt() ?? 0),
                ),
                rating: completed ? 9 : null,
                notes: completed ? 'Seed episode replay history.' : null,
                updatedAt: now,
              ),
            );
          }
        }
      case CatalogMediaKind.anime:
        final mediaId = AnimeMediaId(item.id);
        final episodes = await animeRepository.episodesFor(mediaId);
        for (final episode in episodes) {
          final completed = episode.episodeNumber == 1;
          await animeRepository.updateTracking(
            AnimeTracking(
              id: 'seed-anime-tracking-${item.id}-${episode.id.value}',
              mediaId: mediaId,
              episodeId: episode.id,
              status: completed ? 'Completed' : 'In progress',
              sourceType: TrackingSourceType.physical,
              rating: completed ? 9 : null,
              notes: completed ? 'Seed episode replay history.' : null,
              startedAt: now.subtract(const Duration(days: 30)),
              finishedAt: completed ? now : null,
              progressCurrent: completed ? 1 : 0,
              progressTotal: 1,
              timesCompleted: completed ? 2 : 0,
              seasonNumber: 1,
              episodeNumber: episode.episodeNumber,
              episodeRatings: completed ? {episode.id.value: 9} : const {},
              updatedAt: now,
            ),
          );
        }
      case CatalogMediaKind.comic ||
            CatalogMediaKind.manga ||
            CatalogMediaKind.book ||
            CatalogMediaKind.game ||
            CatalogMediaKind.boardgame ||
            CatalogMediaKind.movie ||
            CatalogMediaKind.music ||
            CatalogMediaKind.unknown:
        break;
    }
  }
}

void _validateSeedFixtures({
  required List<CatalogItem> catalogItems,
  required List<OwnedItem> ownedItems,
  required List<TrackingEntry> trackingEntries,
}) {
  final catalogById = <String, CatalogItem>{};
  for (final item in catalogItems) {
    if (item.id.trim().isEmpty || item.title.trim().isEmpty) {
      throw StateError(
        'Seed catalog item must have a non-empty id and title '
        '(id="${item.id}", kind="${item.kind}", title="${item.title}")',
      );
    }
    if (!devSeedCatalogCounts.containsKey(item.kind)) {
      throw StateError(
          'Seed catalog item ${item.id} has unknown kind ${item.kind}');
    }
    if (catalogById.containsKey(item.id)) {
      throw StateError('Duplicate seed catalog id: ${item.id}');
    }
    catalogById[item.id] = item;
  }

  final actualCounts = <String, int>{};
  for (final item in catalogItems) {
    actualCounts[item.kind] = (actualCounts[item.kind] ?? 0) + 1;
  }
  if (actualCounts.length != devSeedCatalogCounts.length ||
      actualCounts.entries.any(
        (entry) => devSeedCatalogCounts[entry.key] != entry.value,
      )) {
    throw StateError(
      'Seed catalog counts do not match the manifest: $actualCounts',
    );
  }

  final ownedCatalogIds = <String>{};
  final ownedById = <String, OwnedItem>{};
  for (final item in ownedItems) {
    if (ownedById.containsKey(item.id)) {
      throw StateError('Duplicate owned seed id: ${item.id}');
    }
    ownedById[item.id] = item;
    final catalog = catalogById[item.catalogRef.id];
    if (catalog == null) {
      throw StateError(
        'Owned seed ${item.id} references missing catalog ${item.catalogRef.id}',
      );
    }
    if (item.catalogRef.kind != catalog.kind) {
      throw StateError(
        'Owned seed ${item.id} kind ${item.catalogRef.kind} does not match '
        'catalog ${catalog.id} kind ${catalog.kind}',
      );
    }
    if (!ownedCatalogIds.add(item.catalogRef.id)) {
      throw StateError(
        'Duplicate owned seed catalog reference: ${item.catalogRef.id}',
      );
    }
  }
  if (ownedCatalogIds.length != catalogById.length) {
    throw StateError(
      'Seed owned coverage is incomplete: ${ownedCatalogIds.length}/'
      '${catalogById.length} catalog items',
    );
  }

  final trackingCatalogIds = <String>{};
  final trackingIds = <String>{};
  for (final entry in trackingEntries) {
    if (!trackingIds.add(entry.id)) {
      throw StateError('Duplicate tracking seed id: ${entry.id}');
    }
    if (entry.ownedItemId == null) {
      throw StateError(
        'Tracking seed ${entry.id} must reference its owned seed item',
      );
    }
    final catalog = catalogById[entry.catalogRef.id];
    if (catalog == null) {
      throw StateError(
        'Tracking seed ${entry.id} references missing catalog ${entry.catalogRef.id}',
      );
    }
    if (entry.catalogRef.kind != catalog.kind) {
      throw StateError(
        'Tracking seed ${entry.id} kind ${entry.catalogRef.kind} does not '
        'match catalog ${catalog.id} kind ${catalog.kind}',
      );
    }
    if (entry.ownedItemId case final ownedId?) {
      final owned = ownedById[ownedId];
      if (owned == null) {
        throw StateError(
          'Tracking seed ${entry.id} references missing owned item $ownedId',
        );
      }
      if (owned.catalogRef.id != entry.catalogRef.id) {
        throw StateError(
          'Tracking seed ${entry.id} links owned item $ownedId to '
          'catalog ${entry.catalogRef.id}, but it belongs to '
          '${owned.catalogRef.id}',
        );
      }
    }
    if (!trackingCatalogIds.add(entry.catalogRef.id)) {
      throw StateError(
        'Duplicate tracking seed catalog reference: ${entry.catalogRef.id}',
      );
    }
  }
  if (trackingCatalogIds.length != catalogById.length) {
    throw StateError(
      'Seed tracking coverage is incomplete: ${trackingCatalogIds.length}/'
      '${catalogById.length} catalog items',
    );
  }
}

Future<void> _seedItemImages(
  ItemImagesCacheRepository repo,
  List<OwnedItem> ownedItems,
) async {
  for (var i = 0; i < ownedItems.length; i++) {
    final owned = ownedItems[i];
    await repo.upsert(
      id: 'seed-img-front-${owned.id}',
      ownedItemId: owned.id,
      imageType: 'front_cover',
      imageData: seedTinyPngBytes,
      caption: 'Seed front cover',
      sortOrder: 0,
    );
    if (i.isEven) {
      await repo.upsert(
        id: 'seed-img-back-${owned.id}',
        ownedItemId: owned.id,
        imageType: 'back_cover',
        imageData: seedTinyPngBytes,
        caption: 'Seed back cover',
        sortOrder: 1,
      );
    }
    if (i % 3 == 0) {
      await repo.upsert(
        id: 'seed-img-extra-${owned.id}',
        ownedItemId: owned.id,
        imageType: 'detail_photo',
        imageData: seedTinyPngBytes,
        caption: 'Seed extra image',
        sortOrder: 2,
      );
    }
  }
}
