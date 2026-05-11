import 'package:collectarr_app/core/models/catalog_item.dart';
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
}
