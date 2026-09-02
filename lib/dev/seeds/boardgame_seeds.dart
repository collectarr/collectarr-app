import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> boardgameSeedCatalogItems() => [
      testCatalogItem(
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
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-gloomhaven',
          seriesTitle: 'Gloomhaven',
          tags: 'cooperative, dungeon crawl, campaign',
        ),
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 14000,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Isaac Childres', 'role': 'designer'},
        ],
        characters: ['Brute', 'Spellweaver', 'Scoundrel'],
        genres: ['cooperative', 'dungeon crawl', 'tactical'],
      ),
      testCatalogItem(
        id: 'seed-boardgame-02',
        kind: 'boardgame',
        title: 'Gloomhaven: Jaws of the Lion',
        synopsis: 'A standalone prequel to Gloomhaven with simplified rules.',
        publisher: 'Cephalofair Games',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 6, 18),
        sortKey: 'gloomhaven-0002',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-gloomhaven',
          seriesTitle: 'Gloomhaven',
        ),
        creators: [
          {'name': 'Isaac Childres', 'role': 'designer'},
        ],
        characters: ['Valrath Red Guard', 'Inox Hatchet'],
        genres: ['cooperative', 'dungeon crawl'],
      ),
      testCatalogItem(
        id: 'seed-boardgame-03',
        kind: 'boardgame',
        title: 'Wingspan',
        synopsis: 'A competitive bird-collection engine-building board game.',
        publisher: 'Stonemaier Games',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 3, 8),
        ageRating: '10+',
        sortKey: 'wingspan-0001',
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 6500,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Elizabeth Hargrave', 'role': 'designer'},
        ],
        genres: ['engine building', 'card game', 'nature'],
      ),
      testCatalogItem(
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
      testCatalogItem(
        id: 'seed-boardgame-05',
        kind: 'boardgame',
        title: 'Pandemic Legacy: Season 1',
        synopsis:
            'A legacy-style Pandemic where each game permanently alters the board.',
        publisher: 'Z-Man Games',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 10, 8),
        sortKey: 'pandemic-0002',
        series: const CatalogSeriesDetailsDto(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 6999,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Jacob Fryxelius', 'role': 'designer'},
        ],
        genres: ['engine building', 'science', 'corporate'],
      ),
      testCatalogItem(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
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
      testCatalogItem(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 8000,
          currency: 'USD',
        ),
        creators: [
          {'name': 'Jamey Stegmaier', 'role': 'designer'},
          {'name': 'Jakub R├│┼╝alski', 'role': 'artist'},
        ],
        characters: ['Anna & Wojtek', 'Gunter & Nacht'],
        genres: ['strategy', 'area control', 'alternate history'],
      ),
    ];

List<OwnedItem> boardgameSeedOwnedItems(DateTime now) => [
      OwnedItem(
        id: 'seed-owned-bg-01',
        catalogRef: seedCatalogRef('seed-boardgame-01'),
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
    ];

List<TrackingEntry> boardgameSeedTrackingEntries(DateTime now) => [
      TrackingEntry(
        id: 'seed-track-06',
        catalogRef: seedCatalogRef('seed-boardgame-01'),
        ownedItemId: 'seed-owned-bg-01',
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.paused,
        progressCurrent: 35,
        progressTotal: 95,
        notes: 'Scenario 35, paused for summer',
        updatedAt: now,
      ),
    ];
