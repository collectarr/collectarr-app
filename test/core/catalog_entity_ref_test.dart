import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CatalogEntityRef is a stable value key', () {
    const first = CatalogEntityRef(
      kind: 'comic',
      entityType: CatalogEntityType.issue,
      id: 'issue-1',
      rootId: 'series-1',
    );
    const equal = CatalogEntityRef(
      kind: 'comic',
      entityType: CatalogEntityType.issue,
      id: 'issue-1',
      rootId: 'series-1',
    );
    const different = CatalogEntityRef(
      kind: 'comic',
      entityType: CatalogEntityType.issue,
      id: 'issue-2',
      rootId: 'series-1',
    );

    expect(first, equal);
    expect(first.hashCode, equal.hashCode);
    expect({first: 'value'}[equal], 'value');
    expect(first, isNot(different));
  });
}
