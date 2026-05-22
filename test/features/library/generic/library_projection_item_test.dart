import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/library_projection_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library projection prefers structured location path over storage box', () {
    final projection = LibraryProjectionItem.fromShelf(
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: const CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Batman',
        ),
        ownedItem: OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          storageBox: 'Short Box 1',
          locationId: 'loc-1',
          updatedAt: DateTime.utc(2026, 5, 22),
        ),
        locationPath: 'Office › Shelf 2 › Short Box 1',
      ),
    );

    expect(projection.entry.storageBox, 'Office › Shelf 2 › Short Box 1');
  });
}