/// Development seed data for the local database.
///
/// Populates the typed local catalog projections and all kind-owned copies,
/// kind-owned tracking entries, PickListValues, SerialAuthority, and
/// CustomFieldDefinitions/Values with rich entries for every library kind.
///
/// Usage: call `seedLocalDatabase(db)` from main.dart or a debug menu.
/// Safe to call multiple times – uses deterministic IDs (idempotent via upsert).
library;

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/dev/seeds/custom_field_seeds.dart';
import 'package:collectarr_app/dev/seeds/pick_list_seeds.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/collectarr_dev_seed_registry.g.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_unit_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

export 'package:collectarr_app/dev/seeds/collectarr_dev_seed_registry.g.dart';
export 'package:collectarr_app/dev/seeds/custom_field_seeds.dart';
export 'package:collectarr_app/dev/seeds/pick_list_seeds.dart';
export 'package:collectarr_app/dev/seeds/seed_helpers.dart';

/// Expected cardinality of the checked-in development fixture set.
///
/// Keeping this manifest next to the seed entry point makes omissions in an
/// individual kind script fail before anything is written to the database.
const devSeedCatalogCounts = <CatalogMediaKind, int>{
  CatalogMediaKind.movie: 15,
  CatalogMediaKind.tv: 15,
  CatalogMediaKind.anime: 15,
  CatalogMediaKind.manga: 15,
  CatalogMediaKind.book: 15,
  CatalogMediaKind.music: 15,
  CatalogMediaKind.game: 15,
  CatalogMediaKind.boardgame: 15,
  CatalogMediaKind.comic: 15,
};

