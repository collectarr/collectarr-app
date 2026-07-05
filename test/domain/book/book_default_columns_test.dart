import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book list defaults stay book-focused', () {
    expect(
      booksWorkspaceConfig.defaultVisibleColumns,
      containsAll(<LibraryTableColumn>{
        LibraryTableColumn.author,
        LibraryTableColumn.title,
        LibraryTableColumn.publisher,
        LibraryTableColumn.releaseDate,
        LibraryTableColumn.barcode,
        LibraryTableColumn.readStatus,
        LibraryTableColumn.rating,
        LibraryTableColumn.condition,
        LibraryTableColumn.location,
      }),
    );
  });
}
