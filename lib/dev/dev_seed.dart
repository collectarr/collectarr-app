/// Development seed data for the local database.
///
/// Populates the shared Catalog Item cache and all kind-collection items,
/// kind-entry tracking entries, PickListValues, SerialAuthority, and
/// CustomFieldDefinitions/Values with rich entries for every library kind.
///
/// Usage: call `seedLocalDatabase(db)` from main.dart or a debug menu.
/// Safe to call multiple times – uses deterministic IDs (idempotent via upsert).
library;

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/dev/seeds/custom_field_seeds.dart';
import 'package:collectarr_app/dev/seeds/pick_list_seeds.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/dev/seeds/collectarr_dev_seed_registry.g.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';

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

/// Minimum typed catalog-storage coverage expected from the fixture set.
///
/// Some fixtures intentionally contain multiple seasons, episodes, or tracks,
/// so these are lower bounds rather than exact totals.
const devSeedTypedGraphMinimumCounts = <String, int>{
  'comic.catalog_item': 15,
  'comic.reading': 15,
  'manga.catalog_item': 15,
  'book.catalog_item': 15,
  'game.catalog_item': 15,
  'boardgame.catalog_item': 15,
  'movie.catalog_item': 15,
  'tv.catalog_item': 15,
  'tv.season': 15,
  'tv.episode': 30,
  'anime.catalog_item': 15,
  'anime.episode_data': 30,
  'music.item': 15,
  'music.disc': 15,
  'music.track': 15,
};

/// Minimum rows expected in each kind-entry physical-copy details table.
///
/// Every kind is measured from its complete kind-collection item table.
const devSeedTypedEntryMinimumCounts = <String, int>{
  'comic.entry': 15,
  'manga.entry': 15,
  'book.entry': 15,
  'game.entry': 15,
  'boardgame.entry': 15,
  'movie.entry': 15,
  'tv.entry': 15,
  'anime.entry': 15,
  'music.entry': 15,
};

/// Minimum typed tracking rows expected from episodic fixtures.
const devSeedTypedTrackingMinimumCounts = <String, int>{
  'comic.tracking': 15,
  'manga.tracking': 15,
  'book.tracking': 15,
  'game.tracking': 15,
  'boardgame.tracking': 15,
  'movie.tracking': 15,
  'tv.tracking': 15,
  'tv.episode_progress': 30,
  'anime.tracking': 30,
  'tv.watch_sessions': 15,
  'tv.custom_episodes': 15,
  'anime.watch_sessions': 15,
  'anime.custom_episodes': 15,
  'boardgame.play_sessions': 15,
};

/// Minimum kind-entry coordinate rows expected from the typed tracking-unit
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

/// Counts the typed catalog storage written by the development seed.
///
/// This is intentionally a composition-root helper: the seed verifier may
/// enumerate kind tables and the shared flat Movie cache, while runtime
/// catalog code must use the owning repository/codec instead of inspecting
/// storage tables.
Future<Map<String, int>> devSeedTypedGraphCounts(LocalDatabase db) async {
  final boardGameCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.boardgame,
  );
  final animeCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.anime,
  );
  final comicCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.comic,
  );
  final musicCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.music,
  );
  final tvCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.tv,
  );
  final musicAlbums = [
    for (final item in musicCatalogItems)
      MusicCatalogMapper.mapMetadataItemToMusic(item),
  ];
  return {
    'comic.catalog_item': comicCatalogItems.length,
    'comic.reading': (await db.select(db.comicReadingRows).get()).length,
    'manga.catalog_item': (await CatalogItemCacheRepository(db)
            .findAll(kind: CatalogMediaKind.manga))
        .length,
    'book.catalog_item': (await CatalogItemCacheRepository(db)
            .findAll(kind: CatalogMediaKind.book))
        .length,
    'game.catalog_item': (await CatalogItemCacheRepository(db)
            .findAll(kind: CatalogMediaKind.game))
        .length,
    'boardgame.catalog_item': boardGameCatalogItems.length,
    'movie.catalog_item': (await CatalogItemCacheRepository(db)
            .findAll(kind: CatalogMediaKind.movie))
        .length,
    'tv.catalog_item': tvCatalogItems.length,
    'tv.season': tvCatalogItems.fold<int>(
      0,
      (count, item) => count + _countObjects(item.payload['seasons']),
    ),
    'tv.episode': tvCatalogItems.fold<int>(
      0,
      (count, item) =>
          count + _countNestedObjects(item.payload['seasons'], 'episodes'),
    ),
    'anime.catalog_item': animeCatalogItems.length,
    'anime.episode_data': animeCatalogItems.fold<int>(
      0,
      (count, item) {
        final episodes = item.payload['episodes'];
        return count + (episodes is Iterable ? episodes.length : 0);
      },
    ),
    'music.item': musicCatalogItems.length,
    'music.disc': musicAlbums.fold<int>(
      0,
      (count, album) => count + album.discs.length,
    ),
    'music.track': musicAlbums.fold<int>(
      0,
      (count, album) => count + album.trackCount,
    ),
  };
}

