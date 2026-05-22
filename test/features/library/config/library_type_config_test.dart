import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comics library config groups reusable media behavior', () {
    expect(comicsLibraryConfig.workspace.kind, 'comic');
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
    expect(
      comicsLibraryConfig.metadataProviders
          .where((provider) => provider.requiresApiKey)
          .single
          .id,
      'comicvine',
    );
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
    expect(comicsLibraryConfig.countLabel(1), 'Comic');
    expect(comicsLibraryConfig.countLabel(2), 'Comics');
  });

  test('library type config can carry an add dialog launcher override', () {
    Future<bool?> fakeLauncher(BuildContext context, LibraryAddDialogRequest request) {
      return Future.value(true);
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
      'anime',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'music',
    ]);
    expect(collectarrLibraryTypes.byKind('comic'), comicsLibraryConfig);
    expect(collectarrLibraryTypes.byKind(' Comic '), comicsLibraryConfig);
    expect(
        collectarrLibraryTypes.byKind('game')?.defaultMetadataProvider, 'igdb');
    expect(collectarrLibraryTypes.byKind('boardgame')?.defaultMetadataProvider,
        'bgg');
    expect(collectarrLibraryTypes.byKind('manga')?.defaultMetadataProvider,
        'anilist');
    expect(collectarrLibraryTypes.byKind('anime')?.defaultMetadataProvider,
        'anilist');
    expect(collectarrLibraryTypes.byKind('book')?.defaultMetadataProvider,
        'openlibrary');
    expect(collectarrLibraryTypes.byKind('movie')?.defaultMetadataProvider,
        'tmdb');
    expect(
        collectarrLibraryTypes.byKind('tv')?.defaultMetadataProvider, 'tmdb');
    expect(collectarrLibraryTypes.byKind('music')?.defaultMetadataProvider,
        'musicbrainz');
    expect(collectarrLibraryTypes.byKind('bluray'), isNull);
    expect(
      collectarrLibraryTypes.providersForKind('comic').map((row) => row.id),
      ['gcd', 'comicvine'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('manga').map((row) => row.id),
      ['anilist', 'mangadex', 'comicvine', 'hardcover'],
    );
    expect(
      collectarrLibraryTypes.providersForKind('anime').map((row) => row.id),
      ['anilist', 'tmdb'],
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
      collectarrLibraryTypes.providersForKind('music').map((row) => row.id),
      ['musicbrainz'],
    );
    expect(collectarrLibraryTypes.providersForKind('bluray'), isEmpty);
    expect(collectarrLibraryTypes.byKind('movie')?.addDialogLauncher, isNull);
    expect(collectarrLibraryTypes.byKind('movie')?.editDialogBuilder, isNull);
    expect(collectarrLibraryTypes.byKind('movie')?.detailPageBuilder, isNull);
  });

  test('video physical formats are variants under movies and tv', () {
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
    expect(comicsMediaAdapter.viewProfile.config.kind, 'comic');
    expect(comicsMediaAdapter.columnDisplayName(LibraryTableColumn.title),
        'Series');
    expect(comicsMediaAdapter.columnLabel(LibraryTableColumn.cover), '');
    expect(
      comicsMediaAdapter.columnGroup(LibraryTableColumn.storageBox),
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
      'manga',
      'anime',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'music',
    ]);
    expect(collectarrMediaAdapters.supportedKinds, [
      'comic',
      'manga',
      'anime',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'music',
    ]);
    expect(collectarrMediaAdapters.byKind(' Comic '), comicsMediaAdapter);
    expect(collectarrMediaAdapters.byKind('manga'), mangaMediaAdapter);
    expect(collectarrMediaAdapters.byKind('anime'), animeMediaAdapter);
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
    expect(collectarrMediaAdapters.byKind('tv')?.type, tvLibraryConfig);
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
  });
}
