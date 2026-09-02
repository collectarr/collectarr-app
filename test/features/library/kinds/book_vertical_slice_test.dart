import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/contracts/book_contracts.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

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
        editions: [
          BookEditionMetadata(
            id: 'ed_1',
            title: 'The Fellowship of the Ring (50th Anniversary Edition)',
            isbn: '9780007203581',
            format: 'Hardcover',
            publisher: 'HarperCollins',
            imprint: 'Voyager',
            pageCount: 432,
            printing: '1st Print',
            firstEdition: true,
            numberLine: '1 3 5 7 9 10 8 6 4 2',
            dewey: '823.912',
            locClassification: 'PR6039.O32',
            audiobook: const AudiobookDetails(
              narrator: 'Andy Serkis',
              durationMinutes: 1380,
              isAbridged: false,
            ),
          ),
        ],
      );

      final json = metadata.toJson();
      final restored = BookCatalogMetadata.fromJson(json);

      expect(restored.title, 'The Lord of the Rings');
      expect(restored.subtitle, 'The Fellowship of the Ring');
      expect(restored.authors, contains('J. R. R. Tolkien'));
      expect(restored.editors, contains('Christopher Tolkien'));
      expect(restored.translators, contains('Ion Luca'));
      expect(restored.illustrators, contains('Alan Lee'));
      expect(restored.editions.first.isbn, '9780007203581');
      expect(restored.editions.first.format, 'Hardcover');
      expect(restored.editions.first.pageCount, 432);
      expect(restored.editions.first.firstEdition, isTrue);
      expect(restored.editions.first.numberLine, '1 3 5 7 9 10 8 6 4 2');
      expect(restored.editions.first.audiobook?.narrator, 'Andy Serkis');
    });

    test('BookWorkspaceProjector projects metadata and schema fields', () {
      const bookMeta = BookCatalogMetadata(
        title: 'Dune',
        subtitle: 'Part One',
        authors: ['Frank Herbert'],
        translators: ['Ion Hobana'],
        editions: [
          BookEditionMetadata(
            id: 'ed_dune',
            title: 'Dune Deluxe Edition',
            isbn: '9780441013593',
            format: 'Hardcover',
            publisher: 'Ace',
            pageCount: 896,
            printing: 'Special Collector Edition',
            firstEdition: true,
            dewey: '813.54',
          ),
        ],
      );

      final shelfEntry = ShelfEntry(
        itemId: 'book_1',
        catalogItem: const LibraryMetadataItem(
          identity: LibraryItemIdentity(
            id: 'book_1',
            mediaKind: CatalogMediaKind.book,
          ),
          kindMetadata: bookMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'book_1',
            kind: 'book',
            entityType: CatalogEntityType.work,
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = BookWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'book_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.title, 'Dune');
      expect(dto.author, 'Frank Herbert');
      expect(dto.subtitle, 'Part One');
      expect(dto.format, 'Hardcover');
      expect(dto.isbn, '9780441013593');
      expect(dto.pageCount, 896);
      expect(dto.firstEdition, isTrue);
      expect(dto.dewey, '813.54');

      final ctx = LibraryProjectionContext<BookWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(BookKindSchema.title.getValue(ctx), 'Dune');
      expect(BookKindSchema.author.getValue(ctx), 'Frank Herbert');
      expect(BookKindSchema.subtitle.getValue(ctx), 'Part One');
      expect(BookKindSchema.format.getValue(ctx), 'Hardcover');
      expect(BookKindSchema.isbn.getValue(ctx), '9780441013593');
      expect(BookKindSchema.pageCount.getValue(ctx), 896);
      expect(BookKindSchema.firstEdition.getValue(ctx), isTrue);
      expect(BookKindSchema.dewey.getValue(ctx), '813.54');
    });

    test(
        'BookLibraryKindProviderMapper parses OpenLibrary/Hardcover envelope into BookCatalogMetadata',
        () {
      const mapper = BookLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'openlibrary',
          providerItemId: 'OL12345M',
          kind: 'book',
          normalized: const {
            'title': 'Dune',
            'subtitle': 'Part One',
            'authors': ['Frank Herbert'],
            'translators': ['Ion Hobana'],
            'editions': [
              {
                'id': 'ed_1',
                'title': 'Dune',
                'isbn': '9780441013593',
                'format': 'Hardcover',
                'page_count': 896,
                'first_edition': true,
              }
            ],
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<BookCatalogMetadata>());
      final meta = item.kindMetadata as BookCatalogMetadata;
      expect(meta.title, 'Dune');
      expect(meta.subtitle, 'Part One');
      expect(meta.authors, contains('Frank Herbert'));
      expect(meta.editions.first.isbn, '9780441013593');
      expect(meta.editions.first.pageCount, 896);
      expect(meta.editions.first.firstEdition, isTrue);
    });

    test('BookCatalog and BookEntry round-trip and preserve all kind fields',
        () {
      final catalog = BookCatalog.fromJson({
        'id': 'book_lotr',
        'kind': 'book',
        'title': 'The Lord of the Rings',
        'subtitle': 'The Fellowship of the Ring',
        'sort_title': 'Lord of the Rings 1',
        'synopsis': 'An epic high fantasy novel by J. R. R. Tolkien.',
        'authors': ['J. R. R. Tolkien'],
        'genres': ['High Fantasy', 'Adventure'],
        'subjects': ['Middle-earth', 'Rings of Power'],
        'editors': ['Christopher Tolkien'],
        'translators': ['Ion Luca'],
        'illustrators': ['Alan Lee'],
        'original_title': 'The Fellowship of the Ring',
        'original_country': 'UK',
        'original_language': 'en',
        'original_publisher': 'Allen & Unwin',
        'original_publication_date': '1954-07-29T00:00:00.000Z',
        'cover_image_url': 'https://example.com/lotr.jpg',
        'thumbnail_image_url': 'https://example.com/lotr_thumb.jpg',
        'editions': [
          {
            'id': 'ed_1',
            'title': '50th Anniversary Edition',
            'isbn': '9780007203581',
            'format': 'Hardcover',
            'page_count': 432,
            'first_edition': true,
            'audiobook': {
              'narrator': 'Andy Serkis',
              'duration_minutes': 1380,
            },
          }
        ],
      });

      expect(catalog.id, 'book_lotr');
      expect(catalog.mediaKind, CatalogMediaKind.book);
      expect(catalog.title, 'The Lord of the Rings');
      expect(catalog.subtitle, 'The Fellowship of the Ring');
      expect(catalog.author, 'J. R. R. Tolkien');
      expect(catalog.displayCoverUrl, 'https://example.com/lotr_thumb.jpg');
      expect(catalog.editions.first.isbn, '9780007203581');
      expect(catalog.editions.first.audiobook?.narrator, 'Andy Serkis');

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.book);
      expect(envelope.common.title, 'The Lord of the Rings');
      expect(envelope.common.releaseDate?.year, 1954);

      final json = catalog.toJson();
      final restored = BookCatalog.fromJson(json);
      expect(restored.id, 'book_lotr');
      expect(restored.authors, contains('J. R. R. Tolkien'));
      expect(restored.editions.first.format, 'Hardcover');

      final shelfEntry = ShelfEntry(
        itemId: 'book_lotr',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'book_lotr',
            mediaKind: CatalogMediaKind.book,
          ),
          kindMetadata: BookCatalogMetadata.fromJson(json),
        ),
      );

      final entry = BookEntry.fromShelf(shelfEntry);
      expect(entry.id, 'book_lotr');
      expect(entry.title, 'The Lord of the Rings');
    });
  });
}
