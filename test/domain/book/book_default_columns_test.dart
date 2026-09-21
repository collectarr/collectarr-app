import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book list defaults stay book-focused', () {
    final workspace = libraryKindWorkspaceForKind(CatalogMediaKind.book);
    expect(
      workspace.fields.defaultVisibleColumns.map((column) => column.value),
      containsAll(<String>{
        'book.author',
        'book.title',
        'book.cover',
      }),
    );
    expect(
      workspace
          .fieldsForScope(LibraryEntityScope.release)
          .defaultVisibleColumns
          .map((column) => column.value),
      containsAll(<String>{
        'book.publisher',
        'book.release_date',
      }),
    );
    expect(
      workspace
          .fieldsForScope(LibraryEntityScope.copy)
          .defaultVisibleColumns
          .map((column) => column.value),
      containsAll(<String>{
        'book.read_status',
        'book.rating',
        'book.condition',
        'book.location',
      }),
    );
  });
}
