import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
// manga/anime kinds merged into comic/movie; tests adapt accordingly
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
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

  // 'manga' kind has been merged into comics; no separate config test required.

  test('movies library config uses the dedicated add dialog launcher', () {
    expect(
        moviesLibraryConfig.addDialogLauncher, same(showMovieLibraryAddDialog));
    expect(moviesLibraryConfig.editUsesTitleAsSeries, isFalse);
    expect(moviesWorkspaceConfig.accent, const Color(0xFF42AA55));
    expect(libraryAccentForKind('anime'), const Color(0xFF42AA55));
    expect(libraryIconForKind('tv'), Icons.movie_outlined);
    expect(moviesLibraryConfig.collectionExportTitleLabel, 'Title');
  });

  test('collection export title labels are kind-owned', () {
    expect(comicsLibraryConfig.collectionExportTitleLabel, 'Series');
    expect(musicLibraryConfig.collectionExportTitleLabel, 'Release');
    expect(booksLibraryConfig.collectionExportTitleLabel, 'Title');
  });

  test('books library config enables creator spotlight in shared hero chrome', () {
    expect(booksLibraryConfig.capabilities.showsCreatorSpotlight, isTrue);
    expect(moviesLibraryConfig.capabilities.showsCreatorSpotlight, isFalse);
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
      'book',
      'game',
      'boardgame',
      'movie',
      'music',
    ]);
    expect(collectarrLibraryTypes.byKind('comic'), comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind(' Comic '), comicsLibraryConfig);
    expect(
        collectarrLibraryTypes.byKind('game')?.defaultMetadataProvider, 'igdb');
    expect(collectarrLibraryTypes.byKind('boardgame')?.defaultMetadataProvider,
        'bgg');
    // 'manga' and 'anime' are canonicalized into existing kinds; ensure core kinds resolve.
    expect(collectarrLibraryTypes.byKind('book')?.defaultMetadataProvider,
        'openlibrary');
    expect(collectarrLibraryTypes.byKind('movie')?.defaultMetadataProvider,
        'tmdb');
    expect(collectarrLibraryTypes.byKind('music')?.defaultMetadataProvider,
        'musicbrainz');
    expect(collectarrLibraryTypes.byKind('bluray'), isNull);
    expect(
      collectarrLibraryTypes.providersForKind('comic').map((row) => row.id),
      containsAll(['gcd', 'comicvine']),
    );
    // Providers formerly associated with 'manga'/'anime' are merged into comics/movies configs.
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

  test('transferable field keys are kind-owned', () {
    expect(booksLibraryConfig.transferableFieldKeys, kDefaultTransferableFieldKeys);
    expect(
      comicsLibraryConfig.transferableFieldKeys,
      containsAll(kComicTransferableFieldKeys),
    );
    expect(booksLibraryConfig.transferableFieldKeys, isNot(contains('keyComic')));
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
    expect(gamesLibraryConfig.editDialogBuilder,
        same(buildGameLibraryEditDialog));
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
      ['Essential', 'Ownership', 'Value', 'Full'],
    );
    expect(
      comicsMediaAdapter.orderedTableColumns(const {}).first,
      LibraryTableColumn.status,
    );
  });

  test('planned media adapters cover non-comics workspace defaults', () {
    expect(plannedMediaAdapters.supportedKinds, [
      'book',
      'game',
      'boardgame',
      'movie',
      'music',
    ]);
    expect(collectarrMediaAdapters.supportedKinds, [
      'comic',
      'book',
      'game',
      'boardgame',
      'movie',
      'music',
    ]);
    expect(collectarrMediaAdapters.byKind(' Comic '), comicsMediaAdapter);
    // 'manga' and 'anime' adapters removed; adapter behavior now consolidated.
    expect(collectarrMediaAdapters.byKind('book')?.type, booksLibraryConfig);
    expect(collectarrMediaAdapters.byKind('boardgame')?.type,
        boardGamesLibraryConfig);
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
      LibraryGroupMode.publisher,
      LibraryGroupMode.year,
      LibraryGroupMode.location,
      LibraryGroupMode.title,
      LibraryGroupMode.ownership,
    ]);
    expect(
      booksLibraryConfig.presentation.sortFavorites.map((favorite) => favorite.id),
      ['title_asc', 'release_latest', 'recent', 'value_desc'],
    );
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
      comicsLibraryConfig.presentation.columnFavorites.map((preset) => preset.label),
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
