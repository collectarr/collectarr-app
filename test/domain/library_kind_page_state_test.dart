import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import '../helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/anime/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_pages.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_drilldown_library_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known kind pages create concrete state classes', () {
    expect(
        BookLibraryPage(
                type: bookKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/books'))
            .createState(),
        isA<BookLibraryPageState>());
    expect(
        GameLibraryPage(
                type: gameKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/games'))
            .createState(),
        isA<GameLibraryPageState>());
    expect(
        BoardGameLibraryPage(
                type: boardGameKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/boardgames'))
            .createState(),
        isA<BoardGameLibraryPageState>());
    expect(
        MusicLibraryPage(
                type: musicKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/music'))
            .createState(),
        isA<MusicLibraryPageState>());
    expect(
        ComicLibraryPage(
                type: comicKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/comics'))
            .createState(),
        isA<ComicLibraryPageState>());
    expect(
        MangaLibraryPage(
                type: mangaKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/manga'))
            .createState(),
        isA<MangaLibraryPageState>());
    expect(
        MovieLibraryPage(
                type: movieKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/movies'))
            .createState(),
        isA<MovieLibraryPageState>());
    expect(
        TvLibraryPage(
                type: tvKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/tv'))
            .createState(),
        isA<TvLibraryPageState>());
    expect(
        AnimeLibraryPage(
                type: animeKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/anime'))
            .createState(),
        isA<AnimeLibraryPageState>());
  });

  test('book page state owns the book browse folder id', () {
    final state = BookLibraryPageState();
    expect(state.ownsKindReleaseFolderState, isTrue);
    expect(state.kindReleaseFolderTitleItemId, isNull);

    state.kindReleaseFolderTitleItemId = 'book-work-1';
    expect(state.kindReleaseFolderTitleItemId, 'book-work-1');
  });

  test('game page state owns the game browse folder id', () {
    final state = GameLibraryPageState();
    expect(state.ownsKindReleaseFolderState, isTrue);
    expect(state.kindReleaseFolderTitleItemId, isNull);
    state.kindReleaseFolderTitleItemId = 'game-work-1';
    expect(state.kindReleaseFolderTitleItemId, 'game-work-1');
  });

  test('board game page state owns the board game browse folder id', () {
    final state = BoardGameLibraryPageState();
    expect(state.ownsKindReleaseFolderState, isTrue);
    expect(state.kindReleaseFolderTitleItemId, isNull);
    state.kindReleaseFolderTitleItemId = 'boardgame-work-1';
    expect(state.kindReleaseFolderTitleItemId, 'boardgame-work-1');
  });

  test('video-like kinds share the explicit video drilldown state base', () {
    expect(
        MovieLibraryPage(
                type: movieKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/movies'))
            .createState(),
        isA<VideoDrilldownLibraryPageState>());
    expect(
        TvLibraryPage(
                type: tvKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/tv'))
            .createState(),
        isA<GenericLibraryPageState>());
    expect(
        AnimeLibraryPage(
                type: animeKindModule,
                topBar: const SizedBox(),
                accent: Colors.blue,
                routeUri: Uri(path: '/anime'))
            .createState(),
        isA<VideoDrilldownLibraryPageState>());
  });

  test('reading queue visibility is now kind-owned in toolbar actions', () {
    expect(
      bookKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.readingQueue),
      isTrue,
    );
    expect(
      gameKindModule.toolbarActionAvailability
          .allows(LibraryToolbarActionId.readingQueue),
      isFalse,
    );
  });

  test('kind presentation owns track search and group mode categories', () {
    expect(
      musicKindModule.searchTargetOptions
          .contains(LibrarySearchTarget.tracksOnly),
      isTrue,
    );
    expect(
      movieKindModule.searchTargetOptions
          .contains(LibrarySearchTarget.tracksOnly),
      isFalse,
    );

    final comicCategories = libraryGroupModeCategories(
      comicKindModule,
      ['series', 'grade', 'writer'],
    );
    expect(comicCategories.map((category) => category.label), [
      'Main',
      'Value',
      'Creators & Characters',
    ]);
  });

  testWidgets('book edit dialog resolves all-scope requests to media scope',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));

    final request = LibraryEditDialogRequest(
      type: bookKindModule,
      item: LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Hyperion',
        ),
      ),
      ownedItem: null,
      accent: Colors.blue,
      scope: LibraryEditScope.all,
    );

    final dialog = buildBookLibraryEditDialog(
      context,
      request,
    ) as LibraryEditRenderer;

    expect(dialog.scope, LibraryEditScope.media);
  });

  test(
      'library kind page builder dispatches known kinds and falls back to generic',
      () {
    expect(
      buildLibraryKindPage(
        type: defaultLibraryKindRegistry.require(CatalogMediaKind.comic),
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/comic'),
      ),
      isA<ComicLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: defaultLibraryKindRegistry.require(CatalogMediaKind.movie),
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/movie'),
      ),
      isA<MovieLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: defaultLibraryKindRegistry.require(CatalogMediaKind.tv),
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/tv'),
      ),
      isA<TvLibraryPage>(),
    );
    expect(
      buildLibraryKindPage(
        type: genericKindModule,
        topBar: const SizedBox(),
        accent: Colors.blue,
        routeUri: Uri(path: '/unknown'),
      ),
      isA<GenericLibraryPage>(),
    );
  });
}
