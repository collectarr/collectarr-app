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
  });
}
