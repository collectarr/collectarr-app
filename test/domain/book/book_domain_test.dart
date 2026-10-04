import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat Book Catalog Item maps root details and contained printings', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'Guards! Guards!',
      'search_aliases': ['Guards Guards'],
      'genres': ['fantasy'],
      'creators': [
        {'name': 'Terry Pratchett', 'role': 'author'},
      ],
      'series_title': 'Discworld',
      'original_publication_date': '1989-03-16T00:00:00Z',
      'original_language': 'en',
      'sort_title': 'Guards Guards',
      'subtitle': 'A Discworld Novel',
      'synopsis': 'The city needs a dragon.',
      'cover_image_url': 'https://example.com/book.jpg',
      'thumbnail_image_url': 'https://example.com/book-thumb.jpg',
      'publisher': 'Victor Gollancz Ltd',
      'release_date': '1989-03-16T00:00:00Z',
      'barcode': '9780062225729',
      'dewey': '823.914',
      'page_count': 288,
      'country': 'GB',
      'language': 'en',
      'physical_format': 'paperback',
      'physical_format_label': 'Paperback',
      'printings': [
        {
          'id': 'printing-1',
          'printing_number': 1,
          'title': 'Paperback, first printing',
          'publisher': 'Victor Gollancz Ltd',
          'isbn': '9780062225729',
          'language': 'en',
        },
      ],
    });

    final book = BookCatalogItem.fromDto(dto);

    expect(book.title, 'Guards! Guards!');
    expect(book.seriesTitle, 'Discworld');
    expect(book.publisher, 'Victor Gollancz Ltd');
    expect(book.coverImageUrl, 'https://example.com/book.jpg');
    expect(book.thumbnailImageUrl, 'https://example.com/book-thumb.jpg');
    expect(book.barcode, '9780062225729');
    expect(book.synopsis, 'The city needs a dragon.');
    expect(book.creators, hasLength(1));
    expect(book.printings, hasLength(1));
    expect(book.printings.single.title, 'Paperback, first printing');
    expect(book.catalogMetadata.rawPayload['dewey'], '823.914');
    expect(book.pageCount, 288);
    expect(book.physicalFormatLabel, 'Paperback');
  });

  test('book edition facts are stored on the catalog item root', () {
    final metadata = BookCatalogMetadata.fromJson({
      'title': 'The Lord of the Rings',
      'isbn': '9780544003415',
      'format': 'Hardcover',
      'page_count': 423,
      'first_edition': true,
      'number_line': '1 2 3 4 5',
    });

    final json = metadata.toJson();
    final restored = BookCatalogMetadata.fromJson(json);

    expect(json['isbn'], '9780544003415');
    expect(json['page_count'], 423);
    expect(json.containsKey('editions'), isFalse);
    expect(restored.rawPayload['format'], 'Hardcover');
  });

  test('BookEntryDetails supports dust jacket and signature copy fields', () {
    const details = BookEntryDetails(
      signedBy: 'J.R.R. Tolkien',
      dustJacketPresent: true,
      dustJacketCondition: 'Near Fine',
    );

    final json = details.toJson();
    final fromJson = BookEntryDetails.fromJson(json);

    expect(fromJson.signedBy, 'J.R.R. Tolkien');
    expect(fromJson.dustJacketPresent, isTrue);
    expect(fromJson.dustJacketCondition, 'Near Fine');
  });

  test('Book composition roots register dedicated contributors', () {
    expect(bookKindIdentity.kind, CatalogMediaKind.book);
    expect(bookKindAdd.kind, CatalogMediaKind.book);
    expect(bookKindAdd.createInitialDraft(), isA<BookAddDraft>());
    expect(const BookEntryDetailsCodec(), isA<BookEntryDetailsCodec>());
    expect(const BookEntryDetailsCodec().defaultDetails(),
        isA<BookEntryDetails>());
  });
}
