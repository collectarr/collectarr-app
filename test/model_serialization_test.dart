import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
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

  test('sync change serializes wire keys', () {
    final change = SyncChange(
      entityType: 'owned_item',
      entityId: 'owned-1',
      action: 'upsert',
      payload: {'item_id': 'item-1'},
      clientChangedAt: DateTime.utc(2026, 5, 11),
    );

    expect(change.toJson()['entity_type'], 'owned_item');
    expect(change.toJson()['client_changed_at'], '2026-05-11T00:00:00.000Z');
  });
}

