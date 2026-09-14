import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_play_session_repository.dart';

const _boardgameSeedCoverUrls = <String, String>{
  'Gloomhaven':
      'https://upload.wikimedia.org/wikipedia/en/e/ee/Gloomhaven_Cover_Art.jpg',
  'Gloomhaven: Jaws of the Lion':
      'https://cephalofair.com/cdn/shop/files/JawsOfTheLion_GRY_2048.jpg?v=1780958549&width=1920',
  'Wingspan':
      'https://europe.stonemaiergames.com/cdn/shop/products/3d-wingspan.png?v=1634295915',
  'Pandemic':
      'https://upload.wikimedia.org/wikipedia/en/3/36/Pandemic_game.jpg',
  'Pandemic Legacy: Season 1':
      'https://despelletjesvrienden.nl/cdn/shop/files/bordspellen-pandemic-legacy-red-season-1.jpg?v=1718620734',
  'Terraforming Mars':
      'https://upload.wikimedia.org/wikipedia/commons/5/5c/Terraforming_Mars.jpg',
  'Spirit Island':
      'https://www.gameology.com.au/cdn/shop/products/1_1740c173-fbc0-4c8a-9fd4-61172735d778.jpg?v=1768448379',
  'Root':
      'https://cdn.shopify.com/s/files/1/0106/0162/7706/products/1-RootGameBox-Edit-Web_e23b49d9-c5bf-4f0e-bfa7-d8296728d058_480x480.png?v=1614024211',
  'Brass: Birmingham':
      'https://cdn.shoplightspeed.com/shops/637526/files/48207364/roxley-brass-birmingham.jpg',
  'Scythe': 'https://upload.wikimedia.org/wikipedia/en/1/1a/Scythe_boxart.png',
  'Azul':
      'https://upload.wikimedia.org/wikipedia/en/2/23/Picture_of_Azul_game_box.jpg',
  '7 Wonders':
      'https://upload.wikimedia.org/wikipedia/commons/8/88/7_Wonders_game.jpg',
  'Catan':
      'https://upload.wikimedia.org/wikipedia/en/a/a3/Catan-2015-boxart.jpg',
  'Ticket to Ride':
      'https://upload.wikimedia.org/wikipedia/en/9/92/Ticket_to_Ride_Board_Game_Box_EN.jpg',
  'Everdell':
      'https://store.asmodee.com/cdn/shop/products/STG2668EN.jpg?v=1691517815',
};

String boardgameSeedCoverUrl(String title) {
  final coverUrl = _boardgameSeedCoverUrls[title];
  if (coverUrl == null) {
    throw ArgumentError.value(
      title,
      'title',
      'No curated board game seed cover exists for this title',
    );
  }
  return coverUrl;
}

final boardgameDevSeedContributor =
    TypedDevSeedKindContributor<BoardGameOwnedItem>(
  kind: CatalogMediaKind.boardgame,
  catalogDefaults: DevSeedCatalogDefaults(
    includePublishingDetails: false,
    paperType: null,
    originalLanguage: 'en',
    pageCount: 1,
    coverPriceCents: 4499,
    runtimeMinutes: 0,
    ageRating: 'PG',
    audienceRating: '10+',
    enrichPayload: enrichBoardgameSeedPayload,
  ),
  catalogItems: boardgameSeedCatalogItems,
  enrichItem: enrichBoardgameSeedItem,
  validateCatalog: validateBoardgameSeedCatalog,
  validateCatalogGraph: validateBoardgameSeedCatalogGraph,
  validateBarcode: seedValidateStandardBarcode,
  ownedItemsTyped: boardgameSeedOwnedItems,
  ownedSummaryTyped: BoardGameOwnedItemProjection.toSummary,
  validateOwnedTyped: validateBoardgameSeedOwned,
  seedOwnedTyped: (db, now) =>
      BoardGameOwnedRepository(db).upsertAll(boardgameSeedOwnedItems(now)),
  trackingRecords: boardgameSeedTrackingStates,
  seedDatabase: seedBoardgameDatabase,
);

