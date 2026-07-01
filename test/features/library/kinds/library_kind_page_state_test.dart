import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_pages.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known kind pages create concrete state classes', () {
    expect(
        BookLibraryPage(
                type: booksLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/books'))
            .createState(),
        isA<GenericLibraryPageState>());
    expect(
        GameLibraryPage(
                type: gamesLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/games'))
            .createState(),
        isA<GameLibraryPageState>());
    expect(
        BoardGameLibraryPage(
                type: boardGamesLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/boardgames'))
            .createState(),
        isA<BoardGameLibraryPageState>());
    expect(
        MusicLibraryPage(
                type: musicLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/music'))
            .createState(),
        isA<MusicLibraryPageState>());
    expect(
        ComicLibraryPage(
                type: comicsLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/comics'))
            .createState(),
        isA<ComicLibraryPageState>());
    expect(
        MangaLibraryPage(
                type: mangaLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/manga'))
            .createState(),
        isA<MangaLibraryPageState>());
    expect(
        MovieLibraryPage(
                type: moviesLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/movies'))
            .createState(),
        isA<MovieLibraryPageState>());
    expect(
        TvLibraryPage(
                type: tvLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/tv'))
            .createState(),
        isA<TvLibraryPageState>());
    expect(
        AnimeLibraryPage(
                type: animeLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/anime'))
            .createState(),
        isA<AnimeLibraryPageState>());
  });

  test('video-like kinds share the explicit video drilldown state base', () {
    expect(
        MovieLibraryPage(
                type: moviesLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/movies'))
            .createState(),
        isA<VideoDrilldownLibraryPageState>());
    expect(
        TvLibraryPage(
                type: tvLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/tv'))
            .createState(),
        isA<VideoDrilldownLibraryPageState>());
    expect(
        AnimeLibraryPage(
                type: animeLibraryConfig,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/anime'))
            .createState(),
        isA<VideoDrilldownLibraryPageState>());
  });

  test('reading queue visibility is now kind-owned in page state', () {
    expect(booksLibraryConfig.capabilities.supportsReadingQueue, isTrue);
    expect(gamesLibraryConfig.capabilities.supportsReadingQueue, isFalse);
  });

  test('books expose explicit kind hooks for page and inspector behavior', () {
    expect(
      booksLibraryConfig.kindHooks.page.canOpenItemDetailDrilldown,
      isNotNull,
    );
    expect(
      booksLibraryConfig.kindHooks.inspector.showActionBar,
      isFalse,
    );
    expect(
        booksLibraryConfig.kindHooks.edit.defaultScope, LibraryEditScope.media);
  });

  test(
      'library kind page builder dispatches known kinds and falls back to generic',
      () {
    expect(
      buildLibraryKindPage(
        type: collectarrLibraryTypes.byKind('comic')!,
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/comic'),
      ),
      isA<ComicLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: collectarrLibraryTypes.byKind('movie')!,
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/movie'),
      ),
      isA<MovieLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: collectarrLibraryTypes.byKind('tv')!,
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/tv'),
      ),
      isA<TvLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: _unknownLibraryConfig,
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/unknown'),
      ),
      isA<GenericLibraryPage>(),
    );
  });
}

final _unknownLibraryConfig = LibraryTypeConfig(
  workspace: const LibraryWorkspaceConfig(
    kind: CatalogMediaKind.unknown,
    title: 'Unknown',
    icon: Icons.category_outlined,
    accent: Colors.grey,
    preferencePrefix: 'unknown',
    defaultSortColumn: LibrarySortColumn.title,
    availableSortColumns: kAllLibrarySortColumns,
    availableTableColumns: kAllLibraryTableColumns,
    defaultVisibleColumns: {LibraryTableColumn.title},
  ),
  singularLabel: 'Unknown',
  pluralLabel: 'Unknown',
  defaultMetadataProvider: 'gcd',
  metadataProviders: const [gcdMetadataProvider],
  trackingProfile: comicTrackingProfile,
);
