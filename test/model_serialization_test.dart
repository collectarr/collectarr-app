import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog item parses search json', () {
    final item = CatalogItem.fromJson({
      'id': 'id-1',
      'kind': 'comic',
      'title': 'Spider-Man',
      'item_number': '1',
      'synopsis': 'Seed',
      'cover_image_url': null,
    });

    expect(item.title, 'Spider-Man');
    expect(item.itemNumber, '1');
  });

  test('owned item builds sync payload', () {
    final item = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 5, 11),
      pricePaidCents: 1299,
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['item_id'], 'comic-1');
    expect(payload['grade'], '9.8');
    expect(payload['purchase_date'], '2026-05-11T00:00:00.000Z');
  });

  test('wishlist item builds sync payload', () {
    final item = WishlistItem(
      id: 'wish-1',
      itemId: 'comic-1',
      targetPriceCents: 999,
      currency: 'USD',
      createdAt: DateTime.utc(2026, 5, 11),
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['item_id'], 'comic-1');
    expect(payload['target_price_cents'], 999);
    expect(payload['created_at'], '2026-05-11T00:00:00.000Z');
  });
}