void enrichBoardgameSeedPayload(
  CatalogItemDto item,
  Map<String, dynamic> payload,
) {
  payload.putIfAbsent('bgg_rank', () => 1);
  payload.putIfAbsent('bgg_rating', () => 7.5);
  payload.putIfAbsent('play_count', () => 5);
  payload.putIfAbsent(
    'last_played',
    () => item.releaseDate?.toUtc().toIso8601String(),
  );
  payload.putIfAbsent('favorite_player_count', () => 4);
  payload.putIfAbsent(
    'player_stats',
    () => <Map<String, dynamic>>[
      {'players': 2, 'rating': 7.0},
    ],
  );
}

List<String> validateBoardgameSeedCatalog(CatalogItemDto item) {
  final issues = <String>[];
  final prefix = '${item.kind}/${item.id}';
  final payload = item.payload;
  seedRequirePositiveInt(issues, prefix, 'bgg_rank', payload['bgg_rank']);
  seedRequirePositiveNumber(
      issues, prefix, 'bgg_rating', payload['bgg_rating']);
  seedRequireCreatorList(issues, prefix, payload['creators']);
  seedRequirePlayerStats(issues, prefix, payload['player_stats']);
  return issues;
}

List<String> validateBoardgameSeedCatalogGraph(CatalogItemDto item) {
  final issues = <String>[];
  final prefix = '${item.kind}/${item.id}';
  final editions = seedRequireObjectList(
    issues,
    prefix,
    'editions',
    item.payload['editions'],
  );
  seedValidateChildren(
    issues,
    prefix,
    'editions',
    editions,
    kind: CatalogMediaKind.boardgame,
    parentId: item.id,
    parentKey: 'work_id',
    titleKey: 'edition_title',
  );
  for (var index = 0; index < editions.length; index++) {
    final edition = editions[index];
    seedRequirePositiveInt(
      issues,
      prefix,
      'editions[$index].min_players',
      edition['min_players'],
    );
    seedRequirePositiveInt(
      issues,
      prefix,
      'editions[$index].max_players',
      edition['max_players'],
    );
    seedRequirePositiveInt(
      issues,
      prefix,
      'editions[$index].playing_time_minutes',
      edition['playing_time_minutes'],
    );
  }
  return issues;
}

List<String> validateBoardgameSeedOwned(BoardGameOwnedItem item) {
  final issues = <String>[];
  final prefix = '${item.catalogRef.kind}/${item.id}';
  final details = item.details;
  seedRequireText(
      issues, prefix, 'boardgame.edition_language', details.editionLanguage);
  seedRequireText(
      issues, prefix, 'boardgame.edition_region', details.editionRegion);
  seedRequireText(issues, prefix, 'boardgame.component_condition',
      details.componentCondition);
  seedRequireText(issues, prefix, 'boardgame.component_completeness',
      details.componentCompleteness);
  return issues;
}

Future<void> seedBoardgameDatabase(
  LocalDatabase db,
  Iterable<CatalogItemDto> items,
  DateTime now,
) async {
  await BoardGamePlaySessionRepository(db).upsertAll(
    boardgameSeedPlaySessions(now),
  );
}

