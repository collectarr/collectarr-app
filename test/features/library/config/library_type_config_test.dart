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
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryFieldIdRuntime _field(LibraryKindRegistration runtime, String value) =>
    libraryKindWorkspaceForKind(runtime.kind).fields.decodeColumnId(value);

LibrarySortIdRuntime _sort(LibraryKindRegistration runtime, String value) =>
    libraryKindWorkspaceForKind(runtime.kind).fields.decodeSortId(value);

LibraryGroupIdRuntime _group(LibraryKindRegistration runtime, String value) =>
    libraryKindWorkspaceForKind(runtime.kind).fields.decodeGroupId(value);

void main() {
  test('comic runtime groups reusable media behavior', () {
    expect(comicKindModule.identity.kind, CatalogMediaKind.comic);
    expect(comicKindModule.identity.singularLabel, 'Comic');
    expect(comicKindModule.identity.pluralLabel, 'Comics');
    expect(comicKindModule.metadata.defaultProviderId, 'gcd');
    expect(
      comicKindModule.metadata
          .defaultSupportedOption(comicKindModule.identity.kind)
          ?.id,
      'gcd',
    );
    expect(
      comicKindModule.metadata
          .defaultSupportedOption(comicKindModule.identity.kind)
          ?.id,
      'gcd',
    );
    expect(
      comicKindModule.metadata
          .supportsProvider('gcd', comicKindModule.identity.kind),
      isTrue,
    );
    expect(
      comicKindModule.metadata.supportsProvider(
        'comicvine',
        comicKindModule.identity.kind,
      ),
      isTrue,
    );
    expect(
      comicKindModule.metadata
          .defaultSupportedOption(comicKindModule.identity.kind)
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
    expect(mangaKindModule.identity.kind, CatalogMediaKind.manga);
    expect(mangaKindModule.identity.singularLabel, 'Manga');
    expect(mangaKindModule.identity.pluralLabel, 'Manga');
    expect(mangaKindModule.metadata.defaultProviderId, 'hardcover');
    expect(
      mangaKindModule.metadata
          .defaultSupportedOption(mangaKindModule.identity.kind)
          ?.id,
      'hardcover',
    );
    expect(
      mangaKindModule.metadata.supportsProvider(
        'mangadex',
        mangaKindModule.identity.kind,
      ),
      isTrue,
    );
    expect(
      mangaKindModule.metadata.supportsProvider(
        'anilist',
        mangaKindModule.identity.kind,
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
    final source = LibraryWorkspaceSource(
      itemId: 'book-1',
      catalogTransport: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'Dune',
      ).asShelfCatalogItem,
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
      libraryKindWorkspaceForKind(CatalogMediaKind.book).subgroupKeyForEntry(
          item, _group(const BookRegistration(), 'series')),
      isNull,
    );
  });

  test('anime and tv runtimes are first-class video kinds', () {
    expect(animeKindModule.identity.kind, CatalogMediaKind.anime);
    expect(animeKindModule.metadata.defaultProviderId, 'anilist');
    expect(
      animeKindModule.metadata.supportsProvider(
        'anilist',
        animeKindModule.identity.kind,
      ),
      isTrue,
    );
    expect(animeKindModule.edit.editDialogBuilder, isNotNull);

    expect(tvKindModule.identity.kind, CatalogMediaKind.tv);
    expect(tvKindModule.metadata.defaultProviderId, 'tmdb');
    expect(
      tvKindModule.metadata
          .supportsProvider('tmdb', tvKindModule.identity.kind),
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
      const ComicRegistration()
          .toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isTrue,
    );
    expect(
      const MangaRegistration()
          .toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isTrue,
    );
    expect(
      const MovieRegistration()
          .toolbarActionAvailability
          .allows(LibraryToolbarActionId.reassignIndex),
      isFalse,
    );
    expect(
      const BookRegistration()
          .toolbarActionAvailability
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
      const BookRegistration()
          .toolbarActionAvailability
          .allows(LibraryToolbarActionId.readingQueue),
      isTrue,
    );
    expect(
      const MovieRegistration()
          .toolbarActionAvailability
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
      libraryKindWorkspaceForKind(bookRuntime.identity.kind)
          .availableGroupIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      libraryKindWorkspaceForKind(bookRuntime.identity.kind)
          .availableGroupIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.releases,
      ),
      isNotEmpty,
    );
    expect(
      libraryKindWorkspaceForKind(bookRuntime.identity.kind)
          .availableSortIdsForBrowserMode(
        LibraryWorkspaceBrowserMode.media,
      ),
      isNotEmpty,
    );
    expect(
      boardGameKindWorkspace.fields.sorts.map((d) => d.id.value),
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
    final comicMediaGroups =
        libraryKindWorkspaceForKind(comicRuntime.identity.kind)
            .availableGroupIdsForBrowserMode(LibraryWorkspaceBrowserMode.media)
            .map((id) => id.value)
            .toSet();
    expect(comicMediaGroups, containsAll(['comic.series', 'comic.publisher']));

    final movieRuntime = movieKindModule;
    final movieMediaGroups =
        libraryKindWorkspaceForKind(movieRuntime.identity.kind)
            .availableGroupIdsForBrowserMode(LibraryWorkspaceBrowserMode.media)
            .map((id) => id.value)
            .toSet();
    final movieReleaseGroups = libraryKindWorkspaceForKind(
            movieRuntime.identity.kind)
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
    final registrations = defaultLibraryKindRegistry.allModules;
    expect(
        registrations
            .map((registration) => registration.kind.apiValue)
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
        ]);
    expect(defaultLibraryKindRegistry.getByKind(CatalogMediaKind.comic),
        same(const ComicRegistration()));
    expect(defaultLibraryKindRegistry.getByKind(CatalogMediaKind.manga),
        same(const MangaRegistration()));
    const expectedProviders = <CatalogMediaKind, String>{
      CatalogMediaKind.game: 'igdb',
      CatalogMediaKind.boardgame: 'bgg',
      CatalogMediaKind.book: 'hardcover',
      CatalogMediaKind.movie: 'tmdb',
      CatalogMediaKind.tv: 'tmdb',
      CatalogMediaKind.anime: 'anilist',
      CatalogMediaKind.music: 'musicbrainz',
    };
    for (final entry in expectedProviders.entries) {
      expect(collectarrKindMetadata[entry.key]!.defaultProviderId, entry.value);
    }
    expect(defaultLibraryKindRegistry.tryGet(CatalogMediaKind.unknown), isNull);
    expect(
      collectarrKindMetadata[CatalogMediaKind.comic]!
          .providers
          .map((row) => row.id),
      containsAll(['gcd', 'comicvine']),
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.manga]!
          .providers
          .map((row) => row.id),
      ['hardcover', 'comicvine', 'anilist', 'mangadex'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.book]!
          .providers
          .map((row) => row.id),
      ['hardcover', 'openlibrary'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.game]!
          .providers
          .map((row) => row.id),
      ['igdb'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.boardgame]!
          .providers
          .map((row) => row.id),
      ['bgg'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.movie]!
          .providers
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.tv]!
          .providers
          .map((row) => row.id),
      ['tmdb'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.anime]!
          .providers
          .map((row) => row.id),
      ['anilist'],
    );
    expect(
      collectarrKindMetadata[CatalogMediaKind.music]!
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
      libraryKindRegistration(CatalogMediaKind.movie).edit.editDialogBuilder,
      isNotNull,
    );
    expect(
      libraryKindRegistration(CatalogMediaKind.movie)
          .inspector
          .detailPageBuilder,
      isNotNull,
    );
  });

  test('all registered kinds declare an explicit edit dialog builder', () {
    for (final registration in defaultLibraryKindRegistry.allModules) {
      expect(
        collectarrKindEdits[registration.kind]!.editDialogBuilder,
        isNotNull,
        reason:
            'Expected ${registration.kind.apiValue} to declare an explicit edit dialog builder.',
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
    expect(
      bookKindModule.transfer.transferableFieldKeys,
      containsAll([...kDefaultTransferableFieldKeys, 'grade']),
    );
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
      LibraryAddReferenceType.media.labelForType(const BookRegistration()),
      'Media',
    );
    expect(
      LibraryAddReferenceType.media.labelForType(const MusicRegistration()),
      'Album',
    );
    expect(
      musicKindModule.add.chrome.trackScopeSummary,
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
    );
    expect(
      LibraryAddReferenceType.edition
          .helperLabelForType(const MusicRegistration()),
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
    );
    expect(
      movieKindModule.add.chrome.videoKindFilterOptions
          .map((option) => option.scope),
      [
        LibraryAddVideoSearchScope.movie,
        LibraryAddVideoSearchScope.collection,
      ],
    );
    expect(
      movieKindModule.add.chrome.videoKindFilterOptions
          .map((option) => option.label),
      ['Movies', 'Box Sets'],
    );
    expect(
      movieKindModule.add.chrome.defaultVideoKindFilters,
      {LibraryAddVideoSearchScope.movie},
    );
    expect(
      LibraryAddVideoSearchScope.collection.catalogKind,
      CatalogMediaKind.movie,
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
    final comicRuntime = libraryKindRegistration(CatalogMediaKind.comic);
    expect(comicRuntime, same(const ComicRegistration()));
    expect(comicRuntime.kind, CatalogMediaKind.comic);
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind)
          .columnDisplayName(_field(const ComicRegistration(), 'comic.series')),
      'Series',
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind)
          .columnLabel(_field(const ComicRegistration(), 'comic.cover')),
      '',
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind)
          .columnGroup(_field(const ComicRegistration(), 'comic.location')),
      LibraryTableColumnGroup.personal,
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind).columnIsNumeric(
          _field(const ComicRegistration(), 'comic.price_paid')),
      isTrue,
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind).columnSort(
        _field(const ComicRegistration(), 'comic.release_date'),
      ),
      _sort(const ComicRegistration(), 'comic.release_date'),
    );
    expect(
      comicsTableColumnPresets.map((preset) => preset.label),
      ['Essential', 'Ownership', 'Value', 'Full'],
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind)
          .orderedTableColumns(const {}).first,
      _field(const ComicRegistration(), 'comic.status'),
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
    expect(libraryKindRegistration(CatalogMediaKind.book),
        same(const BookRegistration()));
    expect(
      libraryKindRegistration(CatalogMediaKind.boardgame),
      same(const BoardgameRegistration()),
    );
    expect(libraryKindRegistration(CatalogMediaKind.manga),
        same(const MangaRegistration()));
    expect(libraryKindRegistration(CatalogMediaKind.tv),
        same(const TvRegistration()));
    expect(libraryKindRegistration(CatalogMediaKind.anime),
        same(const AnimeRegistration()));
    expect(
      movieKindModule.viewProfile
          .defaults()
          .visibleColumnIds
          .contains(_field(const MovieRegistration(), 'movie.title')),
      isTrue,
    );
    expect(libraryKindRegistration(CatalogMediaKind.music),
        same(const MusicRegistration()));
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.game).columnSort(
        _field(const GameRegistration(), 'game.release_date'),
      ),
      _sort(const GameRegistration(), 'game.release_date'),
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.movie)
          .columnLabel(_field(const MovieRegistration(), 'variant')),
      'Variant',
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.game)
          .columnLabel(_field(const GameRegistration(), 'variant')),
      'Variant',
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.book)
          .columnLabel(_field(const BookRegistration(), 'barcode')),
      'Barcode',
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.book).tableColumnWidth(
        _field(const BookRegistration(), 'book.title'),
        {_field(const BookRegistration(), 'book.title'): 999},
      ),
      520,
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.music)
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
      libraryKindWorkspaceForKind(CatalogMediaKind.book)
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
      libraryKindWorkspaceForKind(CatalogMediaKind.game)
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
      libraryKindWorkspaceForKind(CatalogMediaKind.movie)
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
