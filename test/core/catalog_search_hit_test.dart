import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_search_hit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps only cross-kind search summary data', () {
    final hit = CatalogSearchHit.fromJson({
      'id': 'movie-1',
      'kind': 'movie',
      'title': 'Arrival',
      'summary': 'A linguist meets visitors.',
      'image_url': 'https://example.test/arrival.jpg',
      'payload': {'should_not': 'leak'},
    });

    expect(hit.ref.kind, 'movie');
    expect(hit.ref.entityType, CatalogEntityType.work);
    expect(hit.ref.id, 'movie-1');
    expect(hit.kind, CatalogMediaKind.movie);
    expect(hit.title, 'Arrival');
    expect(hit.subtitle, 'A linguist meets visitors.');
    expect(hit.toJson(), {
      'id': 'movie-1',
      'kind': 'movie',
      'entity_type': 'work',
      'title': 'Arrival',
      'subtitle': 'A linguist meets visitors.',
      'image_url': 'https://example.test/arrival.jpg',
    });
    expect(hit.toJson().containsKey('payload'), isFalse);
  });

  test('builds a work ref from a typed catalog item', () {
    final item = CatalogItem.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'Dune',
      'item_number': '1',
      'cover_image_url': 'https://example.test/dune.jpg',
    });

    final hit = CatalogSearchHit.fromCatalogItem(item);

    expect(hit.ref, isA<CatalogEntityRef>());
    expect(hit.ref.kind, 'book');
    expect(hit.ref.entityType, CatalogEntityType.work);
    expect(hit.ref.id, 'book-1');
    expect(hit.subtitle, '1');
    expect(hit.imageUrl, 'https://example.test/dune.jpg');
  });

  test('rejects incomplete result identities', () {
    expect(
      () => CatalogSearchHit.fromJson({'kind': 'book', 'title': 'Dune'}),
      throwsFormatException,
    );
    expect(
      () => CatalogSearchHit.fromJson({'id': 'book-1', 'kind': 'book'}),
      throwsFormatException,
    );
  });
}
