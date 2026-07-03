/// Development seed data for the local database.
///
/// Populates CatalogCache, OwnedItemsCache, TrackingEntriesCache,
/// PickListValues, SeriesRegistry, CustomFieldDefinitions/Values
/// with ~10 entries per library kind, all fields maximally populated.
///
/// Usage: call `seedLocalDatabase(db)` from main.dart or a debug menu.
/// Safe to call multiple times – uses deterministic IDs (idempotent via upsert).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';

/// Returns `true` if the local catalog cache is empty.
Future<bool> _isDatabaseEmpty(LocalDatabase db) async {
  final countExpr = countAll();
  final count = await (db.selectOnly(db.catalogCache)..addColumns([countExpr]))
      .getSingle();
  return (count.read(countExpr) ?? 0) == 0;
}

/// Seeds the local database with rich dev data if it is empty.
///
/// Call from app startup or a debug menu. Skips seeding if data already exists.
Future<void> seedLocalDatabase(LocalDatabase db, {bool force = false}) async {
  if (!force && !await _isDatabaseEmpty(db)) return;

  final catalogRepo = CatalogCacheRepository(db);
  final ownedRepo = OwnedItemsCacheRepository(db);
  final trackingRepo = TrackingEntriesCacheRepository(db);
  final imagesRepo = ItemImagesCacheRepository(db);
  final pickListRepo = PickListRepository(db);
  final customFieldRepo = CustomFieldRepository(db);

  // --- Catalog Items ---
  final allItems = <CatalogItem>[
    ..._movieItems(),
    ..._tvItems(),
    ..._animeItems(),
    ..._mangaItems(),
    ..._bookItems(),
    ..._musicItems(),
    ..._gameItems(),
    ..._boardgameItems(),
    ..._comicItems(),
  ];

  // upsertAll also auto-populates SeriesRegistry & PickLists from catalog data
  await catalogRepo.upsertAll(allItems);

  // --- Owned Items ---
  final ownedItems = _ownedItems();
  await ownedRepo.upsertAll(ownedItems);

  // --- Item Images (front/back + extras) ---
  await _seedItemImages(imagesRepo, ownedItems);

  // --- Tracking Entries ---
  final trackingEntries = _trackingEntries();
  await trackingRepo.upsertAll(trackingEntries);

  // --- Pick Lists (supplement with extra values) ---
  await _seedPickLists(pickListRepo);

  // --- Custom Fields ---
  await _seedCustomFields(customFieldRepo);
}

// ==========================================================================
//  MOVIES (10)
// ==========================================================================
List<CatalogItem> _movieItems() => [
      CatalogItem(
        id: 'seed-movie-01',
        kind: 'movie',
        title: 'Batman Begins',
        displayTitle: 'Batman Begins (2005)',
        synopsis:
            'After witnessing his parents\' murder, Bruce Wayne trains to become a symbol of justice.',
        publisher: 'Warner Bros.',
        releaseYear: 2005,
        releaseDate: DateTime.utc(2005, 6, 15),
        coverImageUrl: 'https://placehold.co/300x450?text=Batman+Begins',
        thumbnailImageUrl: 'https://placehold.co/100x150?text=BB',
        editionTitle: '4K UHD',
        physicalFormat: '4K UHD',
        physicalFormatLabel: '4K Ultra HD Blu-ray',
        barcode: '012569593763',
        variant: '4K UHD',
        country: 'US',
        language: 'en',
        ageRating: 'PG-13',
        sortKey: 'dark-knight-trilogy-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-dark-knight',
          seriesTitle: 'The Dark Knight Trilogy',
          volumeName: 'The Dark Knight Trilogy',
          volumeNumber: 1,
          volumeStartYear: 2005,
          tags: ['superhero', 'action', 'thriller', 'origin story'],
        ),
        video: const VideoCatalogDetails(
          runtimeMinutes: 140,
          color: 'Color',
          nrDiscs: 1,
          screenRatio: '2.39:1',
          audioTracks: 'English DTS-HD MA 5.1, French DD 5.1',
          subtitles: 'English SDH, French, Spanish',
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 2999,
          currency: 'USD',
          imprint: 'DC Films',
        ),
        creators: [
          {'name': 'Christopher Nolan', 'role': 'director'},
          {'name': 'Hans Zimmer', 'role': 'composer'},
          {'name': 'David S. Goyer', 'role': 'writer'},
        ],
        characters: ['Bruce Wayne', 'Ra\'s al Ghul', 'Alfred Pennyworth'],
        storyArcs: ['Batman\'s Origin'],
        genres: ['superhero', 'action', 'thriller'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-bb-dvd',
            title: 'DVD',
            format: 'DVD',
            publisher: 'Warner Bros.',
            releaseDate: DateTime.utc(2005, 10, 18),
            region: 'US',
            variants: [
              CatalogVariant(
                id: 'seed-var-bb-dvd',
                name: 'DVD',
                variantType: 'physical',
                coverPriceCents: 1999,
                currency: 'USD',
                barcode: '012569593763',
              ),
            ],
          ),
          CatalogEdition(
            id: 'seed-ed-bb-4k',
            title: '4K UHD',
            format: '4K UHD',
            publisher: 'Warner Bros.',
            releaseDate: DateTime.utc(2017, 12, 19),
            region: 'US',
            variants: [
              CatalogVariant(
                id: 'seed-var-bb-4k',
                name: '4K UHD',
                variantType: 'physical',
                coverPriceCents: 2999,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      CatalogItem(
        id: 'seed-movie-02',
        kind: 'movie',
        title: 'The Dark Knight',
        synopsis:
            'Batman faces the Joker, a criminal mastermind who seeks to plunge Gotham into anarchy.',
        publisher: 'Warner Bros.',
        releaseYear: 2008,
        releaseDate: DateTime.utc(2008, 7, 18),
        editionTitle: 'Blu-ray',
        physicalFormat: 'Blu-ray',
        country: 'US',
        language: 'en',
        ageRating: 'PG-13',
        sortKey: 'dark-knight-trilogy-0002',
        itemNumber: '2',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-dark-knight',
          seriesTitle: 'The Dark Knight Trilogy',
          volumeName: 'The Dark Knight Trilogy',
          volumeNumber: 1,
          volumeStartYear: 2005,
        ),
        video: const VideoCatalogDetails(runtimeMinutes: 152),
        creators: [
          {'name': 'Christopher Nolan', 'role': 'director'},
          {'name': 'Heath Ledger', 'role': 'actor'},
        ],
        characters: ['Bruce Wayne', 'The Joker', 'Harvey Dent'],
        genres: ['superhero', 'crime', 'thriller'],
      ),
      CatalogItem(
        id: 'seed-movie-03',
        kind: 'movie',
        title: 'Blade Runner',
        synopsis:
            'A blade runner must pursue and terminate four replicants who have returned to Earth.',
        publisher: 'Warner Bros.',
        releaseYear: 1982,
        releaseDate: DateTime.utc(1982, 6, 25),
        editionTitle: 'The Final Cut',
        physicalFormat: 'Blu-ray',
        country: 'US',
        language: 'en',
        ageRating: 'R',
        sortKey: 'blade-runner-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-blade-runner',
          seriesTitle: 'Blade Runner',
          tags: ['sci-fi', 'noir', 'dystopia', 'cyberpunk'],
        ),
        video: const VideoCatalogDetails(
            runtimeMinutes: 117, screenRatio: '2.39:1'),
        creators: [
          {'name': 'Ridley Scott', 'role': 'director'},
          {'name': 'Vangelis', 'role': 'composer'},
        ],
        characters: ['Rick Deckard', 'Roy Batty', 'Rachael'],
        storyArcs: ['Replicant Hunt'],
        genres: ['sci-fi', 'noir'],
      ),
      CatalogItem(
        id: 'seed-movie-04',
        kind: 'movie',
        title: 'Interstellar',
        synopsis:
            'A team of explorers travel through a wormhole in space to ensure humanity\'s survival.',
        publisher: 'Paramount Pictures',
        releaseYear: 2014,
        releaseDate: DateTime.utc(2014, 11, 7),
        physicalFormat: 'Blu-ray',
        country: 'US',
        language: 'en',
        sortKey: 'interstellar-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-interstellar',
          seriesTitle: 'Interstellar',
        ),
        video: const VideoCatalogDetails(runtimeMinutes: 169),
        creators: [
          {'name': 'Christopher Nolan', 'role': 'director'},
          {'name': 'Hans Zimmer', 'role': 'composer'},
        ],
        characters: ['Cooper', 'Murph', 'Dr. Brand'],
        genres: ['sci-fi', 'drama', 'space'],
      ),
      CatalogItem(
        id: 'seed-movie-05',
        kind: 'movie',
        title: 'Mad Max: Fury Road',
        synopsis:
            'In a post-apocalyptic wasteland, Max teams up with Furiosa to escape a tyrannical warlord.',
        publisher: 'Warner Bros.',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 5, 15),
        country: 'US',
        ageRating: 'R',
        sortKey: 'mad-max-0004',
        video: const VideoCatalogDetails(runtimeMinutes: 120),
        creators: [
          {'name': 'George Miller', 'role': 'director'},
        ],
        characters: ['Max Rockatansky', 'Furiosa', 'Immortan Joe'],
        genres: ['action', 'post-apocalyptic'],
      ),
      CatalogItem(
        id: 'seed-movie-06',
        kind: 'movie',
        title: 'Alien',
        synopsis:
            'The crew of a commercial spacecraft encounters a deadly lifeform after investigating a distress signal.',
        publisher: '20th Century Fox',
        releaseYear: 1979,
        releaseDate: DateTime.utc(1979, 5, 25),
        country: 'US',
        ageRating: 'R',
        sortKey: 'alien-0001',
        video: const VideoCatalogDetails(runtimeMinutes: 117),
        creators: [
          {'name': 'Ridley Scott', 'role': 'director'},
          {'name': 'Dan O\'Bannon', 'role': 'writer'},
        ],
        characters: ['Ellen Ripley', 'Xenomorph', 'Dallas'],
        storyArcs: ['Xenomorph Saga'],
        genres: ['sci-fi', 'horror'],
      ),
      CatalogItem(
        id: 'seed-movie-07',
        kind: 'movie',
        title: 'Aliens',
        synopsis:
            'Ripley returns to the planet where her crew encountered the hostile alien creature.',
        publisher: '20th Century Fox',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 7, 18),
        country: 'US',
        ageRating: 'R',
        sortKey: 'alien-0002',
        video: const VideoCatalogDetails(runtimeMinutes: 137),
        creators: [
          {'name': 'James Cameron', 'role': 'director'},
        ],
        characters: ['Ellen Ripley', 'Newt', 'Xenomorph Queen'],
        storyArcs: ['Xenomorph Saga'],
        genres: ['sci-fi', 'action', 'horror'],
      ),
      CatalogItem(
        id: 'seed-movie-08',
        kind: 'movie',
        title: 'The Matrix',
        synopsis:
            'A computer hacker learns about the true nature of reality and his role in the war against its controllers.',
        publisher: 'Warner Bros.',
        releaseYear: 1999,
        releaseDate: DateTime.utc(1999, 3, 31),
        editionTitle: '4K UHD',
        physicalFormat: '4K UHD',
        barcode: '883929567553',
        country: 'US',
        language: 'en',
        ageRating: 'R',
        sortKey: 'the-matrix-0001',
        video: const VideoCatalogDetails(runtimeMinutes: 136),
        creators: [
          {'name': 'The Wachowskis', 'role': 'director'},
          {'name': 'Keanu Reeves', 'role': 'actor'},
        ],
        characters: ['Neo', 'Morpheus', 'Agent Smith', 'Trinity'],
        genres: ['sci-fi', 'action', 'cyberpunk'],
      ),
      CatalogItem(
        id: 'seed-movie-09',
        kind: 'movie',
        title: 'The Dark Knight Rises',
        synopsis:
            'Eight years after the Joker\'s reign, Bane forces Batman out of exile.',
        publisher: 'Warner Bros.',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 7, 20),
        country: 'US',
        ageRating: 'PG-13',
        sortKey: 'dark-knight-trilogy-0003',
        itemNumber: '3',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-dark-knight',
          seriesTitle: 'The Dark Knight Trilogy',
          volumeNumber: 1,
          volumeStartYear: 2005,
        ),
        video: const VideoCatalogDetails(runtimeMinutes: 165),
        creators: [
          {'name': 'Christopher Nolan', 'role': 'director'},
          {'name': 'Tom Hardy', 'role': 'actor'},
        ],
        characters: ['Bruce Wayne', 'Bane', 'Selina Kyle'],
        genres: ['superhero', 'action'],
      ),
      CatalogItem(
        id: 'seed-movie-10',
        kind: 'movie',
        title: 'Blade Runner 2049',
        synopsis:
            'A young blade runner\'s discovery of a secret leads him to seek out the former blade runner.',
        publisher: 'Columbia Pictures',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 10, 6),
        country: 'US',
        ageRating: 'R',
        sortKey: 'blade-runner-0002',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-blade-runner',
          seriesTitle: 'Blade Runner',
        ),
        video: const VideoCatalogDetails(runtimeMinutes: 164),
        creators: [
          {'name': 'Denis Villeneuve', 'role': 'director'},
          {'name': 'Roger Deakins', 'role': 'cinematographer'},
        ],
        characters: ['Officer K', 'Rick Deckard', 'Niander Wallace'],
        genres: ['sci-fi', 'noir', 'cyberpunk'],
      ),
    ];

