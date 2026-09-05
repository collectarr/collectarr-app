import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';

CatalogItem enrichBoardgameSeedItem(CatalogItem item) {
  final editions = [
    for (final edition in seedEditionPayloads(item))
      {
        ...edition,
        'id': edition['id']?.toString() ?? '${item.id}-edition-01',
        'kind': 'boardgame',
        'work_id': item.id,
        'edition_title': edition['title'] ?? item.editionTitle ?? item.title,
        'format': edition['format'] ?? item.physicalFormat ?? 'Board Game',
        'publisher': edition['publisher'] ?? item.publisher,
        'barcode': edition['barcode'] ?? item.barcode,
        'country': edition['country'] ?? item.payload['country'],
        'language': edition['language'] ?? item.payload['language'],
        'age_rating': edition['age_rating'] ?? item.payload['age_rating'],
        'release_date': edition['release_date'] ??
            item.releaseDate?.toUtc().toIso8601String(),
        'release_status': edition['release_status'] ?? 'released',
        'min_players': edition['min_players'] ?? 1,
        'max_players': edition['max_players'] ?? 4,
        'playing_time_minutes': edition['playing_time_minutes'] ?? 90,
      },
  ];
  return withSeedPayload(item, {'editions': editions});
}

List<CatalogItem> boardgameSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-boardgame-01',
        kind: 'boardgame',
        title: 'Gloomhaven',
        synopsis:
            'A cooperative dungeon-crawling board game with branching narrative and tactical combat.',
        publisher: 'Cephalofair Games',
        barcode: '700300000013',
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
      seedCatalogItem(
        id: 'seed-boardgame-02',
        kind: 'boardgame',
        title: 'Gloomhaven: Jaws of the Lion',
        synopsis: 'A standalone prequel to Gloomhaven with simplified rules.',
        publisher: 'Cephalofair Games',
        barcode: '700300000020',
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
      seedCatalogItem(
        id: 'seed-boardgame-03',
        kind: 'boardgame',
        title: 'Wingspan',
        synopsis: 'A competitive bird-collection engine-building board game.',
        publisher: 'Stonemaier Games',
        barcode: '700300000037',
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
      seedCatalogItem(
        id: 'seed-boardgame-04',
        kind: 'boardgame',
        title: 'Pandemic',
        synopsis:
            'A cooperative game where players work together to stop global outbreaks.',
        publisher: 'Z-Man Games',
        barcode: '700300000044',
        releaseYear: 2008,
        releaseDate: DateTime.utc(2008, 1, 1),
        sortKey: 'pandemic-0001',
        creators: [
          {'name': 'Matt Leacock', 'role': 'designer'},
        ],
        characters: ['Medic', 'Scientist', 'Researcher'],
        genres: ['cooperative', 'strategy'],
      ),
      seedCatalogItem(
        id: 'seed-boardgame-05',
        kind: 'boardgame',
        title: 'Pandemic Legacy: Season 1',
        synopsis:
            'A legacy-style Pandemic where each game permanently alters the board.',
        publisher: 'Z-Man Games',
        barcode: '700300000051',
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
      seedCatalogItem(
        id: 'seed-boardgame-06',
        kind: 'boardgame',
        title: 'Terraforming Mars',
        synopsis:
            'Corporations compete to terraform Mars by raising temperature, oxygen, and ocean coverage.',
        publisher: 'FryxGames',
        barcode: '700300000068',
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
      seedCatalogItem(
        id: 'seed-boardgame-07',
        kind: 'boardgame',
        title: 'Spirit Island',
        synopsis:
            'Spirits of the land work together to drive off colonizing invaders.',
        publisher: 'Greater Than Games',
        barcode: '700300000075',
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
      seedCatalogItem(
        id: 'seed-boardgame-08',
        kind: 'boardgame',
        title: 'Root',
        synopsis:
            'An asymmetric war game where woodland factions battle for control of a vast forest.',
        publisher: 'Leder Games',
        barcode: '700300000082',
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
      seedCatalogItem(
        id: 'seed-boardgame-09',
        kind: 'boardgame',
        title: 'Brass: Birmingham',
        synopsis:
            'Build industries and networks in Birmingham during the industrial revolution.',
        publisher: 'Roxley Games',
        barcode: '700300000099',
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
      seedCatalogItem(
        id: 'seed-boardgame-10',
        kind: 'boardgame',
        title: 'Scythe',
        synopsis:
            'An alternate-history 1920s strategy game featuring mechs and farming.',
        publisher: 'Stonemaier Games',
        barcode: '700300000105',
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
      for (var i = 1; i <= 10; i++)
        OwnedItem(
          // Keep the original first ID so existing local seed data is updated
          // instead of leaving an orphaned copy behind after a re-seed.
          id: i == 1 ? 'seed-owned-bg-01' : 'seed-owned-bg-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-boardgame-${seedOrdinal2(i)}'),
          createdAt: now.subtract(Duration(days: 600 - (i * 25))),
          updatedAt: now,
          isDigital: false,
          condition: i.isEven ? 'Near Mint' : 'Very Good',
          purchaseDate: DateTime.utc(2017 + i, i % 12 + 1, 1),
          pricePaidCents: i == 1 ? 14000 : 4500 + (i * 250),
          currency: 'USD',
          personalNotes: i == 1
              ? 'All characters unlocked.'
              : 'Complete retail copy with rulebook and components.',
          quantity: 1,
          rating: 7 + (i % 4),
          readStatus: i == 1 ? 'in progress' : 'completed',
          startedAt: DateTime.utc(2024, i % 12 + 1, 5),
          finishedAt: i == 1 ? null : DateTime.utc(2024, i % 12 + 1, 20),
          purchaseStore: i.isEven ? 'Local Game Store' : 'Miniature Market',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> boardgameSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 10; i++)
        TrackingEntry(
          // Keep the original first tracking ID for idempotent upgrades.
          id: i == 1
              ? 'seed-track-06'
              : 'seed-track-boardgame-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-boardgame-${seedOrdinal2(i)}'),
          ownedItemId:
              i == 1 ? 'seed-owned-bg-01' : 'seed-owned-bg-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i == 1
              ? MediaTrackingStatus.paused
              : (i <= 6
                  ? MediaTrackingStatus.completed
                  : MediaTrackingStatus.inProgress),
          progressCurrent: i == 1 ? 35 : (i <= 6 ? 1 : 0),
          progressTotal: i == 1 ? 95 : 1,
          notes: i == 1
              ? 'Scenario 35, paused for summer.'
              : 'Played with friends.',
          updatedAt: now,
        ),
    ];
