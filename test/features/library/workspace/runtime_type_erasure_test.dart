import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Isolated Runtime Type Erasure Tests', () {
    final comicModule = libraryKindModuleForKind(CatalogMediaKind.comic);
    final bookModule = libraryKindModuleForKind(CatalogMediaKind.book);

    LibraryProjectionItem createComicItem(String id, String title) {
      final source = ShelfEntry(
        itemId: id,
        catalogItem: testCatalogItem(
          id: id,
          kind: 'comic',
          title: title,
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
      final dto = comicModule.projector.projectTitle(
        source: source,
        node: node,
      );
      return LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );
    }

    LibraryProjectionItem createBookItem(String id, String title) {
      final source = ShelfEntry(
        itemId: id,
        catalogItem: testCatalogItem(
          id: id,
          kind: 'book',
          title: title,
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'book-1');
      final dto = bookModule.projector.projectTitle(
        source: source,
        node: node,
      );
      return LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );
    }

    test('runtime performs sorting without caller casting DTO types', () {
      final itemA = createComicItem('1', 'Amazing Spider-Man');
      final itemB = createComicItem('2', 'Batman');

      final result = comicModule.compareEntries(itemA, itemB, 'comic.title');
      expect(result, isNegative);

      final items = [itemB, itemA];
      comicModule.sortEntries(items, 'comic.title', ascending: true);
      expect(items.first.dto.title, 'Amazing Spider-Man');
      expect(items.last.dto.title, 'Batman');
    });

    test('runtime extracts group value without caller recovering types', () {
      final item = createComicItem('1', 'Saga');
      final groupVal = comicModule.getGroupValue(item, 'comic.series');
      // For comic title projection without explicit series title, getValue returns null or title
      expect(comicModule.fields.findGroupDefinition('comic.series'), isNotNull);
      expect(() => comicModule.getGroupValue(item, 'comic.series'),
          returnsNormally);
    });

    test(
        'runtime rejects projection originating from another kind with clear ArgumentError',
        () {
      final comicItem = createComicItem('1', 'X-Men');
      final bookItem = createBookItem('2', 'Dune');

      // Book module cannot process a comic projection item
      expect(
        () => bookModule.validateProjection(comicItem),
        throwsArgumentError,
      );
      expect(
        () => bookModule.compareEntries(bookItem, comicItem, 'book.title'),
        throwsArgumentError,
      );
      expect(
        () => bookModule.getGroupValue(comicItem, 'book.author'),
        throwsArgumentError,
      );

      // Comic module cannot process a book projection item
      expect(
        () => comicModule.validateProjection(bookItem),
        throwsArgumentError,
      );
    });

    test('heterogeneous registry resolves correct typed module for all 9 kinds',
        () {
      for (final kind in CatalogMediaKind.values
          .where((k) => k != CatalogMediaKind.unknown)) {
        final runtime = libraryKindModuleForKind(kind);
        expect(runtime.kind, kind);
        expect(runtime.fields, isNotNull);
        expect(runtime.projector, isNotNull);
      }
    });
  });
}