// ==========================================================================
//  BOOKS (10)
// ==========================================================================
List<CatalogItem> _bookItems() => [
      CatalogItem(
        id: 'seed-book-01',
        kind: 'book',
        title: 'Dune',
        synopsis:
            'A noble family becomes embroiled in a war for control of the most valuable substance in the universe.',
        publisher: 'Chilton Books',
        releaseYear: 1965,
        releaseDate: DateTime.utc(1965, 8, 1),
        editionTitle: 'Mass Market Paperback',
        physicalFormat: 'Paperback',
        physicalFormatLabel: 'Mass Market Paperback',
        barcode: '9780441172719',
        country: 'US',
        language: 'en',
        ageRating: 'Adult',
        sortKey: 'dune-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-dune',
          seriesTitle: 'Dune',
          volumeName: 'Dune',
          volumeNumber: 1,
          volumeStartYear: 1965,
          tags: ['sci-fi', 'politics', 'ecology', 'space opera'],
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 412,
          coverPriceCents: 999,
          currency: 'USD',
          imprint: 'Ace',
        ),
        creators: [
          {'name': 'Frank Herbert', 'role': 'author'},
        ],
        characters: [
          'Paul Atreides',
          'Duke Leto Atreides',
          'Baron Harkonnen',
          'Lady Jessica',
        ],
        storyArcs: ['Arrakis Saga'],
        genres: ['sci-fi', 'politics', 'space opera'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-dune-pb',
            title: 'Mass Market Paperback',
            format: 'Paperback',
            publisher: 'Ace Books',
            isbn: '9780441172719',
            releaseDate: DateTime.utc(1990, 9, 1),
            variants: [
              CatalogVariant(
                id: 'seed-var-dune-pb',
                name: 'Paperback',
                variantType: 'physical',
                isbn: '9780441172719',
                coverPriceCents: 999,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      CatalogItem(
        id: 'seed-book-02',
        kind: 'book',
        title: 'Dune Messiah',
        synopsis:
            'Paul Atreides faces a conspiracy to overthrow him twelve years after becoming Emperor.',
        publisher: 'Chilton Books',
        releaseYear: 1969,
        releaseDate: DateTime.utc(1969, 10, 1),
        sortKey: 'dune-0002',
        itemNumber: '2',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-dune',
          seriesTitle: 'Dune',
          volumeNumber: 1,
        ),
        publishing: const CatalogPublishingDetails(pageCount: 256),
        creators: [
          {'name': 'Frank Herbert', 'role': 'author'},
        ],
        characters: ['Paul Atreides', 'Alia Atreides', 'Chani'],
        storyArcs: ['Arrakis Saga'],
        genres: ['sci-fi', 'politics'],
      ),
      CatalogItem(
        id: 'seed-book-03',
        kind: 'book',
        title: 'Foundation',
        synopsis:
            'A mathematician predicts the fall of the Galactic Empire and creates a plan to preserve knowledge.',
        publisher: 'Gnome Press',
        releaseYear: 1951,
        releaseDate: DateTime.utc(1951, 5, 1),
        sortKey: 'foundation-0001',
        publishing: const CatalogPublishingDetails(
          pageCount: 244,
          coverPriceCents: 899,
          currency: 'USD',
          imprint: 'Spectra',
        ),
        creators: [
          {'name': 'Isaac Asimov', 'role': 'author'},
        ],
        characters: ['Hari Seldon', 'Salvor Hardin'],
        genres: ['sci-fi', 'galactic empire'],
      ),
      CatalogItem(
        id: 'seed-book-04',
        kind: 'book',
        title: '1984',
        synopsis:
            'In a totalitarian future, a man rebels against the oppressive government that controls every aspect of life.',
        publisher: 'Secker & Warburg',
        releaseYear: 1949,
        releaseDate: DateTime.utc(1949, 6, 8),
        country: 'GB',
        language: 'en',
        sortKey: 'nineteen-eighty-four-0001',
        publishing: const CatalogPublishingDetails(
          pageCount: 328,
          imprint: 'Penguin Classics',
        ),
        creators: [
          {'name': 'George Orwell', 'role': 'author'},
        ],
        characters: ['Winston Smith', 'Big Brother', 'Julia', 'O\'Brien'],
        genres: ['dystopia', 'political fiction', 'classic'],
      ),
      CatalogItem(
        id: 'seed-book-05',
        kind: 'book',
        title: 'Neuromancer',
        synopsis:
            'A washed-up computer hacker is hired for one last job in a world of artificial intelligence.',
        publisher: 'Ace Books',
        releaseYear: 1984,
        releaseDate: DateTime.utc(1984, 7, 1),
        sortKey: 'sprawl-trilogy-0001',
        publishing: const CatalogPublishingDetails(pageCount: 271),
        creators: [
          {'name': 'William Gibson', 'role': 'author'},
        ],
        characters: ['Case', 'Molly Millions', 'Wintermute'],
        genres: ['cyberpunk', 'sci-fi'],
      ),
      CatalogItem(
        id: 'seed-book-06',
        kind: 'book',
        title: 'The Hitchhiker\'s Guide to the Galaxy',
        synopsis:
            'Seconds before Earth is destroyed, Arthur Dent is saved by his friend Ford Prefect.',
        publisher: 'Pan Books',
        releaseYear: 1979,
        releaseDate: DateTime.utc(1979, 10, 12),
        country: 'GB',
        sortKey: 'hitchhikers-guide-0001',
        publishing: const CatalogPublishingDetails(pageCount: 180),
        creators: [
          {'name': 'Douglas Adams', 'role': 'author'},
        ],
        characters: [
          'Arthur Dent',
          'Ford Prefect',
          'Zaphod Beeblebrox',
          'Marvin',
        ],
        genres: ['sci-fi', 'comedy', 'satire'],
      ),
      CatalogItem(
        id: 'seed-book-07',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        synopsis:
            'A hobbit inherits a ring of power and begins a journey to destroy it.',
        publisher: 'George Allen & Unwin',
        releaseYear: 1954,
        releaseDate: DateTime.utc(1954, 7, 29),
        country: 'GB',
        sortKey: 'lord-of-the-rings-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-lotr',
          seriesTitle: 'The Lord of the Rings',
          volumeName: 'The Lord of the Rings',
          volumeNumber: 1,
          volumeStartYear: 1954,
          tags: ['fantasy', 'epic', 'quest'],
        ),
        publishing: const CatalogPublishingDetails(pageCount: 423),
        creators: [
          {'name': 'J.R.R. Tolkien', 'role': 'author'},
        ],
        characters: ['Frodo Baggins', 'Gandalf', 'Aragorn', 'Sauron'],
        storyArcs: ['War of the Ring'],
        genres: ['fantasy', 'epic'],
      ),
      CatalogItem(
        id: 'seed-book-08',
        kind: 'book',
        title: 'The Two Towers',
        synopsis:
            'The fellowship is broken as war spreads and the quest to destroy the ring continues.',
        publisher: 'George Allen & Unwin',
        releaseYear: 1954,
        releaseDate: DateTime.utc(1954, 11, 11),
        country: 'GB',
        sortKey: 'lord-of-the-rings-0002',
        itemNumber: '2',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-lotr',
          seriesTitle: 'The Lord of the Rings',
          volumeNumber: 1,
        ),
        publishing: const CatalogPublishingDetails(pageCount: 352),
        creators: [
          {'name': 'J.R.R. Tolkien', 'role': 'author'},
        ],
        characters: ['Frodo Baggins', 'Samwise Gamgee', 'Gollum'],
        storyArcs: ['War of the Ring'],
        genres: ['fantasy', 'epic', 'war'],
      ),
      CatalogItem(
        id: 'seed-book-09',
        kind: 'book',
        title: 'The Return of the King',
        synopsis:
            'The final battle for Middle-earth begins while Frodo approaches Mount Doom.',
        publisher: 'George Allen & Unwin',
        releaseYear: 1955,
        releaseDate: DateTime.utc(1955, 10, 20),
        country: 'GB',
        sortKey: 'lord-of-the-rings-0003',
        itemNumber: '3',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-lotr',
          seriesTitle: 'The Lord of the Rings',
          volumeNumber: 1,
        ),
        publishing: const CatalogPublishingDetails(pageCount: 416),
        creators: [
          {'name': 'J.R.R. Tolkien', 'role': 'author'},
        ],
        characters: ['Frodo Baggins', 'Aragorn', 'Sauron'],
        storyArcs: ['War of the Ring'],
        genres: ['fantasy', 'epic'],
      ),
      CatalogItem(
        id: 'seed-book-10',
        kind: 'book',
        title: 'The Martian',
        synopsis:
            'An astronaut must rely on his ingenuity to survive alone on Mars after being presumed dead.',
        publisher: 'Crown Publishing',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 3, 1),
        sortKey: 'the-martian-0001',
        publishing: const CatalogPublishingDetails(
          pageCount: 369,
          coverPriceCents: 2400,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Andy Weir', 'role': 'author'},
        ],
        characters: ['Mark Watney', 'Melissa Lewis'],
        genres: ['sci-fi', 'survival', 'humor'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-martian-hc',
            title: 'Hardcover',
            format: 'Hardcover',
            publisher: 'Crown',
            isbn: '9780804139021',
            releaseDate: DateTime.utc(2014, 2, 11),
            variants: [
              CatalogVariant(
                id: 'seed-var-martian-hc',
                name: 'Hardcover',
                variantType: 'physical',
                isbn: '9780804139021',
                coverPriceCents: 2400,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    ];

// ==========================================================================
//  MUSIC (10)
// ==========================================================================
List<CatalogItem> _musicItems() => [
      CatalogItem(
        id: 'seed-music-01',
        kind: 'music',
        title: 'OK Computer',
        synopsis:
            'Radiohead\'s seminal third album exploring themes of modern alienation.',
        publisher: 'Parlophone',
        releaseYear: 1997,
        releaseDate: DateTime.utc(1997, 5, 21),
        editionTitle: 'Vinyl LP',
        physicalFormat: 'Vinyl',
        barcode: '724385522925',
        country: 'GB',
        language: 'en',
        sortKey: 'radiohead-0003',
        itemNumber: '3',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-radiohead',
          seriesTitle: 'Radiohead',
          tags: ['alternative rock', 'art rock'],
        ),
        music: const MusicCatalogDetails(
          trackCount: 12,
          catalogNumber: 'CDNODATA 02',
          tracks: [
            CatalogTrack(title: 'Airbag', position: 1, durationSeconds: 287),
            CatalogTrack(
                title: 'Paranoid Android', position: 2, durationSeconds: 386),
            CatalogTrack(
                title: 'Subterranean Homesick Alien',
                position: 3,
                durationSeconds: 267),
            CatalogTrack(
                title: 'Exit Music (For a Film)',
                position: 4,
                durationSeconds: 261),
            CatalogTrack(title: 'Let Down', position: 5, durationSeconds: 298),
            CatalogTrack(
                title: 'Karma Police', position: 6, durationSeconds: 264),
          ],
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 2499,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Thom Yorke', 'role': 'vocalist'},
          {'name': 'Jonny Greenwood', 'role': 'guitarist'},
          {'name': 'Nigel Godrich', 'role': 'producer'},
        ],
        genres: ['alternative rock', 'art rock', 'electronic'],
      ),
      CatalogItem(
        id: 'seed-music-02',
        kind: 'music',
        title: 'Kid A',
        synopsis:
            'Radiohead\'s radical departure into electronic and experimental territory.',
        publisher: 'XL Recordings',
        releaseYear: 2000,
        releaseDate: DateTime.utc(2000, 10, 2),
        sortKey: 'radiohead-0004',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-radiohead',
          seriesTitle: 'Radiohead',
        ),
        music: const MusicCatalogDetails(trackCount: 10),
        creators: [
          {'name': 'Thom Yorke', 'role': 'vocalist'},
          {'name': 'Nigel Godrich', 'role': 'producer'},
        ],
        genres: ['electronic', 'experimental'],
      ),
      CatalogItem(
        id: 'seed-music-03',
        kind: 'music',
        title: 'The Dark Side of the Moon',
        synopsis:
            'A concept album exploring conflict, greed, time, death, and mental illness.',
        publisher: 'Harvest',
        releaseYear: 1973,
        releaseDate: DateTime.utc(1973, 3, 1),
        country: 'GB',
        sortKey: 'pink-floyd-0008',
        music: const MusicCatalogDetails(
          trackCount: 10,
          catalogNumber: 'SHVL 804',
        ),
        creators: [
          {'name': 'Roger Waters', 'role': 'bassist'},
          {'name': 'David Gilmour', 'role': 'guitarist'},
        ],
        storyArcs: ['The Human Condition'],
        genres: ['progressive rock', 'art rock', 'concept album'],
      ),
      CatalogItem(
        id: 'seed-music-04',
        kind: 'music',
        title: 'good kid, m.A.A.d city',
        synopsis:
            'A concept album following Kendrick\'s experiences growing up in Compton.',
        publisher: 'Top Dawg / Interscope',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 10, 22),
        country: 'US',
        sortKey: 'kendrick-lamar-0002',
        music: const MusicCatalogDetails(trackCount: 12),
        publishing: const CatalogPublishingDetails(
          imprint: 'Top Dawg Entertainment',
        ),
        creators: [
          {'name': 'Kendrick Lamar', 'role': 'artist'},
          {'name': 'Dr. Dre', 'role': 'producer'},
        ],
        storyArcs: ['Compton Chronicles'],
        genres: ['hip hop', 'concept album', 'west coast'],
      ),
      CatalogItem(
        id: 'seed-music-05',
        kind: 'music',
        title: 'To Pimp a Butterfly',
        synopsis:
            'An exploration of African-American culture, politics, and Kendrick\'s own struggles with fame.',
        publisher: 'Top Dawg / Interscope',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 3, 15),
        sortKey: 'kendrick-lamar-0003',
        music: const MusicCatalogDetails(trackCount: 16),
        creators: [
          {'name': 'Kendrick Lamar', 'role': 'artist'},
          {'name': 'Flying Lotus', 'role': 'producer'},
        ],
        genres: ['hip hop', 'funk', 'jazz rap'],
      ),
      CatalogItem(
        id: 'seed-music-06',
        kind: 'music',
        title: 'Discovery',
        synopsis:
            'A landmark electronic album blending house music with pop, funk, and disco.',
        publisher: 'Virgin',
        releaseYear: 2001,
        releaseDate: DateTime.utc(2001, 3, 12),
        country: 'FR',
        language: 'fr',
        sortKey: 'daft-punk-0003',
        music: const MusicCatalogDetails(trackCount: 14),
        creators: [
          {'name': 'Thomas Bangalter', 'role': 'artist'},
          {'name': 'Guy-Manuel de Homem-Christo', 'role': 'artist'},
        ],
        genres: ['electronic', 'house', 'french touch'],
      ),
      CatalogItem(
        id: 'seed-music-07',
        kind: 'music',
        title: 'Kind of Blue',
        synopsis:
            'The best-selling jazz album of all time, a masterclass in modal jazz.',
        publisher: 'Columbia',
        releaseYear: 1959,
        releaseDate: DateTime.utc(1959, 8, 17),
        country: 'US',
        sortKey: 'miles-davis-0005',
        music: const MusicCatalogDetails(
          trackCount: 5,
          catalogNumber: 'CL 1355',
        ),
        creators: [
          {'name': 'Miles Davis', 'role': 'artist'},
          {'name': 'John Coltrane', 'role': 'saxophonist'},
          {'name': 'Bill Evans', 'role': 'pianist'},
        ],
        genres: ['jazz', 'modal jazz', 'cool jazz'],
      ),
      CatalogItem(
        id: 'seed-music-08',
        kind: 'music',
        title: 'Homogenic',
        synopsis:
            'A dense, emotional album blending electronic beats with orchestral strings.',
        publisher: 'One Little Indian',
        releaseYear: 1997,
        releaseDate: DateTime.utc(1997, 9, 22),
        country: 'IS',
        sortKey: 'bjork-0003',
        music: const MusicCatalogDetails(trackCount: 10),
        creators: [
          {'name': 'Björk', 'role': 'artist'},
          {'name': 'Mark Bell', 'role': 'producer'},
        ],
        genres: ['electronic', 'experimental', 'trip hop'],
      ),
      CatalogItem(
        id: 'seed-music-09',
        kind: 'music',
        title: 'Mezzanine',
        synopsis:
            'A dark, brooding trip-hop masterpiece featuring Teardrop and Angel.',
        publisher: 'Wild Bunch / Virgin',
        releaseYear: 1998,
        releaseDate: DateTime.utc(1998, 4, 20),
        country: 'GB',
        sortKey: 'massive-attack-0003',
        music: const MusicCatalogDetails(trackCount: 11),
        creators: [
          {'name': 'Robert Del Naja', 'role': 'artist'},
          {'name': 'Grant Marshall', 'role': 'artist'},
        ],
        genres: ['trip hop', 'electronic', 'dark ambient'],
      ),
      CatalogItem(
        id: 'seed-music-10',
        kind: 'music',
        title: 'Dummy',
        synopsis:
            'The definitive trip-hop debut, fusing hip-hop beats with cinematic string arrangements.',
        publisher: 'Go! Beat',
        releaseYear: 1994,
        releaseDate: DateTime.utc(1994, 8, 22),
        country: 'GB',
        sortKey: 'portishead-0001',
        music: const MusicCatalogDetails(trackCount: 11),
        creators: [
          {'name': 'Beth Gibbons', 'role': 'vocalist'},
          {'name': 'Geoff Barrow', 'role': 'producer'},
        ],
        genres: ['trip hop', 'downtempo', 'cinematic'],
      ),
    ];

