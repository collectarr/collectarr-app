import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/book/book_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/game/game_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart'
    show moviesMediaAdapter;
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
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
import 'package:collectarr_app/features/library/kinds/video/video_detail_page.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestPresentationBuilder extends LibraryMediaPresentationBuilder {
  const _TestPresentationBuilder();

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
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
    expect(comicsLibraryConfig.presentation, comicLibraryMediaPresentation);
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
    expect(mangaLibraryConfig.presentation, mangaLibraryMediaPresentation);
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
    expect(
        libraryAccentForKind(CatalogMediaKind.anime), const Color(0xFFC94DFF));
    expect(libraryIconForKind(CatalogMediaKind.tv), Icons.tv_outlined);
    expect(moviesLibraryConfig.collectionExportTitleLabel, 'Title');
  });

  test('media/release scope labels are kind-owned', () {
    expect(comicsLibraryConfig.mediaReleaseScopeLabel, 'Series');
    expect(musicLibraryConfig.mediaReleaseScopeLabel, 'Media');
    expect(booksLibraryConfig.mediaReleaseScopeLabel, 'Media');
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
      booksMediaAdapter.subgroupKeyForEntry(item, 'series'),
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
    expect(
        animeLibraryConfig.workspaceBehavior.videoSeriesEntryTypes, {'anime'});

    expect(
      animeLibraryConfig.workspaceBehavior.defaultVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      animeLibraryConfig.workspaceBehavior.defaultVideoGrouping,
      VideoGroupingDefault.bySeries,
    );
    expect(animeLibraryConfig.editDialogBuilder, isNotNull);

    expect(tvLibraryConfig.workspace.kind, CatalogMediaKind.tv);
    expect(tvLibraryConfig.defaultMetadataProvider, 'tmdb');
    expect(tvLibraryConfig.supportsMetadataProvider('tmdb'), isTrue);
    expect(tvLibraryConfig.workspaceBehavior.videoSeriesEntryTypes, {'tv'});
    expect(
      tvLibraryConfig.workspaceBehavior.defaultVideoDisplayLevel,
      VideoDisplayLevel.season,
    );
    expect(
      tvLibraryConfig.workspaceBehavior.defaultVideoGrouping,
      VideoGroupingDefault.none,
    );
    expect(tvLibraryConfig.editDialogBuilder, isNotNull);
    expect(
        tvLibraryConfig.detailPageBuilder, same(buildVideoLibraryDetailPage));
  });

  test('movie library config keeps flat title/work defaults', () {
    expect(
      moviesLibraryConfig.workspaceBehavior.defaultVideoDisplayLevel,
      VideoDisplayLevel.titleWork,
    );
    expect(
      moviesLibraryConfig.workspaceBehavior.defaultVideoGrouping,
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
      isNotEmpty,
    );
    expect(
      libraryKindModuleForType(boardGamesLibraryConfig).fields.sorts.map((d) => d.id.value),
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

  test('media adapter registry covers all active kinds', () {
    expect(
      collectarrMediaAdapters.supportedKinds,
      containsAll(collectarrLibraryTypes.supportedKinds),
    );
    for (final kind in collectarrLibraryTypes.supportedKinds) {
      expect(
        collectarrMediaAdapters.byKind(catalogMediaKindFromValue(kind)),
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
      moviesLibraryConfig.workspaceBehavior.videoSeriesEntryTypes,
      {'tv'},
    );
    expect(
      moviesLibraryConfig.workspaceBehavior.videoShelfDrilldownEntryTypes,
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
      comicsMediaAdapter.viewProfile.type.workspace.kind,
      CatalogMediaKind.comic,
    );
    expect(comicsMediaAdapter.columnDisplayName('comic.series'),
        'Series');
    expect(comicsMediaAdapter.columnLabel('cover'), '');
    expect(
      comicsMediaAdapter.columnGroup('location'),
      LibraryTableColumnGroup.personal,
    );
    expect(comicsMediaAdapter.columnIsNumeric('price'), isTrue);
    expect(
      comicsMediaAdapter.columnSort('comic.release_date'),
      'comic.release_date',
    );
    expect(
      comicsTableColumnPresets.map((preset) => preset.label),
      ['Essential', 'Ownership', 'Value', 'Images', 'Full'],
    );
    expect(
      comicsMediaAdapter.orderedTableColumns(const {}).first,
      'status',
    );
  });

  test('media adapters cover workspace defaults', () {
    expect(collectarrMediaAdapters.supportedKinds, [
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
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.book)?.type,
        booksLibraryConfig);
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.boardgame)?.type,
        boardGamesLibraryConfig);
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.manga)?.type,
        mangaLibraryConfig);
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.tv)?.type,
        tvLibraryConfig);
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.anime)?.type,
        animeLibraryConfig);
    expect(
      collectarrMediaAdapters
          .byKind(CatalogMediaKind.movie)
          ?.viewProfile
          .defaults()
          .visibleColumns
          .contains('movie.title'),
      isTrue,
    );
    expect(collectarrMediaAdapters.byKind(CatalogMediaKind.music)?.type,
        musicLibraryConfig);
    expect(
      gamesMediaAdapter.columnSort('game.release_date'),
      'game.release_date',
    );
    expect(
      moviesMediaAdapter.columnLabel('variant'),
      'Variant',
    );
    expect(
      gamesMediaAdapter.columnLabel('variant'),
      'Variant',
    );
    expect(
      booksMediaAdapter.columnLabel('barcode'),
      'Barcode',
    );
    expect(
      booksMediaAdapter.tableColumnWidth(
        'title',
        {'title': 999},
      ),
      520,
    );
    expect(musicLibraryConfig.availableGroupModes, [
      'music.artist',
      'music.publisher',
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
      'book.condition',
      'book.location',
    ]);
    expect(gamesLibraryConfig.availableGroupModes, [
      'game.publisher',
      'game.series',
      'game.location',
    ]);
    expect(comicsLibraryConfig.presentation.externalFacetBucketIdsByMode.keys, [
      'comic.story_arc',
      'comic.character',
    ]);
    expect(comicsLibraryConfig.presentation.supportsSeriesIssueJump, isTrue);
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
      'movie.publisher',
      'movie.series',
      'movie.location',
    ]);
  });
}
