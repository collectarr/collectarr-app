import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('splits flat catalog JSON into common fields and kind payload', () {
    final envelope = CatalogItemEnvelopeDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'A book',
      'release_year': 2024,
      'authors': ['Author'],
    });

    expect(envelope.kind, CatalogMediaKind.book);
    expect(envelope.common.title, 'A book');
    expect(envelope.common.releaseYear, 2024);
    expect(envelope.kindPayload, {'authors': ['Author']});
  });

  test('round trips the nested envelope shape', () {
    final envelope = CatalogItemEnvelopeDto.fromJson({
      'ref': {'kind': 'music', 'entity_type': 'work', 'id': 'music-1'},
      'kind': 'music',
      'common': {'title': 'Album'},
      'payload': {'tracks': []},
    });

    expect(envelope.toJson(), {
      'ref': {'kind': 'music', 'entity_type': 'work', 'id': 'music-1'},
      'kind': 'music',
      'common': {'title': 'Album'},
      'payload': {'tracks': []},
    });
  });
}
