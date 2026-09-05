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
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
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
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';

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
  'boardgame': 10,
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
  'boardgame.media': 10,
  'boardgame.edition': 10,
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
  final ownedRepo = OwnedItemsCacheRepository(db);
  final trackingRepo = TrackingEntriesCacheRepository(
    db,
    codecs: collectarrTrackingEntryCodecs,
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

  _validateSeedFixtures(
    catalogItems: allItems,
    ownedItems: ownedItems,
    trackingEntries: trackingEntries,
  );
  validateSeedCatalogQuality(allItems);
  validateSeedOwnedQuality(ownedItems);
  validateSeedTrackingQuality(trackingEntries);

  // upsertAll also auto-populates SerialAuthority & PickLists from catalog data
  await catalogRepo.upsertAll(allItems);
  await ownedRepo.upsertAll(ownedItems);
  await comicOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.comic)
        .map(ComicOwnedItemLegacyAdapter.fromLegacy),
  );

  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, ownedItems);

  await trackingRepo.upsertAll(trackingEntries);

  // --- Pick Lists (supplement with extra values) ---
  await seedPickLists(pickListRepo);

  // --- Custom Fields ---
  await seedCustomFields(customFieldRepo);
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
