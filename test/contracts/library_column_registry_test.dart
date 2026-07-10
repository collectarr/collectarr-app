import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book presentation exposes typed field definitions', () {
    expect(bookLibraryMediaPresentation.fieldDefinitions,
        bookLibraryFieldDefinitions);
    expect(bookLibraryFieldDefinitions, isNotEmpty);
    expect(bookLibraryFieldDefinitions.first.id.value, 'book.title');
  });
}