// ==========================================================================
//  GAMES (10)
// ==========================================================================
List<CatalogItem> _gameItems() => [
      CatalogItem(
        id: 'seed-game-01',
        kind: 'game',
        title: 'The Witcher 3: Wild Hunt',
        synopsis:
            'Geralt of Rivia sets out to find his adopted daughter in a war-torn fantasy world.',
        publisher: 'CD Projekt Red',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 5, 19),
        editionTitle: 'GOTY PS4',
        physicalFormat: 'PS4',
        country: 'PL',
        ageRating: 'M',
        sortKey: 'the-witcher-0003',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-witcher',
          seriesTitle: 'The Witcher',
          tags: ['RPG', 'open world', 'fantasy'],
        ),
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 4999,
          currency: 'USD',
        ),
        creators: [
          {'name': 'CD Projekt Red', 'role': 'developer'},
          {'name': 'Konrad Tomaszkiewicz', 'role': 'director'},
        ],
        characters: [
          'Geralt of Rivia',
          'Ciri',
          'Yennefer',
          'The Wild Hunt',
        ],
        storyArcs: ['Wild Hunt Pursuit'],
        rawPlatforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        genres: ['RPG', 'open world', 'fantasy'],
      ),
      CatalogItem(
        id: 'seed-game-02',
        kind: 'game',
        title: 'Dark Souls',
        synopsis:
            'An action RPG set in a dark fantasy world, known for its difficulty and deep lore.',
        publisher: 'FromSoftware',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 9, 22),
        sortKey: 'dark-souls-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS3', 'Xbox 360'],
        ),
        creators: [
          {'name': 'Hidetaka Miyazaki', 'role': 'director'},
        ],
        characters: ['Chosen Undead', 'Solaire', 'Gwyn'],
        storyArcs: ['Age of Fire'],
        rawPlatforms: ['PC', 'PS3', 'Xbox 360'],
        genres: ['RPG', 'action', 'souls-like'],
      ),
      CatalogItem(
        id: 'seed-game-03',
        kind: 'game',
        title: 'Dark Souls III',
        synopsis:
            'The final entry in the Dark Souls trilogy, featuring faster combat.',
        publisher: 'FromSoftware',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 3, 24),
        sortKey: 'dark-souls-0003',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One'],
        ),
        creators: [
          {'name': 'Hidetaka Miyazaki', 'role': 'director'},
        ],
        characters: ['Ashen One', 'Fire Keeper', 'Soul of Cinder'],
        rawPlatforms: ['PC', 'PS4', 'Xbox One'],
        genres: ['RPG', 'action', 'souls-like'],
      ),
      CatalogItem(
        id: 'seed-game-04',
        kind: 'game',
        title: 'Elden Ring',
        synopsis:
            'An open-world action RPG set in the Lands Between, created with George R. R. Martin.',
        publisher: 'FromSoftware',
        releaseYear: 2022,
        releaseDate: DateTime.utc(2022, 2, 25),
        editionTitle: 'Standard PS5',
        physicalFormat: 'PS5',
        ageRating: 'M',
        sortKey: 'elden-ring-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Xbox One'],
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 5999,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Hidetaka Miyazaki', 'role': 'director'},
          {'name': 'George R.R. Martin', 'role': 'world builder'},
        ],
        characters: ['Tarnished', 'Melina', 'Radahn', 'Ranni'],
        rawPlatforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Xbox One'],
        genres: ['RPG', 'open world', 'souls-like'],
      ),
      CatalogItem(
        id: 'seed-game-05',
        kind: 'game',
        title: 'Hollow Knight',
        synopsis:
            'A 2D metroidvania through a vast underground kingdom of insects and heroes.',
        publisher: 'Team Cherry',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 2, 24),
        country: 'AU',
        sortKey: 'hollow-knight-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        ),
        creators: [
          {'name': 'Team Cherry', 'role': 'developer'},
          {'name': 'Christopher Larkin', 'role': 'composer'},
        ],
        characters: [
          'The Knight',
          'Hornet',
          'The Hollow Knight',
          'The Radiance',
        ],
        rawPlatforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        genres: ['metroidvania', 'indie', 'platformer'],
      ),
      CatalogItem(
        id: 'seed-game-06',
        kind: 'game',
        title: 'Disco Elysium',
        synopsis:
            'An amnesiac detective solves a murder in a city torn by political conflict.',
        publisher: 'ZA/UM',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 10, 15),
        country: 'EE',
        sortKey: 'disco-elysium-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Switch'],
        ),
        creators: [
          {'name': 'Robert Kurvitz', 'role': 'designer'},
        ],
        characters: ['Harry Du Bois', 'Kim Kitsuragi', 'The Deserter'],
        rawPlatforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Switch'],
        genres: ['RPG', 'detective', 'narrative'],
      ),
      CatalogItem(
        id: 'seed-game-07',
        kind: 'game',
        title: 'Hades',
        synopsis:
            'Zagreus, prince of the Underworld, tries to escape his father\'s domain.',
        publisher: 'Supergiant Games',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 9, 17),
        sortKey: 'hades-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Switch'],
        ),
        creators: [
          {'name': 'Supergiant Games', 'role': 'developer'},
          {'name': 'Darren Korb', 'role': 'composer'},
        ],
        characters: ['Zagreus', 'Hades', 'Megaera', 'Thanatos'],
        rawPlatforms: ['PC', 'PS5', 'PS4', 'Xbox Series', 'Switch'],
        genres: ['roguelike', 'action', 'mythology'],
      ),
      CatalogItem(
        id: 'seed-game-08',
        kind: 'game',
        title: 'Outer Wilds',
        synopsis: 'An astronaut explores a solar system stuck in a time loop.',
        publisher: 'Mobius Digital',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 5, 28),
        sortKey: 'outer-wilds-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One'],
        ),
        creators: [
          {'name': 'Mobius Digital', 'role': 'developer'},
          {'name': 'Andrew Prahlow', 'role': 'composer'},
        ],
        characters: ['Hearthian', 'Solanum'],
        rawPlatforms: ['PC', 'PS4', 'Xbox One'],
        genres: ['exploration', 'puzzle', 'time loop'],
      ),
      CatalogItem(
        id: 'seed-game-09',
        kind: 'game',
        title: 'Baldur\'s Gate 3',
        synopsis:
            'A party-based RPG set in the Forgotten Realms, featuring a story of parasitic mind flayers.',
        publisher: 'Larian Studios',
        releaseYear: 2023,
        releaseDate: DateTime.utc(2023, 8, 3),
        editionTitle: 'Deluxe PS5',
        physicalFormat: 'PS5',
        ageRating: 'M',
        sortKey: 'baldurs-gate-0003',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS5', 'Xbox Series'],
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 7999,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Larian Studios', 'role': 'developer'},
          {'name': 'Swen Vincke', 'role': 'director'},
        ],
        characters: ['Tav', 'Shadowheart', 'Astarion', 'The Absolute'],
        storyArcs: ['Illithid Invasion'],
        rawPlatforms: ['PC', 'PS5', 'Xbox Series'],
        genres: ['RPG', 'turn-based', 'D&D'],
      ),
      CatalogItem(
        id: 'seed-game-10',
        kind: 'game',
        title: 'Celeste',
        synopsis:
            'A young woman named Madeline climbs Celeste Mountain while battling her inner demons.',
        publisher: 'Matt Makes Games',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 1, 25),
        sortKey: 'celeste-0001',
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        ),
        creators: [
          {'name': 'Maddy Thorson', 'role': 'designer'},
          {'name': 'Lena Raine', 'role': 'composer'},
        ],
        characters: ['Madeline', 'Badeline', 'Theo'],
        rawPlatforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        genres: ['platformer', 'indie', 'precision'],
      ),
    ];

