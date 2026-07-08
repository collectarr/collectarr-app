import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book presentation exposes typed field definitions', () {
    expect(booksLibraryMediaPresentation.fieldDefinitions,
        booksLibraryFieldDefinitions);
    expect(booksLibraryFieldDefinitions, isNotEmpty);
    expect(booksLibraryFieldDefinitions.first.id.value, 'book.title');
  });
}
