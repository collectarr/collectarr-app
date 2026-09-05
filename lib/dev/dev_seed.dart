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

  // upsertAll also auto-populates SerialAuthority & PickLists from catalog data
  await catalogRepo.upsertAll(allItems);

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
  await ownedRepo.upsertAll(ownedItems);
  await comicOwnedRepo.upsertAll(
    ownedItems
        .where((item) => item.catalogRef.mediaKind == CatalogMediaKind.comic)
        .map(ComicOwnedItemLegacyAdapter.fromLegacy),
  );

  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, ownedItems);

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
  await trackingRepo.upsertAll(trackingEntries);

  // --- Pick Lists (supplement with extra values) ---
  await seedPickLists(pickListRepo);

  // --- Custom Fields ---
  await seedCustomFields(customFieldRepo);
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