CatalogItemDto enrichBoardgameSeedItem(CatalogItemDto item) {
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

List<CatalogItemDto> boardgameSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-boardgame-01',
        kind: CatalogMediaKind.boardgame,
        title: 'Gloomhaven',
        coverImageUrl: boardgameSeedCoverUrl('Gloomhaven'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Gloomhaven: Jaws of the Lion',
        coverImageUrl: boardgameSeedCoverUrl('Gloomhaven: Jaws of the Lion'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Wingspan',
        coverImageUrl: boardgameSeedCoverUrl('Wingspan'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Pandemic',
        coverImageUrl: boardgameSeedCoverUrl('Pandemic'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Pandemic Legacy: Season 1',
        coverImageUrl: boardgameSeedCoverUrl('Pandemic Legacy: Season 1'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Terraforming Mars',
        coverImageUrl: boardgameSeedCoverUrl('Terraforming Mars'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Spirit Island',
        coverImageUrl: boardgameSeedCoverUrl('Spirit Island'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Root',
        coverImageUrl: boardgameSeedCoverUrl('Root'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Brass: Birmingham',
        coverImageUrl: boardgameSeedCoverUrl('Brass: Birmingham'),
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
        kind: CatalogMediaKind.boardgame,
        title: 'Scythe',
        coverImageUrl: boardgameSeedCoverUrl('Scythe'),
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
      seedCatalogItem(
        id: 'seed-boardgame-11',
        kind: CatalogMediaKind.boardgame,
        title: 'Azul',
        coverImageUrl: boardgameSeedCoverUrl('Azul'),
        synopsis:
            'A tile-drafting game about decorating the walls of the Royal Palace of Evora.',
        publisher: 'Plan B Games',
        barcode: '700300000112',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 10, 1),
        ageRating: '8+',
        sortKey: 'azul-0001',
        creators: [
          {'name': 'Michael Kiesling', 'role': 'designer'},
        ],
        genres: ['abstract', 'tile placement', 'pattern building'],
      ),
      seedCatalogItem(
        id: 'seed-boardgame-12',
        kind: CatalogMediaKind.boardgame,
        title: '7 Wonders',
        coverImageUrl: boardgameSeedCoverUrl('7 Wonders'),
        synopsis:
            'A civilization card game where players develop a city and its wonder across three ages.',
        publisher: 'Repos Production',
        barcode: '700300000129',
        releaseYear: 2010,
        releaseDate: DateTime.utc(2010, 10, 1),
        ageRating: '10+',
        sortKey: '7-wonders-0001',
        creators: [
          {'name': 'Antoine Bauza', 'role': 'designer'},
        ],
        genres: ['card drafting', 'civilization', 'strategy'],
      ),
      seedCatalogItem(
        id: 'seed-boardgame-13',
        kind: CatalogMediaKind.boardgame,
        title: 'Catan',
        coverImageUrl: boardgameSeedCoverUrl('Catan'),
        synopsis:
            'Players collect resources and build settlements, roads, and cities on the island of Catan.',
        publisher: 'Catan Studio',
        barcode: '700300000136',
        releaseYear: 1995,
        releaseDate: DateTime.utc(1995, 1, 1),
        ageRating: '10+',
        sortKey: 'catan-0001',
        creators: [
          {'name': 'Klaus Teuber', 'role': 'designer'},
        ],
        genres: ['trading', 'negotiation', 'strategy'],
      ),
      seedCatalogItem(
        id: 'seed-boardgame-14',
        kind: CatalogMediaKind.boardgame,
        title: 'Ticket to Ride',
        coverImageUrl: boardgameSeedCoverUrl('Ticket to Ride'),
        synopsis:
            'A railway adventure where players claim routes and connect cities across a growing map.',
        publisher: 'Days of Wonder',
        barcode: '700300000143',
        releaseYear: 2004,
        releaseDate: DateTime.utc(2004, 5, 1),
        ageRating: '8+',
        sortKey: 'ticket-to-ride-0001',
        creators: [
          {'name': 'Alan R. Moon', 'role': 'designer'},
        ],
        genres: ['route building', 'family', 'strategy'],
      ),
      seedCatalogItem(
        id: 'seed-boardgame-15',
        kind: CatalogMediaKind.boardgame,
        title: 'Everdell',
        coverImageUrl: boardgameSeedCoverUrl('Everdell'),
        synopsis:
            'A woodland worker-placement game about building a thriving city of critters.',
        publisher: 'Starling Games',
        barcode: '700300000150',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 3, 1),
        ageRating: '10+',
        sortKey: 'everdell-0001',
        creators: [
          {'name': 'James A. Wilson', 'role': 'designer'},
        ],
        genres: ['worker placement', 'tableau building', 'strategy'],
      ),
    ];

List<BoardGameOwnedItem> boardgameSeedOwnedItems(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        BoardGameOwnedItem(
          // Keep a deterministic first ID so repeated seed runs remain
          // idempotent.
          id: BoardGameOwnedItemId(
            i == 1 ? 'seed-owned-bg-01' : 'seed-owned-bg-${seedOrdinal2(i)}',
          ),
          catalogRef: seedCatalogRef(
            CatalogMediaKind.boardgame,
            'seed-boardgame-${seedOrdinal2(i)}',
          ),
          createdAt: now.subtract(Duration(days: 600 - (i * 25))),
          updatedAt: now,
          isDigital: false,
          condition: i.isEven ? 'Near Mint' : 'Very Good',
          details: BoardgameOwnedDetails(
            editionLanguage: 'English',
            editionRegion: 'US',
            componentCondition: i.isEven ? 'Near Mint' : 'Very Good',
            componentCompleteness:
                i == 1 ? 'Complete' : 'Complete with inserts',
            missingPiecesNotes: i == 1 ? null : 'No missing components',
            isSleeved: i.isOdd,
            hasCustomInsert: i == 1,
            hasPaintedMiniatures: i <= 4,
            storageNotes: i == 1 ? 'Dedicated board-game cabinet' : null,
          ),
          purchaseDate: DateTime.utc(2017 + i, i % 12 + 1, 1),
          pricePaidCents: i == 1 ? 14000 : 4500 + (i * 250),
          currency: 'USD',
          personalNotes: i == 1
              ? 'All characters unlocked.'
              : 'Complete retail copy with rulebook and components.',
          quantity: 1,
          purchaseStore: i.isEven ? 'Local Game Store' : 'Miniature Market',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingStorageRecord> boardgameSeedTrackingStates(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        BoardGameTrackingState(
          // Keep a deterministic first tracking ID for idempotent seed runs.
          id: i == 1
              ? 'seed-track-06'
              : 'seed-track-boardgame-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef(
            CatalogMediaKind.boardgame,
            'seed-boardgame-${seedOrdinal2(i)}',
          ),
          ownedRef: seedOwnedRef(
            CatalogMediaKind.boardgame,
            i == 1 ? 'seed-owned-bg-01' : 'seed-owned-bg-${seedOrdinal2(i)}',
          ),
          sourceType: TrackingSourceType.physical,
          status: i == 1
              ? MediaTrackingStatus.paused
              : (i <= 6
                  ? MediaTrackingStatus.completed
                  : MediaTrackingStatus.inProgress),
          progressCurrent: i == 1 ? 35 : (i <= 6 ? 1 : 0),
          progressTotal: i == 1 ? 95 : 1,
          rating: 7 + (i % 4),
          startedAt: DateTime.utc(2024, i % 12 + 1, 5),
          finishedAt: i == 1 ? null : DateTime.utc(2024, i % 12 + 1, 20),
          notes: i == 1
              ? 'Scenario 35, paused for summer.'
              : 'Played with friends.',
          updatedAt: now,
        ),
    ];

List<BoardGamePlaySession> boardgameSeedPlaySessions(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        BoardGamePlaySession(
          id: 'seed-play-boardgame-${seedOrdinal2(i)}',
          boardGameId: 'seed-boardgame-${seedOrdinal2(i)}',
          date: now.subtract(Duration(days: i * 4)),
          players: const ['Alex', 'Sam', 'Mara'],
          winner: i.isEven ? 'Sam' : 'Alex',
          scores: [
            BoardGamePlayerScore(
              playerName: i.isEven ? 'Sam' : 'Alex',
              score: 80 + i,
              isWinner: true,
            ),
            const BoardGamePlayerScore(playerName: 'Mara', score: 64),
          ],
          durationMinutes: 60 + i * 5,
          location: i.isEven ? 'Game night' : 'Living room',
          notes: i == 1 ? 'Seed play session with complete score data.' : null,
        ),
    ];
