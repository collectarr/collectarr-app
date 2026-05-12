import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_csv.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection csv exports and parses owned shelf rows', () {
    final csv = CollectionCsv();
    final exported = csv.exportShelf([
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: const CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Spider-Man, "Vol. 1"',
          itemNumber: '1',
        ),
        ownedItem: OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          condition: 'Near Mint',
          grade: '9.8',
          purchaseDate: DateTime.utc(2026, 5, 11),
          pricePaidCents: 1299,
          currency: 'USD',
          personalNotes: 'Signed copy',
          quantity: 2,
          storageBox: 'Box 6',
          indexNumber: 1310,
          coverPriceCents: 399,
          rawOrSlabbed: 'Raw',
          gradingCompany: 'CGC',
          graderNotes: 'Clean press',
          signedBy: 'Stan Lee',
          keyComic: true,
          keyReason: 'First appearance',
          rating: 5,
          readStatus: 'Read',
          tags: 'spider,key',
          updatedAt: DateTime.utc(2026, 5, 12),
        ),
      ),
    ]);

    expect(exported, contains('"Spider-Man, ""Vol. 1"""'));

    final rows = csv.parse(exported);
    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.isOwned, isTrue);
    expect(rows.single.condition, 'Near Mint');
    expect(rows.single.grade, '9.8');
    expect(rows.single.pricePaidCents, 1299);
    expect(rows.single.notes, 'Signed copy');
    expect(rows.single.quantity, 2);
    expect(rows.single.storageBox, 'Box 6');
    expect(rows.single.indexNumber, 1310);
    expect(rows.single.coverPriceCents, 399);
    expect(rows.single.rawOrSlabbed, 'Raw');
    expect(rows.single.gradingCompany, 'CGC');
    expect(rows.single.graderNotes, 'Clean press');
    expect(rows.single.signedBy, 'Stan Lee');
    expect(rows.single.keyComic, isTrue);
    expect(rows.single.keyReason, 'First appearance');
    expect(rows.single.rating, 5);
    expect(rows.single.readStatus, 'Read');
    expect(rows.single.tags, 'spider,key');
  });

  test('collection csv parses quoted newlines', () {
    final rows = CollectionCsv().parse(
      [
        CollectionCsv.header.join(','),
        'comic-1,Title,1,owned,,,,,,'
            '"Line one\nLine two with ""quote"""',
      ].join('\n'),
    );

    expect(rows, hasLength(1));
    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.notes, 'Line one\nLine two with "quote"');
  });
}