/// Returns relationship errors in the typed rows written by the development
/// fixture. Only deterministic seed rows are inspected so a developer can
/// run this against a database that also contains real local data.
Future<List<String>> devSeedTypedGraphIntegrityIssues(LocalDatabase db) async {
  final issues = <String>[];
  bool isSeed(String id) => id.startsWith('seed-');

  final comicItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.comic,
  );
  for (final item in comicItems.where((item) => isSeed(item.id))) {
    if (seedTitle(item).trim().isEmpty) {
      issues.add('Comic Catalog Item ${item.id} has an empty title');
    }
  }

  final mangaItems = await CatalogItemCacheRepository(db)
      .findAll(kind: CatalogMediaKind.manga);
  for (final item in mangaItems.where((item) => isSeed(item.id))) {
    final chapters = item.payload['chapters'];
    if (chapters is! Iterable || chapters.isEmpty) {
      issues.add('Manga Catalog Item ${item.id} has no persisted chapters');
    }
  }

  final bookItems =
      await CatalogItemCacheRepository(db).findAll(kind: CatalogMediaKind.book);
  for (final item in bookItems.where((item) => isSeed(item.id))) {
    if (seedTitle(item).trim().isEmpty) {
      issues.add('Book Catalog Item ${item.id} has an empty title');
    }
  }

  final gameItems =
      await CatalogItemCacheRepository(db).findAll(kind: CatalogMediaKind.game);
  for (final item in gameItems.where((item) => isSeed(item.id))) {
    if (seedTitle(item).trim().isEmpty) {
      issues.add('Game Catalog Item ${item.id} has an empty title');
    }
  }

  final boardGameItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.boardgame,
  );
  for (final item in boardGameItems.where((item) => isSeed(item.id))) {
    if (seedTitle(item).trim().isEmpty) {
      issues.add('BoardGame Catalog Item ${item.id} has an empty title');
    }
    final minPlayers = item.payload['min_players'];
    final maxPlayers = item.payload['max_players'];
    final playingTime = item.payload['playing_time_minutes'];
    if (minPlayers is! num || maxPlayers is! num || playingTime is! num) {
      issues.add(
        'BoardGame Catalog Item ${item.id} has incomplete player/time data',
      );
    }
  }

  final movieItems = await CatalogItemCacheRepository(db)
      .findAll(kind: CatalogMediaKind.movie);
  for (final item in movieItems.where((item) => isSeed(item.id))) {
    if (item.id.trim().isEmpty) {
      issues.add('seed Movie Catalog Item has an empty id');
    }
    if (seedTitle(item).trim().isEmpty) {
      issues.add('Movie Catalog Item ${item.id} has an empty title');
    }
  }

  final tvItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.tv,
  );
  for (final item in tvItems.where((item) => isSeed(item.id))) {
    final seasonIds = <String>{};
    final episodeIds = <String>{};
    for (final season in _objectMaps(item.payload['seasons'])) {
      final seasonId = season['id']?.toString() ?? '';
      if (seasonId.isEmpty || !seasonIds.add(seasonId)) {
        issues.add('TV Catalog Item ${item.id} has an invalid season ID');
      }
      for (final episode in _objectMaps(season['episodes'])) {
        final episodeId = episode['id']?.toString() ?? '';
        if (episodeId.isEmpty || !episodeIds.add(episodeId)) {
          issues.add('TV Catalog Item ${item.id} has an invalid episode ID');
        }
      }
    }
  }

  final animeItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.anime,
  );
  for (final item in animeItems.where((item) => isSeed(item.id))) {
    if (seedTitle(item).trim().isEmpty) {
      issues.add('Anime Catalog Item ${item.id} has an empty title');
    }
    for (final entry in item.payload['episodes'] is Iterable
        ? item.payload['episodes'] as Iterable
        : const <Object?>[]) {
      if (entry is! Map || entry['id']?.toString().trim().isEmpty == true) {
        issues.add('Anime Catalog Item ${item.id} has an invalid episode');
      }
    }
  }

  final musicCatalogItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.music,
  );
  for (final item in musicCatalogItems.where((item) => isSeed(item.id))) {
    final album = MusicCatalogMapper.mapMetadataItemToMusic(item);
    for (final disc in album.discs) {
      if (disc.discNumber < 1) {
        issues.add('music disc ${disc.id.value} has an invalid disc number');
      }
    }
  }

  return issues;
}

