import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OwnedCopyRef round-trips as a small typed cross-kind reference', () {
    const ref = OwnedCopyRef(
      kind: CatalogMediaKind.book,
      id: OwnedCopyId('owned-book-1'),
    );

    final decoded = OwnedCopyRef.fromJson(ref.toJson());

    expect(decoded, ref);
    expect(decoded.key, 'book:owned-book-1');
  });

  test('OwnedCopySummary contains projection fields only', () {
    const summary = OwnedCopySummary(
      ref: OwnedCopyRef(
        kind: CatalogMediaKind.comic,
        id: OwnedCopyId('owned-comic-1'),
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

  test('OwnedCopyRef rejects an empty identifier', () {
    expect(
      () => OwnedCopyRef.fromJson({'kind': 'comic', 'id': ' '}),
      throwsFormatException,
    );
  });

  test('OwnedCopyRef rejects an unknown kind at the boundary', () {
    expect(
      () => OwnedCopyRef.fromJson({'kind': 'future-kind', 'id': 'owned-1'}),
      throwsFormatException,
    );
  });
}
