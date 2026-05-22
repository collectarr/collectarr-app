import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library projection prefers structured location path over storage box', () {
    final projection = LibraryProjectionItem.fromShelf(
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Batman',
        ),
        ownedItem: OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          storageBox: 'Short Box 1',
          locationId: 'loc-1',
          personalNotes: 'Newsstand copy',
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CGC',
          keyComic: true,
          keyReason: 'First appearance',
          updatedAt: DateTime.utc(2026, 5, 22),
        ),
        locationPath: 'Office › Shelf 2 › Short Box 1',
      ),
    );

    expect(projection.entry.storageBox, 'Office › Shelf 2 › Short Box 1');
    expect(projection.entry.rawOrSlabbed, 'Slabbed');
    expect(projection.entry.gradingCompany, 'CGC');
    expect(projection.entry.keyComic, isTrue);
    expect(projection.entry.keyReason, 'First appearance');
    expect(projection.entry.notes, 'Newsstand copy');
  });
}