/// Returns entries relationship errors in the kind-entry tables written by
/// the development fixture. Only deterministic seed rows are inspected so a
/// developer can run this against a database that also contains local data.
///
/// Every kind-entry table must agree on the same copy IDs. Counts alone are
/// not enough: a wrongly typed row can keep
/// the totals green while disconnecting one catalog kind from its copy data.
Future<List<String>> devSeedTypedEntryIntegrityIssues(LocalDatabase db) async {
  final issues = <String>[];
  final entryRows = await LibraryEntriesRepository(db).listActiveSummaries();
  final entryById = <String, LibraryEntrySummary>{
    for (final row in entryRows) row.ref.id.value: row,
  };
  final expectedByKind = <String, Set<String>>{};
  for (final row in entryRows.where(
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
      final entry = entryById[id];
      if (entry == null) {
        issues.add('$table row $id has no entry repository row');
        continue;
      }
      if (entry.ref.kind.apiValue != kind) {
        issues.add(
          '$table row $id belongs to kind ${entry.ref.kind.apiValue}, '
          'expected $kind',
        );
      }
      if (!(entry.sourceCatalogRef?.id.startsWith('seed-$kind-') ?? false)) {
        issues.add(
          '$table row $id points to ${entry.sourceCatalogRef?.id}, '
          'expected a $kind seed',
        );
      }
    }
    for (final id in expectedIds) {
      if (!typedIds.contains(id)) {
        issues.add('$table is missing seed entry row $id');
      }
    }
  }

  final comicRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('comic')))
      .get();
  checkTypedRows(
      'comic_library_entries', 'comic', comicRows.map((row) => row.id));
  final mangaRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('manga')))
      .get();
  checkTypedRows(
      'manga_library_entries', 'manga', mangaRows.map((row) => row.id));
  final bookRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('book')))
      .get();
  checkTypedRows('book_library_entries', 'book', bookRows.map((row) => row.id));
  final gameRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('game')))
      .get();
  checkTypedRows('game_library_entries', 'game', gameRows.map((row) => row.id));
  final boardGameRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('boardgame')))
      .get();
  checkTypedRows('boardgame_library_entries', 'boardgame',
      boardGameRows.map((row) => row.id));
  final movieRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('movie')))
      .get();
  checkTypedRows(
      'movie_library_entries', 'movie', movieRows.map((row) => row.id));
  final tvRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('tv')))
      .get();
  checkTypedRows('tv_library_entries', 'tv', tvRows.map((row) => row.id));
  final animeRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('anime')))
      .get();
  checkTypedRows(
      'anime_library_entries', 'anime', animeRows.map((row) => row.id));
  final musicRows = await (db.select(db.libraryEntries)
        ..where((t) => t.kind.equals('music')))
      .get();
  checkTypedRows(
      'music_library_entries', 'music', musicRows.map((row) => row.id));

  return issues;
}

/// Counts kind-entry entries rows written by the development seed.
Future<Map<String, int>> devSeedTypedEntryCounts(LocalDatabase db) async {
  return {
    'comic.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('comic')))
            .get())
        .length,
    'manga.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('manga')))
            .get())
        .length,
    'book.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('book')))
            .get())
        .length,
    'game.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('game')))
            .get())
        .length,
    'boardgame.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('boardgame')))
            .get())
        .length,
    'movie.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('movie')))
            .get())
        .length,
    'tv.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('tv')))
            .get())
        .length,
    'anime.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('anime')))
            .get())
        .length,
    'music.entry': (await (db.select(db.libraryEntries)
              ..where((t) => t.kind.equals('music')))
            .get())
        .length,
  };
}

