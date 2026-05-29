import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryProjectionItem _projectionItem({
  required ShelfEntry source,
  required LibraryWorkspaceEntry entry,
}) {
  return LibraryProjectionItem(
    source: source,
    entry: entry,
    node: LibraryBrowserNode(
      id: entry.id,
      scope: LibraryBrowserScope.title,
      titleItemId: entry.id,
      entry: entry,
    ),
  );
}

void main() {
  test('music grouping labels use artist and label terminology', () {
    expect(
      genericGroupModeLabel(LibraryGroupMode.series, musicLibraryConfig),
      'Artist',
    );
    expect(
      genericGroupModeSidebarTitle(LibraryGroupMode.series, musicLibraryConfig),
      'Artists',
    );
    expect(
      genericGroupModeLabel(LibraryGroupMode.publisher, musicLibraryConfig),
      'Label',
    );
    expect(
      genericGroupModeSidebarTitle(
        LibraryGroupMode.publisher,
        musicLibraryConfig,
      ),
      'Labels',
    );
  });

  test('music grouping fallbacks use unknown artist and label buckets', () {
    final item = _projectionItem(
      source: const ShelfEntry(itemId: 'music-1'),
      entry: LibraryWorkspaceEntry(
        id: 'music-1',
        mediaType: 'music',
        title: '',
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      genericBucketForItemMode(item, musicLibraryConfig, LibraryGroupMode.series),
      'Unknown artist',
    );
    expect(
      genericBucketForItemMode(
        item,
        musicLibraryConfig,
        LibraryGroupMode.publisher,
      ),
      'Unknown label',
    );
    expect(
      genericBucketForItemMode(
        item,
        musicLibraryConfig,
        LibraryGroupMode.location,
      ),
      'No location',
    );
  });

  test('location grouping uses structured location path when available', () {
    final item = _projectionItem(
      source: const ShelfEntry(itemId: 'comic-1'),
      entry: LibraryWorkspaceEntry(
        id: 'comic-1',
        mediaType: 'comic',
        title: 'Saga #1',
        storageBox: 'Office › Shelf A › Short Box 1',
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      genericGroupModeLabel(LibraryGroupMode.location, comicsLibraryConfig),
      'Location',
    );
    expect(
      genericGroupModeSidebarTitle(
        LibraryGroupMode.location,
        comicsLibraryConfig,
      ),
      'Locations',
    );
    expect(
      genericBucketForItemMode(
        item,
        comicsLibraryConfig,
        LibraryGroupMode.location,
      ),
      'Office › Shelf A › Short Box 1',
    );
  });

  test('movie personal grouping uses owned and tracking fields', () {
    final source = ShelfEntry(
      itemId: 'movie-1',
      locationPath: 'Living Room › Shelf 2',
      ownedItem: OwnedItem(
        id: 'owned-1',
        itemId: 'movie-1',
        condition: 'Sealed',
        purchaseDate: DateTime.utc(2024, 11, 6),
        purchaseStore: 'Orbit DVD',
        storageDevice: 'NAS',
        collectionStatus: 'Backlog',
        tags: 'favorite, sci-fi',
        updatedAt: DateTime.utc(2026, 4, 2),
      ),
      trackingEntry: TrackingEntry(
        id: 'tracking-1',
        itemId: 'movie-1',
        rating: 9,
        status: 'Completed',
        finishedAt: DateTime.utc(2026, 4, 10),
        updatedAt: DateTime.utc(2026, 4, 10),
      ),
    );
    final item = _projectionItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: 'movie-1',
        mediaType: 'movie',
        title: 'Blade Runner 2049',
        isOwned: true,
        condition: 'Sealed',
        storageBox: 'Living Room › Shelf 2',
        tags: 'favorite, sci-fi',
        updatedAt: source.updatedAt,
      ),
    );

    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.collectionStatus,
      ),
      'Backlog',
    );
    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, LibraryGroupMode.myRating),
      '9',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.purchaseDate,
      ),
      '2024-11-06',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.purchaseMonth,
      ),
      'November 2024',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.purchaseYear,
      ),
      '2024',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.purchaseStore,
      ),
      'Orbit DVD',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.storageDevice,
      ),
      'NAS',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.modifiedDate,
      ),
      '2026-04-10',
    );
    expect(
      genericBucketForItemMode(
        item,
        moviesLibraryConfig,
        LibraryGroupMode.modifiedMonth,
      ),
      'April 2026',
    );
    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, LibraryGroupMode.watched),
      'Watched',
    );
  });

  test('linked metadata filter matches exact metadata values', () {
    final entry = LibraryWorkspaceEntry(
      id: 'comic-1',
      mediaType: 'comic',
      title: 'Saga #1',
      publisher: 'Image',
      creators: const [
        {'name': 'Brian K. Vaughan', 'role': 'Writer'},
      ],
      genres: const ['Sci-Fi'],
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(libraryEntryMatchesLinkedMetadataFilter(entry, 'Image'), isTrue);
    expect(
      libraryEntryMatchesLinkedMetadataFilter(entry, 'Brian K. Vaughan'),
      isTrue,
    );
    expect(libraryEntryMatchesLinkedMetadataFilter(entry, 'Sci-Fi'), isTrue);
  });

  test('linked metadata filter does not fall back to fuzzy matches', () {
    final entry = LibraryWorkspaceEntry(
      id: 'movie-1',
      mediaType: 'movie',
      title: 'Blade Runner 2049',
      publisher: 'Warner Bros.',
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(libraryEntryMatchesLinkedMetadataFilter(entry, 'Blade'), isFalse);
    expect(libraryEntryMatchesLinkedMetadataFilter(entry, 'Warner'), isFalse);
  });

  test('series buckets include owned completion percentages', () {
    final items = [
      _projectionItem(
        source: const ShelfEntry(itemId: 'comic-1'),
        entry: LibraryWorkspaceEntry(
          id: 'comic-1',
          mediaType: 'comic',
          title: 'Saga #1',
          isOwned: true,
          series: const CatalogSeriesDetails(seriesTitle: 'Saga'),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
      _projectionItem(
        source: const ShelfEntry(itemId: 'comic-2'),
        entry: LibraryWorkspaceEntry(
          id: 'comic-2',
          mediaType: 'comic',
          title: 'Saga #2',
          series: const CatalogSeriesDetails(seriesTitle: 'Saga'),
          updatedAt: DateTime(2026, 1, 2),
        ),
      ),
      _projectionItem(
        source: const ShelfEntry(itemId: 'comic-3'),
        entry: LibraryWorkspaceEntry(
          id: 'comic-3',
          mediaType: 'comic',
          title: 'Paper Girls #1',
          isOwned: true,
          series: const CatalogSeriesDetails(seriesTitle: 'Paper Girls'),
          updatedAt: DateTime(2026, 1, 3),
        ),
      ),
    ];

    final buckets = libraryBucketsForItems(
      items,
      comicsLibraryConfig,
      LibraryGroupMode.series,
    );

    final allBucket = buckets.firstWhere(
      (bucket) => bucket.title == genericAllBucketLabel(comicsLibraryConfig),
    );
    final sagaBucket = buckets.firstWhere((bucket) => bucket.title == 'Saga');

    expect(allBucket.ownedCount, 2);
    expect(allBucket.completionPercent, 67);
    expect(sagaBucket.ownedCount, 1);
    expect(sagaBucket.completionPercent, 50);
  });
}