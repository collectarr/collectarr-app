import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('synthetic catalog transport exposes structural catalog identity', () {
    final item = CatalogItemDto.fromJson({
      'id': 'anilist-local:42',
      'kind': CatalogMediaKind.anime.apiValue,
      'title': 'A Place Further Than the Universe',
      'display_title': 'A Place Further Than the Universe',
      'release_date': DateTime.utc(2018, 1, 6).toIso8601String(),
    });

    expect(item.catalogRef.kind, CatalogMediaKind.anime);
    expect(item.catalogRef.id, 'anilist-local:42');
    expect(item.title, 'A Place Further Than the Universe');
    expect(item.mediaKind, CatalogMediaKind.anime);
  });
}
