import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_detail_page.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestPresentationBuilder extends LibraryMediaPresentationBuilder {
  const _TestPresentationBuilder();

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    throw UnimplementedError();
  }
}

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
    expect(comicsLibraryConfig.presentation, comicsLibraryMediaPresentation);
    expect(
        comicsLibraryConfig.addDialogLauncher, same(showComicLibraryAddDialog));
    expect(
      comicsLibraryConfig.editDialogBuilder,
      same(buildComicLibraryEditDialog),
    );
    expect(comicsLibraryConfig.inspectorSectionsBuilder,
        same(buildComicInspectorSections));
    expect(comicsLibraryConfig.editUsesTitleAsSeries, isTrue);
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
    expect(mangaLibraryConfig.presentation, comicsLibraryMediaPresentation);
    expect(mangaLibraryConfig.editDialogBuilder, isNotNull);
    expect(mangaLibraryConfig.countLabel(1), 'Manga');
    expect(mangaLibraryConfig.countLabel(2), 'Manga');
  });

  test('movies library config uses the dedicated add dialog launcher', () {
    expect(
        moviesLibraryConfig.addDialogLauncher, same(showMovieLibraryAddDialog));
    expect(moviesLibraryConfig.editUsesTitleAsSeries, isFalse);
    expect(moviesLibraryConfig.mediaReleaseScopeLabel, 'Media');
    expect(moviesWorkspaceConfig.accent, const Color(0xFF42AA55));
    expect(libraryAccentForKind('anime'), const Color(0xFFC94DFF));
    expect(libraryIconForKind('tv'), Icons.tv_outlined);
    expect(moviesLibraryConfig.collectionExportTitleLabel, 'Title');
  });

  test('media/release scope labels are kind-owned', () {
    expect(comicsLibraryConfig.mediaReleaseScopeLabel, 'Series');
    expect(musicLibraryConfig.mediaReleaseScopeLabel, 'Media');
    expect(booksLibraryConfig.mediaReleaseScopeLabel, 'Media');
  });

  test('books do not create series subgroups for volume metadata', () {
    final entry = LibraryWorkspaceEntry(
      id: 'book-1',
      mediaType: 'book',
      title: 'Dune',
      series: const CatalogSeriesDetails(
        seriesId: 'seed-series-dune',
        seriesTitle: 'Dune',
        volumeName: 'Dune',
        volumeNumber: 1,
      ),
      updatedAt: DateTime.utc(2026, 6, 27),
    );

    expect(
      booksMediaAdapter.subgroupKeyForEntry(entry, LibraryGroupMode.series),
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
      expect(config.inspectorPanelBuilder, isNotNull);
    }
  });

  test('missing group mode definitions fall back safely', () {
    final presentation = LibraryMediaPresentation(
      searchFieldLabels: const LibraryMediaSearchFieldLabels(
        queryHint: 'Query',
        emptySearchMessage: 'Empty',
        seriesHint: 'Series',
        numberHint: 'Number',
        publisherHint: 'Publisher',
      ),
      filterLabels: const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Publisher',
        anyPublisher: 'Any publisher',
      ),
      groupLabels: const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Publisher',
        publisherPlural: 'Publishers',
        unknownPublisher: 'Unknown publisher',
      ),
      builder: const _TestPresentationBuilder(),
      workspaceEntryBuilder: (source) => throw UnimplementedError(),
      releaseEntryBuilder: (request) => throw UnimplementedError(),
      bucketLabelBuilder: (context) => 'bucket',
      sortColumnDefinitions: const [],
      groupModeDefinitions: const [],
      groupModes: const [LibraryGroupMode.title],
    );

    final definition = presentation.groupModeDefinitionFor(
      LibraryGroupMode.title,
    );

    expect(definition.mode, LibraryGroupMode.title);
    expect(definition.label, 'Title');
    expect(definition.sidebarTitle, 'Titles');
  });

  test('anime and tv library configs are first-class video kinds', () {
    expect(animeLibraryConfig.workspace.kind, CatalogMediaKind.anime);
    expect(animeLibraryConfig.defaultMetadataProvider, 'anilist');
    expect(animeLibraryConfig.supportsMetadataProvider('anilist'), isTrue);
    expect(animeLibraryConfig.capabilities.videoSeriesEntryTypes, {'anime'});
    expect(
      animeLibraryConfig.capabilities.resolvedVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      animeLibraryConfig.capabilities.resolvedVideoGrouping,
      VideoGroupingDefault.bySeries,
    );
    expect(animeLibraryConfig.editDialogBuilder, isNotNull);

    expect(tvLibraryConfig.workspace.kind, CatalogMediaKind.tv);
    expect(tvLibraryConfig.defaultMetadataProvider, 'tmdb');
    expect(tvLibraryConfig.supportsMetadataProvider('tmdb'), isTrue);
    expect(tvLibraryConfig.capabilities.videoSeriesEntryTypes, {'tv'});
    expect(
      tvLibraryConfig.capabilities.resolvedVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      tvLibraryConfig.capabilities.resolvedVideoGrouping,
      VideoGroupingDefault.bySeries,
    );
    expect(tvLibraryConfig.editDialogBuilder, isNotNull);
    expect(tvLibraryConfig.detailPageBuilder, same(buildVideoLibraryDetailPage));
  });

  test('movie library config keeps flat title/work defaults', () {
    expect(
      moviesLibraryConfig.capabilities.resolvedVideoDisplayLevel,
      VideoDisplayLevel.titleWork,
    );
    expect(
      moviesLibraryConfig.capabilities.resolvedVideoGrouping,
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

    final mediaTabs = tvLibraryConfig.editPresentation
        .builderForScope(LibraryEditScope.media)
        .buildTabs(context: context);
    final releaseTabs = tvLibraryConfig.editPresentation
        .builderForScope(LibraryEditScope.release)
        .buildTabs(context: context);

    expect(mediaTabs.any((tab) => tab.id == 'release_media'), isFalse);
    expect(mediaTabs.any((tab) => tab.id == 'episode_map'), isTrue);
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
    expect(comicsLibraryConfig.collectionExportTitleLabel, 'Series');
    expect(musicLibraryConfig.collectionExportTitleLabel, 'Release');
    expect(booksLibraryConfig.collectionExportTitleLabel, 'Title');
  });

  test('books library config enables creator spotlight in shared hero chrome',
      () {
    expect(booksLibraryConfig.capabilities.showsCreatorSpotlight, isTrue);
    expect(booksLibraryConfig.supportsReadingQueue, isTrue);
    expect(booksLibraryConfig.supportsMediaReleaseSplit, isTrue);
    expect(booksLibraryConfig.supportsSeriesIssueJump, isFalse);
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
      contains(LibrarySortColumn.title),
    );
    expect(boardGamesLibraryConfig.availableSortColumns,
        boardGamesLibrarySortColumns);
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
    expect(collectarrLibraryTypes.byKind('comic'), comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind(' Comic '), comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind('manga'), mangaLibraryConfig);
    expect(
        collectarrLibraryTypes.byKind('game')?.defaultMetadataProvider, 'igdb');
    expect(collectarrLibraryTypes.byKind('boardgame')?.defaultMetadataProvider,
        'bgg');
    expect(collectarrLibraryTypes.byKind('book')?.defaultMetadataProvider,
        'openlibrary');
    expect(collectarrLibraryTypes.byKind('movie')?.defaultMetadataProvider,
        'tmdb');
    expect(
        collectarrLibraryTypes.byKind('tv')?.defaultMetadataProvider, 'tmdb');
    expect(collectarrLibraryTypes.byKind('anime')?.defaultMetadataProvider,
        'anilist');
    expect(collectarrLibraryTypes.byKind('music')?.defaultMetadataProvider,
        'musicbrainz');
    expect(collectarrLibraryTypes.byKind('bluray'), isNull);
    expect(
      collectarrLibraryTypes.providersForKind('comic').map((row) => row.id),
      containsAll(['gcd', 'comicvine']),
    );
    expect(
      collectarrLibraryTypes.providersForKind('manga').map((row) => row.id),
      ['hardcover', 'comicvine', 'anilist', 'mangadex'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('book').map((row) => row.id),
      ['openlibrary', 'hardcover'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('game').map((row) => row.id),
      ['igdb'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('boardgame').map((row) => row.id),
      ['bgg'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('movie').map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('tv').map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('anime').map((row) => row.id),
      ['anilist'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('music').map((row) => row.id),
      ['musicbrainz'],
    );
    expect(collectarrLibraryTypes.providersForKind('bluray'), isEmpty);
    expect(
      collectarrLibraryTypes.byKind('movie')?.addDialogLauncher,
      same(showMovieLibraryAddDialog),
    );
    expect(
        collectarrLibraryTypes.byKind('movie')?.editDialogBuilder, isNotNull);
    expect(
        collectarrLibraryTypes.byKind('movie')?.detailPageBuilder, isNotNull);
  });

  test('all registered kinds declare an explicit edit dialog builder', () {
    for (final kind in collectarrLibraryTypes.supportedKinds) {
      expect(
        collectarrLibraryTypes.byKind(kind)?.editDialogBuilder,
        isNotNull,
        reason: 'Expected $kind to declare an explicit edit dialog builder.',
      );
    }
  });

  test('media adapter registry covers all active kinds', () {
    expect(
      collectarrMediaAdapters.supportedKinds,
      containsAll(collectarrLibraryTypes.supportedKinds),
    );
    for (final kind in collectarrLibraryTypes.supportedKinds) {
      expect(
        collectarrMediaAdapters.byKind(kind),
        isNotNull,
        reason: 'Missing media adapter for $kind.',
      );
    }
  });

  test('transferable field keys are kind-owned', () {
    expect(booksLibraryConfig.transferableFieldKeys,
        kDefaultTransferableFieldKeys);
    expect(
      comicsLibraryConfig.transferableFieldKeys,
      containsAll(kComicTransferableFieldKeys),
    );
    expect(
        booksLibraryConfig.transferableFieldKeys, isNot(contains('keyComic')));
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
      moviesLibraryConfig.capabilities.videoSeriesEntryTypes,
      {'tv'},
    );
    expect(
      moviesLibraryConfig.capabilities.videoShelfDrilldownEntryTypes,
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

  test('comics media adapter exposes reusable workspace table behavior', () {
    expect(comicsMediaAdapter.type, comicsLibraryConfig);
    expect(
      comicsMediaAdapter.viewProfile.config.kind,
      CatalogMediaKind.comic,
    );
    expect(comicsMediaAdapter.columnDisplayName(LibraryTableColumn.title),
        'Series');
    expect(comicsMediaAdapter.columnLabel(LibraryTableColumn.cover), '');
    expect(
      comicsMediaAdapter.columnGroup(LibraryTableColumn.location),
      LibraryTableColumnGroup.personal,
    );
    expect(
        comicsMediaAdapter.columnIsNumeric(LibraryTableColumn.price), isTrue);
    expect(
      comicsMediaAdapter.columnSort(LibraryTableColumn.releaseDate),
      LibrarySortColumn.releaseDate,
    );
    expect(comicTableColumnDescription(LibraryTableColumn.price),
        contains('purchase price'));
    expect(
      comicsTableColumnPresets.map((preset) => preset.label),
      ['Essential', 'Ownership', 'Value', 'Images', 'Full'],
    );
    expect(
      comicsMediaAdapter.orderedTableColumns(const {}).first,
      LibraryTableColumn.status,
    );
  });

  test('media adapters cover workspace defaults', () {
    expect(collectarrMediaAdapters.supportedKinds, [
      'comic',
      'book',
      'game',
      'boardgame',
      'manga',
      'movie',
      'tv',
      'anime',
      'music',
    ]);
    expect(collectarrMediaAdapters.byKind(' Comic '), comicsMediaAdapter);
    expect(collectarrMediaAdapters.byKind('book')?.type, booksLibraryConfig);
    expect(collectarrMediaAdapters.byKind('boardgame')?.type,
        boardGamesLibraryConfig);
    expect(collectarrMediaAdapters.byKind('manga')?.type, mangaLibraryConfig);
    expect(collectarrMediaAdapters.byKind('tv')?.type, tvLibraryConfig);
    expect(collectarrMediaAdapters.byKind('anime')?.type, animeLibraryConfig);
    expect(
      collectarrMediaAdapters
          .byKind('movie')
          ?.viewProfile
          .defaults()
          .visibleColumns
          .contains(LibraryTableColumn.title),
      isTrue,
    );
    expect(collectarrMediaAdapters.byKind('music')?.type, musicLibraryConfig);
    expect(
      gamesMediaAdapter.columnSort(LibraryTableColumn.releaseDate),
      LibrarySortColumn.releaseDate,
    );
    expect(
      moviesMediaAdapter.columnLabel(LibraryTableColumn.variant),
      'Format / Edition',
    );
    expect(
      gamesMediaAdapter.columnLabel(LibraryTableColumn.variant),
      'Platform / Edition',
    );
    expect(
      booksMediaAdapter.columnLabel(LibraryTableColumn.barcode),
      'ISBN / Barcode',
    );
    expect(
      booksMediaAdapter.tableColumnWidth(
        LibraryTableColumn.title,
        {LibraryTableColumn.title: 999},
      ),
      560,
    );
    expect(musicLibraryConfig.presentation.groupModes, [
      LibraryGroupMode.series,
      LibraryGroupMode.format,
      LibraryGroupMode.genre,
      LibraryGroupMode.publisher,
      LibraryGroupMode.originalReleaseDate,
      LibraryGroupMode.originalReleaseMonth,
      LibraryGroupMode.originalReleaseYear,
      LibraryGroupMode.recordingDate,
      LibraryGroupMode.recordingMonth,
      LibraryGroupMode.recordingYear,
      LibraryGroupMode.releaseDate,
      LibraryGroupMode.releaseMonth,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.title,
      LibraryGroupMode.boxSet,
      LibraryGroupMode.country,
      LibraryGroupMode.extras,
      LibraryGroupMode.instrument,
      LibraryGroupMode.isLive,
      LibraryGroupMode.mediaCondition,
      LibraryGroupMode.condition,
      LibraryGroupMode.packaging,
      LibraryGroupMode.rpm,
      LibraryGroupMode.spars,
      LibraryGroupMode.soundType,
      LibraryGroupMode.storageDevice,
      LibraryGroupMode.studio,
      LibraryGroupMode.vinylColor,
      LibraryGroupMode.chorus,
      LibraryGroupMode.composer,
      LibraryGroupMode.composition,
      LibraryGroupMode.conductor,
      LibraryGroupMode.orchestra,
      LibraryGroupMode.engineer,
      LibraryGroupMode.musician,
      LibraryGroupMode.producer,
      LibraryGroupMode.writer,
      LibraryGroupMode.addedDate,
      LibraryGroupMode.addedMonth,
      LibraryGroupMode.addedYear,
      LibraryGroupMode.collectionStatus,
      LibraryGroupMode.imageType,
      LibraryGroupMode.isSigned,
      LibraryGroupMode.bagBoardDate,
      LibraryGroupMode.bagBoardMonth,
      LibraryGroupMode.bagBoardYear,
      LibraryGroupMode.location,
      LibraryGroupMode.modifiedDate,
      LibraryGroupMode.modifiedMonth,
      LibraryGroupMode.myRating,
      LibraryGroupMode.owner,
      LibraryGroupMode.watched,
      LibraryGroupMode.watchDate,
      LibraryGroupMode.watchMonth,
      LibraryGroupMode.watchYear,
      LibraryGroupMode.purchaseDate,
      LibraryGroupMode.purchaseMonth,
      LibraryGroupMode.purchaseStore,
      LibraryGroupMode.purchaseYear,
      LibraryGroupMode.signedBy,
      LibraryGroupMode.tags,
    ]);
    expect(
      booksLibraryConfig.presentation.sortFavorites
          .map((favorite) => favorite.id),
      ['title_asc', 'release_latest', 'recent', 'value_desc'],
    );
    expect(booksLibraryConfig.presentation.groupModes, [
      LibraryGroupMode.creator,
      LibraryGroupMode.country,
      LibraryGroupMode.language,
      LibraryGroupMode.releaseDate,
      LibraryGroupMode.releaseMonth,
      LibraryGroupMode.publicationPlace,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.publisher,
      LibraryGroupMode.series,
      LibraryGroupMode.condition,
      LibraryGroupMode.dustJacketCondition,
      LibraryGroupMode.isSigned,
      LibraryGroupMode.purchaseDate,
      LibraryGroupMode.purchaseMonth,
      LibraryGroupMode.purchaseStore,
      LibraryGroupMode.purchaseYear,
      LibraryGroupMode.signedBy,
      LibraryGroupMode.soldDate,
      LibraryGroupMode.soldMonth,
      LibraryGroupMode.soldYear,
      LibraryGroupMode.audiobookAbridged,
      LibraryGroupMode.boxSet,
      LibraryGroupMode.edition,
      LibraryGroupMode.extras,
      LibraryGroupMode.firstEdition,
      LibraryGroupMode.format,
      LibraryGroupMode.narrator,
      LibraryGroupMode.originalCountry,
      LibraryGroupMode.originalLanguage,
      LibraryGroupMode.originalPublicationDate,
      LibraryGroupMode.originalPublicationMonth,
      LibraryGroupMode.originalPublicationPlace,
      LibraryGroupMode.originalPublicationYear,
      LibraryGroupMode.originalPublisher,
      LibraryGroupMode.paperType,
      LibraryGroupMode.printedBy,
      LibraryGroupMode.coverArtist,
      LibraryGroupMode.editor,
      LibraryGroupMode.forewordAuthor,
      LibraryGroupMode.ghostWriter,
      LibraryGroupMode.illustrator,
      LibraryGroupMode.photography,
      LibraryGroupMode.translator,
      LibraryGroupMode.genre,
      LibraryGroupMode.subject,
      LibraryGroupMode.addedDate,
      LibraryGroupMode.addedMonth,
      LibraryGroupMode.addedYear,
      LibraryGroupMode.collectionStatus,
      LibraryGroupMode.dustJacket,
      LibraryGroupMode.imageType,
      LibraryGroupMode.location,
      LibraryGroupMode.modifiedDate,
      LibraryGroupMode.modifiedMonth,
      LibraryGroupMode.myRating,
      LibraryGroupMode.owner,
      LibraryGroupMode.readDate,
      LibraryGroupMode.watched,
      LibraryGroupMode.readMonth,
      LibraryGroupMode.readYear,
      LibraryGroupMode.reader,
      LibraryGroupMode.readingStatus,
      LibraryGroupMode.tags,
    ]);
    expect(gamesLibraryConfig.presentation.groupModes, [
      LibraryGroupMode.audienceRating,
      LibraryGroupMode.developer,
      LibraryGroupMode.genre,
      LibraryGroupMode.platform,
      LibraryGroupMode.publisher,
      LibraryGroupMode.releaseDate,
      LibraryGroupMode.releaseMonth,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.series,
      LibraryGroupMode.title,
      LibraryGroupMode.completeness,
      LibraryGroupMode.condition,
      LibraryGroupMode.purchaseDate,
      LibraryGroupMode.purchaseMonth,
      LibraryGroupMode.purchaseStore,
      LibraryGroupMode.purchaseYear,
      LibraryGroupMode.valueLocked,
      LibraryGroupMode.toySubtype,
      LibraryGroupMode.toyType,
      LibraryGroupMode.format,
      LibraryGroupMode.regions,
      LibraryGroupMode.addedDate,
      LibraryGroupMode.addedMonth,
      LibraryGroupMode.addedYear,
      LibraryGroupMode.collectionStatus,
      LibraryGroupMode.completed,
      LibraryGroupMode.completedDate,
      LibraryGroupMode.completedMonth,
      LibraryGroupMode.completedYear,
      LibraryGroupMode.imageType,
      LibraryGroupMode.location,
      LibraryGroupMode.modifiedDate,
      LibraryGroupMode.modifiedMonth,
      LibraryGroupMode.myRating,
      LibraryGroupMode.owner,
      LibraryGroupMode.storageDevice,
      LibraryGroupMode.tags,
    ]);
    expect(comicsLibraryConfig.presentation.externalFacetBucketModes, [
      LibraryGroupMode.storyArc,
      LibraryGroupMode.character,
    ]);
    expect(comicsLibraryConfig.presentation.supportsSeriesIssueJump, isTrue);
    expect(
      comicsLibraryConfig.presentation.sortFavorites
          .map((favorite) => favorite.id),
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
    expect(moviesLibraryConfig.presentation.groupModes, [
      LibraryGroupMode.audienceRating,
      LibraryGroupMode.color,
      LibraryGroupMode.country,
      LibraryGroupMode.genre,
      LibraryGroupMode.language,
      LibraryGroupMode.ageRating,
      LibraryGroupMode.movieOrTvSeries,
      LibraryGroupMode.releaseDate,
      LibraryGroupMode.releaseMonth,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.series,
      LibraryGroupMode.publisher,
      LibraryGroupMode.audioTracks,
      LibraryGroupMode.boxSet,
      LibraryGroupMode.distributor,
      LibraryGroupMode.editionReleaseDate,
      LibraryGroupMode.editionReleaseMonth,
      LibraryGroupMode.editionReleaseYear,
      LibraryGroupMode.extras,
      LibraryGroupMode.format,
      LibraryGroupMode.hdr,
      LibraryGroupMode.layers,
      LibraryGroupMode.packaging,
      LibraryGroupMode.regions,
      LibraryGroupMode.screenRatios,
      LibraryGroupMode.subtitles,
      LibraryGroupMode.actor,
      LibraryGroupMode.director,
      LibraryGroupMode.musician,
      LibraryGroupMode.photography,
      LibraryGroupMode.producer,
      LibraryGroupMode.writer,
      LibraryGroupMode.title,
      LibraryGroupMode.ownership,
      LibraryGroupMode.addedDate,
      LibraryGroupMode.addedMonth,
      LibraryGroupMode.addedYear,
      LibraryGroupMode.collectionStatus,
      LibraryGroupMode.condition,
      LibraryGroupMode.imageType,
      LibraryGroupMode.location,
      LibraryGroupMode.modifiedDate,
      LibraryGroupMode.modifiedMonth,
      LibraryGroupMode.myRating,
      LibraryGroupMode.owner,
      LibraryGroupMode.purchaseDate,
      LibraryGroupMode.purchaseMonth,
      LibraryGroupMode.purchaseYear,
      LibraryGroupMode.purchaseStore,
      LibraryGroupMode.storageDevice,
      LibraryGroupMode.tags,
      LibraryGroupMode.watchDate,
      LibraryGroupMode.watchMonth,
      LibraryGroupMode.watchYear,
      LibraryGroupMode.watched,
      LibraryGroupMode.watchedWhere,
    ]);
  });
}