/// Counts kind-entry tracking rows written by the development seed.
Future<Map<String, int>> devSeedTypedTrackingCounts(LocalDatabase db) async {
  return {
    'comic.tracking': (await db.select(db.comicTrackingRows).get()).length,
    'manga.tracking': (await db.select(db.mangaTrackingRows).get()).length,
    'book.tracking': (await db.select(db.bookTrackingRows).get()).length,
    'game.tracking': (await db.select(db.gameTrackingRows).get()).length,
    'boardgame.tracking':
        (await db.select(db.boardGameTrackingRows).get()).length,
    'movie.tracking': (await db.select(db.movieTrackingRows).get()).length,
    'tv.tracking': (await db.select(db.tvTrackingRows).get()).length,
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

/// Counts kind-entry tracking-unit coordinate rows written by the seed.
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

/// Counts universal seed fixtures that are not entry by one catalog kind.
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

/// Counts each kind-entry vocabulary independently so a missing list cannot
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
/// verifier. Keeping the checks here prevents a new kind-entry table or seed
/// invariant from being added to one entry point and forgotten by the other.
final class DevSeedVerificationReport {
  const DevSeedVerificationReport({
    required this.catalogCount,
    required this.seededCatalogCount,
    required this.entryCount,
    required this.trackingCount,
    required this.imageCount,
    required this.typedGraphCounts,
    required this.typedEntryCounts,
    required this.typedTrackingCounts,
    required this.typedTrackingUnitCounts,
    required this.vocabularyCounts,
    required this.auxiliaryCounts,
  });

  final int catalogCount;
  final int seededCatalogCount;
  final int entryCount;
  final int trackingCount;
  final int imageCount;
  final Map<String, int> typedGraphCounts;
  final Map<String, int> typedEntryCounts;
  final Map<String, int> typedTrackingCounts;
  final Map<String, int> typedTrackingUnitCounts;
  final Map<String, int> vocabularyCounts;
  final Map<String, int> auxiliaryCounts;
}

/// Verifies the complete persisted development fixture graph.
///
/// This is deliberately a composition-root/dev helper. It may enumerate all
/// kind-entry tables to verify the fixture, while runtime library code must
/// continue to use the owning kind repositories and codecs.
Future<DevSeedVerificationReport> verifyDevSeedDatabase(
    LocalDatabase db) async {
  final catalogRows = await CatalogSnapshotRepository(db).findAll();
  final entryRows = await LibraryEntriesRepository(db).listActiveSummaries();
  final trackingRows = await TrackingStorageRepository(
    db,
    codecs: libraryTrackingStorageCodecs,
  ).listActiveStorageRecords();
  final imageRows = await db.select(db.itemImagesCache).get();
  final typedGraphCounts = await devSeedTypedGraphCounts(db);
  final typedEntryCounts = await devSeedTypedEntryCounts(db);
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
  final seededEntryRows = entryRows
      .where((row) => row.ref.id.value.startsWith('seed-'))
      .toList(growable: false);
  final seededTrackingRows = trackingRows
      .where((row) => row.libraryEntryRef.id.value.startsWith('seed-'))
      .toList(growable: false);

  require(
    seededCatalogRows.length == expectedSeedCount,
    'expected $expectedSeedCount seed catalog rows, found '
    '${seededCatalogRows.length}',
  );
  require(
    seededEntryRows.length == expectedSeedCount,
    'expected $expectedSeedCount seed entry rows, found '
    '${seededEntryRows.length}',
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
    seededEntryRows.map((row) => row.ref.id.value).toSet().length ==
        seededEntryRows.length,
    'seed entry IDs are not unique',
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
    final entryCount =
        seededEntryRows.where((row) => row.ref.kind == entry.key).length;
    final trackingCount = seededTrackingRows
        .where((row) => row.libraryEntryRef.kind == entry.key)
        .length;
    require(
      catalogCount == entry.value,
      '${entry.key}: expected ${entry.value} catalog rows, found $catalogCount',
    );
    require(
      entryCount == entry.value,
      '${entry.key}: expected ${entry.value} entry rows, found $entryCount',
    );
    require(
      trackingCount == entry.value,
      '${entry.key}: expected ${entry.value} tracking rows, found $trackingCount',
    );
  }

  final catalogById = {
    for (final row in seededCatalogRows) row.id: row,
  };
  final entryById = {
    for (final row in seededEntryRows) row.ref.key: row,
  };
  for (final row in seededCatalogRows) {
    final kind = catalogMediaKindFromApiValue(row.kind);
    require(seedTitle(row).trim().isNotEmpty, 'catalog ${row.id} has no title');
    require(
        kind != CatalogMediaKind.unknown, 'catalog ${row.id} has unknown kind');
    require(
      seedCoverImageUrl(row)?.trim().isNotEmpty == true,
      'catalog ${row.id} is missing cover image URLs',
    );
    final barcode = seedBarcode(row);
    require(barcode != null && barcode.trim().isNotEmpty,
        'catalog ${row.id} is missing a barcode');
    if (barcode != null && barcode.trim().isNotEmpty) {
      require(
        resolveLibraryBarcodeForKind(kind, barcode) != null,
        'catalog ${row.id} has a barcode rejected by ${row.kind}',
      );
    }
  }
  for (final row in seededEntryRows) {
    final sourceRef = row.sourceCatalogRef;
    if (sourceRef != null) {
      final catalog = catalogById[sourceRef.id];
      require(
        catalog != null,
        'entry ${row.ref.id.value} references missing source catalog ${sourceRef.id}',
      );
      require(
        sourceRef.kind.apiValue == catalog?.kind &&
            sourceRef.kind == row.ref.kind,
        'entry ${row.ref.id.value} has a mismatched source catalog ref',
      );
    }
  }
  for (final row in seededTrackingRows) {
    require(
      entryById.containsKey(row.libraryEntryRef.key),
      'tracking ${row.id} references missing library entry ${row.libraryEntryRef.key}',
    );
    require(
      entryById[row.libraryEntryRef.key]?.ref.kind == row.libraryEntryRef.kind,
      'tracking ${row.id} kind ${row.libraryEntryRef.kind} does not match '
      'library entry ${row.libraryEntryRef.key}',
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
  for (final entry in devSeedTypedEntryMinimumCounts.entries) {
    require(
      (typedEntryCounts[entry.key] ?? 0) >= entry.value,
      'typed entry ${entry.key}: expected at least ${entry.value}, found '
      '${typedEntryCounts[entry.key] ?? 0}',
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
  final entryIssues = await devSeedTypedEntryIntegrityIssues(db);
  issues.addAll(graphIssues);
  issues.addAll(entryIssues);

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

  final bookItems = (await CatalogItemCacheRepository(db)
          .findAll(kind: CatalogMediaKind.book))
      .where((item) => item.id.startsWith('seed-'));
  require(
    bookItems.every((item) =>
        item.id.trim().isNotEmpty && seedTitle(item).trim().isNotEmpty),
    'Book seed Catalog Items are missing canonical identity fields',
  );
  final boardGameItems = (await CatalogItemCacheRepository(db)
          .findAll(kind: CatalogMediaKind.boardgame))
      .where((item) => item.id.startsWith('seed-'));
  require(
    boardGameItems.every((item) =>
        item.payload['title']?.toString().trim().isNotEmpty == true &&
        item.payload['min_players'] is num &&
        item.payload['max_players'] is num &&
        item.payload['playing_time_minutes'] is num),
    'Board Game seed Catalog Items are missing edition-level data',
  );
  final musicItems = await CatalogItemCacheRepository(db).findAll(
    kind: CatalogMediaKind.music,
  );
  final musicTracks = [
    for (final item in musicItems.where((item) => item.id.startsWith('seed-')))
      for (final disc in MusicCatalogMapper.mapMetadataItemToMusic(item).discs)
        for (final track in disc.tracks)
          if (track.id.value.startsWith('seed-')) track,
  ];
  require(
    musicTracks.every(
      (track) => track.durationMs != null,
    ),
    'music seed tracks are missing disc/duration metadata',
  );

  final seedImages = imageRows
      .where(
        (row) => entryById.values
            .any((entry) => entry.ref.key == row.libraryEntryRefKey),
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
  final entryKeys = entryRows.map((row) => row.ref.key).toSet();
  require(
    customFieldValues
        .where((row) => row.targetId.startsWith('seed-'))
        .every((row) => entryKeys.contains(row.targetId)),
    'a seed custom-field value targets a missing collection item',
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
    entryCount: entryRows.length,
    trackingCount: trackingRows.length,
    imageCount: imageRows.length,
    typedGraphCounts: typedGraphCounts,
    typedEntryCounts: typedEntryCounts,
    typedTrackingCounts: typedTrackingCounts,
    typedTrackingUnitCounts: typedTrackingUnitCounts,
    vocabularyCounts: vocabularyCounts,
    auxiliaryCounts: auxiliaryCounts,
  );
}

/// Validates the source coverage emitted by every kind-entry seed script.
///
/// The persisted verifier checks the complete database graph. This source
/// guard runs before persistence and reports an incomplete contributor at its
/// source instead of allowing aggregate counts to hide it behind another
/// contributor's rows.
void validateDevSeedContributorCoverage({
  DateTime? now,
  Iterable<DevSeedKindContributor>? contributors,
}) {
  final effectiveNow = now ?? DateTime.utc(2024, 1, 1);
  final values = (contributors ?? collectarrDevSeedContributors).toList();
  final issues = <String>[];
  final expectedKinds = devSeedCatalogCounts.keys.toSet();
  final actualKinds = values.map((contributor) => contributor.kind).toSet();

  for (final kind in expectedKinds.difference(actualKinds)) {
    issues.add('missing seed contributor for ${kind.apiValue}');
  }
  for (final kind in actualKinds.difference(expectedKinds)) {
    issues.add('unexpected seed contributor for ${kind.apiValue}');
  }
  if (values.length != actualKinds.length) {
    issues.add('duplicate seed contributor kind registration');
  }

  for (final contributor in values) {
    final kind = contributor.kind;
    final expectedCount = devSeedCatalogCounts[kind];
    if (expectedCount == null) continue;
    final kindPrefix = 'seed-${kind.apiValue}-';

    final catalogItems = contributor.catalogItems();
    if (catalogItems.length != expectedCount) {
      issues.add(
        '${kind.apiValue}: expected $expectedCount source catalog items, '
        'found ${catalogItems.length}',
      );
    }
    final catalogIds = <String>{};
    for (final item in catalogItems) {
      if (item.mediaKind != kind) {
        issues.add(
          '${kind.apiValue}: source catalog ${item.id} emits kind '
          '${item.mediaKind.apiValue}',
        );
      }
      if (!item.id.startsWith(kindPrefix)) {
        issues.add(
          '${kind.apiValue}: source catalog id ${item.id} must start with '
          '$kindPrefix',
        );
      }
      if (!catalogIds.add(item.id)) {
        issues.add('${kind.apiValue}: duplicate source catalog id ${item.id}');
      }
    }

    final libraryEntries = contributor.entrySummaries(effectiveNow);
    if (libraryEntries.length != expectedCount) {
      issues.add(
        '${kind.apiValue}: expected $expectedCount source Collection items, '
        'found ${libraryEntries.length}',
      );
    }
    final entryIds = <String>{};
    for (final item in libraryEntries) {
      final id = item.ref.id.value;
      if (!entryIds.add(id)) {
        issues.add('${kind.apiValue}: duplicate source Entry id $id');
      }
      if (item.ref.kind != kind) {
        issues.add(
          '${kind.apiValue}: source Entry $id emits kind '
          '${item.ref.kind.apiValue}',
        );
      }
      if (!id.startsWith('seed-')) {
        issues
            .add('${kind.apiValue}: source Entry id $id is not deterministic');
      }
      final sourceCatalogRef = item.sourceCatalogRef;
      if (sourceCatalogRef != null && sourceCatalogRef.kind != kind) {
        issues.add(
          '${kind.apiValue}: source Entry $id has a mismatched source catalog ref',
        );
      }
    }

    final trackingItems = contributor.trackingRecords(effectiveNow);
    if (trackingItems.length != expectedCount) {
      issues.add(
        '${kind.apiValue}: expected $expectedCount source tracking items, '
        'found ${trackingItems.length}',
      );
    }
    final trackingIds = <String>{};
    for (final item in trackingItems) {
      if (!trackingIds.add(item.id)) {
        issues.add('${kind.apiValue}: duplicate source tracking id ${item.id}');
      }
      if (!item.id.startsWith('seed-')) {
        issues.add(
          '${kind.apiValue}: source tracking id ${item.id} is not deterministic',
        );
      }
      if (item.libraryEntryRef.kind != kind) {
        issues.add(
          '${kind.apiValue}: source tracking ${item.id} emits entry kind '
          '${item.libraryEntryRef.kind.apiValue}',
        );
      }
      final libraryEntryRef = item.libraryEntryRef;
      if (libraryEntryRef.kind != kind) {
        issues.add(
          '${kind.apiValue}: source tracking ${item.id} emits Entry kind '
          '${libraryEntryRef.kind.apiValue}',
        );
      }
    }
  }

  if (issues.isNotEmpty) {
    throw StateError(
      'Development seed contributor coverage failed:\n'
      '${issues.map((issue) => '- $issue').join('\n')}',
    );
  }
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
  final trackingRepo = TrackingStorageRepository(
    db,
    codecs: libraryTrackingStorageCodecs,
  );
  final trackingUnitsRepo = TrackingUnitStorageRepository(
    db,
    codecs: libraryTrackingUnitCodecs,
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

  // Fail before any database write if one of the concrete kind seed scripts
  // is missing rows or emits a cross-kind reference.
  validateDevSeedContributorCoverage(now: now);

  // --- Entry summaries ---
  // The central seed runner only carries the deliberately small structural
  // projection. Complete Entry aggregates stay inside each kind contributor.
  final entrySummaries = <LibraryEntrySummary>[
    for (final contributor in collectarrDevSeedContributors)
      ...contributor.entrySummaries(now),
  ];

  // --- Tracking Entries ---
  final trackingRecords = <TrackingStorageRecord>[
    for (final contributor in collectarrDevSeedContributors)
      ...contributor.trackingRecords(now),
  ];
  final trackingUnits = <TrackingUnitSummary>[];
  final watchSessions = <WatchSession>[];
  for (final contributor in collectarrDevSeedContributors) {
    final trackingUnitFactory = contributor.trackingUnits;
    if (trackingUnitFactory != null) {
      trackingUnits.addAll(trackingUnitFactory(allItems, now));
    }
    final watchSessionFactory = contributor.watchSessions;
    if (watchSessionFactory != null) {
      watchSessions.addAll(watchSessionFactory(now));
    }
  }

  _validateSeedFixtures(
    catalogItems: allItems,
    entrySummaries: entrySummaries,
    trackingRecords: trackingRecords,
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
  validateSeedEntryQuality(entrySummaries);
  final entryQualityIssues = [
    for (final contributor in collectarrDevSeedContributors)
      ...contributor.validateEntry(now),
  ];
  if (entryQualityIssues.isNotEmpty) {
    throw StateError(
      'Development seed typed Entry validation failed:\n'
      '${entryQualityIssues.map((issue) => '- $issue').join('\n')}',
    );
  }
  validateSeedTrackingQuality(trackingRecords);
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
  for (final contributor in collectarrDevSeedContributors) {
    await contributor.seedEntry(db, now);
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
    codecs: libraryWatchSessionCodecs,
  ).upsertAll(watchSessions);
  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, entrySummaries);

  await trackingRepo.upsertStorageRecords(trackingRecords);

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
  final entryRefs = {
    for (final item in catalogItems)
      seedLibraryEntryRef(item.mediaKind, 'seed-entry-${item.id}').key:
          seedLibraryEntryRef(item.mediaKind, 'seed-entry-${item.id}'),
  };
  final ids = <String>{};
  for (final unit in units) {
    if (!ids.add(unit.id)) {
      throw StateError('Duplicate seed tracking-unit id: ${unit.id}');
    }
    final entryRef = entryRefs[unit.libraryEntryRef.key];
    if (entryRef == null) {
      throw StateError(
        'Seed tracking unit ${unit.id} references missing local entry '
        '${unit.libraryEntryRef.key}',
      );
    }
    if (unit.libraryEntryRef.kind != entryRef.kind) {
      throw StateError(
        'Seed tracking unit ${unit.id} has invalid local entry reference '
        '${unit.libraryEntryRef.key}',
      );
    }
    if (!supportedKinds.contains(unit.libraryEntryRef.kind.apiValue)) {
      throw StateError(
        'Seed tracking unit ${unit.id} has no typed coordinate codec for '
        '${unit.libraryEntryRef.kind}',
      );
    }
  }
}

void _validateSeedFixtures({
  required List<CatalogItemDto> catalogItems,
  required List<LibraryEntrySummary> entrySummaries,
  required List<TrackingStorageRecord> trackingRecords,
}) {
  final catalogByRef = <String, CatalogItemDto>{};
  String catalogKey(CatalogMediaKind kind, String id) => '${kind.apiValue}/$id';
  for (final item in catalogItems) {
    if (item.id.trim().isEmpty || seedTitle(item).trim().isEmpty) {
      throw StateError(
        'Seed catalog item must have a non-empty id and title '
        '(id="${item.id}", kind="${item.kind}", title="${seedTitle(item)}")',
      );
    }
    final kind = catalogMediaKindFromApiValue(item.kind);
    if (!devSeedCatalogCounts.containsKey(kind)) {
      throw StateError(
          'Seed catalog item ${item.id} has unknown kind ${item.kind}');
    }
    final key = catalogKey(kind, item.id);
    if (catalogByRef.containsKey(key)) {
      throw StateError('Duplicate seed catalog ref: $key');
    }
    catalogByRef[key] = item;
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

  final entryByRef = <String, LibraryEntrySummary>{};
  for (final item in entrySummaries) {
    final ref = item.ref;
    if (ref.id.value.trim().isEmpty || ref.kind == CatalogMediaKind.unknown) {
      throw StateError('Entry seed has invalid local identity: ${ref.key}');
    }
    if (entryByRef.containsKey(ref.key)) {
      throw StateError('Duplicate entry seed ref: ${ref.key}');
    }
    entryByRef[ref.key] = item;
    final sourceRef = item.sourceCatalogRef;
    if (sourceRef != null) {
      final catalog = catalogByRef[catalogKey(sourceRef.kind, sourceRef.id)];
      if (catalog == null) {
        throw StateError('Entry seed ${ref.key} references missing source '
            'catalog ${sourceRef.key}');
      }
      if (sourceRef.kind != ref.kind ||
          sourceRef.kind.apiValue != catalog.kind) {
        throw StateError('Entry seed ${ref.key} has mismatched source catalog '
            '${sourceRef.key}');
      }
    }
  }

  final trackingEntryRefs = <String>{};
  final trackingIds = <String>{};
  for (final entry in trackingRecords) {
    if (!trackingIds.add(entry.id)) {
      throw StateError('Duplicate tracking seed id: ${entry.id}');
    }
    final libraryEntryRef = entry.libraryEntryRef;
    final target = entryByRef[libraryEntryRef.key];
    if (target == null) {
      throw StateError('Tracking seed ${entry.id} references missing library '
          'entry ${libraryEntryRef.key}');
    }
    if (target.ref.kind != libraryEntryRef.kind) {
      throw StateError('Tracking seed ${entry.id} kind ${libraryEntryRef.kind} '
          'does not match library entry kind ${target.ref.kind}');
    }
    if (!trackingEntryRefs.add(libraryEntryRef.key)) {
      throw StateError('Duplicate tracking seed library entry: '
          '${libraryEntryRef.key}');
    }
  }
}

Future<void> _seedItemImages(
  ItemImagesCacheRepository repo,
  List<LibraryEntrySummary> entrySummaries,
) async {
  for (var i = 0; i < entrySummaries.length; i++) {
    final libraryEntryRef = entrySummaries[i].ref;
    final entryId = libraryEntryRef.id.value;
    await repo.upsert(
      id: 'seed-img-front-$entryId',
      libraryEntryRef: libraryEntryRef,
      imageType: 'front_cover',
      imageData: seedTinyPngBytes,
      caption: 'Seed front cover',
      sortOrder: 0,
    );
    if (i.isEven) {
      await repo.upsert(
        id: 'seed-img-back-$entryId',
        libraryEntryRef: libraryEntryRef,
        imageType: 'back_cover',
        imageData: seedTinyPngBytes,
        caption: 'Seed back cover',
        sortOrder: 1,
      );
    }
    if (i % 3 == 0) {
      await repo.upsert(
        id: 'seed-img-extra-$entryId',
        libraryEntryRef: libraryEntryRef,
        imageType: 'detail_photo',
        imageData: seedTinyPngBytes,
        caption: 'Seed extra image',
        sortOrder: 2,
      );
    }
  }
}

int _countObjects(Object? value) => _objectMaps(value).length;

int _countNestedObjects(Object? parents, String childKey) =>
    _objectMaps(parents).fold<int>(
      0,
      (count, parent) => count + _countObjects(parent[childKey]),
    );

List<Map<String, dynamic>> _objectMaps(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}
