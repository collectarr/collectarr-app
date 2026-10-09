import 'package:collectarr_app/core/models/catalog_item_ref.dart';
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
    expect(hit.ref.id, 'movie-1');
    expect(hit.kind, CatalogMediaKind.movie);
    expect(hit.primaryLabel, 'Arrival');
    expect(hit.title, 'Arrival');
    expect(hit.subtitle, 'A linguist meets visitors.');
    expect(hit.toJson(), {
      'id': 'movie-1',
      'kind': 'movie',
      'primary_label': 'Arrival',
      'title': 'Arrival',
      'subtitle': 'A linguist meets visitors.',
      'image_url': 'https://example.test/arrival.jpg',
    });
    expect(hit.toJson().containsKey('payload'), isFalse);
  });

  test('keeps a typed item reference in the structural projection', () {
    final hit = CatalogSearchHit(
      ref: const CatalogItemRef(
        kind: CatalogMediaKind.book,
        id: 'book-1',
      ),
      kind: CatalogMediaKind.book,
      title: 'Dune',
      subtitle: '1',
      imageUrl: 'https://example.test/dune.jpg',
    );

    expect(hit.ref, isA<CatalogItemRef>());
    expect(hit.ref.kind, CatalogMediaKind.book);
    expect(hit.ref.id, 'book-1');
    expect(hit.primaryLabel, 'Dune');
    expect(hit.title, 'Dune');
    expect(hit.subtitle, '1');
    expect(hit.imageUrl, 'https://example.test/dune.jpg');
  });

  test('rejects incomplete result identities', () {
    expect(
      () => CatalogSearchHit.fromJson({'kind': 'book', 'title': 'Dune'}),
      throwsFormatException,
    );
  });

  test('allows hits without title by falling back to primaryLabel or id', () {
    final hitWithLabel = CatalogSearchHit.fromJson({
      'id': 'spec-1',
      'kind': 'book',
      'primary_label': 'SPEC-101',
    });
    expect(hitWithLabel.primaryLabel, 'SPEC-101');
    expect(hitWithLabel.title, 'SPEC-101');

    final hitOnlyId =
        CatalogSearchHit.fromJson({'id': 'item-1', 'kind': 'book'});
    expect(hitOnlyId.primaryLabel, 'item-1');
    expect(hitOnlyId.title, 'item-1');
  });
}
