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
  final trackingRepo = TrackingEntriesCacheRepository(db);
  final imagesRepo = ItemImagesCacheRepository(db);
  final pickListRepo = PickListRepository(db);
  final customFieldRepo = CustomFieldRepository(db);

  // --- Catalog Items ---
  final allItems = <CatalogItem>[
    ...movieSeedCatalogItems().map(enrichSeedItem),
    ...tvSeedCatalogItems().map(enrichSeedItem),
    ...animeSeedCatalogItems().map(enrichSeedItem),
    ...mangaSeedCatalogItems().map(enrichSeedItem),
    ...bookSeedCatalogItems().map(enrichSeedItem),
    ...musicSeedCatalogItems().map(enrichSeedItem),
    ...gameSeedCatalogItems().map(enrichSeedItem),
    ...boardgameSeedCatalogItems().map(enrichSeedItem),
    ...comicSeedCatalogItems().map(enrichSeedItem),
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
      throw StateError('Seed catalog item must have a non-empty id and title');
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
