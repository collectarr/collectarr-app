import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/shared/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('other drilldowns still remain enabled', () {
    expect(
      libraryAllowsGroupDrilldown(
        currentMode: 'publisher',
        childMode: 'title',
      ),
      isTrue,
    );
  });

  test('music grouping fallbacks use unknown artist and label buckets', () {
    final item = const MusicWorkspaceProjector().project(
      source: const ShelfEntry(itemId: 'music-1'),
      node: const LibraryTitleNodeRef('music-1'),
    );

    expect(
      genericBucketForItemMode(item, musicLibraryConfig, 'series'),
      'Unknown artist',
    );

    expect(
      genericBucketForItemMode(item, musicLibraryConfig, 'publisher'),
      'Unknown label',
    );

    expect(
      genericBucketForItemMode(item, musicLibraryConfig, 'location'),
      'No location',
    );
  });

  test('location grouping uses structured location path when available', () {
    final item = const ComicWorkspaceProjector().project(
      source: const ShelfEntry(
        itemId: 'comic-1',
        locationPath: 'Office › Shelf A › Short Box 1',
      ),
      node: const LibraryTitleNodeRef('comic-1'),
    );

    expect(
      genericGroupModeLabel('location', comicsLibraryConfig),
      'Location',
    );

    expect(
      genericGroupModeSidebarTitle('location', comicsLibraryConfig),
      'Locations',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'location'),
      'Office › Shelf A › Short Box 1',
    );
  });

  test('movie main grouping uses release and video metadata', () {
    final item = VideoLibraryWorkspaceProjector(kind: 'movie').project(
      source: ShelfEntry(
        itemId: 'movie-main-1',
        catalogItem: const CatalogItemDto(
          id: 'movie-main-1',
          kind: 'movie',
          title: 'Twin Peaks: Fire Walk with Me',
          publisher: 'New Line Cinema',
        ),
        ownedItem: testOwnedItem(
          id: 'owned-main-1',
          itemId: 'movie-main-1',
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      ),
      node: const LibraryTitleNodeRef('movie-main-1'),
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'publisher'),
      'New Line Cinema',
    );
  });

  test('comic grouping maps crossover imprint and series group', () {
    final item = const ComicWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'comic-main-1',
          kind: 'comic',
          title: 'Batman #608',
          crossover: 'Hush',
          publishing: const CatalogPublishingDetails(
            imprint: 'DC Black Label',
            seriesGroup: 'Batman Events',
          ),
          comic: const CatalogComicDetails(
            coverDate: DateTime.utc(2002, 10, 1),
          ),
        ),
      ),
      node: const LibraryTitleNodeRef('comic-main-1'),
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'crossover'),
      'Hush',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'imprint'),
      'DC Black Label',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'series_group'),
      'Batman Events',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'cover_date'),
      '2002-10-01',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'cover_month'),
      'October 2002',
    );

    expect(
      genericBucketForItemMode(item, comicsLibraryConfig, 'cover_year'),
      '2002',
    );
  });

  test('movie creator grouping resolves cast director composer and crew', () {
    final item = VideoLibraryWorkspaceProjector(kind: 'movie').project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'movie-credits-1',
          kind: 'movie',
          title: 'Heat',
          creators: [
            {'name': 'Al Pacino', 'role': 'Cast'},
            {'name': 'Michael Mann', 'role': 'Director'},
            {'name': 'Elliot Goldenthal', 'role': 'Original Music Composer'},
            {'name': 'Dante Spinotti', 'role': 'Director of Photography'},
            {'name': 'Art Linson', 'role': 'Producer'},
            {'name': 'Michael Mann', 'role': 'Writer'},
          ],
        ),
        ownedItem: testOwnedItem(
          id: 'owned-credits-1',
          itemId: 'movie-credits-1',
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      ),
      node: const LibraryTitleNodeRef('movie-credits-1'),
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'actor'),
      'Al Pacino',
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'director'),
      'Michael Mann',
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'musician'),
      'Elliot Goldenthal',
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'photography'),
      'Dante Spinotti',
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'producer'),
      'Art Linson',
    );

    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, 'writer'),
      'Michael Mann',
    );
  });

  test('linked metadata filter matches exact metadata values', () {
    final item = const ComicWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga #1',
          publisher: 'Image',
          creators: [
            {'name': 'Brian K. Vaughan', 'role': 'Writer'},
          ],
          genres: ['Sci-Fi'],
        ),
      ),
      node: LibraryTitleNodeRef('comic-1'),
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(item, 'Image', comicsMediaAdapter),
      isTrue,
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(item, 'Brian K. Vaughan', comicsMediaAdapter),
      isTrue,
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(item, 'Sci-Fi', comicsMediaAdapter),
      isTrue,
    );
  });

  test('linked metadata filter does not fall back to fuzzy matches', () {
    final item = VideoLibraryWorkspaceProjector(kind: 'movie').project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Blade Runner 2049',
          publisher: 'Warner Bros.',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(item, 'Blade', comicsMediaAdapter),
      isFalse,
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(item, 'Warner', comicsMediaAdapter),
      isFalse,
    );
  });

  test('series buckets include owned completion percentages', () {
    final item1 = const ComicWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga #1',
          series: CatalogSeriesDetails(seriesTitle: 'Saga'),
        ),
        ownedItem: testOwnedItem(id: 'o1', itemId: 'comic-1'),
      ),
      node: const LibraryTitleNodeRef('comic-1'),
    );
    final item2 = const ComicWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'comic-2',
          kind: 'comic',
          title: 'Saga #2',
          series: CatalogSeriesDetails(seriesTitle: 'Saga'),
        ),
      ),
      node: const LibraryTitleNodeRef('comic-2'),
    );
    final item3 = const ComicWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'comic-3',
          kind: 'comic',
          title: 'Paper Girls #1',
          series: CatalogSeriesDetails(seriesTitle: 'Paper Girls'),
        ),
        ownedItem: testOwnedItem(id: 'o3', itemId: 'comic-3'),
      ),
      node: const LibraryTitleNodeRef('comic-3'),
    );

    final buckets = groupLibraryItems([item1, item2, item3], groupMode: 'series', type: comicsLibraryConfig);
    expect(buckets.map((b) => b.label), containsAll(['Saga', 'Paper Girls']));
  });
}
