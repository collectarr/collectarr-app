import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_browser_navigation_policy.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
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
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_release_detail_page.dart';
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
    expect(comicKindIdentity.kind, CatalogMediaKind.comic);
    expect(comicKindIdentity.singularLabel, 'Comic');
    expect(comicKindIdentity.pluralLabel, 'Comics');
    expect(comicKindMetadata.defaultProviderId, 'gcd');
    expect(
      comicKindMetadata.defaultSupportedOption(comicKindIdentity.kind)?.id,
      'gcd',
    );
    expect(
      comicKindMetadata.defaultSupportedOption(comicKindIdentity.kind)?.id,
      'gcd',
    );
    expect(
      comicKindMetadata.supportsProvider('gcd', comicKindIdentity.kind),
      isTrue,
    );
    expect(
      comicKindMetadata.supportsProvider(
        'comicvine',
        comicKindIdentity.kind,
      ),
      isTrue,
    );
    expect(
      comicKindMetadata
          .defaultSupportedOption(comicKindIdentity.kind)
          ?.usagePolicy
          ?.summary,
      contains('CC BY-SA'),
    );
    final apiKeyIds = comicKindMetadata.providers
        .where((provider) => provider.requiresApiKey)
        .map((provider) => provider.id)
        .toList();
    expect(apiKeyIds, contains('comicvine'));
    expect(comicKindMetadata.providerLabel('gcd'), 'GCD');
    expect(comicKindMetadata.providerLabel('comicvine'), 'Comic Vine');
    expect(
      comicKindMetadata.providerLabel('unknown-provider'),
      'unknown-provider',
    );
    expect(comicKindTrackingProfile, comicTrackingProfile);
    expect(comicKindPresentation, comicLibraryMediaPresentation);
    expect(comicKindAdd.dialogLauncher, same(showComicLibraryAddDialog));
    expect(
        comicKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        same(buildComicLibraryEditDialog));
    expect(
      comicKindInspector.entityRegistry
          .contributorForScope(LibraryEntityScope.work)
          ?.sectionsBuilder,
      same(buildComicWorkInspectorSections),
    );
    expect(comicKindIdentity.countLabel(1), 'Comic');
    expect(comicKindIdentity.countLabel(2), 'Comics');
  });

  test('manga runtime is a first-class comic-family kind', () {
    expect(mangaKindIdentity.kind, CatalogMediaKind.manga);
    expect(mangaKindIdentity.singularLabel, 'Manga');
    expect(mangaKindIdentity.pluralLabel, 'Manga');
    expect(mangaKindMetadata.defaultProviderId, 'hardcover');
    expect(
      mangaKindMetadata.defaultSupportedOption(mangaKindIdentity.kind)?.id,
      'hardcover',
    );
    expect(
      mangaKindMetadata.supportsProvider(
        'mangadex',
        mangaKindIdentity.kind,
      ),
      isTrue,
    );
    expect(
      mangaKindMetadata.supportsProvider(
        'anilist',
        mangaKindIdentity.kind,
      ),
      isTrue,
    );
    expect(mangaKindTrackingProfile, mangaTrackingProfile);
    expect(mangaKindPresentation, mangaLibraryMediaPresentation);
    expect(
        mangaKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        isNotNull);
    expect(
        mangaKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.copy),
        same(buildMangaMediaLibraryEditDialog));
    expect(mangaKindEditCapabilities.presentationCapability.presentation,
        same(mangaLibraryEditPresentation));
    expect(mangaKindIdentity.countLabel(1), 'Manga');
    expect(mangaKindIdentity.countLabel(2), 'Manga');
  });

  test('movies library config uses the dedicated add dialog launcher', () {
    expect(movieKindAdd.dialogLauncher, same(showMovieLibraryAddDialog));
    expect(movieKindIdentity.accent, const Color(0xFF42AA55));
    expect(
        libraryAccentForKind(CatalogMediaKind.anime), const Color(0xFFC94DFF));
    expect(libraryIconForKind(CatalogMediaKind.tv), Icons.tv_outlined);
  });

  test('media and export labels are kind-owned', () {
    expect(
      comicKindPresentation.previewLabels.labelFor(
        'media_scope',
        fallback: 'Media',
      ),
      'Series',
    );
    expect(
      musicKindPresentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Release',
    );
  });

  test('books do not create series subgroups for volume metadata', () {
    final source = testLibraryWorkspaceSource(
      itemId: 'book-1',
      kind: 'book',
      title: 'Dune',
    );
    const node = LibraryWorkRef(workId: 'book-1');
    final dto = const BookWorkspaceProjector().project(
      source: source,
      entity: node,
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
    expect(animeKindIdentity.kind, CatalogMediaKind.anime);
    expect(animeKindMetadata.defaultProviderId, 'anilist');
    expect(
      animeKindMetadata.supportsProvider(
        'anilist',
        animeKindIdentity.kind,
      ),
      isTrue,
    );
    expect(
        animeKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        isNotNull);

    expect(tvKindIdentity.kind, CatalogMediaKind.tv);
    expect(tvKindMetadata.defaultProviderId, 'tmdb');
    expect(
      tvKindMetadata.supportsProvider('tmdb', tvKindIdentity.kind),
      isTrue,
    );
    expect(
        tvKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        isNotNull);
    expect(
      tvKindInspector.detailPageBuilderForScope(LibraryEntityScope.release),
      same(buildLibraryReleaseDetailPage),
    );
    expect(tvKindInspector.mediaDetailContributionBuilder, isNotNull);
    expect(movieKindInspector.mediaDetailContributionBuilder, isNull);
  });

  test('tv edit presentation splits media and release tabs', () {
    const context = LibraryEditPresentationContext(
      isOwned: false,
      isTrackingOnly: false,
      hasTrackingContext: false,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: true,
      hasOwnedTargetOptions: true,
      hasAdditionalTargetOptions: false,
      hasCustomFields: false,
    );

    final mediaTabs = tvKindEditCapabilities.presentationCapability.presentation
        .builderForScope(LibraryEntityScope.work)
        .buildTabs(context: context);
    final releaseTabs = tvKindEditCapabilities
        .presentationCapability.presentation
        .builderForScope(LibraryEntityScope.release)
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
      comicKindPresentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Series',
    );
    expect(
      musicKindPresentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Release',
    );
    expect(
      bookKindPresentation.previewLabels.labelFor(
        'export_title',
        fallback: 'Title',
      ),
      'Title',
    );
  });

  test('book runtime enables creator spotlight in shared hero chrome', () {
    expect(bookKindInspector.showsCreatorSpotlight, isTrue);
    expect(
      libraryEntityVocabularyForKind(CatalogMediaKind.book).release.singular,
      'Edition',
    );
    expect(movieKindInspector.showsCreatorSpotlight, isFalse);
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
      bookKindEditCapabilities.presentationCapability.editRegistry
          .builderForScope(LibraryEntityScope.copy),
      same(buildBookMediaLibraryEditDialog),
    );
    expect(
      bookKindEditCapabilities.presentationCapability.editRegistry
          .builderForScope(LibraryEntityScope.release),
      same(buildBookReleaseLibraryEditDialog),
    );
    expect(bookKindHierarchy.childrenTitle(2), 'Editions (2)');

    const context = LibraryEditPresentationContext(
      isOwned: true,
      isTrackingOnly: false,
      hasTrackingContext: false,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: true,
      hasOwnedTargetOptions: true,
      hasAdditionalTargetOptions: false,
      hasCustomFields: false,
    );
    final tabs = bookKindEditCapabilities.presentationCapability.presentation
        .builderForScope(LibraryEntityScope.work)
        .buildTabs(context: context);
    expect(tabs.map((tab) => tab.id), contains('owned'));
  });

  test('book and boardgame runtimes own their scoped browser options', () {
    const bookKind = CatalogMediaKind.book;
    expect(
      libraryKindWorkspaceForKind(bookKind)
          .availableGroupIdsForScope(LibraryEntityScope.work),
      isNotEmpty,
    );
    expect(
      libraryKindWorkspaceForKind(bookKind)
          .availableGroupIdsForScope(LibraryEntityScope.release),
      isNotEmpty,
    );
    expect(
      libraryKindWorkspaceForKind(bookKind)
          .availableSortIdsForScope(LibraryEntityScope.work),
      isNotEmpty,
    );
    expect(
      boardGameKindWorkspace.fields.sorts.map((d) => d.id.value),
      contains('boardgame.title'),
    );
  });

  test('typed browser scopes preserve comic and movie options', () {
    const comicKind = CatalogMediaKind.comic;
    expect(
      libraryEntityVocabularyForKind(comicKind).release.singular,
      'Variant',
    );
    final comicMediaGroups = libraryKindWorkspaceForKind(comicKind)
        .availableGroupIdsForScope(LibraryEntityScope.work)
        .map((id) => id.value)
        .toSet();
    final comicReleaseGroups = libraryKindWorkspaceForKind(comicKind)
        .availableGroupIdsForScope(LibraryEntityScope.release)
        .map((id) => id.value)
        .toSet();
    expect(comicMediaGroups, contains('comic.series'));
    expect(comicReleaseGroups, contains('comic.publisher'));

    const movieKind = CatalogMediaKind.movie;
    final movieMediaGroups = libraryKindWorkspaceForKind(movieKind)
        .availableGroupIdsForScope(LibraryEntityScope.work)
        .map((id) => id.value)
        .toSet();
    final movieReleaseGroups = libraryKindWorkspaceForKind(movieKind)
        .availableGroupIdsForScope(LibraryEntityScope.release)
        .map((id) => id.value)
        .toSet();
    expect(
        movieMediaGroups,
        containsAll([
          'movie.director',
          'movie.genre',
        ]));
    expect(
        movieReleaseGroups,
        containsAll([
          'movie.publisher',
          'movie.format',
          'movie.audio_tracks',
          'movie.edition_release_date',
        ]));
  });

  test('edit scope follows the active browser mode', () {
    expect(
      libraryBrowserNavigationPolicy.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.work,
      ),
      LibraryEntityScope.work,
    );
    expect(
      libraryBrowserNavigationPolicy.editScopeForBrowserMode(
        LibraryWorkspaceBrowserMode.release,
      ),
      LibraryEntityScope.release,
    );
  });

  test('library kind registry resolves runtimes and providers', () {
    final registrations = defaultLibraryKindRegistry.allKinds;
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
    for (final kind in [
      CatalogMediaKind.game,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
      CatalogMediaKind.anime,
      CatalogMediaKind.music,
    ]) {
      final expectedProvider = switch (kind) {
        CatalogMediaKind.game => 'igdb',
        CatalogMediaKind.boardgame => 'bgg',
        CatalogMediaKind.book => 'hardcover',
        CatalogMediaKind.movie || CatalogMediaKind.tv => 'tmdb',
        CatalogMediaKind.anime => 'anilist',
        CatalogMediaKind.music => 'musicbrainz',
        _ => throw ArgumentError.value(kind),
      };
      expect(
        collectarrKindMetadata[kind]!.defaultProviderId,
        expectedProvider,
      );
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
    expect(movieKindAdd.dialogLauncher, same(showMovieLibraryAddDialog));
    expect(
      libraryEditPresentationForKind(CatalogMediaKind.movie)
          .editRegistry
          .builderForScope(LibraryEntityScope.work),
      isNotNull,
    );
    expect(
      libraryInspectorForKind(CatalogMediaKind.movie)
          .detailPageBuilderForScope(LibraryEntityScope.release),
      isNotNull,
    );
  });

  test('all registered kinds declare an explicit edit dialog builder', () {
    for (final registration in defaultLibraryKindRegistry.allKinds) {
      expect(
        collectarrKindEditCapabilities[registration.kind]!
            .presentationCapability
            .editRegistry
            .builderForScope(LibraryEntityScope.work),
        isNotNull,
        reason:
            'Expected ${registration.kind.apiValue} to declare an explicit edit dialog builder.',
      );
    }
  });

  test('library kind registry covers all active kinds', () {
    final registeredKinds = defaultLibraryKindRegistry.allKinds
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
    for (final runtime in defaultLibraryKindRegistry.allKinds) {
      expect(
        defaultLibraryKindRegistry.getByKind(runtime.kind),
        same(runtime),
        reason: 'Missing runtime for ${runtime.kind.apiValue}.',
      );
    }
  });

  test('transferable field keys are kind-owned', () {
    expect(
      bookKindTransfer.transferableFieldKeys,
      containsAll([...kDefaultTransferableFieldKeys, 'grade']),
    );
    expect(
      comicKindTransfer.transferableFieldKeys,
      containsAll([
        'rawOrSlabbed',
        'gradingCompany',
        'graderNotes',
        'signedBy',
        'keyReason',
        'keyComic',
      ]),
    );
    expect(bookKindTransfer.transferableFieldKeys, isNot(contains('keyComic')));
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
      musicKindAdd.chrome.trackScopeSummary,
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
    );
    expect(
      LibraryAddReferenceType.edition
          .helperLabelForType(const MusicRegistration()),
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
    );
    expect(
      movieKindAdd.chrome.kindFilterOptions.map((option) => option.scope),
      [
        const LibraryAddSearchScope(
          kind: CatalogMediaKind.movie,
          providerValue: 'movie',
        ),
        const LibraryAddSearchScope(
          kind: CatalogMediaKind.movie,
          providerValue: 'collection',
        ),
      ],
    );
    expect(
      movieKindAdd.chrome.kindFilterOptions.map((option) => option.label),
      ['Movies', 'Box Sets'],
    );
    expect(
      movieKindAdd.chrome.defaultKindFilters,
      {
        const LibraryAddSearchScope(
          kind: CatalogMediaKind.movie,
          providerValue: 'movie',
        ),
      },
    );
    expect(
      const LibraryAddSearchScope(
        kind: CatalogMediaKind.movie,
        providerValue: 'collection',
      ).kind,
      CatalogMediaKind.movie,
    );
  });

  test('comic kind uses dedicated edit dialog builder', () {
    expect(
        comicKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        same(buildComicLibraryEditDialog));
  });

  test('music kind uses dedicated release edit dialog builder', () {
    expect(
        musicKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        same(buildMusicReleaseGroupLibraryEditDialog));
    expect(
      musicKindEditCapabilities.presentationCapability.editRegistry
          .builderForScope(LibraryEntityScope.release),
      same(buildMusicReleaseLibraryEditDialog),
    );
  });

  test('game kinds use dedicated edit dialog builders', () {
    expect(
        gameKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
        same(buildGameLibraryEditDialog));
    expect(
        boardGameKindEditCapabilities.presentationCapability.editRegistry
            .builderForScope(LibraryEntityScope.work),
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
      LibraryTableColumnGroup.main,
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind).columnIsNumeric(
          _field(const ComicRegistration(), 'comic.price_paid')),
      isFalse,
    );
    expect(
      libraryKindWorkspaceForKind(comicRuntime.kind).columnSort(
        _field(const ComicRegistration(), 'comic.release_date'),
        node: const LibraryReleaseRef(
          workId: 'comic-work',
          releaseId: 'comic-release',
          release: LibraryWorkspaceReleaseSummary(
            id: 'comic-release',
            title: 'Comic release',
          ),
        ),
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
      _field(const ComicRegistration(), 'comic.cover'),
    );
  });

  test('kind runtimes cover workspace defaults', () {
    expect(
      defaultLibraryKindRegistry.allKinds
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
      movieKindViewProfile
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
        node: const LibraryReleaseRef(
          workId: 'game-work',
          releaseId: 'game-release',
          release: LibraryWorkspaceReleaseSummary(
            id: 'game-release',
            title: 'Game release',
          ),
        ),
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
        'music.genre',
      ],
    );
    expect(
      bookKindPresentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['title_asc', 'release_latest', 'recent', 'value_desc'],
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.book)
          .availableGroupIds
          .map((id) => id.value),
      [
        'book.author',
        'book.series',
      ],
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.game)
          .availableGroupIds
          .map((id) => id.value),
      [
        'game.platform',
        'game.franchise',
      ],
    );
    expect(comicLibraryFacetModule.externalFacetBucketIdsByMode.keys, [
      'comic.story_arc',
      'comic.character',
    ]);
    expect(
      comicKindPresentation.sortFavorites
          .map((LibrarySortFavorite favorite) => favorite.id),
      ['series_issue', 'recent', 'publisher_date', 'value_desc'],
    );
    expect(
      comicKindPresentation.columnFavorites.map((preset) => preset.label),
      comicsTableColumnPresets.map((preset) => preset.label),
    );
    expect(bookKindPresentation.compactBucketIcon, Icons.folder);
    expect(
      movieKindPresentation.compactBucketIcon,
      Icons.movie_filter_outlined,
    );
    expect(
      musicKindPresentation.compactBucketIcon,
      Icons.person_2_outlined,
    );
    expect(bookKindPresentation.emptyStateProviderSummarySuffix, '');
    expect(
      movieKindPresentation.emptyStateProviderSummarySuffix,
      ' Physical formats are tracked as editions.',
    );
    expect(
      libraryKindWorkspaceForKind(CatalogMediaKind.movie)
          .availableGroupIds
          .map((id) => id.value),
      [
        'movie.director',
        'movie.genre',
        'movie.audience_rating',
        'movie.movie_or_tv_series',
      ],
    );
  });
}
