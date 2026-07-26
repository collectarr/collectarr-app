import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book shelf entry builds from the book dto domain path', () {
    final work = BookWork(
      id: 'book-1',
      work: const BookWorkMetadata(
        title: 'Guards! Guards!',
        genres: ['fantasy'],
        creators: [BookCreator(name: 'Terry Pratchett', role: 'author')],
      ),
      publishing: const BookPublishingMetadata(pageCount: 288, publisher: 'Victor Gollancz Ltd'),
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
