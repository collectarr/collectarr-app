import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music search result is one concrete album with kind-owned details', () {
    final result = CatalogMusicItemDto.fromJson({
      'id': 'album-1',
      'kind': 'music',
      'title': 'Kind of Blue (2025 Vinyl)',
      'artist': 'Miles Davis',
      'label': 'Columbia',
      'format': 'Vinyl',
      'barcode': '0196588000000',
      'discs': const <Map<String, Object?>>[],
    }).toSearchJson();

    expect(result['id'], 'album-1');
    expect(result['title'], 'Kind of Blue (2025 Vinyl)');
    expect(result['music'], containsPair('artist', 'Miles Davis'));
    expect(result['music'], containsPair('format', 'Vinyl'));
    expect(result, isNot(contains('release_group')));
    expect(result, isNot(contains('releases')));
  });
}
