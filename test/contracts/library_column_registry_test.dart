import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book presentation exposes typed field definitions', () {
    final fields = bookKindWorkspace.fields.fields;
    expect(fields, isNotEmpty);
    expect(
        fields.every((field) => field.entityScope == LibraryEntityScope.work),
        isTrue);
    expect(fields.any((field) => field.id.value == 'book.title'), isTrue);
    expect(bookWorkWorkspaceFieldDefinitions, isNotEmpty);
    expect(bookWorkWorkspaceFieldDefinitions.first.id.value, 'book.title');
  });
}
