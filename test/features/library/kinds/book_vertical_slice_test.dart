import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Book Kind Vertical Slice Tests (C4)', () {
    test('BookCatalogMetadata serializes and deserializes full domain fields',
        () {
      final metadata = BookCatalogMetadata(
        title: 'The Lord of the Rings',
        subtitle: 'The Fellowship of the Ring',
        sortTitle: 'Lord of the Rings 1',
        synopsis: 'An epic high fantasy novel by J. R. R. Tolkien.',
        authors: const ['J. R. R. Tolkien'],
        genres: const ['High Fantasy', 'Adventure'],
        subjects: const ['Middle-earth', 'Rings of Power', 'Hobbits'],
        editors: const ['Christopher Tolkien'],
        translators: const ['Ion Luca'],
        illustrators: const ['Alan Lee'],
        coverArtists: const ['Ted Nasmith'],
        rawPayload: const {
          'isbn': '9780007203581',
          'format': 'Hardcover',
          'page_count': 432,
          'printing': '1st Print',
          'first_edition': true,
          'number_line': '1 3 5 7 9 10 8 6 4 2',
          'dewey': '823.912',
          'loc_classification': 'PR6039.O32',
        },
      );

      final json = metadata.toJson();
      final restored = BookCatalogMetadata.fromJson(json);

      expect(restored.title, 'The Lord of the Rings');
      expect(restored.subtitle, 'The Fellowship of the Ring');
      expect(restored.authors, contains('J. R. R. Tolkien'));
      expect(restored.editors, contains('Christopher Tolkien'));
      expect(restored.translators, contains('Ion Luca'));
      expect(restored.illustrators, contains('Alan Lee'));
      expect(restored.rawPayload['isbn'], '9780007203581');
      expect(restored.rawPayload['format'], 'Hardcover');
      expect(restored.rawPayload['page_count'], 432);
      expect(restored.rawPayload['first_edition'], isTrue);
      expect(restored.rawPayload['number_line'], '1 3 5 7 9 10 8 6 4 2');
    });

    test('BookWorkspaceProjector projects metadata and schema fields', () {
      const bookMeta = BookCatalogMetadata(
        title: 'Dune',
        subtitle: 'Part One',
        authors: ['Frank Herbert'],
        translators: ['Ion Hobana'],
        rawPayload: {
          'isbn': '9780441013593',
          'format': 'Hardcover',
          'page_count': 896,
          'printing': 'Special Collector Edition',
          'first_edition': true,
          'dewey': '813.54',
        },
      );

      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'book_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: LibraryItemIdentity(
            id: 'book_1',
            mediaKind: CatalogMediaKind.book,
          ),
          kindData: bookMeta,
        ).asShelfCatalogItem),
        libraryEntrySummary: testLibraryEntrySummary(testLibraryEntry(
          id: 'entry_1',
          catalogRef: const CatalogEntityRef(
            id: 'book_1',
            kind: CatalogMediaKind.book,
            entityType: CatalogEntityTypeId.catalogItem,
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        )),
      );

      const projector = BookWorkspaceProjector();
      const node = LibraryCatalogItemNodeRef(
        catalogItemId: 'book_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.metadata?.title, 'Dune');
      expect(dto.author, 'Frank Herbert');
      expect(dto.subtitle, 'Part One');
      expect(dto.format, isNull);
      expect(dto.isbn, isNull);
      expect(dto.pageCount, isNull);

      final ctx = LibraryProjectionContext<BookWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(BookCatalogItemWorkspaceFields.title.getValue(ctx), 'Dune');
      expect(
        BookCatalogItemWorkspaceFields.author.getValue(ctx),
        'Frank Herbert',
      );
      expect(BookCatalogItemWorkspaceFields.subtitle.getValue(ctx), 'Part One');
      expect(
          BookCatalogItemDetailsWorkspaceFields.format.getValue(ctx), isNull);
      expect(BookCatalogItemDetailsWorkspaceFields.isbn.getValue(ctx), isNull);
      expect(
        BookCatalogItemDetailsWorkspaceFields.pageCount.getValue(ctx),
        isNull,
      );
    });
  });
}
