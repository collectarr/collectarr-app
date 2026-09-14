import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('BookWorkDto maps directly into BookMedia and typed editions', () {
    final dto = BookWorkDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'The Left Hand of Darkness',
      'search_aliases': ['Left Hand of Darkness'],
      'genres': ['Science fiction'],
      'contributors': [
        {'name': 'Ursula K. Le Guin', 'role': 'author'},
      ],
      'series': [
        {'id': 'series-hainish', 'title': 'Hainish Cycle'},
      ],
      'first_publication_date': '1969-03-01T00:00:00Z',
      'original_publication_date': '1969-03-01T00:00:00Z',
      'original_language': 'en',
      'sort_title': 'Left Hand of Darkness, The',
      'subtitle': 'A Novel',
      'description': 'A diplomatic mission on a winter world.',
      'cover_image_url': 'https://example.com/book.jpg',
      'editions': [
        {
          'id': 'edition-1',
          'work_id': 'book-1',
          'title': 'Paperback',
          'display_title': 'Paperback Edition',
          'format': 'paperback',
          'publisher': 'Ace',
          'isbn': '9780441478125',
          'page_count': 304,
          'publication_date': '1976-03-01T00:00:00Z',
          'language': 'en',
          'region': 'US',
          'release_status': 'published',
          'first_edition': false,
          'dimensions': '178 x 108 mm',
          'variants': [
            {
              'id': 'variant-1',
              'name': 'Cover A',
              'is_primary': true,
            },
          ],
        },
      ],
    });

    final media = BookCoreMapper.fromWorkDto(dto);

    expect(media.id, const BookMediaId('book-1'));
    expect(media.title, 'The Left Hand of Darkness');
    expect(media.sortTitle, 'Left Hand of Darkness, The');
    expect(media.description, 'A diplomatic mission on a winter world.');
    expect(media.firstPublicationDate, DateTime.utc(1969, 3, 1));
    expect(media.originalLanguage, 'en');
    expect(media.searchAliases, ['Left Hand of Darkness']);
    expect(media.genres, ['Science fiction']);
    expect(media.contributors.single, isA<Map<String, dynamic>>());
    expect(media.series.single, isA<Map<String, dynamic>>());
    expect(media.editions, hasLength(1));
    expect(media.editions.single.typedId, const BookReleaseId('edition-1'));
    expect(media.editions.single.title, 'Paperback Edition');
    expect(media.editions.single.pageCount, 304);
    expect(media.editions.single.dimensions, '178 x 108 mm');
    expect(media.editions.single.variants.single.isPrimary, isTrue);
  });

  test('Book mapper rejects a DTO with the wrong kind', () {
    final dto = BookWorkDto.fromJson({
      'id': 'not-book',
      'kind': 'comic',
      'title': 'Wrong kind',
    });

    expect(
      () => BookCoreMapper.fromWorkDto(dto),
      throwsA(isA<StateError>()),
    );
  });

  test('Book remote source maps a fetched Core DTO', () async {
    final source = ApiBookRemoteSource((id) async {
      expect(id, 'book-2');
      return BookWorkDto.fromJson({
        'id': id,
        'kind': 'book',
        'title': 'The Dispossessed',
      });
    });

    final media = await source.fetchMedia(const BookMediaId('book-2'));

    expect(media.id, const BookMediaId('book-2'));
    expect(media.title, 'The Dispossessed');
  });

  defineCoreMappingContract<BookMedia, BookWorkDto>(
    name: 'book',
    createDomain: () => BookMedia(
      id: const BookMediaId('book-contract'),
      title: 'Contract Book',
      sortTitle: 'Contract Book',
      description: 'Contract description',
      firstPublicationDate: DateTime.utc(2020, 1, 2),
      originalLanguage: 'en',
      originalPublicationDate: DateTime.utc(2019, 12, 1),
      subtitle: 'Contract subtitle',
      searchAliases: const ['Contract'],
      genres: const ['Fiction'],
      contributors: const [
        {'name': 'Creator', 'role': 'author'},
      ],
      editions: const [
        BookRelease(
          id: 'edition-contract',
          title: 'Contract Edition',
          workId: 'book-contract',
          titleValue: 'Contract Edition',
          displayTitle: 'Contract Edition',
          physicalFormat: 'hardcover',
        ),
      ],
      series: const [
        {'id': 'series-contract', 'title': 'Contract Series'},
      ],
    ),
    encode: (domain) => BookWorkDto.fromJson(domain.toJson()),
    decode: BookCoreMapper.fromWorkDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.sortTitle == right.sortTitle &&
        left.description == right.description &&
        left.firstPublicationDate == right.firstPublicationDate &&
        left.originalLanguage == right.originalLanguage &&
        left.originalPublicationDate == right.originalPublicationDate &&
        left.subtitle == right.subtitle &&
        left.searchAliases.length == right.searchAliases.length &&
        left.genres.length == right.genres.length &&
        left.contributors.length == right.contributors.length &&
        left.editions.length == right.editions.length &&
        left.series.length == right.series.length,
  );

  test('BookWorkDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'BookWorkDto',
        mapped: {
          'id',
          'title',
          'searchAliases',
          'genres',
          'contributors',
          'editions',
          'series',
          'firstPublicationDate',
          'originalPublicationDate',
          'originalLanguage',
          'sortTitle',
          'subtitle',
          'description',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Book DTO boundary',
        },
      ),
    );
  });

  test('BookEditionDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'BookEditionDto',
        mapped: {
          'id',
          'workId',
          'titleValue',
          'ageRating',
          'audioLengthMinutes',
          'binding',
          'contributors',
          'coverImageKey',
          'coverImageUrlValue',
          'description',
          'displayTitle',
          'editionStatement',
          'format',
          'identifiers',
          'imprint',
          'language',
          'isbn',
          'pageCount',
          'publicationDate',
          'publisher',
          'region',
          'releaseStatus',
          'upc',
        },
        intentionallyIgnored: {},
      ),
    );
  });
}
