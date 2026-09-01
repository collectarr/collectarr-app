import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'every book defaultVisibleColumnId resolves exactly to a column definition',
      () {
    final registry = bookKindModule.fields;
    final columnIds =
        bookKindModule.fields.columns.map((c) => c.id.value).toSet();

    for (final defaultId in bookKindModule.fields.defaultVisibleColumns) {
      final definition = registry.columnDefinitionForId(defaultId);
      expect(
        definition,
        isNotNull,
        reason:
            'Default visible column ID "$defaultId" should resolve to an existing column definition.',
      );
      expect(
        columnIds.contains(definition!.id.value),
        isTrue,
        reason:
            'Resolved column ID "${definition.id.value}" for "$defaultId" must exist in columns list.',
      );
    }
  });
}
