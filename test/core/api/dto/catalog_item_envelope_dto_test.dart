import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps every catalog field in the kind-owned payload', () {
    final item = CatalogItemDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'A book',
      'release_year': 2024,
      'authors': ['Author'],
    });
    final envelope = item.toEnvelope();

    expect(envelope.kind, CatalogMediaKind.book);
    expect(envelope.ref,
        const CatalogItemRef(kind: CatalogMediaKind.book, id: 'book-1'));
    expect(envelope.kindData, {
      'title': 'A book',
      'release_year': 2024,
      'authors': ['Author'],
    });
  });

  test('round trips the nested envelope shape', () {
    final envelope = CatalogItemEnvelopeDto.fromJson({
      'id': 'music-1',
      'kind': 'music',
      'kind_data': {'title': 'Album', 'tracks': <dynamic>[]},
    });

    expect(envelope.toJson(), {
      'id': 'music-1',
      'kind': 'music',
      'kind_data': {'title': 'Album', 'tracks': <dynamic>[]},
    });
  });

  test('decodes the payload through the catalog codec registry', () {
    final item = CatalogItemDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'A book',
      'authors': ['Author'],
    });
    final envelope = item.toEnvelope();

    final decodedItem = envelope.decodeCatalogItem();

    expect(decodedItem.mediaKind, CatalogMediaKind.book);
    expect(decodedItem.title, 'A book');
  });
}
