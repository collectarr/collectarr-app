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
    final kindData = result['kind_data'] as Map<String, dynamic>;
    expect(kindData['title'], 'Kind of Blue (2025 Vinyl)');
    expect(kindData['artist_credits'], [
      {'name': 'Miles Davis'}
    ]);
    expect(kindData['format'], 'Vinyl');
    expect(result, isNot(contains('title')));
    expect(result, isNot(contains('music')));
    expect(result, isNot(contains('release_group')));
    expect(result, isNot(contains('releases')));
  });
}
