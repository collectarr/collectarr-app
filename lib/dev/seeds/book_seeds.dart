import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';

Iterable<BookTrackingUnit> bookSeedTrackingUnits(
  Iterable<CatalogItem> items,
  DateTime now,
) sync* {
  for (final item in items.where((item) => item.kind == 'book')) {
    final volumeNumber = _seedBookInt(item.itemNumber) ?? 1;
    yield BookTrackingUnit(
      id: 'seed-unit-book-${item.id}',
      targetRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      volumeNumber: volumeNumber,
      chapterNumber: 1,
      completedAt: now.subtract(const Duration(days: 4)),
      updatedAt: now,
    );
  }
}

int? _seedBookInt(String? value) => int.tryParse(value ?? '');

CatalogItem enrichBookSeedItem(CatalogItem item) {
  final editions = [
    for (final edition in seedEditionPayloads(item))
      {
        ...edition,
        'id': edition['id']?.toString() ?? '${item.id}-edition-01',
        'kind': 'book',
        'work_id': item.id,
        'display_title': edition['title'] ?? item.editionTitle ?? item.title,
        'format': edition['format'] ?? item.physicalFormat,
        'binding': edition['binding'] ?? item.physicalFormat,
        'publisher': edition['publisher'] ?? item.publisher,
        'isbn': edition['isbn'] ?? item.barcode,
        'language': edition['language'] ?? item.payload['language'],
        'region': edition['region'] ?? item.payload['country'],
        'publication_date': edition['release_date'] ??
            item.releaseDate?.toUtc().toIso8601String(),
        'page_count': item.payload['page_count'],
      },
  ];
  return withSeedPayload(item, {'editions': editions});
}

