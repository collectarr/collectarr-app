import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Isolated Runtime Type Erasure Tests', () {
    final comicWorkspace = comicKindWorkspace;
    final bookWorkspace = bookKindWorkspace;

    LibraryProjectionView createComicItem(String id, String title) {
      final source = LibraryWorkspaceSource(
        itemId: id,
        catalogTransport: testCatalogItem(
          id: id,
          kind: 'comic',
          title: title,
        ).asShelfCatalogItem,
      );
      const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
      return comicWorkspace.project(source: source, node: node);
    }

    LibraryProjectionView createBookItem(String id, String title) {
      final source = LibraryWorkspaceSource(
        itemId: id,
        catalogTransport: testCatalogItem(
          id: id,
          kind: 'book',
          title: title,
        ).asShelfCatalogItem,
      );
      const node = LibraryTitleNodeRef(titleItemId: 'book-1');
      return bookWorkspace.project(source: source, node: node);
    }

    test('runtime performs sorting without caller casting DTO types', () {
      final itemA = createComicItem('1', 'Amazing Spider-Man');
      final itemB = createComicItem('2', 'Batman');

      final result = comicWorkspace.compare(itemA, itemB, ComicSortIds.title);
      expect(result, isNegative);

      final items = [itemB, itemA];
      comicWorkspace.sort(items, ComicSortIds.title, ascending: true);
      expect(items.first.dto.title, 'Amazing Spider-Man');
      expect(items.last.dto.title, 'Batman');
    });

    test('runtime extracts group value without caller recovering types', () {
      final item = createComicItem('1', 'Saga');
      final groupVal = comicWorkspace.groupValue(item, ComicGroupIds.series);
      expect(groupVal, isA<String?>());
      expect(
        comicWorkspace.fields.findGroupDefinition(
          comicWorkspace.fields.decodeGroupId('comic.series'),
        ),
        isNotNull,
      );
      expect(() => comicWorkspace.groupValue(item, ComicGroupIds.series),
          returnsNormally);
    });

    test('runtime builds card presentation via behavior boundary', () {
      final item = createComicItem('1', 'Saga');
      final card = comicLibraryMediaPresentation.buildCardPresentation(
        item,
        musicVertical: false,
      );
      expect(card, isNotNull);
    });

    test(
        'runtime rejects projection originating from another kind with clear ArgumentError',
        () {
      final comicItem = createComicItem('1', 'X-Men');
      final bookItem = createBookItem('2', 'Dune');

      // Book module cannot process a comic projection item
      expect(
        () => bookWorkspace.validateProjection(comicItem),
        throwsArgumentError,
      );
      expect(
        () => bookWorkspace.compare(bookItem, comicItem, BookSortIds.title),
        throwsArgumentError,
      );
      expect(
        () => bookWorkspace.groupValue(comicItem, BookGroupIds.author),
        throwsArgumentError,
      );

      // Comic module cannot process a book projection item
      expect(
        () => comicWorkspace.validateProjection(bookItem),
        throwsArgumentError,
      );
    });

    test('every concrete kind exposes its typed workspace directly', () {
      expect(animeKindModule.identity.kind, CatalogMediaKind.anime);
      expect(animeKindWorkspace.fields, isNotNull);
      expect(animeKindWorkspace.projector, isNotNull);
      expect(boardGameKindModule.identity.kind, CatalogMediaKind.boardgame);
      expect(boardGameKindWorkspace.fields, isNotNull);
      expect(boardGameKindWorkspace.projector, isNotNull);
      expect(bookKindModule.identity.kind, CatalogMediaKind.book);
      expect(bookKindWorkspace.fields, isNotNull);
      expect(bookKindWorkspace.projector, isNotNull);
      expect(comicKindModule.identity.kind, CatalogMediaKind.comic);
      expect(comicKindWorkspace.fields, isNotNull);
      expect(comicKindWorkspace.projector, isNotNull);
      expect(gameKindModule.identity.kind, CatalogMediaKind.game);
      expect(gameKindWorkspace.fields, isNotNull);
      expect(gameKindWorkspace.projector, isNotNull);
      expect(mangaKindModule.identity.kind, CatalogMediaKind.manga);
      expect(mangaKindWorkspace.fields, isNotNull);
      expect(mangaKindWorkspace.projector, isNotNull);
      expect(movieKindModule.identity.kind, CatalogMediaKind.movie);
      expect(movieKindWorkspace.fields, isNotNull);
      expect(movieKindWorkspace.projector, isNotNull);
      expect(musicKindModule.identity.kind, CatalogMediaKind.music);
      expect(musicKindWorkspace.fields, isNotNull);
      expect(musicKindWorkspace.projector, isNotNull);
      expect(tvKindModule.identity.kind, CatalogMediaKind.tv);
      expect(tvKindWorkspace.fields, isNotNull);
      expect(tvKindWorkspace.projector, isNotNull);
    });
  });
}
