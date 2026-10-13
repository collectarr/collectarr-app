import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders/library_entry_builder.dart';

void main() {
  test(
      'fixtures reject details owned by another kind instead of dropping its values',
      () {
    expect(
        () =>
            testLibraryEntry(kind: 'book', details: const MusicEntryDetails()),
        throwsArgumentError);
    expect(
        testLibraryEntry(kind: 'book', details: const BookEntryDetails())
            .details,
        isA<BookEntryDetails>());
  });
  test('entry provenance and declared fixture kind cannot disagree', () {
    expect(
        () => testLibraryEntry(
            kind: 'music',
            catalogRef: const CatalogItemRef(
                kind: CatalogMediaKind.book, id: 'book-1')),
        throwsArgumentError);
  });
}