// ==========================================================================
//  BOARD GAMES (10)
// ==========================================================================
List<CatalogItem> _boardgameItems() => [
      CatalogItem(
        id: 'seed-boardgame-01',
        kind: 'boardgame',
        title: 'Gloomhaven',
        synopsis:
            'A cooperative dungeon-crawling board game with branching narrative and tactical combat.',
        publisher: 'Cephalofair Games',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 4, 1),
        editionTitle: '2nd Printing',
        physicalFormat: 'Board Game',
        ageRating: '14+',
        sortKey: 'gloomhaven-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-gloomhaven',
          seriesTitle: 'Gloomhaven',
          tags: ['cooperative', 'dungeon crawl', 'campaign'],
        ),
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 14000,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Isaac Childres', 'role': 'designer'},
        ],
        characters: ['Brute', 'Spellweaver', 'Scoundrel'],
        genres: ['cooperative', 'dungeon crawl', 'tactical'],
      ),
      CatalogItem(
        id: 'seed-boardgame-02',
        kind: 'boardgame',
        title: 'Gloomhaven: Jaws of the Lion',
        synopsis: 'A standalone prequel to Gloomhaven with simplified rules.',
        publisher: 'Cephalofair Games',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 6, 18),
        sortKey: 'gloomhaven-0002',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-gloomhaven',
          seriesTitle: 'Gloomhaven',
        ),
        creators: [
          {'name': 'Isaac Childres', 'role': 'designer'},
        ],
        characters: ['Valrath Red Guard', 'Inox Hatchet'],
        genres: ['cooperative', 'dungeon crawl'],
      ),
      CatalogItem(
        id: 'seed-boardgame-03',
        kind: 'boardgame',
        title: 'Wingspan',
        synopsis: 'A competitive bird-collection engine-building board game.',
        publisher: 'Stonemaier Games',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 3, 8),
        ageRating: '10+',
        sortKey: 'wingspan-0001',
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 6500,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Elizabeth Hargrave', 'role': 'designer'},
        ],
        genres: ['engine building', 'card game', 'nature'],
      ),
      CatalogItem(
        id: 'seed-boardgame-04',
        kind: 'boardgame',
        title: 'Pandemic',
        synopsis:
            'A cooperative game where players work together to stop global outbreaks.',
        publisher: 'Z-Man Games',
        releaseYear: 2008,
        releaseDate: DateTime.utc(2008, 1, 1),
        sortKey: 'pandemic-0001',
        creators: [
          {'name': 'Matt Leacock', 'role': 'designer'},
        ],
        characters: ['Medic', 'Scientist', 'Researcher'],
        genres: ['cooperative', 'strategy'],
      ),
      CatalogItem(
        id: 'seed-boardgame-05',
        kind: 'boardgame',
        title: 'Pandemic Legacy: Season 1',
        synopsis:
            'A legacy-style Pandemic where each game permanently alters the board.',
        publisher: 'Z-Man Games',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 10, 8),
        sortKey: 'pandemic-0002',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-pandemic',
          seriesTitle: 'Pandemic',
        ),
        creators: [
          {'name': 'Matt Leacock', 'role': 'designer'},
          {'name': 'Rob Daviau', 'role': 'designer'},
        ],
        storyArcs: ['Legacy Campaign'],
        genres: ['cooperative', 'legacy', 'campaign'],
      ),
      CatalogItem(
        id: 'seed-boardgame-06',
        kind: 'boardgame',
        title: 'Terraforming Mars',
        synopsis:
            'Corporations compete to terraform Mars by raising temperature, oxygen, and ocean coverage.',
        publisher: 'FryxGames',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 10, 1),
        ageRating: '12+',
        country: 'SE',
        sortKey: 'terraforming-mars-0001',
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 6999,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Jacob Fryxelius', 'role': 'designer'},
        ],
        genres: ['engine building', 'science', 'corporate'],
      ),
      CatalogItem(
        id: 'seed-boardgame-07',
        kind: 'boardgame',
        title: 'Spirit Island',
        synopsis:
            'Spirits of the land work together to drive off colonizing invaders.',
        publisher: 'Greater Than Games',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 9, 22),
        sortKey: 'spirit-island-0001',
        creators: [
          {'name': 'R. Eric Reuss', 'role': 'designer'},
        ],
        characters: [
          'Lightning\'s Swift Strike',
          'River Surges in Sunlight',
        ],
        genres: ['cooperative', 'strategy', 'asymmetric'],
      ),
      CatalogItem(
        id: 'seed-boardgame-08',
        kind: 'boardgame',
        title: 'Root',
        synopsis:
            'An asymmetric war game where woodland factions battle for control of a vast forest.',
        publisher: 'Leder Games',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 8, 1),
        ageRating: '10+',
        sortKey: 'root-0001',
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 6000,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Cole Wehrle', 'role': 'designer'},
          {'name': 'Kyle Ferrin', 'role': 'artist'},
        ],
        characters: [
          'Marquise de Cat',
          'Eyrie Dynasties',
          'Woodland Alliance',
          'Vagabond',
        ],
        genres: ['asymmetric', 'war game', 'area control'],
      ),
      CatalogItem(
        id: 'seed-boardgame-09',
        kind: 'boardgame',
        title: 'Brass: Birmingham',
        synopsis:
            'Build industries and networks in Birmingham during the industrial revolution.',
        publisher: 'Roxley Games',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 12, 1),
        country: 'CA',
        sortKey: 'brass-0001',
        creators: [
          {'name': 'Gavan Brown', 'role': 'designer'},
          {'name': 'Martin Wallace', 'role': 'original designer'},
        ],
        genres: ['economic', 'network building', 'industrial'],
      ),
      CatalogItem(
        id: 'seed-boardgame-10',
        kind: 'boardgame',
        title: 'Scythe',
        synopsis:
            'An alternate-history 1920s strategy game featuring mechs and farming.',
        publisher: 'Stonemaier Games',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 8, 18),
        ageRating: '14+',
        sortKey: 'scythe-0001',
        publishing: const CatalogPublishingDetails(
          coverPriceCents: 8000,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Jamey Stegmaier', 'role': 'designer'},
          {'name': 'Jakub Różalski', 'role': 'artist'},
        ],
        characters: ['Anna & Wojtek', 'Gunter & Nacht'],
        genres: ['strategy', 'area control', 'alternate history'],
      ),
    ];

