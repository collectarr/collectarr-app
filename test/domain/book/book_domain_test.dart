import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book dto maps rich metadata into book domain', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'Guards! Guards!',
      'search_aliases': ['Guards Guards'],
      'genres': ['fantasy'],
      'contributors': [
        {'name': 'Terry Pratchett', 'role': 'author'},
      ],
      'series': {'series_id': 's1', 'series_title': 'Discworld'},
      'first_publication_date': '1989-03-16T00:00:00Z',
      'original_publication_date': '1989-03-16T00:00:00Z',
      'original_language': 'en',
      'sort_title': 'Guards Guards',
      'subtitle': 'A Discworld Novel',
      'description': 'The city needs a dragon.',
      'cover_image_url': 'https://example.com/book.jpg',
      'thumbnail_image_url': 'https://example.com/book-thumb.jpg',
      'publisher': 'Victor Gollancz Ltd',
      'cover_date': '1989-03-16T00:00:00Z',
      'release_date': '1989-03-16T00:00:00Z',
      'release_year': 1989,
      'barcode': '9780062225729',
      'dewey': '823.914',
      'page_count': 288,
      'edition_title': 'Paperback',
      'crossover': 'City Watch',
      'plot_summary': 'The city needs a dragon.',
      'plot_description': 'A dragon threatens Ankh-Morpork.',
      'creators': [
        {'name': 'Terry Pratchett', 'role': 'author'},
      ],
      'characters': ['Vimes'],
      'story_arcs': ['Ankh-Morpork'],
      'country': 'GB',
      'language': 'en',
      'age_rating': 'PG',
      'audience_rating': 'Teen',
      'physical_format': 'paperback',
      'physical_format_label': 'Paperback',
      'original_details': {
        'original_publisher': 'Victor Gollancz Ltd',
        'dewey': '823.914',
        'lccn': '89012345',
        'loc_control_number': '89012345',
      },
      'editions': [
        {
          'id': 'book-edition-1',
          'work_id': 'book-1',
          'display_title': 'Paperback',
          'format': 'paperback',
          'physical_format_label': 'Paperback',
          'publisher': 'Victor Gollancz Ltd',
          'isbn': '9780062225729',
          'page_count': 288,
          'publication_date': '1989-03-16T00:00:00Z',
          'language': 'en',
          'release_status': 'published',
          'dimensions': '198 x 129 mm',
          'dust_jacket': true,
          'printing': '1st printing',
          'first_edition': true,
          'number_line': '1 3 5 7 9',
          'cover_image_path': '/covers/book-edition-1-front.jpg',
          'thumbnail_image_path': '/covers/book-edition-1-thumb.jpg',
          'back_image_path': '/covers/book-edition-1-back.jpg',
          'variants': [
            {
              'id': 'v1',
              'name': 'Standard',
              'cover_image_url': 'https://example.com/book.jpg',
              'thumbnail_image_url': 'https://example.com/book-thumb.jpg',
            }
          ]
        },
      ],
    });

    final book = BookWork.fromDto(dto);

    expect(book.title, 'Guards! Guards!');
    expect(book.series?.seriesTitle, 'Discworld');
    expect(book.publisher, 'Victor Gollancz Ltd');
    expect(book.coverImageUrl, 'https://example.com/book.jpg');
    expect(book.thumbnailImageUrl, 'https://example.com/book-thumb.jpg');
    expect(book.barcode, '9780062225729');
    expect(book.plotSummary, 'The city needs a dragon.');
    expect(book.creators, hasLength(1));
    expect(book.characters, ['Vimes']);
    expect(book.storyArcs, ['Ankh-Morpork']);
    expect(book.editions, hasLength(1));
    expect(book.editions.first.title, 'Paperback');
    expect(book.originalDetails?.dewey, '823.914');
    expect(book.editions.first.dimensions, '198 x 129 mm');
    expect(book.editions.first.firstEdition, isTrue);
    expect(book.physicalFormatLabel, 'Paperback');
  });

  test('BookCatalogMetadata and BookEditionMetadata roundtrip', () {
    final meta = BookCatalogMetadata(
      title: 'The Lord of the Rings',
      subtitle: 'The Fellowship of the Ring',
      sortTitle: 'Lord of the Rings, The',
      authors: const ['J.R.R. Tolkien'],
      genres: const ['Fantasy', 'High Fantasy'],
      subjects: const ['Quests', 'Middle-earth'],
      editors: const ['Christopher Tolkien'],
      illustrators: const ['Alan Lee'],
      originalTitle: 'The Lord of the Rings',
      originalLanguage: 'en',
      originalCountry: 'GB',
      originalPublisher: 'George Allen & Unwin',
      originalPublicationDate: DateTime.utc(1954, 7, 29),
      editions: [
        BookEditionMetadata(
          id: 'ed-1',
          title: 'Collector Hardcover',
          isbn: '9780544003415',
          format: 'Hardcover',
          publisher: 'Houghton Mifflin Harcourt',
          pageCount: 423,
          firstEdition: true,
          printing: '1st',
          numberLine: '1 2 3 4 5',
          printedBy: 'Clays Ltd',
          paperType: 'Acid-free 80gsm',
          locClassification: 'PR6039.O32',
          locControlNumber: '2004052341',
          dewey: '823.912',
          boxSetName: 'The Lord of the Rings 50th Anniversary Set',
        ),
        const BookEditionMetadata(
          id: 'ed-audio',
          title: 'Unabridged Audiobook',
          format: 'Audiobook',
          publisher: 'Recorded Books',
          audiobook: AudiobookDetails(
            narrator: 'Andy Serkis',
            durationMinutes: 1320,
            isAbridged: false,
          ),
        ),
      ],
    );

    final json = meta.toJson();
    final fromJson = BookCatalogMetadata.fromJson(json);

    expect(fromJson.title, 'The Lord of the Rings');
    expect(fromJson.subtitle, 'The Fellowship of the Ring');
    expect(fromJson.illustrators, contains('Alan Lee'));
    expect(fromJson.editions, hasLength(2));

    final printEdition = fromJson.editions.first;
    expect(printEdition.firstEdition, isTrue);
    expect(printEdition.locClassification, 'PR6039.O32');
    expect(printEdition.isAudiobook, isFalse);

    final audioEdition = fromJson.editions.last;
    expect(audioEdition.isAudiobook, isTrue);
    expect(audioEdition.audiobook?.narrator, 'Andy Serkis');
    expect(audioEdition.audiobook?.durationMinutes, 1320);
    expect(audioEdition.audiobook?.isAbridged, isFalse);
  });

  test('BookOwnedDetails supports dust jacket and signature copy fields', () {
    const details = BookOwnedDetails(
      signedBy: 'J.R.R. Tolkien',
      dustJacketPresent: true,
      dustJacketCondition: 'Near Fine',
    );

    final json = details.toJson();
    final fromJson = BookOwnedDetails.fromJson(json);

    expect(fromJson.signedBy, 'J.R.R. Tolkien');
    expect(fromJson.dustJacketPresent, isTrue);
    expect(fromJson.dustJacketCondition, 'Near Fine');
  });

  test('bookKindModule registers dedicated Book capabilities', () {
    expect(bookKindModule.kind, CatalogMediaKind.book);
    expect(bookKindModule.add.kind, CatalogMediaKind.book);
    expect(bookKindModule.add.createInitialDraft(), isA<BookAddDraft>());
    expect(bookKindModule.ownedDetailsCodec, isA<BookOwnedDetailsCodec>());
    expect(bookKindModule.defaultOwnedDetails(), isA<BookOwnedDetails>());
  });
}
