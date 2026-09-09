import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CatalogEntityRef is a stable value key', () {
    const first = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityType.issue,
      id: 'issue-1',
      rootId: 'series-1',
    );
    const equal = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityType.issue,
      id: 'issue-1',
      rootId: 'series-1',
    );
    const different = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityType.issue,
      id: 'issue-2',
      rootId: 'series-1',
    );

    expect(first, equal);
    expect(first.hashCode, equal.hashCode);
    expect({first: 'value'}[equal], 'value');
    expect(first, isNot(different));
  });

  test('CatalogEntityRef keeps kind typed in memory and stable on the v1 wire', () {
    const ref = CatalogEntityRef(
      kind: CatalogMediaKind.book,
      entityType: CatalogEntityType.edition,
      id: 'edition-1',
      rootId: 'book-1',
    );

    expect(ref.kind, CatalogMediaKind.book);
    expect(ref.mediaKind, CatalogMediaKind.book);
    expect(ref.toJson(), {
      'kind': 'book',
      'entity_type': 'edition',
      'id': 'edition-1',
      'root_id': 'book-1',
    });
    expect(CatalogEntityRef.fromJson(ref.toJson()), ref);
  });
}
