import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/release/book_release_edit_dialog.dart';

import '../../../helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_video_detail_page.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryFieldIdRuntime _field(LibraryKindModule runtime, String value) =>
    runtime.fields.decodeColumnId(value);

LibrarySortIdRuntime _sort(LibraryKindModule runtime, String value) =>
    runtime.fields.decodeSortId(value);

LibraryGroupIdRuntime _group(LibraryKindModule runtime, String value) =>
    runtime.fields.decodeGroupId(value);

void main() {
  test('comic runtime groups reusable media behavior', () {
    expect(comicKindModule.kind, CatalogMediaKind.comic);
    expect(comicKindModule.identity.singularLabel, 'Comic');
    expect(comicKindModule.identity.pluralLabel, 'Comics');
    expect(comicKindModule.metadata.defaultProviderId, 'gcd');
    expect(
      comicKindModule.metadata.defaultSupportedOption(comicKindModule.kind)?.id,
      'gcd',
    );
    expect(
      comicKindModule.metadata.defaultSupportedOption(comicKindModule.kind)?.id,
      'gcd',
    );
    expect(
      comicKindModule.metadata.supportsProvider('gcd', comicKindModule.kind),
      isTrue,
    );
    expect(
      comicKindModule.metadata.supportsProvider(
        'comicvine',
        comicKindModule.kind,
      ),
      isTrue,
    );
    expect(
      comicKindModule.metadata
          .defaultSupportedOption(comicKindModule.kind)
          ?.usagePolicy
          ?.summary,
      contains('CC BY-SA'),
    );
    final apiKeyIds = comicKindModule.metadata.providers
        .where((provider) => provider.requiresApiKey)
        .map((provider) => provider.id)
        .toList();
    expect(apiKeyIds, contains('comicvine'));
    expect(comicKindModule.metadata.providerLabel('gcd'), 'GCD');
    expect(comicKindModule.metadata.providerLabel('comicvine'), 'Comic Vine');
    expect(
      comicKindModule.metadata.providerLabel('unknown-provider'),
      'unknown-provider',
    );
    expect(comicKindModule.trackingProfile, comicTrackingProfile);
    expect(comicKindModule.presentation, comicLibraryMediaPresentation);
    expect(comicKindModule.add.dialogLauncher, same(showComicLibraryAddDialog));
    expect(comicKindModule.edit.editDialogBuilder,
        same(buildComicLibraryEditDialog));
    expect(comicKindModule.inspector.sectionsBuilder,
        same(buildComicInspectorSections));
    expect(comicKindModule.identity.countLabel(1), 'Comic');
    expect(comicKindModule.identity.countLabel(2), 'Comics');
  });

  test('manga runtime is a first-class comic-family kind', () {
    expect(mangaKindModule.kind, CatalogMediaKind.manga);
    expect(mangaKindModule.identity.singularLabel, 'Manga');
    expect(mangaKindModule.identity.pluralLabel, 'Manga');
    expect(mangaKindModule.metadata.defaultProviderId, 'hardcover');
    expect(
      mangaKindModule.metadata.defaultSupportedOption(mangaKindModule.kind)?.id,
      'hardcover',
    );
    expect(
      mangaKindModule.metadata.supportsProvider(
        'mangadex',
        mangaKindModule.kind,
      ),
      isTrue,
    );
    expect(
      mangaKindModule.metadata.supportsProvider(
        'anilist',
        mangaKindModule.kind,
      ),
      isTrue,
    );
    expect(mangaKindModule.trackingProfile, mangaTrackingProfile);
    expect(mangaKindModule.presentation, mangaLibraryMediaPresentation);
    expect(mangaKindModule.edit.editDialogBuilder, isNotNull);
    expect(mangaKindModule.edit.mediaEditDialogBuilder,
        same(buildMangaMediaLibraryEditDialog));
    expect(
        mangaKindModule.edit.presentation, same(mangaLibraryEditPresentation));
    expect(mangaKindModule.identity.countLabel(1), 'Manga');
    expect(mangaKindModule.identity.countLabel(2), 'Manga');
  });

  test('movies library config uses the dedicated add dialog launcher', () {
    expect(movieKindModule.add.dialogLauncher, same(showMovieLibraryAddDialog));
    expect(movieKindModule.identity.accent, const Color(0xFF42AA55));
    expect(
        libraryAccentForKind(CatalogMediaKind.anime), const Color(0xFFC94DFF));
    expect(libraryIconForKind(CatalogMediaKind.tv), Icons.tv_outlined);
  });

  test('media and export labels are kind-owned', () {
    expect(
      comicKindModule.presentation.previewLabels.labelFor(
        'media_scope',
        fallback: 'Media',
      ),
      'Series',
    );
    expect(
      musicKindModule.presentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Release',
    );
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
      bookKindModule.workspace
          .subgroupKeyForEntry(item, _group(bookKindModule, 'series')),
      isNull,
    );
  });

  test('anime and tv runtimes are first-class video kinds', () {
    expect(animeKindModule.kind, CatalogMediaKind.anime);
    expect(animeKindModule.metadata.defaultProviderId, 'anilist');
    expect(
      animeKindModule.metadata.supportsProvider(
        'anilist',
        animeKindModule.kind,
      ),
      isTrue,
    );
    expect(animeKindModule.edit.editDialogBuilder, isNotNull);

    expect(tvKindModule.kind, CatalogMediaKind.tv);
    expect(tvKindModule.metadata.defaultProviderId, 'tmdb');
    expect(
      tvKindModule.metadata.supportsProvider('tmdb', tvKindModule.kind),
      isTrue,
    );
    expect(tvKindModule.edit.editDialogBuilder, isNotNull);
    expect(tvKindModule.inspector.detailPageBuilder,
        same(buildLibraryVideoDetailPage));
    expect(tvKindModule.inspector.videoDetailContributionBuilder, isNotNull);
    expect(movieKindModule.inspector.videoDetailContributionBuilder, isNull);
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
    expect(
      comicKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isTrue,
    );
    expect(
      mangaKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isTrue,
    );
    expect(
      movieKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isFalse,
    );
    expect(
      bookKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isFalse,
    );
  });

  test('collection export title labels are kind-owned', () {
    expect(
      comicKindModule.presentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Series',
    );
    expect(
      musicKindModule.presentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Release',
    );
    expect(
      bookKindModule.presentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Title',
    );
  });

  test('book runtime enables creator spotlight in shared hero chrome', () {
    expect(bookKindModule.inspector.showsCreatorSpotlight, isTrue);
    expect(bookKindModule.hierarchy.supportsMediaReleaseSplit, isTrue);
    expect(movieKindModule.inspector.showsCreatorSpotlight, isFalse);
    expect(
      bookKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.readingQueue),
      isTrue,
    );
    expect(
      movieKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.readingQueue),
      isFalse,
    );
  });

  test('book runtime registers typed add and edit hierarchy surfaces', () {
    expect(
      bookKindModule.edit.mediaEditDialogBuilder,
      same(buildBookMediaLibraryEditDialog),
    );
    expect(
      bookKindModule.edit.releaseEditDialogBuilder,
      same(buildBookReleaseLibraryEditDialog),
    );
    expect(bookKindModule.hierarchy.childrenTitle(2), 'Editions (2)');

    const context = LibraryEditPresentationContext(
      isOwned: true,
      isTrackingOnly: false,
      hasTrackingContext: false,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: true,
      hasEditionAnchors: true,
      hasBundleReleaseAnchors: false,
      hasCustomFields: false,
    );
    final tabs = bookKindModule.edit.presentation
        .builderForScope(LibraryEditScope.media)
        .buildTabs(context: context);
    expect(tabs.map((tab) => tab.id), contains('owned'));
  });

  test('book and boardgame runtimes own their scoped browser options', () {
    final bookRuntime = bookKindModule;
    expect(
      bookRuntime.workspace.availableGroupIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      bookRuntime.workspace.availableGroupIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.releases,
      ),
      isNotEmpty,
    );
    expect(
      bookRuntime.workspace.availableSortIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      boardGameKindModule.fields.sorts.map((d) => d.id.value),
      contains('boardgame.title'),
    );
  });

  test('typed browser scopes preserve comic and movie options', () {
    final comicRuntime = comicKindModule;
    expect(comicRuntime.hierarchy.supportsMediaReleaseSplit, isFalse);
    expect(
      comicKindModule.hierarchy.scopesOptionsByBrowserMode,
      isFalse,
    );
    final comicMediaGroups = comicRuntime.workspace
        .availableGroupIdsForBrowserMode(LibraryWorkspaceBrowserMode.media)
        .map((id) => id.value)
        .toSet();
    expect(comicMediaGroups, containsAll(['comic.series', 'comic.publisher']));

    final movieRuntime = movieKindModule;
    final movieMediaGroups = movieRuntime.workspace
        .availableGroupIdsForBrowserMode(LibraryWorkspaceBrowserMode.media)
        .map((id) => id.value)
        .toSet();
    final movieReleaseGroups = movieRuntime.workspace
        .availableGroupIdsForBrowserMode(LibraryWorkspaceBrowserMode.releases)
        .map((id) => id.value)
        .toSet();
    expect(
        movieMediaGroups,
        containsAll([
          'movie.director',
          'movie.publisher',
          'movie.genre',
        ]));
    expect(
        movieReleaseGroups,
        containsAll([
          'movie.format',
          'movie.audio_tracks',
          'movie.edition_release_date',
        ]));
  });

  test('edit scope follows the active browser mode', () {
    final bookRuntime = bookKindModule;
    expect(
      bookRuntime.hierarchy.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      LibraryEditScope.media,
    );
    expect(
      bookRuntime.hierarchy.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.releases,
      ),
      LibraryEditScope.release,
    );
  });

  test('library kind registry resolves runtimes and providers', () {
    final runtimes = defaultLibraryKindRegistry.allModules;
    expect(runtimes.map((runtime) => runtime.kind.apiValue).toList(), [
      'anime',
      'boardgame',
      'book',
      'comic',
      'game',
      'manga',
      'movie',
      'music',
      'tv',
    ]);
    expect(defaultLibraryKindRegistry.getByKind(CatalogMediaKind.comic),
        same(comicKindModule));
    expect(defaultLibraryKindRegistry.getByKind(CatalogMediaKind.manga),
        same(mangaKindModule));
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.game)
            .metadata
            .defaultProviderId,
        'igdb');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.boardgame)
            .metadata
            .defaultProviderId,
        'bgg');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.book)
            .metadata
            .defaultProviderId,
        'hardcover');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.movie)
            .metadata
            .defaultProviderId,
        'tmdb');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.tv)
            .metadata
            .defaultProviderId,
        'tmdb');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.anime)
            .metadata
            .defaultProviderId,
        'anilist');
    expect(
        defaultLibraryKindRegistry
            .getByKind(CatalogMediaKind.music)
            .metadata
            .defaultProviderId,
        'musicbrainz');
    expect(defaultLibraryKindRegistry.tryGet(CatalogMediaKind.unknown), isNull);
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.comic)
          .metadata
          .providers
          .map((row) => row.id),
      containsAll(['gcd', 'comicvine']),
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.manga)
          .metadata
          .providers
          .map((row) => row.id),
      ['hardcover', 'comicvine', 'anilist', 'mangadex'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.book)
          .metadata
          .providers
          .map((row) => row.id),
      ['hardcover', 'openlibrary'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.game)
          .metadata
          .providers
          .map((row) => row.id),
      ['igdb'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.boardgame)
          .metadata
          .providers
          .map((row) => row.id),
      ['bgg'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.movie)
          .metadata
          .providers
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.tv)
          .metadata
          .providers
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.anime)
          .metadata
          .providers
          .map((row) => row.id),
      ['anilist'],
    );
    expect(
      defaultLibraryKindRegistry
          .getByKind(CatalogMediaKind.music)
          .metadata
          .providers
          .map((row) => row.id),
      ['musicbrainz'],
    );
    expect(
      defaultLibraryKindRegistry.tryGet(CatalogMediaKind.unknown),
      isNull,
    );
    expect(movieKindModule.add.dialogLauncher, same(showMovieLibraryAddDialog));
    expect(
      libraryKindModule(CatalogMediaKind.movie).edit.editDialogBuilder,
      isNotNull,
    );
    expect(
      libraryKindModule(CatalogMediaKind.movie).inspector.detailPageBuilder,
      isNotNull,
    );
  });

  test('all registered kinds declare an explicit edit dialog builder', () {
    for (final runtime in defaultLibraryKindRegistry.allModules) {
      expect(
        runtime.edit.editDialogBuilder,
        isNotNull,
        reason:
            'Expected ${runtime.kind.apiValue} to declare an explicit edit dialog builder.',
      );
    }
  });

  test('library kind registry covers all active kinds', () {
    final registeredKinds = defaultLibraryKindRegistry.allModules
        .map((runtime) => runtime.kind.apiValue)
        .toList();
    expect(
      registeredKinds,
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
    for (final runtime in defaultLibraryKindRegistry.allModules) {
      expect(
        defaultLibraryKindRegistry.getByKind(runtime.kind),
        same(runtime),
        reason: 'Missing runtime for ${runtime.kind.apiValue}.',
      );
    }
  });

  test('transferable field keys are kind-owned', () {
    expect(bookKindModule.transfer.transferableFieldKeys,
        kDefaultTransferableFieldKeys);
    expect(
      comicKindModule.transfer.transferableFieldKeys,
      containsAll([
        'rawOrSlabbed',
        'gradingCompany',
        'graderNotes',
        'signedBy',
        'keyReason',
        'keyComic',
      ]),
    );
    expect(bookKindModule.transfer.transferableFieldKeys,
        isNot(contains('keyComic')));
  });

  test('add wording chrome is kind-owned', () {
    expect(
      LibraryAddReferenceType.media.labelForType(bookKindModule),
      'Media',
    );
    expect(
      LibraryAddReferenceType.media.labelForType(musicKindModule),
      'Album',
    );
    expect(
      musicKindModule.add.chrome.trackScopeSummary,
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
    );
    expect(
      LibraryAddReferenceType.edition.helperLabelForType(musicKindModule),
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
    );
    expect(
      movieKindModule.add.chrome.videoKindFilterOptions
          .map((option) => option.label),
      ['Movies', 'Box Sets'],
    );
    expect(
      movieKindModule.add.chrome.defaultVideoKindFilters,
      {'movie'},
    );
  });

  test('comic kind uses dedicated edit dialog builder', () {
    expect(comicKindModule.edit.editDialogBuilder,
        same(buildComicLibraryEditDialog));
  });

  test('music kind uses dedicated edit dialog builder', () {
    expect(musicKindModule.edit.editDialogBuilder,
        same(buildMusicLibraryEditDialog));
  });

  test('game kinds use dedicated edit dialog builders', () {
    expect(gameKindModule.edit.editDialogBuilder,
        same(buildGameLibraryEditDialog));
    expect(boardGameKindModule.edit.editDialogBuilder,
        same(buildBoardGameLibraryEditDialog));
  });

  test('video physical formats are variants under movies', () {
    expect(
      moviePhysicalMediaFormats.map((format) => format.id),
      ['dvd', 'blu-ray', '4k-uhd', 'vhs', 'laserdisc', 'digital'],
    );
    expect(
      physicalMediaFormatById(
        ' blu-ray ',
        formats: moviePhysicalMediaFormats,
      )?.label,
      'Blu-ray',
    );
    expect(
      physicalMediaFormatById('bluray', formats: moviePhysicalMediaFormats)
          ?.label,
      'Blu-ray',
    );
    expect(
      physicalMediaFormatById('4k blu-ray', formats: moviePhysicalMediaFormats)
          ?.label,
      '4K UHD',
    );
    expect(
      physicalMediaFormatById('digital', formats: moviePhysicalMediaFormats)
          ?.variantType,
      'digital',
    );
  });

  test('comics runtime exposes reusable workspace table behavior', () {
    final comicRuntime = libraryKindModule(CatalogMediaKind.comic);
    expect(comicRuntime, same(comicKindModule));
    expect(comicRuntime.kind, CatalogMediaKind.comic);
    expect(
      comicRuntime.workspace
          .columnDisplayName(_field(comicKindModule, 'comic.series')),
      'Series',
    );
    expect(
      comicRuntime.workspace.columnLabel(_field(comicKindModule, 'cover')),
      'Cover',
    );
    expect(
      comicRuntime.workspace.columnGroup(_field(comicKindModule, 'location')),
      LibraryTableColumnGroup.main,
    );
    expect(
      comicRuntime.workspace
          .columnIsNumeric(_field(comicKindModule, 'comic.price_paid')),
      isTrue,
    );
    expect(
      comicRuntime.workspace.columnSort(
        _field(comicKindModule, 'comic.release_date'),
      ),
      _sort(comicKindModule, 'comic.release_date'),
    );
    expect(
      comicsTableColumnPresets.map((preset) => preset.label),
      ['Essential', 'Ownership', 'Value', 'Full'],
    );
    expect(
      comicRuntime.workspace.orderedTableColumns(const {}).first,
      _field(comicKindModule, 'comic.status'),
    );
  });

  test('kind runtimes cover workspace defaults', () {
    expect(
      defaultLibraryKindRegistry.allModules
          .map((runtime) => runtime.kind.apiValue)
          .toList(),
      [
        'anime',
        'boardgame',
        'book',
        'comic',
        'game',
        'manga',
        'movie',
        'music',
        'tv',
      ],
    );
    expect(libraryKindModule(CatalogMediaKind.book), same(bookKindModule));
    expect(
      libraryKindModule(CatalogMediaKind.boardgame),
      same(boardGameKindModule),
    );
    expect(libraryKindModule(CatalogMediaKind.manga), same(mangaKindModule));
    expect(libraryKindModule(CatalogMediaKind.tv), same(tvKindModule));
    expect(libraryKindModule(CatalogMediaKind.anime), same(animeKindModule));
    expect(
      movieKindModule.viewProfile
          .defaults()
          .visibleColumnIds
          .contains(_field(movieKindModule, 'movie.title')),
      isTrue,
    );
    expect(libraryKindModule(CatalogMediaKind.music), same(musicKindModule));
    expect(
      libraryKindModule(CatalogMediaKind.game).workspace.columnSort(
            _field(gameKindModule, 'game.release_date'),
          ),
      _sort(gameKindModule, 'game.release_date'),
    );
    expect(
      libraryKindModule(CatalogMediaKind.movie)
          .workspace
          .columnLabel(_field(movieKindModule, 'variant')),
      'Variant',
    );
    expect(
      libraryKindModule(CatalogMediaKind.game)
          .workspace
          .columnLabel(_field(gameKindModule, 'variant')),
      'Variant',
    );
    expect(
      libraryKindModule(CatalogMediaKind.book)
          .workspace
          .columnLabel(_field(bookKindModule, 'barcode')),
      'Barcode',
    );
    expect(
      libraryKindModule(CatalogMediaKind.book).workspace.tableColumnWidth(
        _field(bookKindModule, 'title'),
        {_field(bookKindModule, 'title'): 999},
      ),
      260,
    );
    expect(
      libraryKindModule(CatalogMediaKind.music)
          .workspace
          .availableGroupIds
          .map((id) => id.value),
      [
        'music.artist',
        'music.publisher',
        'music.format',
        'music.country',
        'music.condition',
        'music.location',
      ],
    );
    expect(
      bookKindModule.presentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['title_asc', 'release_latest', 'recent', 'value_desc'],
    );
    expect(
      libraryKindModule(CatalogMediaKind.book)
          .workspace
          .availableGroupIds
          .map((id) => id.value),
      [
        'book.author',
        'book.publisher',
        'book.series',
        'book.format',
        'book.condition',
        'book.location',
      ],
    );
    expect(
      libraryKindModule(CatalogMediaKind.game)
          .workspace
          .availableGroupIds
          .map((id) => id.value),
      [
        'game.platform',
        'game.publisher',
        'game.franchise',
        'game.location',
        'game.completeness',
      ],
    );
    expect(comicLibraryFacetModule.externalFacetBucketIdsByMode.keys, [
      'comic.story_arc',
      'comic.character',
    ]);
    expect(
      comicKindModule.presentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['series_issue', 'recent', 'publisher_date', 'value_desc'],
    );
    expect(
      comicKindModule.presentation.columnFavorites
          .map((preset) => preset.label),
      comicsTableColumnPresets.map((preset) => preset.label),
    );
    expect(bookKindModule.presentation.compactBucketIcon, Icons.folder);
    expect(
      movieKindModule.presentation.compactBucketIcon,
      Icons.movie_filter_outlined,
    );
    expect(
      musicKindModule.presentation.compactBucketIcon,
      Icons.person_2_outlined,
    );
    expect(bookKindModule.presentation.emptyStateProviderSummarySuffix, '');
    expect(
      movieKindModule.presentation.emptyStateProviderSummarySuffix,
      ' Physical formats are tracked as editions.',
    );
    expect(
      libraryKindModule(CatalogMediaKind.movie)
          .workspace
          .availableGroupIds
          .map((id) => id.value),
      [
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
      ],
    );
  });
}
