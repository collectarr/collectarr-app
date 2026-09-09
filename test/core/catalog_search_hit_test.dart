import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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

    expect(hit.ref.kind, CatalogMediaKind.movie);
    expect(hit.ref.entityType, const CatalogEntityTypeId('work'));
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

  test('keeps a typed work reference in the structural projection', () {
    final hit = CatalogSearchHit(
      ref: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: const CatalogEntityTypeId('work'),
        id: 'book-1',
      ),
      kind: CatalogMediaKind.book,
      title: 'Dune',
      subtitle: '1',
      imageUrl: 'https://example.test/dune.jpg',
    );

    expect(hit.ref, isA<CatalogEntityRef>());
    expect(hit.ref.kind, CatalogMediaKind.book);
    expect(hit.ref.entityType, const CatalogEntityTypeId('work'));
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
