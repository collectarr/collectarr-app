import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book metadata item maps into book domain', () {
    final metadata = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'Guards! Guards!',
        searchAliases: ['Guards Guards'],
        series: const CatalogSeriesDetails(seriesTitle: 'Discworld'),
        publishing: const CatalogPublishingDetails(pageCount: 288),
        coverImageUrl: 'https://example.com/book.jpg',
        thumbnailImageUrl: 'https://example.com/book-thumb.jpg',
        publisher: 'Victor Gollancz Ltd',
        coverDate: DateTime.parse('1989-03-16T00:00:00Z'),
        releaseDate: DateTime.parse('1989-03-16T00:00:00Z'),
        releaseYear: 1989,
        barcode: '9780062225729',
        variant: 'First edition',
        crossover: 'City Watch',
        plotSummary: 'The city needs a dragon.',
        plotDescription: 'A dragon threatens Ankh-Morpork.',
        creators: const [
          {'name': 'Terry Pratchett', 'role': 'author'},
        ],
        characters: const ['Vimes'],
        storyArcs: const ['Ankh-Morpork'],
        genres: const ['fantasy'],
        country: 'GB',
        language: 'en',
        ageRating: 'PG',
        audienceRating: 'Teen',
        physicalFormatLabel: 'Paperback',
      ),
    );

    final book = BookWork.fromMetadataItem(metadata);

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
    expect(book.physicalFormatLabel, 'Paperback');
  });
}
