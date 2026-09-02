import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

List<CatalogItem> animeSeedCatalogItems() {
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
      testCatalogItem(
        id: 'seed-anime-${seedOrdinal2(i + 1)}',
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
        sortKey: 'seed-anime-${seedOrdinal2(i + 1)}',
        itemNumber: '${i + 1}',
        series: CatalogSeriesDetailsDto(
          seriesId: 'seed-series-anime-${seedOrdinal2(i + 1)}',
          seriesTitle: titles[i],
          volumeName: titles[i],
          volumeNumber: '1',
          volumeStartYear: 1998 + i,
          tags: 'anime, seed',
        ),
        video: VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 2 + (i % 2),
          subtitles: 'Japanese, English',
          audioTracks: 'Japanese 2.0, English 2.0',
        ),
        publishing: CatalogPublishingDetailsDto(
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

List<OwnedItem> animeSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('anime', 10))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
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
    ];

List<TrackingEntry> animeSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 10; i++)
        TrackingEntry(
          id: 'seed-track-anime-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-anime-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-anime-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i.isEven
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          progressCurrent: i.isEven ? null : 8,
          progressTotal: i.isEven ? null : 12,
          rating: 9,
          updatedAt: now,
        ),
    ];
