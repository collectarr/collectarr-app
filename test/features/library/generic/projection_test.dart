import 'dart:typed_data';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_data_factories.dart';

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

final _defaultViewState = LibraryWorkspaceViewState(
  viewMode: LibraryViewMode.grid,
  detailsLayout: LibraryDetailsLayout.hidden,
  isSidebarVisible: true,
  sortColumn: LibrarySortColumn.title,
  sortAscending: true,
  coverSize: 128,
  sidebarWidth: 200,
  detailsWidth: 300,
  detailsHeight: 220,
  visibleColumns: const {},
  columnWidths: const {},
);

void main() {
  test('projection sorts filtered items through adapter rules', () {
    final shelf = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Owned later issue',
            itemNumber: '10',
          ),
          ownedItem: testOwnedItem(
            id: 'owned-1',
            itemId: 'comic-1',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
        ShelfEntry(
          itemId: 'comic-2',
          catalogItem: CatalogItem(
            id: 'comic-2',
            kind: 'comic',
            title: 'Missing issue',
            itemNumber: '1',
          ),
        ),
        ShelfEntry(
          itemId: 'comic-3',
          catalogItem: CatalogItem(
            id: 'comic-3',
            kind: 'comic',
            title: 'Owned earlier issue',
            itemNumber: '2',
          ),
          ownedItem: testOwnedItem(
            id: 'owned-3',
            itemId: 'comic-3',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      ],
      ownedCount: 2,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final projection = LibraryProjection.fromShelf(
      shelf: shelf,
      type: comicsLibraryConfig,
      adapter: comicsMediaAdapter,
      viewState: _defaultViewState.copyWith(
        sortRules: const [
          LibrarySortRule(column: LibrarySortColumn.status, ascending: true),
          LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
        ],
      ),
      query: '',
      selectedBucket: null,
      selectedItemId: null,
      quickView: null,
      groupMode: LibraryGroupMode.series,
    );

    expect(
      projection.filteredItems.map((item) => item.entry.title),
      ['Owned earlier issue', 'Owned later issue', 'Missing issue'],
    );
  });

  test('projection service builds the same merged workspace projection', () {
    final shelf = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Merged issue',
            itemNumber: '1',
          ),
          ownedItem: testOwnedItem(
            id: 'owned-1',
            itemId: 'comic-1',
            condition: 'Near Mint',
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      ],
      ownedCount: 1,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final projection = const LibraryProjectionService().build(
      shelf: shelf,
      type: comicsLibraryConfig,
      adapter: comicsMediaAdapter,
      viewState: _defaultViewState,
      query: '',
      selectedBucket: null,
      selectedItemId: null,
      quickView: null,
      groupMode: LibraryGroupMode.series,
    );

    expect(projection.allItems, hasLength(1));
    expect(projection.filteredItems.single.entry.title, 'Merged issue');
    expect(projection.filteredItems.single.source.ownedItem?.condition,
        'Near Mint');
  });

  test('projection applies ancestor bucket scopes to current group buckets',
      () {
    final shelf = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'movie-1',
          catalogItem: CatalogItem(
            id: 'movie-1',
            kind: 'movie',
            title: 'Alpha 2020',
            series: const CatalogSeriesDetails(seriesTitle: 'Alpha'),
            releaseDate: DateTime.utc(2020, 1, 1),
          ),
        ),
        ShelfEntry(
          itemId: 'movie-2',
          catalogItem: CatalogItem(
            id: 'movie-2',
            kind: 'movie',
            title: 'Alpha 2021',
            series: const CatalogSeriesDetails(seriesTitle: 'Alpha'),
            releaseDate: DateTime.utc(2021, 1, 1),
          ),
        ),
        ShelfEntry(
          itemId: 'movie-3',
          catalogItem: CatalogItem(
            id: 'movie-3',
            kind: 'movie',
            title: 'Beta 2021',
            series: const CatalogSeriesDetails(seriesTitle: 'Beta'),
            releaseDate: DateTime.utc(2021, 1, 1),
          ),
        ),
      ],
      ownedCount: 0,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final projection = LibraryProjection.fromShelf(
      shelf: shelf,
      type: moviesLibraryConfig,
      adapter: moviesMediaAdapter,
      viewState: _defaultViewState,
      query: '',
      selectedBucket: null,
      selectedItemId: null,
      quickView: null,
      groupMode: LibraryGroupMode.year,
      bucketScopeFilters: const [
        LibraryBucketScopeFilter(
          groupMode: LibraryGroupMode.series,
          bucket: 'Alpha',
        ),
      ],
    );

    expect(
      projection.filteredItems.map((item) => item.entry.title),
      ['Alpha 2020', 'Alpha 2021'],
    );
    expect(
      projection.buckets.map((bucket) => bucket.title),
      ['[All Movies]', '2020', '2021'],
    );
  });

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

  test('series grouping does not drill into title buckets', () {
    expect(
      libraryAllowsGroupDrilldown(
        currentMode: LibraryGroupMode.series,
        childMode: LibraryGroupMode.title,
      ),
      isFalse,
    );
    expect(
      libraryAllowsGroupDrilldown(
        currentMode: LibraryGroupMode.series,
        childMode: null,
      ),
      isFalse,
    );
  });

  test('other drilldowns still remain enabled', () {
    expect(
      libraryAllowsGroupDrilldown(
        currentMode: LibraryGroupMode.publisher,
        childMode: LibraryGroupMode.title,
      ),
      isTrue,
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
      genericBucketForItemMode(
          item, musicLibraryConfig, LibraryGroupMode.series),
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
        locationPath: 'Office › Shelf A › Short Box 1',
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

  test('movie main grouping uses release and video metadata', () {
    final item = _projectionItem(
      source: ShelfEntry(
        itemId: 'movie-main-1',
        ownedItem: testOwnedItem(
          id: 'owned-main-1',
          itemId: 'movie-main-1',
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      ),
      entry: LibraryWorkspaceEntry(
        id: 'movie-main-1',
        mediaType: 'movie',
        title: 'Twin Peaks: Fire Walk with Me',
        publisher: 'New Line Cinema',
        releaseDate: DateTime.utc(1992, 8, 28),
        releaseYear: 1992,
        genres: const ['Drama'],
        country: 'USA',
        language: 'English',
        audienceRating: '8.1',
        video: const VideoCatalogDetails(color: 'Color'),
        series: const CatalogSeriesDetails(seasonNumber: 1),
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
    );

    expect(
      genericGroupModeLabel(LibraryGroupMode.publisher, moviesLibraryConfig),
      'Studios',
    );
    expect(
      genericGroupModeLabel(LibraryGroupMode.genre, moviesLibraryConfig),
      'Genres',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.audienceRating),
      '8.1',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.color),
      'Color',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.movieOrTvSeries),
      'TV Series',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.releaseDate),
      '1992-08-28',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.releaseMonth),
      'August 1992',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.releaseYear),
      '1992',
    );
  });

  test(
      'comic CLZ grouping uses crossover, imprint, series group, and cover date',
      () {
    final item = _projectionItem(
      source: const ShelfEntry(itemId: 'comic-main-1'),
      entry: LibraryWorkspaceEntry(
        id: 'comic-main-1',
        mediaType: 'comic',
        title: 'Batman #608',
        coverDate: DateTime.utc(2002, 10, 1),
        crossover: 'Hush',
        publishing: const CatalogPublishingDetails(
          imprint: 'DC Black Label',
          seriesGroup: 'Batman Events',
        ),
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
    );

    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.crossover),
      'Hush',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.imprint),
      'DC Black Label',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.seriesGroup),
      'Batman Events',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.coverDate),
      '2002-10-01',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.coverMonth),
      'October 2002',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.coverYear),
      '2002',
    );
  });

  test('comic creator grouping resolves extended CLZ roles', () {
    final item = _projectionItem(
      source: const ShelfEntry(itemId: 'comic-credits-1'),
      entry: LibraryWorkspaceEntry(
        id: 'comic-credits-1',
        mediaType: 'comic',
        title: 'Spawn #1',
        creators: const [
          {'name': 'Scott Williams', 'role': 'Inker'},
          {'name': 'Brian Haberlin', 'role': 'Cover Colorist'},
          {'name': 'Tom Orzechowski', 'role': 'Letterer'},
          {'name': 'Neil Gaiman', 'role': 'Plotter'},
          {'name': 'Tom DeFalco', 'role': 'Editor in Chief'},
        ],
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
    );

    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.inker),
      'Scott Williams',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.coverColorist),
      'Brian Haberlin',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.plotter),
      'Neil Gaiman',
    );
    expect(
      genericBucketForItemMode(
          item, comicsLibraryConfig, LibraryGroupMode.editorInChief),
      'Tom DeFalco',
    );
  });

  test('movie personal grouping uses owned and tracking fields', () {
    final source = ShelfEntry(
      itemId: 'movie-1',
      locationPath: 'Living Room › Shelf 2',
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'movie-1',
        editionId: 'edition-4k',
        createdAt: DateTime.utc(2024, 9, 30),
        condition: 'Sealed',
        purchaseDate: DateTime.utc(2024, 11, 6),
        purchaseStore: 'Orbit DVD',
        storageDevice: 'NAS',
        collectionStatus: 'Backlog',
        boxSetName: 'Nolan Collection',
        features: 'Commentary',
        hdrFormats: const ['HDR10'],
        packaging: 'Steelbook',
        distributor: 'Warner Home Video',
        region: 'B',
        ownerUserId: 'user-1',
        ownerLabel: 'me@example.com',
        tags: 'favorite, sci-fi',
        updatedAt: DateTime.utc(2026, 4, 2),
      ),
      wishlistItem: WishlistItem(
        id: 'wish-1',
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        createdAt: DateTime.utc(2024, 10, 1),
        updatedAt: DateTime.utc(2024, 10, 1),
      ),
      trackingEntry: TrackingEntry(
        id: 'tracking-1',
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        rating: 9,
        status: 'Completed',
        finishedAt: DateTime.utc(2026, 4, 10),
        updatedAt: DateTime.utc(2026, 4, 10),
      ),
      watchSessions: [
        WatchSession(
          id: 'watch-2',
          targetRef: testCatalogRef('movie-1', kind: 'movie'),
          watchedAt: DateTime.utc(2026, 4, 10),
          sourceType: TrackingSourceType.streaming,
          updatedAt: DateTime.utc(2026, 4, 10),
        ),
        WatchSession(
          id: 'watch-1',
          targetRef: testCatalogRef('movie-1', kind: 'movie'),
          watchedAt: DateTime.utc(2026, 4, 9),
          sourceType: TrackingSourceType.physical,
          updatedAt: DateTime.utc(2026, 4, 9),
        ),
      ],
      itemImages: [
        ItemImage(
          id: 'img-1',
          ownedItemId: 'owned-1',
          imageType: 'back_cover',
          imageData: Uint8List.fromList('data'.codeUnits),
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      ],
    );
    final item = _projectionItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: 'movie-1',
        mediaType: 'movie',
        title: 'Blade Runner 2049',
        isOwned: true,
        condition: 'Sealed',
        locationPath: 'Living Room › Shelf 2',
        tags: 'favorite, sci-fi',
        video: const VideoCatalogDetails(
          audioTracks: 'English DTS-HD MA',
          subtitles: 'English, Romanian',
          layers: 'BD-100',
          screenRatio: '2.39:1',
        ),
        referenceEditionId: 'edition-4k',
        editions: [
          CatalogEdition(
            id: 'edition-4k',
            title: '4K UHD',
            releaseDate: DateTime.utc(2023, 10, 12),
            physicalFormat: '4k_uhd',
            physicalFormatLabel: '4K UHD',
            region: 'A/B/C',
          ),
        ],
        updatedAt: source.updatedAt,
      ),
    );

    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.audioTracks),
      'English DTS-HD MA',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.boxSet),
      'Nolan Collection',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.distributor),
      'Warner Home Video',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.editionReleaseDate),
      '2023-10-12',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.editionReleaseMonth),
      'October 2023',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.editionReleaseYear),
      '2023',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.extras),
      'Commentary',
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
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.addedDate),
      '2024-09-30',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.addedMonth),
      'September 2024',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.addedYear),
      '2024',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.format),
      '4K UHD',
    );
    expect(
      genericBucketForItemMode(item, moviesLibraryConfig, LibraryGroupMode.hdr),
      'HDR10',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.imageType),
      'Back Cover',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.layers),
      'BD-100',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.myRating),
      '9',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.owner),
      'me@example.com',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.packaging),
      'Steelbook',
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
          item, moviesLibraryConfig, LibraryGroupMode.regions),
      'A/B/C',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.screenRatios),
      '2.39:1',
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
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.watchDate),
      '2026-04-10',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.watchMonth),
      'April 2026',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.watchYear),
      '2026',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.watched),
      'Watched',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.subtitles),
      'English, Romanian',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.watchedWhere),
      'Streaming',
    );
  });

  test('movie cast and crew grouping uses role aliases', () {
    final item = _projectionItem(
      source: ShelfEntry(
        itemId: 'movie-credits-1',
        ownedItem: testOwnedItem(
          id: 'owned-credits-1',
          itemId: 'movie-credits-1',
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      ),
      entry: LibraryWorkspaceEntry(
        id: 'movie-credits-1',
        mediaType: 'movie',
        title: 'Heat',
        isOwned: true,
        creators: const [
          {'name': 'Al Pacino', 'role': 'Cast'},
          {'name': 'Michael Mann', 'role': 'Director'},
          {'name': 'Elliot Goldenthal', 'role': 'Original Music Composer'},
          {'name': 'Dante Spinotti', 'role': 'Director of Photography'},
          {'name': 'Art Linson', 'role': 'Producer'},
          {'name': 'Michael Mann', 'role': 'Writer'},
        ],
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
    );

    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.actor),
      'Al Pacino',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.director),
      'Michael Mann',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.musician),
      'Elliot Goldenthal',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.photography),
      'Dante Spinotti',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.producer),
      'Art Linson',
    );
    expect(
      genericBucketForItemMode(
          item, moviesLibraryConfig, LibraryGroupMode.writer),
      'Michael Mann',
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

    expect(
      libraryEntryMatchesLinkedMetadataFilter(
          entry, 'Image', comicsMediaAdapter),
      isTrue,
    );
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        entry,
        'Brian K. Vaughan',
        comicsMediaAdapter,
      ),
      isTrue,
    );
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        entry,
        'Sci-Fi',
        comicsMediaAdapter,
      ),
      isTrue,
    );
  });

  test('linked metadata filter does not fall back to fuzzy matches', () {
    final entry = LibraryWorkspaceEntry(
      id: 'movie-1',
      mediaType: 'movie',
      title: 'Blade Runner 2049',
      publisher: 'Warner Bros.',
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(
          entry, 'Blade', comicsMediaAdapter),
      isFalse,
    );
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
          entry, 'Warner', comicsMediaAdapter),
      isFalse,
    );
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

  test('music projection can search only tracks', () {
    final shelf = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'album-1',
          catalogItem: CatalogItem(
            id: 'album-1',
            kind: 'music',
            title: 'Lupus Dei',
            music: const MusicCatalogDetails(
              tracks: [
                CatalogTrack(title: 'Lupus Daemonis (Intro)', position: 1),
                CatalogTrack(title: 'Prayer In The Dark', position: 3),
              ],
            ),
          ),
        ),
        ShelfEntry(
          itemId: 'album-2',
          catalogItem: CatalogItem(
            id: 'album-2',
            kind: 'music',
            title: 'Bible of the Beast',
            music: const MusicCatalogDetails(
              tracks: [
                CatalogTrack(title: 'Raise Your Fist, Evangelist', position: 1),
              ],
            ),
          ),
        ),
      ],
      ownedCount: 0,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final projection = LibraryProjection.fromShelf(
      shelf: shelf,
      type: musicLibraryConfig,
      adapter: musicMediaAdapter,
      viewState: _defaultViewState,
      query: 'prayer',
      selectedBucket: null,
      selectedItemId: null,
      quickView: null,
      groupMode: LibraryGroupMode.series,
      searchTarget: LibrarySearchTarget.tracksOnly,
    );

    expect(projection.filteredItems, hasLength(1));
    expect(projection.filteredItems.first.entry.id, 'album-1');
  });

  test('music projection can search only albums', () {
    final shelf = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'album-1',
          catalogItem: CatalogItem(
            id: 'album-1',
            kind: 'music',
            title: 'Lupus Dei',
            music: const MusicCatalogDetails(
              tracks: [
                CatalogTrack(title: 'Prayer In The Dark', position: 3),
              ],
            ),
          ),
        ),
      ],
      ownedCount: 0,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final projection = LibraryProjection.fromShelf(
      shelf: shelf,
      type: musicLibraryConfig,
      adapter: musicMediaAdapter,
      viewState: _defaultViewState,
      query: 'prayer',
      selectedBucket: null,
      selectedItemId: null,
      quickView: null,
      groupMode: LibraryGroupMode.series,
      searchTarget: LibrarySearchTarget.mediaOnly,
    );

    expect(projection.filteredItems, isEmpty);
  });
}
