import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> gameSeedCatalogItems() => [
      testCatalogItem(
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
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-witcher',
          seriesTitle: 'The Witcher',
          tags: 'RPG, open world, fantasy',
        ),
        game: const GameCatalogDetails(
          platforms: ['PC', 'PS4', 'Xbox One', 'Switch'],
        ),
        publishing: const CatalogPublishingDetailsDto(
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
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
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
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
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
      testCatalogItem(
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

List<OwnedItem> gameSeedOwnedItems(DateTime now) => [
      OwnedItem(
        id: 'seed-owned-game-01',
        catalogRef: seedCatalogRef('seed-game-01'),
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
        catalogRef: seedCatalogRef('seed-game-04'),
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now,
        isDigital: true,
        pricePaidCents: 5999,
        currency: 'USD',
        rating: 9,
        readStatus: 'inProgress',
        startedAt: DateTime.utc(2024, 1, 15),
      ),
    ];

List<TrackingEntry> gameSeedTrackingEntries(DateTime now) => [
      TrackingEntry(
        id: 'seed-track-03',
        catalogRef: seedCatalogRef('seed-game-04'),
        ownedItemId: 'seed-owned-game-04',
        sourceType: TrackingSourceType.digital,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: 60,
        progressTotal: 100,
        startedAt: DateTime.utc(2024, 1, 15),
        rating: 9,
        updatedAt: now,
      ),
    ];
