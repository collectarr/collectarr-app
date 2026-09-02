import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> tvSeedCatalogItems() {
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
      testCatalogItem(
        id: 'seed-tv-${seedOrdinal2(i + 1)}',
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
        sortKey: 'seed-tv-${seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetailsDto(
          seriesId: 'seed-series-tv-${seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: '1',
          volumeStartYear: 2008 + i,
          tags: 'tv, drama, seed',
        ),
        video: VideoCatalogDetails(
          runtimeMinutes: 46 + (i % 12),
          nrDiscs: 2 + (i % 3),
          subtitles: 'English, Spanish',
          audioTracks: 'English 5.1',
        ),
        publishing: CatalogPublishingDetailsDto(
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

List<OwnedItem> tvSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('tv', 10))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
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
    ];

List<TrackingEntry> tvSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 10; i++)
        TrackingEntry(
          id: 'seed-track-tv-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-tv-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-tv-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: MediaTrackingStatus.completed,
          rating: 8,
          timesCompleted: 1,
          updatedAt: now,
        ),
    ];
