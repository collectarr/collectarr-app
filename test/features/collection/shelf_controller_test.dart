import 'dart:typed_data';


import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('shelf state combines owned and wishlist records', () {
    final state = ShelfState.from(
      ownedItems: [
        testOwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          condition: 'Near Mint',
          grade: '9.8',
          pricePaidCents: 1200,
          coverPriceCents: 1500,
          currency: 'USD',
          updatedAt: DateTime.utc(2026, 5, 11),
        ),
        testOwnedItem(
          id: 'owned-2',
          itemId: 'comic-2',
          condition: 'Fine',
          pricePaidCents: 800,
          coverPriceCents: 1000,
          currency: 'USD',
          updatedAt: DateTime.utc(2026, 5, 10),
        ),
      ],
      wishlistItems: [
        WishlistItem(
          id: 'wish-1',
          catalogRef: testCatalogRef('comic-3', kind: 'comic'),
          createdAt: DateTime.utc(2026, 5, 9),
          updatedAt: DateTime.utc(2026, 5, 9),
        ),
      ],
      watchSessions: [
        WatchSession(
          id: 'watch-1',
          targetRef: testCatalogRef('comic-1', kind: 'comic'),
          watchedAt: DateTime.utc(2026, 5, 8),
          sourceType: TrackingSourceType.streaming,
          updatedAt: DateTime.utc(2026, 5, 8),
        ),
      ],
      catalogItems: {
        'comic-1': CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga',
          itemNumber: '1',
        ),
      },
      itemImagesByOwnedItem: {
        'owned-1': [
          ItemImage(
            id: 'img-1',
            ownedItemId: 'owned-1',
            imageType: 'back_cover',
            imageData: Uint8List.fromList('data'.codeUnits),
            createdAt: DateTime.utc(2026, 5, 8),
          ),
        ],
      },
    );

    expect(state.ownedCount, 2);
    expect(state.wishlistCount, 1);
    expect(state.missingGradeCount, 1);
    expect(state.totalPaidCents, 2000);
    expect(state.coverPricedCount, 2);
    expect(state.totalCoverPriceCents, 2500);
    expect(state.coverPriceCurrency, 'USD');
    expect(state.primaryCurrency, 'USD');
    expect(state.missingMetadataCount, 2);
    expect(state.gradeCounts, {'9.8': 1, 'Ungraded': 1});
    expect(state.conditionCounts, {'Near Mint': 1, 'Fine': 1});
    expect(state.entries.first.title, 'Saga #1');
    expect(state.entries.first.watchSessions.single.sourceType, TrackingSourceType.streaming);
    expect(state.entries.first.itemImages.single.imageType, 'back_cover');
  });

  test('shelf state keys records by catalog ref id', () {
    final state = ShelfState.from(
      ownedItems: [
        testOwnedItem(
          id: 'owned-1',
          itemId: 'legacy-owned-1',
          catalogRef: const CatalogEntityRef(
            kind: 'book',
            entityType: CatalogEntityType.work,
            id: 'book-1',
          ),
          updatedAt: DateTime.utc(2026, 5, 11),
        ),
      ],
      wishlistItems: [
        WishlistItem(
          id: 'wish-1',
          catalogRef: const CatalogEntityRef(
            kind: 'book',
            entityType: CatalogEntityType.work,
            id: 'book-1',
          ),
          createdAt: DateTime.utc(2026, 5, 9),
          updatedAt: DateTime.utc(2026, 5, 9),
        ),
      ],
      trackingEntries: [
        TrackingEntry(
          id: 'track-1',
          catalogRef: const CatalogEntityRef(
            kind: 'book',
            entityType: CatalogEntityType.work,
            id: 'book-1',
          ),
          updatedAt: DateTime.utc(2026, 5, 8),
        ),
      ],
      catalogItems: {
        'book-1': CatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Catalog keyed by ref',
        ),
      },
    );

    expect(state.entries, hasLength(1));
    expect(state.entries.single.itemId, 'book-1');
    expect(state.entries.single.title, 'Catalog keyed by ref');
    expect(state.ownedCount, 1);
    expect(state.wishlistCount, 1);
  });
}
