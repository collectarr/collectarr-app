import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book shelf entry builds from the book dto domain path', () {
    final work = BookWork(
      id: 'book-1',
      title: 'Guards! Guards!',
      searchAliases: const ['Guards Guards'],
      genres: const ['fantasy'],
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
      country: 'GB',
      language: 'en',
      ageRating: 'PG',
      audienceRating: 'Teen',
      physicalFormatLabel: 'Paperback',
      editions: [
        BookEdition(
          id: 'book-edition-1',
          title: 'Paperback',
          format: 'paperback',
          publisher: 'Victor Gollancz Ltd',
          isbn: '9780062225729',
          releaseDate: DateTime.parse('1989-03-16T00:00:00Z'),
          language: 'en',
          physicalFormatLabel: 'Paperback',
        ),
      ],
    );

    final entry = buildBookWorkspaceEntry(work, const BookPersonalOverlay())
        as BookWorkspaceEntry;

    expect(entry.title, 'Guards! Guards!');
    expect(entry.series?.seriesTitle, 'Discworld');
    expect(entry.publishing?.pageCount, 288);
    expect(entry.coverImageUrl, 'https://example.com/book.jpg');
    expect(entry.thumbnailImageUrl, 'https://example.com/book-thumb.jpg');
    expect(entry.barcode, '9780062225729');
    expect(entry.bookEditions, hasLength(1));
    expect(entry.bookEditions.first.title, 'Paperback');
  });
}
