import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('duplicate groups rank barcode matches ahead of metadata-only matches', () {
    final groups = findDuplicateShelfGroups([
      _entry(
        itemId: 'barcode-a',
        title: 'Saga',
        barcode: '1111',
        issue: '1',
        publisher: 'Image',
        releaseYear: 2012,
        owned: true,
      ),
      _entry(
        itemId: 'barcode-b',
        title: 'Saga',
        barcode: '1111',
        issue: '1',
        publisher: 'Image',
        releaseYear: 2012,
      ),
      _entry(
        itemId: 'issue-a',
        title: 'Paper Girls',
        issue: '3',
        publisher: 'Image',
        releaseYear: 2016,
      ),
      _entry(
        itemId: 'issue-b',
        title: 'Paper Girls',
        issue: '3',
        publisher: 'Image',
        releaseYear: 2016,
        wishlisted: true,
      ),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.reason, 'Same barcode');
    expect(groups.first.confidenceScore, greaterThan(groups.last.confidenceScore));
  });

  test('duplicate groups reward richer matching metadata', () {
    final groups = findDuplicateShelfGroups([
      _entry(
        itemId: 'rich-a',
        title: 'Batman',
        issue: '50',
        publisher: 'DC',
        releaseYear: 2018,
      ),
      _entry(
        itemId: 'rich-b',
        title: 'Batman',
        issue: '50',
        publisher: 'DC',
        releaseYear: 2018,
      ),
      _entry(
        itemId: 'lean-a',
        title: 'Spawn',
        issue: '10',
      ),
      _entry(
        itemId: 'lean-b',
        title: 'Spawn',
        issue: '10',
      ),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.label, contains('Batman'));
    expect(groups.first.confidenceScore, greaterThan(groups.last.confidenceScore));
  });
}

ShelfEntry _entry({
  required String itemId,
  required String title,
  String? barcode,
  String? issue,
  String? publisher,
  int? releaseYear,
  bool owned = false,
  bool wishlisted = false,
}) {
  final timestamp = DateTime.utc(2024, 1, 1);
  return ShelfEntry(
    itemId: itemId,
    catalogItem: CatalogItem(
      id: itemId,
      kind: 'comic',
      title: title,
      barcode: barcode,
      itemNumber: issue,
      publisher: publisher,
      releaseYear: releaseYear,
    ),
    ownedItem: owned
        ? OwnedItem(
            id: 'owned-$itemId',
            itemId: itemId,
            quantity: 1,
            updatedAt: timestamp,
          )
        : null,
    wishlistItem: wishlisted
        ? WishlistItem(
            id: 'wish-$itemId',
            itemId: itemId,
            createdAt: timestamp,
            updatedAt: timestamp,
          )
        : null,
  );
}