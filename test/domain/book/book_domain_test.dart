import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book dto maps rich metadata into book domain', () {
    final dto = BookWorkDto.fromJson({
      'id': 'book-1',
      'title': 'Guards! Guards!',
      'search_aliases': ['Guards Guards'],
      'genres': ['fantasy'],
      'contributors': [
        {'name': 'Terry Pratchett', 'role': 'author'},
      ],
      'series': ['Discworld'],
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
      'variant': 'First edition',
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
}
