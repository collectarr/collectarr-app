import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book list defaults stay book-focused', () {
    expect(
      libraryKindRuntimeForKind(CatalogMediaKind.book)
          .fields
          .defaultVisibleColumnIds,
      containsAll(<Object>{
        'book.author',
        'book.title',
        'book.publisher',
        'book.release_date',
        'book.isbn',
        'book.read_status',
        'book.rating',
        'book.condition',
        'book.location',
      }),
    );
  });
}