// ==========================================================================
//  COMICS (10)
// ==========================================================================
List<CatalogItem> _comicItems() => [
      CatalogItem(
        id: 'seed-comic-01',
        kind: 'comic',
        title: 'Saga',
        synopsis:
            'Two soldiers from opposite sides of a galactic war fall in love and become fugitives.',
        publisher: 'Image Comics',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 3, 14),
        editionTitle: 'Single Issue',
        physicalFormat: 'Single Issue',
        barcode: '70985302415600111',
        country: 'US',
        language: 'en',
        ageRating: 'Mature',
        sortKey: 'saga-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-saga',
          seriesTitle: 'Saga',
          volumeName: 'Saga',
          volumeNumber: 1,
          volumeStartYear: 2012,
          tags: ['sci-fi', 'fantasy', 'romance'],
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 44,
          coverPriceCents: 299,
          currency: 'USD',
          imprint: 'Image',
        ),
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Fiona Staples', 'role': 'artist'},
        ],
        characters: ['Alana', 'Marko', 'Hazel', 'The Will'],
        genres: ['sci-fi', 'fantasy', 'romance'],
      ),
      CatalogItem(
        id: 'seed-comic-02',
        kind: 'comic',
        title: 'Saga',
        displayTitle: 'Saga #2',
        synopsis: 'Alana and Marko flee with their newborn daughter.',
        publisher: 'Image Comics',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 4, 11),
        itemNumber: '2',
        sortKey: 'saga-0002',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-saga',
          seriesTitle: 'Saga',
          volumeNumber: 1,
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 32,
          coverPriceCents: 299,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Fiona Staples', 'role': 'artist'},
        ],
        characters: ['Alana', 'Marko', 'The Stalk'],
        genres: ['sci-fi', 'fantasy'],
      ),
      CatalogItem(
        id: 'seed-comic-03',
        kind: 'comic',
        title: 'Watchmen',
        synopsis:
            'In an alternate 1985, costumed heroes investigate one of their own\'s murder.',
        publisher: 'DC Comics',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 9, 1),
        itemNumber: '1',
        sortKey: 'watchmen-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-watchmen',
          seriesTitle: 'Watchmen',
          volumeName: 'Watchmen',
          volumeNumber: 1,
          volumeStartYear: 1986,
          tags: ['superhero', 'deconstruction', 'political'],
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 32,
          coverPriceCents: 150,
          currency: 'USD',
          imprint: 'DC',
        ),
        creators: [
          {'name': 'Alan Moore', 'role': 'writer'},
          {'name': 'Dave Gibbons', 'role': 'artist'},
        ],
        characters: [
          'Rorschach',
          'Dr. Manhattan',
          'Nite Owl',
          'Ozymandias',
        ],
        genres: ['superhero', 'deconstruction'],
      ),
      CatalogItem(
        id: 'seed-comic-04',
        kind: 'comic',
        title: 'Sandman',
        synopsis:
            'Morpheus, the king of dreams, is captured and held prisoner for decades.',
        publisher: 'DC Comics',
        releaseYear: 1989,
        releaseDate: DateTime.utc(1989, 1, 1),
        itemNumber: '1',
        sortKey: 'sandman-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-sandman',
          seriesTitle: 'The Sandman',
          volumeName: 'The Sandman',
          volumeNumber: 1,
          volumeStartYear: 1989,
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 40,
          imprint: 'Vertigo',
        ),
        creators: [
          {'name': 'Neil Gaiman', 'role': 'writer'},
          {'name': 'Sam Kieth', 'role': 'artist'},
        ],
        characters: ['Morpheus', 'Death', 'Lucifer'],
        genres: ['fantasy', 'horror', 'mythology'],
      ),
      CatalogItem(
        id: 'seed-comic-05',
        kind: 'comic',
        title: 'Maus',
        synopsis:
            'A graphic novel about the Holocaust, told through anthropomorphic animals.',
        publisher: 'Pantheon Books',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 1, 1),
        sortKey: 'maus-0001',
        publishing: const CatalogPublishingDetails(pageCount: 296),
        creators: [
          {'name': 'Art Spiegelman', 'role': 'writer'},
          {'name': 'Art Spiegelman', 'role': 'artist'},
        ],
        characters: ['Vladek Spiegelman', 'Art Spiegelman'],
        genres: ['biography', 'historical', 'graphic novel'],
      ),
      CatalogItem(
        id: 'seed-comic-06',
        kind: 'comic',
        title: 'Batman: The Killing Joke',
        synopsis:
            'The Joker\'s attempt to prove that anyone can be driven insane.',
        publisher: 'DC Comics',
        releaseYear: 1988,
        releaseDate: DateTime.utc(1988, 3, 1),
        sortKey: 'batman-killing-joke-0001',
        publishing: const CatalogPublishingDetails(
          pageCount: 64,
          coverPriceCents: 350,
          currency: 'USD',
          imprint: 'DC',
        ),
        creators: [
          {'name': 'Alan Moore', 'role': 'writer'},
          {'name': 'Brian Bolland', 'role': 'artist'},
        ],
        characters: ['Batman', 'The Joker', 'Barbara Gordon'],
        genres: ['superhero', 'psychological'],
      ),
      CatalogItem(
        id: 'seed-comic-07',
        kind: 'comic',
        title: 'Invincible',
        synopsis:
            'Mark Grayson inherits his father\'s superpowers and discovers the truth about his heritage.',
        publisher: 'Image Comics',
        releaseYear: 2003,
        releaseDate: DateTime.utc(2003, 1, 22),
        itemNumber: '1',
        sortKey: 'invincible-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-invincible',
          seriesTitle: 'Invincible',
          volumeNumber: 1,
          volumeStartYear: 2003,
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 24,
          coverPriceCents: 295,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Robert Kirkman', 'role': 'writer'},
          {'name': 'Cory Walker', 'role': 'artist'},
        ],
        characters: ['Mark Grayson', 'Nolan Grayson', 'Atom Eve'],
        genres: ['superhero', 'action'],
      ),
      CatalogItem(
        id: 'seed-comic-08',
        kind: 'comic',
        title: 'Y: The Last Man',
        synopsis:
            'The only male survivor of a global androcide must navigate the new world.',
        publisher: 'DC Comics',
        releaseYear: 2002,
        releaseDate: DateTime.utc(2002, 9, 1),
        itemNumber: '1',
        sortKey: 'y-last-man-0001',
        publishing: const CatalogPublishingDetails(
          pageCount: 24,
          imprint: 'Vertigo',
        ),
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Pia Guerra', 'role': 'artist'},
        ],
        characters: ['Yorick Brown', 'Agent 355', 'Ampersand'],
        genres: ['sci-fi', 'post-apocalyptic'],
      ),
      CatalogItem(
        id: 'seed-comic-09',
        kind: 'comic',
        title: 'Bone',
        synopsis:
            'Three cousins from Boneville are lost in a vast desert and stumble upon a mysterious valley.',
        publisher: 'Cartoon Books',
        releaseYear: 1991,
        releaseDate: DateTime.utc(1991, 7, 1),
        itemNumber: '1',
        sortKey: 'bone-0001',
        publishing: const CatalogPublishingDetails(pageCount: 28),
        creators: [
          {'name': 'Jeff Smith', 'role': 'writer'},
          {'name': 'Jeff Smith', 'role': 'artist'},
        ],
        characters: ['Fone Bone', 'Phoney Bone', 'Thorn'],
        genres: ['fantasy', 'adventure', 'comedy'],
      ),
      CatalogItem(
        id: 'seed-comic-10',
        kind: 'comic',
        title: 'Hellboy: Seed of Destruction',
        synopsis:
            'Hellboy investigates the mystery of his own origin in his first full-length story.',
        publisher: 'Dark Horse Comics',
        releaseYear: 1994,
        releaseDate: DateTime.utc(1994, 3, 1),
        itemNumber: '1',
        sortKey: 'hellboy-0001',
        series: const CatalogSeriesDetails(
          seriesId: 'seed-series-hellboy',
          seriesTitle: 'Hellboy',
          volumeNumber: 1,
          volumeStartYear: 1994,
        ),
        publishing: const CatalogPublishingDetails(
          pageCount: 32,
          coverPriceCents: 295,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Mike Mignola', 'role': 'writer'},
          {'name': 'Mike Mignola', 'role': 'artist'},
        ],
        characters: ['Hellboy', 'Abe Sapien', 'Rasputin'],
        genres: ['horror', 'occult', 'action'],
      ),
    ];