/// Minimum typed graph coverage expected from the fixture set.
///
/// Some fixtures intentionally contain multiple editions/tracks, so these
/// are lower bounds rather than exact totals.
const devSeedTypedGraphMinimumCounts = <String, int>{
  'comic.media': 15,
  'comic.release': 15,
  'comic.reading': 15,
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
  'tv.release_episode_map': 15,
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
  'tv.watch_sessions': 15,
  'tv.custom_episodes': 15,
  'anime.watch_sessions': 15,
  'anime.custom_episodes': 15,
  'boardgame.play_sessions': 15,
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
    'comic.reading': (await db.select(db.comicReadingRows).get()).length,
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
    'tv.release_episode_map':
        (await db.select(db.tvReleaseEpisodeMapRows).get()).length,
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
/// Every kind-owned table must agree on the same copy IDs. Counts alone are
/// not enough: a wrongly typed row can keep
/// the totals green while disconnecting one catalog kind from its copy data.
Future<List<String>> devSeedTypedOwnedIntegrityIssues(LocalDatabase db) async {
  final issues = <String>[];
  final ownedRows = await OwnedItemsRepository(db).listActiveSummaries();
  final ownedById = <String, OwnedItemSummary>{
    for (final row in ownedRows) row.ref.id.value: row,
  };
  final expectedByKind = <String, Set<String>>{};
  for (final row in ownedRows.where(
    (row) => row.ref.id.value.startsWith('seed-'),
  )) {
    expectedByKind
        .putIfAbsent(row.ref.kind.apiValue, () => <String>{})
        .add(row.ref.id.value);
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
        issues.add('$table row $id has no owned repository row');
        continue;
      }
      if (owned.ref.kind.apiValue != kind) {
        issues.add(
          '$table row $id belongs to kind ${owned.ref.kind.apiValue}, '
          'expected $kind',
        );
      }
      if (!(owned.catalogRef?.id.startsWith('seed-$kind-') ?? false)) {
        issues.add(
          '$table row $id points to ${owned.catalogRef?.id}, '
          'expected a $kind seed',
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
  final gameRows = await db.select(db.gameOwnedItemsRows).get();
  checkTypedRows('game_owned_items', 'game', gameRows.map((row) => row.id));
  final boardGameRows = await db.select(db.boardGameOwnedItemsRows).get();
  checkTypedRows(
      'boardgame_owned_items', 'boardgame', boardGameRows.map((row) => row.id));
  final movieRows = await db.select(db.movieOwnedItemsRows).get();
  checkTypedRows('movie_owned_items', 'movie', movieRows.map((row) => row.id));
  final tvRows = await db.select(db.tvOwnedItemsRows).get();
  checkTypedRows('tv_owned_items', 'tv', tvRows.map((row) => row.id));
  final animeRows = await db.select(db.animeOwnedItemsRows).get();
  checkTypedRows('anime_owned_items', 'anime', animeRows.map((row) => row.id));
  final musicRows = await db.select(db.musicOwnedItemsRows).get();
  checkTypedRows('music_owned_items', 'music', musicRows.map((row) => row.id));

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
    'tv.watch_sessions': (await db.select(db.tvWatchSessionRows).get()).length,
    'tv.custom_episodes':
        (await db.select(db.tvCustomEpisodeRows).get()).length,
    'anime.watch_sessions':
        (await db.select(db.animeWatchSessionRows).get()).length,
    'anime.custom_episodes':
        (await db.select(db.animeCustomEpisodeRows).get()).length,
    'boardgame.play_sessions':
        (await db.select(db.boardGamePlaySessionsRows).get()).length,
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

/// Counts each kind-owned vocabulary independently so a missing list cannot
/// be hidden by the aggregate pick-list total.
Future<Map<String, int>> devSeedVocabularyCounts(LocalDatabase db) async {
  final repository = PickListRepository(db);
  final counts = <String, int>{};
  for (final key in devSeedVocabularyMinimumCounts().keys) {
    final separator = key.indexOf('.');
    if (separator <= 0) continue;
    final kind = key.substring(0, separator);
    counts[key] = (await repository.getValues(
      key,
      mediaKind: kind,
    ))
        .length;
  }
  return counts;
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
    required this.vocabularyCounts,
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
  final Map<String, int> vocabularyCounts;
  final Map<String, int> auxiliaryCounts;
}

/// Verifies the complete persisted development fixture graph.
///
/// This is deliberately a composition-root/dev helper. It may enumerate all
/// kind-owned tables to verify the fixture, while runtime library code must
/// continue to use the owning kind repositories and codecs.
Future<DevSeedVerificationReport> verifyDevSeedDatabase(
    LocalDatabase db) async {
  final catalogRows = await CatalogSnapshotRepository(db).findAll();
  final ownedRows = await OwnedItemsRepository(db).listActiveSummaries();
  final trackingRows = await TrackingLifecycleRepository(
    db,
    codecs: collectarrTrackingLifecycleCodecs,
  ).listActive();
  final imageRows = await db.select(db.itemImagesCache).get();
  final typedGraphCounts = await devSeedTypedGraphCounts(db);
  final typedOwnedCounts = await devSeedTypedOwnedCounts(db);
  final typedTrackingCounts = await devSeedTypedTrackingCounts(db);
  final typedTrackingUnitCounts = await devSeedTypedTrackingUnitCounts(db);
  final vocabularyCounts = await devSeedVocabularyCounts(db);
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
      .where((row) => row.ref.id.value.startsWith('seed-'))
      .toList(growable: false);
  final seededTrackingRows = trackingRows
      .where((row) => row.catalogRef.id.startsWith('seed-'))
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
    seededOwnedRows.map((row) => row.ref.id.value).toSet().length ==
        seededOwnedRows.length,
    'seed owned IDs are not unique',
  );
  require(
    seededTrackingRows.map((row) => row.id).toSet().length ==
        seededTrackingRows.length,
    'seed tracking IDs are not unique',
  );

  for (final entry in devSeedCatalogCounts.entries) {
    final catalogCount = seededCatalogRows
        .where((row) => catalogMediaKindFromApiValue(row.kind) == entry.key)
        .length;
    final ownedCount = seededOwnedRows
        .where((row) =>
            row.catalogRef?.id.startsWith('seed-${entry.key.apiValue}-') ??
            false)
        .length;
    final trackingCount = seededTrackingRows
        .where((row) => row.catalogRef.id.startsWith(
              'seed-${entry.key.apiValue}-',
            ))
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
    for (final row in seededOwnedRows) row.ref.id.value: row,
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
  }
  for (final row in seededOwnedRows) {
    final catalog =
        row.catalogRef == null ? null : catalogById[row.catalogRef!.id];
    require(catalog != null,
        'owned ${row.ref.id.value} references missing ${row.catalogRef?.id}');
    require(
      row.catalogRef?.kind.apiValue == catalog?.kind,
      'owned ${row.ref.id.value} kind ${row.catalogRef?.kind} does not match '
      'catalog ${row.catalogRef?.id}',
    );
  }
  for (final row in seededTrackingRows) {
    final ownedRef = row.ownedRef;
    require(
      ownedRef != null && ownedById.containsKey(ownedRef.id.value),
      'tracking ${row.id} references missing owned item',
    );
    require(
      row.statusStorageValue != null &&
          row.rating != null &&
          row.startedAt != null,
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
  for (final entry in devSeedVocabularyMinimumCounts().entries) {
    require(
      (vocabularyCounts[entry.key] ?? 0) >= entry.value,
      'vocabulary ${entry.key}: expected at least ${entry.value}, found '
      '${vocabularyCounts[entry.key] ?? 0}',
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
      .where(
        (row) =>
            ownedById.values.any((owned) => owned.ref.key == row.ownedItemId),
      )
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
  final ownedIds = ownedRows.map((row) => row.ref.id.value).toSet();
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
    vocabularyCounts: vocabularyCounts,
    auxiliaryCounts: auxiliaryCounts,
  );
}

/// Returns `true` if all typed local catalog graphs are empty.
Future<bool> _isDatabaseEmpty(LocalDatabase db) async {
  return (await CatalogSnapshotRepository(db).findAll()).isEmpty;
}

/// Seeds the local database with rich dev data if it is empty.
///
/// Call from app startup or a debug menu. Skips seeding if data already exists.
Future<void> seedLocalDatabase(LocalDatabase db, {bool force = false}) async {
  if (!force && !await _isDatabaseEmpty(db)) return;

  final catalogRepo = CatalogTransportRepository(db);
  final ownedRepo = OwnedItemsRepository(db);
  final trackingRepo = TrackingLifecycleRepository(
    db,
    codecs: collectarrTrackingLifecycleCodecs,
  );
  final trackingUnitsRepo = TrackingUnitRepository(
    db,
    codecs: collectarrTrackingUnitCodecs,
  );
  final imagesRepo = ItemImagesCacheRepository(db);
  final pickListRepo = PickListRepository(db);
  final customFieldRepo = CustomFieldRepository(db);

  // --- Catalog Items ---
  final allItems = <CatalogItemDto>[
    for (final contributor in collectarrDevSeedContributors)
      ...contributor
          .catalogItems()
          .map(
            (item) => enrichSeedItem(
              item,
              defaults: contributor.catalogDefaults,
            ),
          )
          .map(contributor.enrichItem),
  ];

  final now = DateTime.now().toUtc();

  // --- Owned Items ---
  final ownedItems = <Object>[
    for (final contributor in collectarrDevSeedContributors)
      ...contributor.ownedItems(now),
  ];

  // --- Tracking Entries ---
  final trackingLifecycles = <TrackingLifecycle>[
    for (final contributor in collectarrDevSeedContributors)
      ...contributor.trackingLifecycles(now),
  ];
  final trackingUnits = <TrackingUnitSummary>[];
  final watchSessions = <WatchSession>[];
  final customEpisodes = <CustomEpisode>[];
  for (final contributor in collectarrDevSeedContributors) {
    final trackingUnitFactory = contributor.trackingUnits;
    if (trackingUnitFactory != null) {
      trackingUnits.addAll(trackingUnitFactory(allItems, now));
    }
    final watchSessionFactory = contributor.watchSessions;
    if (watchSessionFactory != null) {
      watchSessions.addAll(watchSessionFactory(now));
    }
    final customEpisodeFactory = contributor.customEpisodes;
    if (customEpisodeFactory != null) {
      customEpisodes.addAll(customEpisodeFactory(now));
    }
  }

  _validateSeedFixtures(
    catalogItems: allItems,
    ownedItems: ownedItems,
    trackingLifecycles: trackingLifecycles,
  );
  validateSeedCatalogQuality(
    allItems,
    validators: {
      for (final contributor in collectarrDevSeedContributors)
        contributor.kind: contributor.validateCatalog,
    },
    graphValidators: {
      for (final contributor in collectarrDevSeedContributors)
        contributor.kind: contributor.validateCatalogGraph,
    },
    barcodeValidators: {
      for (final contributor in collectarrDevSeedContributors)
        contributor.kind: contributor.validateBarcode,
    },
  );
  validateSeedOwnedQuality(
    ownedItems,
    validators: {
      for (final contributor in collectarrDevSeedContributors)
        contributor.kind: contributor.validateOwned,
    },
  );
  validateSeedTrackingQuality(trackingLifecycles);
  _validateSeedTrackingUnits(
    trackingUnits,
    allItems,
    supportedKinds: {
      for (final contributor in collectarrDevSeedContributors)
        if (contributor.trackingUnits != null) contributor.kind.apiValue,
    },
  );

  // upsertAll also auto-populates SerialAuthority & PickLists from catalog data
  await catalogRepo.upsertTransportItems(allItems);
  for (final ownedItem in ownedItems) {
    final ref = collectarrTypedOwnedItemRef(ownedItem);
    await ownedRepo.replaceFromPayload(
      ref.kind,
      collectarrTypedOwnedItemJson(ownedItem),
    );
  }
  for (final contributor in collectarrDevSeedContributors) {
    final databaseSeeder = contributor.seedDatabase;
    if (databaseSeeder != null) {
      await databaseSeeder(db, allItems, now);
    }
  }
  await trackingUnitsRepo.upsertAll(trackingUnits);
  await WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  ).upsertAll(watchSessions);
  await CustomEpisodesRepository(
    db,
    codecs: collectarrCustomEpisodeCodecs,
  ).upsertAll(customEpisodes);
  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, ownedItems);

  await trackingRepo.upsertAll(trackingLifecycles);

  // --- Pick Lists (supplement with extra values) ---
  await seedPickLists(pickListRepo);

  // --- Custom Fields ---
  await seedCustomFields(customFieldRepo);
}

void _validateSeedTrackingUnits(
  Iterable<TrackingUnitSummary> units,
  Iterable<CatalogItemDto> catalogItems, {
  required Set<String> supportedKinds,
}) {
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
    if (unit.targetRef.kind.apiValue != catalog.kind ||
        unit.targetRef.entityType != const CatalogEntityTypeId('work')) {
      throw StateError(
        'Seed tracking unit ${unit.id} has invalid catalog reference '
        '${unit.targetRef.toJson()}',
      );
    }
    if (!supportedKinds.contains(unit.targetRef.kind.apiValue)) {
      throw StateError(
        'Seed tracking unit ${unit.id} has no typed coordinate codec for '
        '${unit.targetRef.kind}',
      );
    }
  }
}

void _validateSeedFixtures({
  required List<CatalogItemDto> catalogItems,
  required List<Object> ownedItems,
  required List<TrackingLifecycle> trackingLifecycles,
}) {
  final catalogById = <String, CatalogItemDto>{};
  for (final item in catalogItems) {
    if (item.id.trim().isEmpty || item.title.trim().isEmpty) {
      throw StateError(
        'Seed catalog item must have a non-empty id and title '
        '(id="${item.id}", kind="${item.kind}", title="${item.title}")',
      );
    }
    final kind = catalogMediaKindFromApiValue(item.kind);
    if (!devSeedCatalogCounts.containsKey(kind)) {
      throw StateError(
          'Seed catalog item ${item.id} has unknown kind ${item.kind}');
    }
    if (catalogById.containsKey(item.id)) {
      throw StateError('Duplicate seed catalog id: ${item.id}');
    }
    catalogById[item.id] = item;
  }

  final actualCounts = <CatalogMediaKind, int>{};
  for (final item in catalogItems) {
    final kind = catalogMediaKindFromApiValue(item.kind);
    actualCounts[kind] = (actualCounts[kind] ?? 0) + 1;
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
  final ownedById = <String, OwnedItemSummary>{};
  for (final item in ownedItems) {
    final ref = collectarrTypedOwnedItemRef(item);
    final json = collectarrTypedOwnedItemJson(item);
    final rawCatalogRef = json['catalog_ref'];
    if (rawCatalogRef is! Map) {
      throw StateError(
        'Owned seed ${ref.id.value} is missing catalog_ref',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(
      Map<String, dynamic>.from(rawCatalogRef),
    );
    final summary = OwnedItemSummary(
      ref: ref,
      title: catalogRef.id,
      catalogRef: catalogRef,
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] is String
          ? DateTime.tryParse(json['deleted_at'] as String)
          : null,
    );
    if (ownedById.containsKey(ref.id.value)) {
      throw StateError('Duplicate owned seed id: ${ref.id.value}');
    }
    ownedById[ref.id.value] = summary;
    final catalog = catalogById[catalogRef.id];
    if (catalog == null) {
      throw StateError('Owned seed ${ref.id.value} references missing catalog '
          '${catalogRef.id}');
    }
    if (catalogRef.mediaKind != catalog.mediaKind) {
      throw StateError('Owned seed ${ref.id.value} kind ${catalogRef.kind} '
          'does not match catalog ${catalog.id} kind ${catalog.kind}');
    }
    if (!ownedCatalogIds.add(catalogRef.id)) {
      throw StateError('Duplicate owned seed catalog reference: '
          '${catalogRef.id}');
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
  for (final entry in trackingLifecycles) {
    if (!trackingIds.add(entry.id)) {
      throw StateError('Duplicate tracking seed id: ${entry.id}');
    }
    if (entry.ownedRef == null) {
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
    if (entry.catalogRef.kind.apiValue != catalog.kind) {
      throw StateError(
        'Tracking seed ${entry.id} kind ${entry.catalogRef.kind} does not '
        'match catalog ${catalog.id} kind ${catalog.kind}',
      );
    }
    if (entry.ownedRef case final ownedRef?) {
      final ownedId = ownedRef.id.value;
      final owned = ownedById[ownedId];
      if (owned == null) {
        throw StateError(
          'Tracking seed ${entry.id} references missing owned item $ownedId',
        );
      }
      if (owned.catalogRef?.id != entry.catalogRef.id) {
        throw StateError(
          'Tracking seed ${entry.id} links owned item $ownedId to '
          'catalog ${entry.catalogRef.id}, but it belongs to '
          '${owned.catalogRef?.id}',
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
  List<Object> ownedItems,
) async {
  for (var i = 0; i < ownedItems.length; i++) {
    final owned = ownedItems[i];
    final ownedRef = collectarrTypedOwnedItemRef(owned);
    final ownedId = ownedRef.id.value;
    await repo.upsert(
      id: 'seed-img-front-$ownedId',
      ownedRef: ownedRef,
      imageType: 'front_cover',
      imageData: seedTinyPngBytes,
      caption: 'Seed front cover',
      sortOrder: 0,
    );
    if (i.isEven) {
      await repo.upsert(
        id: 'seed-img-back-$ownedId',
        ownedRef: ownedRef,
        imageType: 'back_cover',
        imageData: seedTinyPngBytes,
        caption: 'Seed back cover',
        sortOrder: 1,
      );
    }
    if (i % 3 == 0) {
      await repo.upsert(
        id: 'seed-img-extra-$ownedId',
        ownedRef: ownedRef,
        imageType: 'detail_photo',
        imageData: seedTinyPngBytes,
        caption: 'Seed extra image',
        sortOrder: 2,
      );
    }
  }
}
