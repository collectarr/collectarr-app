import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CollectionItemRef round-trips as a small typed cross-kind reference', () {
    const ref = CollectionItemRef(
      kind: CatalogMediaKind.book,
      id: CollectionItemId('owned-book-1'),
    );

    final decoded = CollectionItemRef.fromJson(ref.toJson());

    expect(decoded, ref);
    expect(decoded.key, 'book:owned-book-1');
  });

  test('CollectionItemSummary contains projection fields only', () {
    const summary = CollectionItemSummary(
      ref: CollectionItemRef(
        kind: CatalogMediaKind.comic,
        id: CollectionItemId('owned-comic-1'),
      ),
      title: 'Batman #1',
      subtitle: 'Detective Comics',
      ownerLabel: 'Alex',
      locationLabel: 'Shelf A',
    );

    expect(summary.title, 'Batman #1');
    expect(summary.ref.kind, CatalogMediaKind.comic);
    expect(summary.ownerLabel, 'Alex');
  });

  test('CollectionItemRef rejects an empty identifier', () {
    expect(
      () => CollectionItemRef.fromJson({'kind': 'comic', 'id': ' '}),
      throwsFormatException,
    );
  });

  test('CollectionItemRef rejects an unknown kind at the boundary', () {
    expect(
      () => CollectionItemRef.fromJson({'kind': 'future-kind', 'id': 'owned-1'}),
      throwsFormatException,
    );
  });
}
