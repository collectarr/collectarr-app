import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OwnedItemRef round-trips as a small typed cross-kind reference', () {
    const ref = OwnedItemRef(
      kind: CatalogMediaKind.book,
      id: OwnedItemId('owned-book-1'),
    );

    final decoded = OwnedItemRef.fromJson(ref.toJson());

    expect(decoded, ref);
    expect(decoded.key, 'book:owned-book-1');
  });

  test('OwnedItemSummary contains projection fields only', () {
    const summary = OwnedItemSummary(
      ref: OwnedItemRef(
        kind: CatalogMediaKind.comic,
        id: OwnedItemId('owned-comic-1'),
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

  test('OwnedItemRef rejects an empty identifier', () {
    expect(
      () => OwnedItemRef.fromJson({'kind': 'comic', 'id': ' '}),
      throwsFormatException,
    );
  });
}
