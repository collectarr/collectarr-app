import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_display_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';

import '../../../helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_detail_page.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comics library config groups reusable media behavior', () {
    expect(comicsLibraryConfig.workspace.kind, CatalogMediaKind.comic);
    expect(comicsLibraryConfig.singularLabel, 'Comic');
    expect(comicsLibraryConfig.pluralLabel, 'Comics');
    expect(comicsLibraryConfig.defaultMetadataProvider, 'gcd');
    expect(comicsLibraryConfig.defaultSupportedMetadataProvider, 'gcd');
    expect(
        comicsLibraryConfig.defaultSupportedMetadataProviderOption?.id, 'gcd');
    expect(comicsLibraryConfig.supportsMetadataProvider('gcd'), isTrue);
    expect(comicsLibraryConfig.supportsMetadataProvider('comicvine'), isTrue);
    expect(
      comicsLibraryConfig.defaultMetadataProviderOption?.usagePolicy?.summary,
      contains('CC BY-SA'),
    );
    final apiKeyIds = comicsLibraryConfig.metadataProviders
        .where((provider) => provider.requiresApiKey)
        .map((p) => p.id)
        .toList();
    expect(apiKeyIds, contains('comicvine'));
    expect(comicsLibraryConfig.metadataProviderLabel('gcd'), 'GCD');
    expect(
      comicsLibraryConfig.metadataProviderLabel('comicvine'),
      'Comic Vine',
    );
    expect(
      comicsLibraryConfig.metadataProviderLabel('unknown-provider'),
      'unknown-provider',
    );
    expect(comicsLibraryConfig.trackingProfile, comicTrackingProfile);
    expect(comicsLibraryConfig.presentation, comicLibraryMediaPresentation);
    expect(
        comicsLibraryConfig.addDialogLauncher, same(showComicLibraryAddDialog));
    expect(
      comicsLibraryConfig.editDialogBuilder,
      same(buildComicLibraryEditDialog),
    );
    expect(comicsLibraryConfig.inspectorSectionsBuilder,
        same(buildComicInspectorSections));
    expect(comicKindModule.edit.editUsesTitleAsSeries, isTrue);
    expect(comicsLibraryConfig.countLabel(1), 'Comic');
    expect(comicsLibraryConfig.countLabel(2), 'Comics');
  });
  test('manga library config is a first-class comic-family kind', () {
    expect(mangaLibraryConfig.workspace.kind, CatalogMediaKind.manga);
    expect(mangaLibraryConfig.singularLabel, 'Manga');
    expect(mangaLibraryConfig.pluralLabel, 'Manga');
    expect(mangaLibraryConfig.defaultMetadataProvider, 'hardcover');
    expect(mangaLibraryConfig.defaultSupportedMetadataProvider, 'hardcover');
    expect(mangaLibraryConfig.supportsMetadataProvider('mangadex'), isTrue);
    expect(mangaLibraryConfig.supportsMetadataProvider('anilist'), isTrue);
    expect(mangaLibraryConfig.trackingProfile, comicTrackingProfile);
    expect(mangaLibraryConfig.presentation, mangaLibraryMediaPresentation);
    expect(mangaLibraryConfig.editDialogBuilder, isNotNull);
    expect(mangaLibraryConfig.countLabel(1), 'Manga');
    expect(mangaLibraryConfig.countLabel(2), 'Manga');
  });

  test('movies library config uses the dedicated add dialog launcher', () {
    expect(
        moviesLibraryConfig.addDialogLauncher, same(showMovieLibraryAddDialog));
    expect(movieKindModule.edit.editUsesTitleAsSeries, isFalse);
    expect(movieKindModule.hierarchy.mediaReleaseScopeLabel, 'Media');
    expect(moviesWorkspaceConfig.accent, const Color(0xFF42AA55));
    expect(
        libraryAccentForKind(CatalogMediaKind.anime), const Color(0xFFC94DFF));
    expect(libraryIconForKind(CatalogMediaKind.tv), Icons.tv_outlined);
    expect(movieKindModule.hierarchy.collectionExportTitleLabel, 'Title');
  });

  test('media/release scope labels are kind-owned', () {
    expect(comicKindModule.hierarchy.mediaReleaseScopeLabel, 'Series');
    expect(musicKindModule.hierarchy.mediaReleaseScopeLabel, 'Media');
    expect(bookKindModule.hierarchy.mediaReleaseScopeLabel, 'Media');
  });

  test('books do not create series subgroups for volume metadata', () {
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'Dune',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(
      libraryKindRuntimeForType(booksLibraryConfig)
          .subgroupKeyForEntry(item, 'series'),
      isNull,
    );
  });

  test('all active kinds declare an inspector panel builder', () {
    for (final config in [
      comicsLibraryConfig,
      mangaLibraryConfig,
      booksLibraryConfig,
      gamesLibraryConfig,
      boardGamesLibraryConfig,
      moviesLibraryConfig,
      tvLibraryConfig,
      animeLibraryConfig,
      musicLibraryConfig,
    ]) {
      expect(config.inspectorSectionsBuilder, isNotNull);
    }
  });

  test('anime and tv library configs are first-class video kinds', () {
    expect(animeLibraryConfig.workspace.kind, CatalogMediaKind.anime);
    expect(animeLibraryConfig.defaultMetadataProvider, 'anilist');
    expect(animeLibraryConfig.supportsMetadataProvider('anilist'), isTrue);
    expect(animeLibraryConfig.presentation.videoSeriesEntryTypes, {'anime'});

    expect(
      animeLibraryConfig.presentation.defaultVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      animeLibraryConfig.presentation.defaultVideoGrouping,
      VideoGroupingDefault.bySeries,
    );
    expect(animeLibraryConfig.editDialogBuilder, isNotNull);

    expect(tvLibraryConfig.workspace.kind, CatalogMediaKind.tv);
    expect(tvLibraryConfig.defaultMetadataProvider, 'tmdb');
    expect(tvLibraryConfig.supportsMetadataProvider('tmdb'), isTrue);
    expect(tvLibraryConfig.presentation.videoSeriesEntryTypes, {'tv'});
    expect(
      tvLibraryConfig.presentation.defaultVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      tvLibraryConfig.presentation.defaultVideoGrouping,
      VideoGroupingDefault.none,
    );
    expect(tvLibraryConfig.editDialogBuilder, isNotNull);
    expect(
        tvLibraryConfig.detailPageBuilder, same(buildVideoLibraryDetailPage));
  });

  test('movie library config keeps flat title/work defaults', () {
    expect(
      moviesLibraryConfig.presentation.defaultVideoDisplayLevel,
      VideoDisplayLevel.titleWork,
    );
    expect(
      moviesLibraryConfig.presentation.defaultVideoGrouping,
      VideoGroupingDefault.none,
    );
  });

  test('tv edit presentation splits media and release tabs', () {
    const context = LibraryEditPresentationContext(
      isOwned: false,
      isTrackingOnly: false,
      hasTrackingContext: false,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: true,
      hasEditionAnchors: true,
      hasBundleReleaseAnchors: false,
      hasCustomFields: false,
    );

    final mediaTabs = tvKindModule.edit.presentation
        .builderForScope(LibraryEditScope.media)
        .buildTabs(context: context);
    final releaseTabs = tvKindModule.edit.presentation
        .builderForScope(LibraryEditScope.release)
        .buildTabs(context: context);

    expect(mediaTabs.any((tab) => tab.id == 'episodes'), isTrue);
    expect(mediaTabs.any((tab) => tab.id == 'release_media'), isFalse);
    expect(mediaTabs.any((tab) => tab.id == 'episode_map'), isTrue);
    expect(releaseTabs.any((tab) => tab.id == 'episodes'), isTrue);
    expect(releaseTabs.any((tab) => tab.id == 'release_media'), isTrue);
    expect(releaseTabs.any((tab) => tab.id == 'episode_map'), isFalse);
  });

  test('index reassignment capability is kind-owned', () {
    expect(comicsLibraryConfig.capabilities.supportsIndexReassignment, isTrue);
    expect(mangaLibraryConfig.capabilities.supportsIndexReassignment, isTrue);
    expect(moviesLibraryConfig.capabilities.supportsIndexReassignment, isFalse);
    expect(booksLibraryConfig.capabilities.supportsIndexReassignment, isFalse);
  });

  test('collection export title labels are kind-owned', () {
    expect(comicKindModule.hierarchy.collectionExportTitleLabel, 'Series');
    expect(musicKindModule.hierarchy.collectionExportTitleLabel, 'Release');
    expect(bookKindModule.hierarchy.collectionExportTitleLabel, 'Title');
  });

  test('books library config enables creator spotlight in shared hero chrome',
      () {
    expect(booksLibraryConfig.capabilities.showsCreatorSpotlight, isTrue);
    expect(booksLibraryConfig.supportsReadingQueue, isTrue);
    expect(booksLibraryConfig.supportsMediaReleaseSplit, isTrue);
    expect(moviesLibraryConfig.capabilities.showsCreatorSpotlight, isFalse);
    expect(moviesLibraryConfig.supportsReadingQueue, isFalse);
  });

  test('book and boardgame configs own their scoped browser options', () {
    expect(
      booksLibraryConfig.availableGroupModesForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      booksLibraryConfig.availableGroupModesForBrowserMode(
        LibraryWorkspaceBrowserMode.releases,
      ),
      isNotEmpty,
    );
    expect(
      booksLibraryConfig.availableSortColumnsForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      libraryKindRuntimeForType(boardGamesLibraryConfig)
          .fields
          .sorts
          .map((d) => d.id.value),
      contains('boardgame.title'),
    );
  });

  test('edit scope follows the active browser mode', () {
    expect(
      booksLibraryConfig.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      LibraryEditScope.media,
    );
    expect(
      booksLibraryConfig.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.releases,
      ),
      LibraryEditScope.release,
    );
  });

  test('library type config can carry an add dialog launcher override', () {
    Future<LibraryAddDialogResult?> fakeLauncher(
      BuildContext context,
      LibraryAddDialogRequest request,
    ) {
      return Future.value(
        const LibraryAddDialogResult(
          target: LibraryAddTarget.owned,
          itemIds: ['comic-1'],
        ),
      );
    }

    final config = LibraryTypeConfig(
      workspace: comicsWorkspaceConfig,
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
      defaultMetadataProvider: 'gcd',
      metadataProviders: const [gcdMetadataProvider],
      trackingProfile: comicTrackingProfile,
      addDialogLauncher: fakeLauncher,
    );

    expect(config.addDialogLauncher, same(fakeLauncher));
  });

  test('library type config can carry an edit dialog builder override', () {
    Widget fakeBuilder(BuildContext context, LibraryEditDialogRequest request) {
      return const SizedBox.shrink();
    }

    final config = LibraryTypeConfig(
      workspace: comicsWorkspaceConfig,
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
      defaultMetadataProvider: 'gcd',
      metadataProviders: const [gcdMetadataProvider],
      trackingProfile: comicTrackingProfile,
      editDialogBuilder: fakeBuilder,
    );

    expect(config.editDialogBuilder, same(fakeBuilder));
  });

  test('library type config can carry a detail page builder override', () {
    Widget fakeBuilder(BuildContext context, LibraryDetailPageRequest request) {
      return const SizedBox.shrink();
    }

    final config = LibraryTypeConfig(
      workspace: comicsWorkspaceConfig,
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
      defaultMetadataProvider: 'gcd',
      metadataProviders: const [gcdMetadataProvider],
      trackingProfile: comicTrackingProfile,
      detailPageBuilder: fakeBuilder,
    );

    expect(config.detailPageBuilder, same(fakeBuilder));
  });

  test('library type registry resolves supported media kinds and providers',
      () {
    expect(collectarrLibraryTypes.supportedKinds, [
      'comic',
      'manga',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'anime',
      'music',
    ]);
    expect(collectarrLibraryTypes.byKind(CatalogMediaKind.comic),
        comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind(CatalogMediaKind.manga),
        mangaLibraryConfig);
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.game)
            ?.defaultMetadataProvider,
        'igdb');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.boardgame)
            ?.defaultMetadataProvider,
        'bgg');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.book)
            ?.defaultMetadataProvider,
        'openlibrary');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.movie)
            ?.defaultMetadataProvider,
        'tmdb');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.tv)
            ?.defaultMetadataProvider,
        'tmdb');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.anime)
            ?.defaultMetadataProvider,
        'anilist');
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.music)
            ?.defaultMetadataProvider,
        'musicbrainz');
    expect(collectarrLibraryTypes.byKind(CatalogMediaKind.unknown), isNull);
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.comic)
          .map((row) => row.id),
      containsAll(['gcd', 'comicvine']),
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.manga)
          .map((row) => row.id),
      ['hardcover', 'comicvine', 'anilist', 'mangadex'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.book)
          .map((row) => row.id),
      ['openlibrary', 'hardcover'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.game)
          .map((row) => row.id),
      ['igdb'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.boardgame)
          .map((row) => row.id),
      ['bgg'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.movie)
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.tv)
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.anime)
          .map((row) => row.id),
      ['anilist'],
    );
    expect(
      collectarrLibraryTypes
          .providersForKind(CatalogMediaKind.music)
          .map((row) => row.id),
      ['musicbrainz'],
    );
    expect(collectarrLibraryTypes.providersForKind(CatalogMediaKind.unknown),
        isEmpty);
    expect(
      collectarrLibraryTypes.byKind(CatalogMediaKind.movie)?.addDialogLauncher,
      same(showMovieLibraryAddDialog),
    );
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.movie)
            ?.editDialogBuilder,
        isNotNull);
    expect(
        collectarrLibraryTypes
            .byKind(CatalogMediaKind.movie)
            ?.detailPageBuilder,
        isNotNull);
  });

  test('all registered kinds declare an explicit edit dialog builder', () {
    for (final kind in collectarrLibraryTypes.supportedKinds) {
      expect(
        collectarrLibraryTypes
            .byKind(catalogMediaKindFromValue(kind))
            ?.editDialogBuilder,
        isNotNull,
        reason: 'Expected $kind to declare an explicit edit dialog builder.',
      );
    }
  });

  test('library kind registry covers all active kinds', () {
    expect(
      collectarrLibraryTypes.supportedKinds,
      containsAll([
        'comic',
        'manga',
        'book',
        'game',
        'boardgame',
        'movie',
        'tv',
        'anime',
        'music',
      ]),
    );
    for (final kind in collectarrLibraryTypes.supportedKinds) {
      expect(
        libraryKindRuntime(catalogMediaKindFromValue(kind)),
        isNotNull,
        reason: 'Missing runtime for $kind.',
      );
    }
  });

  test('transferable field keys are kind-owned', () {
    expect(bookKindModule.transfer.transferableFieldKeys,
        kDefaultTransferableFieldKeys);
    expect(
      comicKindModule.transfer.transferableFieldKeys,
      containsAll(comicTransferableFieldKeys),
    );
    expect(bookKindModule.transfer.transferableFieldKeys,
        isNot(contains('keyComic')));
  });

  test('add wording chrome is kind-owned', () {
    expect(
      LibraryAddReferenceType.media.labelForType(booksLibraryConfig),
      'Media',
    );
    expect(
      LibraryAddReferenceType.media.labelForType(musicLibraryConfig),
      'Album',
    );
    expect(
      musicLibraryConfig.addChrome.trackScopeSummary,
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
    );
    expect(
      LibraryAddReferenceType.edition.helperLabelForType(musicLibraryConfig),
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
    );
    expect(
      moviesLibraryConfig.presentation.videoSeriesEntryTypes,
      {'tv'},
    );
    expect(
      moviesLibraryConfig.presentation.videoShelfDrilldownEntryTypes,
      {'movie', 'tv', 'anime'},
    );
    expect(
      moviesLibraryConfig.addChrome.videoKindFilterOptions
          .map((option) => option.label),
      ['Movies', 'Box Sets'],
    );
    expect(
      moviesLibraryConfig.addChrome.defaultVideoKindFilters,
      {'movie'},
    );
  });

  test('comic kind uses dedicated edit dialog builder', () {
    expect(comicsLibraryConfig.editDialogBuilder,
        same(buildComicLibraryEditDialog));
  });

  test('music kind uses dedicated edit dialog builder', () {
    expect(musicLibraryConfig.editDialogBuilder,
        same(buildMusicLibraryEditDialog));
  });

  test('game kinds use dedicated edit dialog builders', () {
    expect(
        gamesLibraryConfig.editDialogBuilder, same(buildGameLibraryEditDialog));
    expect(boardGamesLibraryConfig.editDialogBuilder,
        same(buildBoardGameLibraryEditDialog));
  });

  test('video physical formats are variants under movies', () {
    expect(
      videoPhysicalMediaFormats.map((format) => format.id),
      ['dvd', 'blu-ray', '4k-uhd', 'vhs', 'laserdisc', 'digital'],
    );
    expect(physicalMediaFormatById(' blu-ray ')?.label, 'Blu-ray');
    expect(physicalMediaFormatById('bluray')?.label, 'Blu-ray');
    expect(physicalMediaFormatById('4k blu-ray')?.label, '4K UHD');
    expect(physicalMediaFormatById('digital')?.variantType, 'digital');
  });

  test('comics runtime exposes reusable workspace table behavior', () {
    final comicRuntime = libraryKindRuntime(CatalogMediaKind.comic);
    expect(comicRuntime.type, comicsLibraryConfig);
    expect(
      comicRuntime.viewProfile.type.workspace.kind,
      CatalogMediaKind.comic,
    );
    expect(comicRuntime.columnDisplayName('comic.series'), 'Series');
    expect(comicRuntime.columnLabel('cover'), '');
    expect(
      comicRuntime.columnGroup('location'),
      LibraryTableColumnGroup.personal,
    );
    expect(comicRuntime.columnIsNumeric('price'), isTrue);
    expect(
      comicRuntime.columnSort('comic.release_date'),
      'comic.release_date',
    );
    expect(
      comicsTableColumnPresets.map((preset) => preset.label),
      ['Essential', 'Ownership', 'Value', 'Full'],
    );
    expect(
      comicRuntime.orderedTableColumns(const {}).first,
      'comic.status',
    );
  });

  test('kind runtimes cover workspace defaults', () {
    expect(collectarrLibraryTypes.supportedKinds, [
      'comic',
      'manga',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'anime',
      'music',
    ]);
    expect(libraryKindRuntime(CatalogMediaKind.book).type, booksLibraryConfig);
    expect(libraryKindRuntime(CatalogMediaKind.boardgame).type,
        boardGamesLibraryConfig);
    expect(libraryKindRuntime(CatalogMediaKind.manga).type, mangaLibraryConfig);
    expect(libraryKindRuntime(CatalogMediaKind.tv).type, tvLibraryConfig);
    expect(libraryKindRuntime(CatalogMediaKind.anime).type, animeLibraryConfig);
    expect(
      libraryKindRuntime(CatalogMediaKind.movie)
          .viewProfile
          .defaults()
          .visibleColumns
          .contains('movie.title'),
      isTrue,
    );
    expect(libraryKindRuntime(CatalogMediaKind.music).type, musicLibraryConfig);
    expect(
      libraryKindRuntime(CatalogMediaKind.game).columnSort('game.release_date'),
      'game.release_date',
    );
    expect(
      libraryKindRuntime(CatalogMediaKind.movie).columnLabel('variant'),
      'Variant',
    );
    expect(
      libraryKindRuntime(CatalogMediaKind.game).columnLabel('variant'),
      'Variant',
    );
    expect(
      libraryKindRuntime(CatalogMediaKind.book).columnLabel('barcode'),
      'Barcode',
    );
    expect(
      libraryKindRuntime(CatalogMediaKind.book).tableColumnWidth(
        'title',
        {'title': 999},
      ),
      520,
    );
    expect(musicLibraryConfig.availableGroupModes, [
      'music.artist',
      'music.publisher',
      'music.format',
      'music.country',
      'music.condition',
      'music.location',
    ]);
    expect(
      booksLibraryConfig.presentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['title_asc', 'release_latest', 'recent', 'value_desc'],
    );
    expect(booksLibraryConfig.availableGroupModes, [
      'book.author',
      'book.publisher',
      'book.series',
      'book.format',
      'book.condition',
      'book.location',
    ]);
    expect(gamesLibraryConfig.availableGroupModes, [
      'game.platform',
      'game.publisher',
      'game.franchise',
      'game.location',
      'game.completeness',
    ]);
    expect(comicsLibraryConfig.presentation.externalFacetBucketIdsByMode.keys, [
      'comic.story_arc',
      'comic.character',
    ]);
    expect(
      comicsLibraryConfig.presentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['series_issue', 'recent', 'publisher_date', 'value_desc'],
    );
    expect(
      comicsLibraryConfig.presentation.columnFavorites
          .map((preset) => preset.label),
      comicsTableColumnPresets.map((preset) => preset.label),
    );
    expect(booksLibraryConfig.presentation.compactBucketIcon, Icons.folder);
    expect(
      moviesLibraryConfig.presentation.compactBucketIcon,
      Icons.movie_filter_outlined,
    );
    expect(
      musicLibraryConfig.presentation.compactBucketIcon,
      Icons.person_2_outlined,
    );
    expect(booksLibraryConfig.presentation.emptyStateProviderSummarySuffix, '');
    expect(
      moviesLibraryConfig.presentation.emptyStateProviderSummarySuffix,
      ' Physical formats are tracked as editions.',
    );
    expect(moviesLibraryConfig.availableGroupModes, [
      'movie.director',
      'movie.publisher',
      'movie.genre',
      'movie.release_year',
      'movie.audience_rating',
      'movie.movie_or_tv_series',
      'movie.format',
      'movie.audio_tracks',
      'movie.edition_release_date',
      'movie.location',
    ]);
  });
}
