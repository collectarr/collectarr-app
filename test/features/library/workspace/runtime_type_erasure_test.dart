import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Isolated Runtime Type Erasure Tests', () {
    final comicWorkspace = libraryKindWorkspaceForKind(CatalogMediaKind.comic);
    final bookWorkspace = libraryKindWorkspaceForKind(CatalogMediaKind.book);

    LibraryProjectionView createComicItem(String id, String title) {
      final source = ShelfEntry(
        itemId: id,
        catalogItem: testCatalogItem(
          id: id,
          kind: 'comic',
          title: title,
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
      return comicWorkspace.project(source: source, node: node);
    }

    LibraryProjectionView createBookItem(String id, String title) {
      final source = ShelfEntry(
        itemId: id,
        catalogItem: testCatalogItem(
          id: id,
          kind: 'book',
          title: title,
        ),
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

    test('heterogeneous registry resolves correct typed module for all 9 kinds',
        () {
      for (final kind in CatalogMediaKind.values
          .where((k) => k != CatalogMediaKind.unknown)) {
        final runtime = libraryKindModuleForKind(kind);
        expect(runtime.kind, kind);
        final workspace = libraryKindWorkspaceForKind(kind);
        expect(workspace.fields, isNotNull);
        expect(workspace.projector, isNotNull);
      }
    });
  });
}
