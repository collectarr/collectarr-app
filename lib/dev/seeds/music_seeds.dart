import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> musicSeedCatalogItems() => [
      testCatalogItem(
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
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-radiohead',
          seriesTitle: 'Radiohead',
          tags: 'alternative rock, art rock',
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
        publishing: const CatalogPublishingDetailsDto(
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
      testCatalogItem(
        id: 'seed-music-02',
        kind: 'music',
        title: 'Kid A',
        synopsis:
            'Radiohead\'s radical departure into electronic and experimental territory.',
        publisher: 'XL Recordings',
        releaseYear: 2000,
        releaseDate: DateTime.utc(2000, 10, 2),
        sortKey: 'radiohead-0004',
        series: const CatalogSeriesDetailsDto(
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
      testCatalogItem(
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
      testCatalogItem(
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
        publishing: const CatalogPublishingDetailsDto(
          imprint: 'Top Dawg Entertainment',
        ),
        creators: [
          {'name': 'Kendrick Lamar', 'role': 'artist'},
          {'name': 'Dr. Dre', 'role': 'producer'},
        ],
        storyArcs: ['Compton Chronicles'],
        genres: ['hip hop', 'concept album', 'west coast'],
      ),
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
      testCatalogItem(
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
          {'name': 'Bj├╢rk', 'role': 'artist'},
          {'name': 'Mark Bell', 'role': 'producer'},
        ],
        genres: ['electronic', 'experimental', 'trip hop'],
      ),
      testCatalogItem(
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
      testCatalogItem(
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

List<OwnedItem> musicSeedOwnedItems(DateTime now) => [
      OwnedItem(
        id: 'seed-owned-music-01',
        catalogRef: seedCatalogRef('seed-music-01'),
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
        details: const MusicOwnedDetails(
          storageDevice: 'Shelf A',
          storageSlot: 'R-3',
        ),
      ),
      OwnedItem(
        id: 'seed-owned-music-07',
        catalogRef: seedCatalogRef('seed-music-07'),
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
    ];

List<TrackingEntry> musicSeedTrackingEntries(DateTime now) => [
      TrackingEntry(
        id: 'seed-track-04',
        catalogRef: seedCatalogRef('seed-music-01'),
        ownedItemId: 'seed-owned-music-01',
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
        rating: 9,
        timesCompleted: 50,
        notes: 'All-time favorite album',
        updatedAt: now,
      ),
    ];