String _seedOrdinal2(int value) => value.toString().padLeft(2, '0');

// ===========================================================================
//  TV (10)
// ===========================================================================
List<CatalogItem> _tvItems() {
  const titles = [
    'Breaking Bad',
    'Better Call Saul',
    'The Wire',
    'Chernobyl',
    'True Detective',
    'Mindhunter',
    'Severance',
    'The Last of Us',
    'Fargo',
    'Dark',
  ];
  return [
    for (var i = 0; i < titles.length; i++)
      CatalogItem(
        id: 'seed-tv-${_seedOrdinal2(i + 1)}',
        kind: 'tv',
        title: titles[i],
        displayTitle: '${titles[i]} Season ${i + 1}',
        synopsis:
            'Seed TV entry for ${titles[i]} with complete metadata, creators, series grouping and collectible details.',
        publisher: i.isEven ? 'HBO' : 'AMC',
        releaseYear: 2008 + i,
        releaseDate: DateTime.utc(2008 + i, ((i % 12) + 1), 1 + (i % 20)),
        coverImageUrl:
            'https://placehold.co/300x450?text=${Uri.encodeComponent(titles[i])}+TV',
        thumbnailImageUrl: 'https://placehold.co/100x150?text=TV${i + 1}',
        editionTitle: 'Complete Season ${i + 1}',
        physicalFormat: 'Blu-ray',
        variant: 'Collector',
        barcode: 'TV-${(100000000000 + i).toString()}',
        country: i.isEven ? 'US' : 'DE',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'seed-tv-${_seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetails(
          seriesId: 'seed-series-tv-${_seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: 1,
          volumeStartYear: 2008 + i,
          tags: const ['tv', 'drama', 'seed'],
        ),
        video: VideoCatalogDetails(
          runtimeMinutes: 46 + (i % 12),
          nrDiscs: 2 + (i % 3),
          subtitles: 'English, Spanish',
          audioTracks: 'English 5.1',
        ),
        publishing: CatalogPublishingDetails(
          coverPriceCents: 3999 + (i * 100),
          currency: 'USD',
          imprint: 'Collector Seed',
        ),
        creators: [
          {'name': 'Seed Showrunner ${i + 1}', 'role': 'creator'},
          {'name': 'Seed Director ${i + 1}', 'role': 'director'},
        ],
        characters: [
          'Lead ${i + 1}',
          'Support ${i + 1}',
          'Antagonist ${i + 1}'
        ],
        storyArcs: ['Season ${i + 1} Arc'],
        genres: const ['drama', 'thriller'],
      ),
  ];
}

// ===========================================================================
//  ANIME (10)
// ===========================================================================
List<CatalogItem> _animeItems() {
  const titles = [
    'Cowboy Bebop',
    'Fullmetal Alchemist: Brotherhood',
    'Steins;Gate',
    'Attack on Titan',
    'Mob Psycho 100',
    'Vinland Saga',
    'Jujutsu Kaisen',
    'Frieren',
    'Psycho-Pass',
    'Neon Genesis Evangelion',
  ];
  return [
    for (var i = 0; i < titles.length; i++)
      CatalogItem(
        id: 'seed-anime-${_seedOrdinal2(i + 1)}',
        kind: 'anime',
        title: titles[i],
        displayTitle: '${titles[i]} Cour ${i + 1}',
        synopsis:
            'Seed anime entry for ${titles[i]} including detailed metadata and collectible release information.',
        publisher: i.isEven ? 'Aniplex' : 'Toho',
        releaseYear: 1998 + i,
        releaseDate: DateTime.utc(1998 + i, ((i % 12) + 1), 3 + (i % 20)),
        coverImageUrl:
            'https://placehold.co/300x450?text=${Uri.encodeComponent(titles[i])}+Anime',
        thumbnailImageUrl: 'https://placehold.co/100x150?text=AN${i + 1}',
        editionTitle: 'Blu-ray Box ${i + 1}',
        physicalFormat: 'Blu-ray',
        variant: 'Limited',
        barcode: 'AN-${(200000000000 + i).toString()}',
        country: 'JP',
        language: 'ja',
        ageRating: '16+',
        sortKey: 'seed-anime-${_seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetails(
          seriesId: 'seed-series-anime-${_seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: 1,
          volumeStartYear: 1998 + i,
          tags: const ['anime', 'seed'],
        ),
        video: VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 2 + (i % 2),
          subtitles: 'Japanese, English',
          audioTracks: 'Japanese 2.0, English 2.0',
        ),
        publishing: CatalogPublishingDetails(
          coverPriceCents: 4599 + (i * 120),
          currency: 'USD',
          imprint: 'Seed Anime Label',
        ),
        creators: [
          {'name': 'Seed Mangaka ${i + 1}', 'role': 'creator'},
          {'name': 'Seed Director ${i + 1}', 'role': 'director'},
        ],
        characters: ['Protagonist ${i + 1}', 'Deuteragonist ${i + 1}'],
        storyArcs: ['Arc ${i + 1}'],
        genres: const ['anime', 'action', 'drama'],
      ),
  ];
}

