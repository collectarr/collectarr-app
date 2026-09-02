import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> mangaSeedCatalogItems() {
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
      testCatalogItem(
        id: 'seed-manga-${seedOrdinal2(i + 1)}',
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
        sortKey: 'seed-manga-${seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetailsDto(
          seriesId: 'seed-series-manga-${seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: '${i + 1}',
          volumeStartYear: 1999 + i,
          tags: 'manga, seed',
        ),
        publishing: CatalogPublishingDetailsDto(
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

List<OwnedItem> mangaSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('manga', 10))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
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

List<TrackingEntry> mangaSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 10; i++)
        TrackingEntry(
          id: 'seed-track-manga-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-manga-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-manga-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: MediaTrackingStatus.inProgress,
          progressCurrent: i,
          progressTotal: 12,
          rating: 8,
          updatedAt: now,
        ),
    ];
