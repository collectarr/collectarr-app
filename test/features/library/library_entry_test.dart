import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('library entry exposes shared ownership and tracking state', () {
    final entry = LibraryEntry(
      itemId: 'comic-1',
      catalogItem: CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga',
        itemNumber: '1',
      ),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        readStatus: 'Reading',
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
    );

    expect(entry.title, 'Saga #1');
    expect(entry.subtitle, 'Owned');
    expect(entry.isOwned, isTrue);
    expect(entry.isWishlisted, isFalse);
    expect(entry.tracking.status, MediaTrackingStatus.inProgress);
  });

  test('library entry falls back when catalog metadata is missing', () {
    const entry = LibraryEntry(itemId: 'abcdef123456');

    expect(entry.title, 'Catalog item abcdef12');
    expect(entry.subtitle, 'Wishlist');
    expect(entry.tracking.status, MediaTrackingStatus.none);
  });
}