// ===========================================================================
//  MANGA (10)
// ===========================================================================
List<CatalogItem> _mangaItems() {
  const titles = [
    'Berserk',
    'Monster',
    'Vagabond',
    '20th Century Boys',
    'Pluto',
    'Dorohedoro',
    'Blue Lock',
    'Chainsaw Man',
    'Kaiju No. 8',
    'Sakamoto Days',
  ];
  return [
    for (var i = 0; i < titles.length; i++)
      CatalogItem(
        id: 'seed-manga-${_seedOrdinal2(i + 1)}',
        kind: 'manga',
        title: titles[i],
        displayTitle: '${titles[i]} Vol. ${i + 1}',
        synopsis:
            'Seed manga entry for ${titles[i]} with volume-level metadata, variants, personal-ready fields and cover assets.',
        publisher: i.isEven ? 'Shueisha' : 'Kodansha',
        releaseYear: 1999 + i,
        releaseDate: DateTime.utc(1999 + i, ((i % 12) + 1), 5 + (i % 20)),
        coverImageUrl:
            'https://placehold.co/300x450?text=${Uri.encodeComponent(titles[i])}+Manga',
        thumbnailImageUrl: 'https://placehold.co/100x150?text=MG${i + 1}',
        editionTitle: 'Tankobon ${i + 1}',
        physicalFormat: 'Tankobon',
        variant: 'Standard',
        barcode: 'MG-${(300000000000 + i).toString()}',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen',
        sortKey: 'seed-manga-${_seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetails(
          seriesId: 'seed-series-manga-${_seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: i + 1,
          volumeStartYear: 1999 + i,
          tags: const ['manga', 'seed'],
        ),
        publishing: CatalogPublishingDetails(
          coverPriceCents: 1299 + (i * 70),
          currency: 'USD',
          imprint: 'Seed Manga Label',
        ),
        creators: [
          {'name': 'Seed Mangaka ${i + 1}', 'role': 'writer'},
          {'name': 'Seed Artist ${i + 1}', 'role': 'artist'},
        ],
        characters: ['Lead ${i + 1}', 'Rival ${i + 1}'],
        storyArcs: ['Volume ${i + 1} Arc'],
        genres: const ['manga', 'action'],
      ),
  ];
}

// ==========================================================================
//  OWNED ITEMS
// ==========================================================================
Iterable<String> _seedIds(String kind, int count) sync* {
  for (var i = 1; i <= count; i++) {
    yield 'seed-$kind-${_seedOrdinal2(i)}';
  }
}

List<OwnedItem> _ownedItems() {
  final now = DateTime.now().toUtc();
  return [
    // Movies
    OwnedItem(
      id: 'seed-owned-movie-01',
      itemId: 'seed-movie-01',
      createdAt: now.subtract(const Duration(days: 365)),
      updatedAt: now,
      isDigital: false,
      condition: 'Near Mint',
      purchaseDate: DateTime.utc(2018, 6, 1),
      pricePaidCents: 2999,
      currency: 'USD',
      personalNotes: 'First 4K UHD purchase',
      quantity: 1,
      rating: 9,
      readStatus: 'completed',
      finishedAt: DateTime.utc(2018, 6, 5),
      purchaseStore: 'Amazon',
      region: 'US',
      packaging: 'Keep Case',
      collectionStatus: 'collected',
    ),
    OwnedItem(
      id: 'seed-owned-movie-02',
      itemId: 'seed-movie-02',
      createdAt: now.subtract(const Duration(days: 300)),
      updatedAt: now,
      isDigital: false,
      condition: 'Mint',
      pricePaidCents: 3499,
      currency: 'USD',
      rating: 10,
      readStatus: 'completed',
      purchaseStore: 'Best Buy',
    ),
    // Books
    OwnedItem(
      id: 'seed-owned-book-01',
      itemId: 'seed-book-01',
      createdAt: now.subtract(const Duration(days: 500)),
      updatedAt: now,
      isDigital: false,
      condition: 'Very Good',
      purchaseDate: DateTime.utc(2020, 3, 15),
      pricePaidCents: 999,
      currency: 'USD',
      personalNotes: 'Signed by the estate',
      quantity: 1,
      rating: 10,
      readStatus: 'completed',
      startedAt: DateTime.utc(2020, 4, 1),
      finishedAt: DateTime.utc(2020, 5, 10),
      signedBy: 'Estate of Frank Herbert',
      purchaseStore: 'Powell\'s Books',
    ),
    OwnedItem(
      id: 'seed-owned-book-07',
      itemId: 'seed-book-07',
      createdAt: now.subtract(const Duration(days: 1000)),
      updatedAt: now,
      isDigital: false,
      condition: 'Good',
      pricePaidCents: 1500,
      currency: 'USD',
      rating: 10,
      readStatus: 'completed',
      tags: 'fantasy,classic,tolkien',
    ),
    // Music
    OwnedItem(
      id: 'seed-owned-music-01',
      itemId: 'seed-music-01',
      createdAt: now.subtract(const Duration(days: 200)),
      updatedAt: now,
      isDigital: false,
      condition: 'Near Mint',
      purchaseDate: DateTime.utc(2022, 1, 10),
      pricePaidCents: 2499,
      currency: 'USD',
      rating: 9,
      readStatus: 'completed',
      purchaseStore: 'Discogs',
      storageDevice: 'Shelf A',
      storageSlot: 'R-3',
    ),
    OwnedItem(
      id: 'seed-owned-music-07',
      itemId: 'seed-music-07',
      createdAt: now.subtract(const Duration(days: 800)),
      updatedAt: now,
      isDigital: false,
      condition: 'Good',
      pricePaidCents: 4500,
      currency: 'USD',
      personalNotes: 'Original mono pressing, light surface noise',
      rating: 10,
      readStatus: 'completed',
      marketValueCents: 15000,
    ),
    // Games
    OwnedItem(
      id: 'seed-owned-game-01',
      itemId: 'seed-game-01',
      createdAt: now.subtract(const Duration(days: 400)),
      updatedAt: now,
      isDigital: false,
      condition: 'Very Good',
      purchaseDate: DateTime.utc(2016, 12, 25),
      pricePaidCents: 4999,
      currency: 'USD',
      rating: 10,
      readStatus: 'completed',
      startedAt: DateTime.utc(2017, 1, 1),
      finishedAt: DateTime.utc(2017, 6, 30),
      purchaseStore: 'GameStop',
    ),
    OwnedItem(
      id: 'seed-owned-game-04',
      itemId: 'seed-game-04',
      createdAt: now.subtract(const Duration(days: 100)),
      updatedAt: now,
      isDigital: true,
      pricePaidCents: 5999,
      currency: 'USD',
      rating: 9,
      readStatus: 'inProgress',
      startedAt: DateTime.utc(2024, 1, 15),
    ),
    // Board Games
    OwnedItem(
      id: 'seed-owned-bg-01',
      itemId: 'seed-boardgame-01',
      createdAt: now.subtract(const Duration(days: 600)),
      updatedAt: now,
      isDigital: false,
      condition: 'Very Good',
      purchaseDate: DateTime.utc(2019, 8, 1),
      pricePaidCents: 14000,
      currency: 'USD',
      personalNotes: 'All characters unlocked',
      rating: 9,
      readStatus: 'inProgress',
      purchaseStore: 'Miniature Market',
    ),
    // Comics
    OwnedItem(
      id: 'seed-owned-comic-01',
      itemId: 'seed-comic-01',
      createdAt: now.subtract(const Duration(days: 900)),
      updatedAt: now,
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.4',
      rawOrSlabbed: 'raw',
      pricePaidCents: 499,
      currency: 'USD',
      rating: 9,
      readStatus: 'completed',
      keyComic: true,
      keyReason: 'First printing, first appearance of Saga characters',
      keyCategory: 'first_appearance',
      keySeverity: 'major',
      marketValueCents: 15000,
      coverPriceCents: 299,
      lastBagBoardDate: DateTime.utc(2024, 6, 1),
    ),
    OwnedItem(
      id: 'seed-owned-comic-03',
      itemId: 'seed-comic-03',
      createdAt: now.subtract(const Duration(days: 1200)),
      updatedAt: now,
      isDigital: false,
      condition: 'Very Good',
      grade: '8.0',
      rawOrSlabbed: 'slabbed',
      gradingCompany: 'CGC',
      certificationNumber: '1234567890',
      pricePaidCents: 8500,
      currency: 'USD',
      rating: 10,
      readStatus: 'completed',
      keyComic: true,
      keyReason: 'Iconic first issue of Watchmen',
      keyCategory: 'first_issue',
      keySeverity: 'major',
      marketValueCents: 35000,
      coverPriceCents: 150,
    ),
    for (final itemId in _seedIds('tv', 10))
      OwnedItem(
        id: 'seed-owned-$itemId',
        itemId: itemId,
        createdAt: now.subtract(const Duration(days: 240)),
        updatedAt: now,
        isDigital: false,
        condition: 'Near Mint',
        purchaseDate: DateTime.utc(2023, 1, 10),
        pricePaidCents: 3299,
        currency: 'USD',
        personalNotes: 'Seed TV collectible copy',
        quantity: 1,
        rating: 8,
        readStatus: 'completed',
        startedAt: DateTime.utc(2023, 1, 11),
        finishedAt: DateTime.utc(2023, 1, 11),
        purchaseStore: 'Seed Store',
        collectionStatus: 'collected',
      ),
    for (final itemId in _seedIds('anime', 10))
      OwnedItem(
        id: 'seed-owned-$itemId',
        itemId: itemId,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
        isDigital: false,
        condition: 'Mint',
        purchaseDate: DateTime.utc(2023, 2, 12),
        pricePaidCents: 4199,
        currency: 'USD',
        personalNotes: 'Seed anime box set',
        quantity: 1,
        rating: 9,
        readStatus: 'completed',
        startedAt: DateTime.utc(2023, 2, 13),
        finishedAt: DateTime.utc(2023, 2, 13),
        purchaseStore: 'AmiAmi',
        collectionStatus: 'collected',
      ),
    for (final itemId in _seedIds('manga', 10))
      OwnedItem(
        id: 'seed-owned-$itemId',
        itemId: itemId,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
        isDigital: false,
        condition: 'Very Fine',
        purchaseDate: DateTime.utc(2023, 3, 14),
        pricePaidCents: 1499,
        currency: 'USD',
        personalNotes: 'Seed manga volume copy',
        quantity: 1,
        rating: 8,
        readStatus: 'inProgress',
        startedAt: DateTime.utc(2023, 3, 15),
        purchaseStore: 'Kinokuniya',
        collectionStatus: 'collected',
      ),
  ];
}

