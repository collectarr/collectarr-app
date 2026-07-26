import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book shelf entry builds from the book dto domain path', () {
    final work = BookCatalogItem(
      id: 'book-1',
      work: const BookWorkMetadata(
        title: 'Guards! Guards!',
        genres: ['fantasy'],
        creators: [BookCreatorCredit(name: 'Terry Pratchett', role: 'author')],
      ),
      publishing: const BookPublishingMetadata(pageCount: 288),
      releases: [
        BookRelease(
          id: 'book-edition-1',
          title: 'Paperback',
          publisher: 'Victor Gollancz Ltd',
          isbn: '9780062225729',
          releaseDate: DateTime.parse('1989-03-16T00:00:00Z'),
          language: 'en',
        ),
      ],
    );

    final entry = buildBookWorkspaceEntry(
      work,
      const BookPersonalOverlay(),
    );

    expect(entry.id, 'book-1');
    expect(entry.title, 'Guards! Guards!');
    expect(entry.publisher, 'Victor Gollancz Ltd');
  });
}