List<CatalogItem> bookSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-book-01',
        kind: 'book',
        title: 'Dune',
        displayTitle: 'Dune (Deluxe Edition)',
        synopsis:
            'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the "spice" melange.',
        publisher: 'Ace Books / Penguin Random House',
        releaseYear: 1965,
        releaseDate: DateTime.utc(1965, 8, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg',
        editionTitle: 'Deluxe Hardcover Edition',
        physicalFormat: 'Hardcover',
        physicalFormatLabel: 'Deluxe Hardcover with Poster',
        barcode: '9780441172719',
        variant: 'Deluxe Hardcover',
        country: 'US',
        language: 'en',
        ageRating: 'Adult',
        sortKey: 'dune-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-dune-chronicles',
          seriesTitle: 'Dune Chronicles',
          volumeName: 'Dune',
          volumeNumber: '1',
          volumeStartYear: 1965,
          tags: 'sci-fi, space opera, politics, ecology',
        ),
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 688,
          coverPriceCents: 4000,
          currency: 'USD',
          imprint: 'Ace',
        ),
        creators: [
          {'name': 'Frank Herbert', 'role': 'author'},
        ],
        characters: [
          'Paul Atreides',
          'Lady Jessica',
          'Duke Leto Atreides',
          'Baron Vladimir Harkonnen',
          'Chani'
        ],
        storyArcs: ['Arrakis Revolt'],
        genres: ['science fiction', 'space opera', 'philosophical fiction'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-dune-deluxe',
            title: 'Dune Deluxe Edition',
            format: 'Hardcover',
            publisher: 'Ace Books',
            isbn: '9780593099322',
            releaseDate: DateTime.utc(2019, 10, 1),
            variants: [
              CatalogVariant(
                id: 'seed-var-dune-deluxe',
                name: 'Deluxe Hardcover w/ Stained Edges',
                variantType: 'physical',
                isbn: '9780593099322',
                coverPriceCents: 4000,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
          CatalogEdition(
            id: 'seed-ed-dune-pb',
            title: 'Mass Market Paperback',
            format: 'Paperback',
            publisher: 'Ace Books',
            isbn: '9780441172719',
            releaseDate: DateTime.utc(1990, 9, 1),
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-book-02',
        kind: 'book',
        title: 'Dune Messiah',
        displayTitle: 'Dune Messiah',
        synopsis:
            'Twelve years after his conquest, Emperor Paul Atreides faces a complex conspiracy of enemies including the Bene Gesserit, the Spacing Guild, and the Tleilaxu Face Dancers.',
        publisher: 'Ace Books',
        releaseYear: 1969,
        releaseDate: DateTime.utc(1969, 10, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441172696-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441172696-L.jpg',
        editionTitle: 'Trade Paperback',
        physicalFormat: 'Paperback',
        barcode: '9780441172696',
        country: 'US',
        language: 'en',
        sortKey: 'dune-0002',
        itemNumber: '2',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-dune-chronicles',
          seriesTitle: 'Dune Chronicles',
          volumeName: 'Dune Messiah',
          volumeNumber: '2',
          volumeStartYear: 1965,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 336, coverPriceCents: 1700, currency: 'USD'),
        creators: [
          {'name': 'Frank Herbert', 'role': 'author'},
        ],
        characters: [
          'Paul Atreides',
          'Alia Atreides',
          'Chani',
          'Hayt (Duncan Idaho)',
          'Princess Irulan'
        ],
        genres: ['science fiction', 'tragedy', 'political fiction'],
      ),
      seedCatalogItem(
        id: 'seed-book-03',
        kind: 'book',
        title: 'Foundation',
        displayTitle: 'Foundation',
        synopsis:
            'For twelve thousand years the Galactic Empire has ruled supreme. Now it is dying. Only Hari Seldon, creator of the revolutionary science of psychohistory, can foresee the dark age ahead.',
        publisher: 'Gnome Press / Bantam Spectra',
        releaseYear: 1951,
        releaseDate: DateTime.utc(1951, 5, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553293357-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553293357-L.jpg',
        editionTitle: 'Mass Market Paperback',
        physicalFormat: 'Paperback',
        barcode: '9780553293357',
        country: 'US',
        language: 'en',
        sortKey: 'foundation-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-foundation',
          seriesTitle: 'Foundation Series',
          volumeName: 'Foundation',
          volumeNumber: '1',
          volumeStartYear: 1951,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 256, coverPriceCents: 899, currency: 'USD'),
        creators: [
          {'name': 'Isaac Asimov', 'role': 'author'},
        ],
        characters: [
          'Hari Seldon',
          'Salvor Hardin',
          'Hober Mallow',
          'Gaal Dornick'
        ],
        genres: ['science fiction', 'galactic empire', 'hard sci-fi'],
      ),
      seedCatalogItem(
        id: 'seed-book-04',
        kind: 'book',
        title: 'Neuromancer',
        displayTitle: 'Neuromancer (Sprawl Trilogy Book 1)',
        synopsis:
            'Case had been the sharpest data-thief in the business, until ex-employers crippled his nervous system. Now a charismatic stranger offers him a cure in exchange for hacking an unthinkably powerful artificial intelligence.',
        publisher: 'Ace Books',
        releaseYear: 1984,
        releaseDate: DateTime.utc(1984, 7, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441569595-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780441569595-L.jpg',
        editionTitle: 'Ace Science Fiction Special',
        physicalFormat: 'Paperback',
        barcode: '9780441569595',
        country: 'US',
        language: 'en',
        sortKey: 'neuromancer-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-sprawl',
          seriesTitle: 'Sprawl Trilogy',
          volumeName: 'Sprawl',
          volumeNumber: '1',
          volumeStartYear: 1984,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 271, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'William Gibson', 'role': 'author'},
        ],
        characters: [
          'Henry Dorsett Case',
          'Molly Millions',
          'Armitage',
          'Wintermute',
          'Neuromancer'
        ],
        genres: ['cyberpunk', 'science fiction', 'neo-noir'],
      ),
      seedCatalogItem(
        id: 'seed-book-05',
        kind: 'book',
        title: 'The Hobbit',
        displayTitle: 'The Hobbit: 75th Anniversary Illustrated Edition',
        synopsis:
            'Bilbo Baggins is a hobbit who enjoys a comfortable and unambitious life, rarely traveling any farther than his pantry or cellar. But his contentment is disturbed when the wizard Gandalf and a company of thirteen dwarves arrive.',
        publisher: 'Houghton Mifflin Harcourt',
        releaseYear: 1937,
        releaseDate: DateTime.utc(1937, 9, 21),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg',
        editionTitle: '75th Anniversary Illustrated Edition',
        physicalFormat: 'Hardcover',
        barcode: '9780547928227',
        country: 'GB',
        language: 'en',
        sortKey: 'middle-earth-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-middle-earth',
          seriesTitle: 'Middle-earth Legendarium',
          volumeName: 'The Hobbit',
          volumeNumber: '1',
          volumeStartYear: 1937,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 320, coverPriceCents: 3500, currency: 'USD'),
        creators: [
          {'name': 'J.R.R. Tolkien', 'role': 'author & illustrator'},
        ],
        characters: [
          'Bilbo Baggins',
          'Gandalf',
          'Thorin Oakenshield',
          'Smaug',
          'Gollum'
        ],
        genres: ['high fantasy', 'adventure', 'children\'s literature'],
      ),
      seedCatalogItem(
        id: 'seed-book-06',
        kind: 'book',
        title: '1984',
        displayTitle: 'Nineteen Eighty-Four',
        synopsis:
            'Winston Smith toils for the Ministry of Truth, rewriting history to conform to the state\'s ever-changing narrative. Deep within his heart, Winston longs to rebel against the omnipresent Big Brother.',
        publisher: 'Secker & Warburg / Signet Classics',
        releaseYear: 1949,
        releaseDate: DateTime.utc(1949, 6, 8),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
        editionTitle: 'Centennial Edition',
        physicalFormat: 'Paperback',
        barcode: '9780451524935',
        country: 'GB',
        language: 'en',
        sortKey: 'nineteen-eighty-four-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 328, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'George Orwell', 'role': 'author'},
        ],
        characters: ['Winston Smith', 'Julia', 'O\'Brien', 'Big Brother'],
        genres: ['dystopian', 'political fiction', 'social science fiction'],
      ),
      seedCatalogItem(
        id: 'seed-book-07',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        displayTitle:
            'The Fellowship of the Ring (The Lord of the Rings Book 1)',
        synopsis:
            'Frodo Baggins inherits the One Ring of power forged by the Dark Lord Sauron. Accompanied by eight companions, he sets out on an impossible quest toward Mount Doom.',
        publisher: 'Houghton Mifflin / HarperCollins',
        releaseYear: 1954,
        releaseDate: DateTime.utc(1954, 7, 29),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780618346257-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780618346257-L.jpg',
        editionTitle: '50th Anniversary Hardcover',
        physicalFormat: 'Hardcover',
        barcode: '9780618346257',
        country: 'GB',
        language: 'en',
        sortKey: 'middle-earth-0002',
        itemNumber: '2',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-middle-earth',
          seriesTitle: 'Middle-earth Legendarium',
          volumeName: 'The Lord of the Rings',
          volumeNumber: '1',
          volumeStartYear: 1954,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 432, coverPriceCents: 2600, currency: 'USD'),
        creators: [
          {'name': 'J.R.R. Tolkien', 'role': 'author'},
        ],
        characters: [
          'Frodo Baggins',
          'Samwise Gamgee',
          'Gandalf',
          'Aragorn',
          'Legolas',
          'Gimli'
        ],
        genres: ['high fantasy', 'epic', 'adventure'],
      ),
      seedCatalogItem(
        id: 'seed-book-08',
        kind: 'book',
        title: 'Hyperion',
        displayTitle: 'Hyperion (Hyperion Cantos Book 1)',
        synopsis:
            'On the world called Hyperion, beyond the reach of galactic law, waits a creature called the Shrike. On the eve of Armageddon, seven pilgrims set forth on a final voyage to Hyperion seeking answers to the unsolved riddles of their lives.',
        publisher: 'Doubleday / Bantam Spectra',
        releaseYear: 1989,
        releaseDate: DateTime.utc(1989, 5, 26),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553283686-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553283686-L.jpg',
        editionTitle: 'Hugo Award Winning Edition',
        physicalFormat: 'Paperback',
        barcode: '9780553283686',
        country: 'US',
        language: 'en',
        sortKey: 'hyperion-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-hyperion',
          seriesTitle: 'Hyperion Cantos',
          volumeName: 'Hyperion',
          volumeNumber: '1',
          volumeStartYear: 1989,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 482, coverPriceCents: 1099, currency: 'USD'),
        creators: [
          {'name': 'Dan Simmons', 'role': 'author'},
        ],
        characters: [
          'The Consul',
          'Father Lenar Hoyt',
          'Colonel Fedmahn Kassad',
          'Martin Silenus',
          'The Shrike'
        ],
        genres: ['space opera', 'science fiction', 'frame narrative'],
      ),
      seedCatalogItem(
        id: 'seed-book-09',
        kind: 'book',
        title: 'Snow Crash',
        displayTitle: 'Snow Crash',
        synopsis:
            'In reality, Hiro Protagonist delivers pizza for Uncle Enzo\'s CosoNostra Pizza Inc. But in the Metaverse he\'s a warrior prince. Plunging headlong into the enigma of a new computer virus that\'s striking down hackers everywhere.',
        publisher: 'Bantam Books',
        releaseYear: 1992,
        releaseDate: DateTime.utc(1992, 6, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553380958-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780553380958-L.jpg',
        editionTitle: 'Trade Paperback Edition',
        physicalFormat: 'Paperback',
        barcode: '9780553380958',
        country: 'US',
        language: 'en',
        sortKey: 'snow-crash-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 480, coverPriceCents: 1800, currency: 'USD'),
        creators: [
          {'name': 'Neal Stephenson', 'role': 'author'},
        ],
        characters: [
          'Hiro Protagonist',
          'Y.T.',
          'Uncle Enzo',
          'Raven',
          'L. Bob Rife'
        ],
        genres: ['cyberpunk', 'satire', 'science fiction'],
      ),
      seedCatalogItem(
        id: 'seed-book-10',
        kind: 'book',
        title: 'Ender\'s Game',
        displayTitle: 'Ender\'s Game',
        synopsis:
            'In order to develop a secure defense against a hostile alien race\'s next attack, government agencies breed child geniuses and train them in Battle School. Ender Wiggin may be the military commander they desperately need.',
        publisher: 'Tor Books',
        releaseYear: 1985,
        releaseDate: DateTime.utc(1985, 1, 15),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780812550702-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780812550702-L.jpg',
        editionTitle: 'Tor Science Fiction Edition',
        physicalFormat: 'Paperback',
        barcode: '9780812550702',
        country: 'US',
        language: 'en',
        sortKey: 'enders-game-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-ender',
          seriesTitle: 'Enderverse',
          volumeName: 'Ender\'s Saga',
          volumeNumber: '1',
          volumeStartYear: 1985,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 352, coverPriceCents: 899, currency: 'USD'),
        creators: [
          {'name': 'Orson Scott Card', 'role': 'author'},
        ],
        characters: [
          'Andrew "Ender" Wiggin',
          'Valentine Wiggin',
          'Peter Wiggin',
          'Colonel Graff',
          'Bean'
        ],
        genres: ['military sci-fi', 'science fiction', 'space warfare'],
      ),
      seedCatalogItem(
        id: 'seed-book-11',
        kind: 'book',
        title: 'Fahrenheit 451',
        displayTitle: 'Fahrenheit 451: 60th Anniversary Edition',
        synopsis:
            'Guy Montag is a fireman whose job is to burn books, which are forbidden and the source of all discord. But when he meets an eccentric young neighbor, Montag begins questioning everything he knows.',
        publisher: 'Simon & Schuster',
        releaseYear: 1953,
        releaseDate: DateTime.utc(1953, 10, 19),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg',
        editionTitle: '60th Anniversary Paperback',
        physicalFormat: 'Paperback',
        barcode: '9781451673319',
        country: 'US',
        language: 'en',
        sortKey: 'fahrenheit-451-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 256, coverPriceCents: 1700, currency: 'USD'),
        creators: [
          {'name': 'Ray Bradbury', 'role': 'author'},
        ],
        characters: [
          'Guy Montag',
          'Clarisse McClellan',
          'Captain Beatty',
          'Faber'
        ],
        genres: ['dystopian', 'science fiction'],
      ),
      seedCatalogItem(
        id: 'seed-book-12',
        kind: 'book',
        title: 'Brave New World',
        displayTitle: 'Brave New World',
        synopsis:
            'A futuristic World State where citizens are environmentally engineered into an intelligence-based social hierarchy, while sleep-learning, psychological conditioning, and the soothing drug soma keep the populace docile.',
        publisher: 'Harper Perennial',
        releaseYear: 1932,
        releaseDate: DateTime.utc(1932, 2, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg',
        editionTitle: 'Perennial Classics Edition',
        physicalFormat: 'Paperback',
        barcode: '9780060850524',
        country: 'GB',
        language: 'en',
        sortKey: 'brave-new-world-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 288, coverPriceCents: 1699, currency: 'USD'),
        creators: [
          {'name': 'Aldous Huxley', 'role': 'author'},
        ],
        characters: [
          'Bernard Marx',
          'John the Savage',
          'Lenina Crowne',
          'Mustapha Mond'
        ],
        genres: ['dystopian', 'science fiction', 'philosophical'],
      ),
      seedCatalogItem(
        id: 'seed-book-13',
        kind: 'book',
        title: 'The Way of Kings',
        displayTitle: 'The Way of Kings (The Stormlight Archive Book 1)',
        synopsis:
            'Roshar is a world of stone and storms. Centuries have passed since the fall of the ten consecrated orders known as the Knights Radiant, but their Shardblades and Shardplate remain: mystical weapons that turn ordinary men into near-invincible warriors.',
        publisher: 'Tor Books',
        releaseYear: 2010,
        releaseDate: DateTime.utc(2010, 8, 31),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780765365279-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780765365279-L.jpg',
        editionTitle: 'Trade Paperback Edition',
        physicalFormat: 'Hardcover',
        barcode: '9780765365279',
        country: 'US',
        language: 'en',
        sortKey: 'stormlight-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-stormlight',
          seriesTitle: 'The Stormlight Archive',
          volumeName: 'The Way of Kings',
          volumeNumber: '1',
          volumeStartYear: 2010,
          tags: 'high fantasy, epic, cosmere',
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 1007, coverPriceCents: 3799, currency: 'USD'),
        creators: [
          {'name': 'Brandon Sanderson', 'role': 'author'},
          {'name': 'Michael Whelan', 'role': 'cover artist'},
        ],
        characters: [
          'Kaladin Stormblessed',
          'Shallan Davar',
          'Dalinar Kholin',
          'Szeth-son-son-Vallano',
          'Wit'
        ],
        genres: ['epic fantasy', 'high fantasy'],
      ),
      seedCatalogItem(
        id: 'seed-book-14',
        kind: 'book',
        title: 'The Name of the Wind',
        displayTitle:
            'The Name of the Wind (The Kingkiller Chronicle: Day One)',
        synopsis:
            'Told in Kvothe\'s own voice, this is the tale of the magically gifted young man who grows to be the most notorious wizard his world has ever seen.',
        publisher: 'DAW Books',
        releaseYear: 2007,
        releaseDate: DateTime.utc(2007, 3, 27),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780756404741-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780756404741-L.jpg',
        editionTitle: '10th Anniversary Deluxe Hardcover',
        physicalFormat: 'Hardcover',
        barcode: '9780756404741',
        country: 'US',
        language: 'en',
        sortKey: 'kingkiller-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-kingkiller',
          seriesTitle: 'The Kingkiller Chronicle',
          volumeName: 'The Kingkiller Chronicle',
          volumeNumber: '1',
          volumeStartYear: 2007,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 662, coverPriceCents: 2995, currency: 'USD'),
        creators: [
          {'name': 'Patrick Rothfuss', 'role': 'author'},
        ],
        characters: ['Kvothe', 'Denna', 'Bast', 'Chronicler', 'Elodin'],
        genres: ['heroic fantasy', 'high fantasy', 'coming-of-age'],
      ),
      seedCatalogItem(
        id: 'seed-book-15',
        kind: 'book',
        title: 'Project Hail Mary',
        displayTitle: 'Project Hail Mary',
        synopsis:
            'Ryland Grace is the sole survivor on a desperate, last-chance mission-and if he fails, humanity and the Earth itself will perish. Except that right now, he doesn\'t even remember his own name.',
        publisher: 'Ballantine Books',
        releaseYear: 2021,
        releaseDate: DateTime.utc(2021, 5, 4),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780593135204-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780593135204-L.jpg',
        editionTitle: 'First Edition Hardcover',
        physicalFormat: 'Hardcover',
        barcode: '9780593135204',
        country: 'US',
        language: 'en',
        sortKey: 'project-hail-mary-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 496, coverPriceCents: 2899, currency: 'USD'),
        creators: [
          {'name': 'Andy Weir', 'role': 'author'},
        ],
        characters: ['Ryland Grace', 'Rocky', 'Eva Stratt'],
        genres: ['hard science fiction', 'space exploration', 'first contact'],
      ),
    ];

List<OwnedItem> bookSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('book', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 300)),
          updatedAt: now,
          isDigital: false,
          condition: 'Near Mint',
          details: const BookOwnedDetails(
            signedBy: 'Facsimile author signature',
            dustJacketPresent: true,
            dustJacketCondition: 'Fine',
          ),
          purchaseDate: DateTime.utc(2021, 10, 1),
          pricePaidCents: 2499,
          currency: 'USD',
          personalNotes: 'Deluxe physical copy on library shelf.',
          quantity: 1,
          rating: 9,
          readStatus: 'completed',
          startedAt: DateTime.utc(2021, 10, 5),
          finishedAt: DateTime.utc(2021, 10, 20),
          purchaseStore: 'Barnes & Noble',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> bookSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-book-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-book-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-book-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 10
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2021, 10, 1),
          finishedAt: i <= 10 ? DateTime.utc(2021, 10, 25) : null,
          timesCompleted: 1,
          updatedAt: now,
        ),
    ];