// ==========================================================================
//  TRACKING ENTRIES
// ==========================================================================
List<TrackingEntry> _trackingEntries() {
  final now = DateTime.now().toUtc();
  return [
    // Completed movie
    TrackingEntry(
      id: 'seed-track-01',
      itemId: 'seed-movie-01',
      ownedItemId: 'seed-owned-movie-01',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.completed,
      rating: 9,
      startedAt: DateTime.utc(2018, 6, 5),
      finishedAt: DateTime.utc(2018, 6, 5),
      timesCompleted: 3,
      notes: 'Rewatched annually',
      updatedAt: now,
    ),
    // In-progress book
    TrackingEntry(
      id: 'seed-track-02',
      itemId: 'seed-book-02',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.inProgress,
      progressCurrent: 120,
      progressTotal: 256,
      startedAt: DateTime.utc(2025, 5, 1),
      updatedAt: now,
    ),
    // Planned game
    TrackingEntry(
      id: 'seed-track-03',
      itemId: 'seed-game-04',
      ownedItemId: 'seed-owned-game-04',
      sourceType: TrackingSourceType.digital,
      status: MediaTrackingStatus.inProgress,
      progressCurrent: 60,
      progressTotal: 100,
      startedAt: DateTime.utc(2024, 1, 15),
      rating: 9,
      updatedAt: now,
    ),
    // Completed music album
    TrackingEntry(
      id: 'seed-track-04',
      itemId: 'seed-music-01',
      ownedItemId: 'seed-owned-music-01',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.completed,
      rating: 9,
      timesCompleted: 50,
      notes: 'All-time favorite album',
      updatedAt: now,
    ),
    // Completed comic
    TrackingEntry(
      id: 'seed-track-05',
      itemId: 'seed-comic-01',
      ownedItemId: 'seed-owned-comic-01',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.completed,
      rating: 9,
      timesCompleted: 2,
      updatedAt: now,
    ),
    // Paused board game
    TrackingEntry(
      id: 'seed-track-06',
      itemId: 'seed-boardgame-01',
      ownedItemId: 'seed-owned-bg-01',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.paused,
      progressCurrent: 35,
      progressTotal: 95,
      notes: 'Scenario 35, paused for summer',
      updatedAt: now,
    ),
    // Streaming movie
    TrackingEntry(
      id: 'seed-track-07',
      itemId: 'seed-movie-04',
      sourceType: TrackingSourceType.streaming,
      status: MediaTrackingStatus.completed,
      rating: 10,
      timesCompleted: 2,
      finishedAt: DateTime.utc(2024, 12, 20),
      updatedAt: now,
    ),
    // Dropped book
    TrackingEntry(
      id: 'seed-track-08',
      itemId: 'seed-book-05',
      sourceType: TrackingSourceType.physical,
      status: MediaTrackingStatus.dropped,
      progressCurrent: 80,
      progressTotal: 271,
      notes: 'Couldn\'t get into it',
      updatedAt: now,
    ),
    for (var i = 1; i <= 10; i++)
      TrackingEntry(
        id: 'seed-track-tv-${_seedOrdinal2(i)}',
        itemId: 'seed-tv-${_seedOrdinal2(i)}',
        ownedItemId: 'seed-owned-seed-tv-${_seedOrdinal2(i)}',
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
        rating: 8,
        timesCompleted: 1,
        updatedAt: now,
      ),
    for (var i = 1; i <= 10; i++)
      TrackingEntry(
        id: 'seed-track-anime-${_seedOrdinal2(i)}',
        itemId: 'seed-anime-${_seedOrdinal2(i)}',
        ownedItemId: 'seed-owned-seed-anime-${_seedOrdinal2(i)}',
        sourceType: TrackingSourceType.physical,
        status: i.isEven
            ? MediaTrackingStatus.completed
            : MediaTrackingStatus.inProgress,
        progressCurrent: i.isEven ? null : 8,
        progressTotal: i.isEven ? null : 12,
        rating: 9,
        updatedAt: now,
      ),
    for (var i = 1; i <= 10; i++)
      TrackingEntry(
        id: 'seed-track-manga-${_seedOrdinal2(i)}',
        itemId: 'seed-manga-${_seedOrdinal2(i)}',
        ownedItemId: 'seed-owned-seed-manga-${_seedOrdinal2(i)}',
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: i,
        progressTotal: 12,
        rating: 8,
        updatedAt: now,
      ),
  ];
}

final Uint8List _seedTinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zx1EAAAAASUVORK5CYII=',
);

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
      imageData: _seedTinyPngBytes,
      caption: 'Seed front cover',
      sortOrder: 0,
    );
    if (i.isEven) {
      await repo.upsert(
        id: 'seed-img-back-${owned.id}',
        ownedItemId: owned.id,
        imageType: 'back_cover',
        imageData: _seedTinyPngBytes,
        caption: 'Seed back cover',
        sortOrder: 1,
      );
    }
    if (i % 3 == 0) {
      await repo.upsert(
        id: 'seed-img-extra-${owned.id}',
        ownedItemId: owned.id,
        imageType: 'detail_photo',
        imageData: _seedTinyPngBytes,
        caption: 'Seed extra image',
        sortOrder: 2,
      );
    }
  }
}

// ==========================================================================
//  PICK LISTS (supplemental values)
// ==========================================================================
Future<void> _seedPickLists(PickListRepository repo) async {
  await repo.setValues('conditions', [
    'Mint',
    'Near Mint',
    'Very Fine',
    'Fine',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
  ]);
  await repo.setValues('grades', [
    '10.0',
    '9.8',
    '9.6',
    '9.4',
    '9.2',
    '9.0',
    '8.5',
    '8.0',
    '7.5',
    '7.0',
    '6.5',
    '6.0',
    '5.5',
    '5.0',
  ]);
  await repo.setValues('physical_formats', [
    'Single Issue',
    'Trade Paperback',
    'Hardcover',
    'Omnibus',
    'Paperback',
    'Audiobook',
    'DVD',
    'Blu-ray',
    '4K UHD',
    'Vinyl',
    'CD',
    'Cassette',
    'SACD',
    'Board Game',
    'Expansion',
    'PS4',
    'PS5',
    'Xbox One',
    'Xbox Series',
    'Switch',
    'PC',
  ]);
  await repo.setValues('countries', [
    'US',
    'GB',
    'CA',
    'AU',
    'DE',
    'FR',
    'JP',
    'SE',
    'IS',
    'EE',
    'PL',
  ]);
  await repo.setValues('languages', [
    'en',
    'fr',
    'de',
    'ja',
    'is',
    'es',
  ]);
  await repo.setValues('age_ratings', [
    'Everyone',
    'E10+',
    'Teen',
    'T',
    'M',
    'PG',
    'PG-13',
    'R',
    'TV-MA',
    '10+',
    '12+',
    '14+',
    'Adult',
    'Mature',
  ]);
  await repo.setValues('genres', [
    'action',
    'adventure',
    'comedy',
    'crime',
    'drama',
    'fantasy',
    'horror',
    'mystery',
    'romance',
    'sci-fi',
    'thriller',
    'superhero',
    'RPG',
    'platformer',
    'roguelike',
    'cooperative',
    'strategy',
    'hip hop',
    'jazz',
    'electronic',
    'rock',
    'alternative rock',
    'trip hop',
  ]);
  await repo.setValues('story_arcs', [
    'Batman\'s Origin',
    'Gotham\'s Reckoning',
    'Replicant Hunt',
    'Xenomorph Saga',
    'Arrakis Saga',
    'War of the Ring',
    'Wild Hunt Pursuit',
    'Age of Fire',
    'Illithid Invasion',
    'Legacy Campaign',
    'The Human Condition',
    'Compton Chronicles',
  ]);
}

// ==========================================================================
//  CUSTOM FIELDS
// ==========================================================================
Future<void> _seedCustomFields(CustomFieldRepository repo) async {
  final now = DateTime.now().toUtc();

  // Definitions
  final defs = [
    CustomFieldDefinition(
      id: 'seed-cf-def-01',
      name: 'Acquisition Source',
      fieldType: 'select',
      sortOrder: 1,
      options: '["Gift","Purchase","Trade","Found","Inherited"]',
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-02',
      name: 'Personal Rating Notes',
      fieldType: 'text',
      sortOrder: 2,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-03',
      name: 'Insurance Value',
      fieldType: 'number',
      sortOrder: 3,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-04',
      name: 'Date Cataloged',
      fieldType: 'date',
      sortOrder: 4,
      createdAt: now,
    ),
    CustomFieldDefinition(
      id: 'seed-cf-def-05',
      name: 'Lent Out',
      fieldType: 'bool',
      sortOrder: 5,
      createdAt: now,
    ),
  ];

  for (final def in defs) {
    await repo.upsertDefinition(def);
  }

  // Values for some owned items
  final values = [
    CustomFieldValue(
      id: 'seed-cf-val-01',
      targetId: 'seed-owned-comic-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-01',
      value: 'Purchase',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-02',
      targetId: 'seed-owned-comic-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-02',
      value: 'First print, great condition for the price',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-03',
      targetId: 'seed-owned-comic-03',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-03',
      value: '350',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-04',
      targetId: 'seed-owned-book-01',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-04',
      value: '2020-03-16',
      updatedAt: now,
    ),
    CustomFieldValue(
      id: 'seed-cf-val-05',
      targetId: 'seed-owned-book-07',
      targetScope: CustomFieldTargetScope.ownedCopy,
      fieldDefinitionId: 'seed-cf-def-05',
      value: 'true',
      updatedAt: now,
    ),
  ];

  await repo.upsertValues(values);
}
