import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('typed catalog dto decode preserves kind-specific lists', () {
    final game = GameWorkDto.fromJson({
      'id': 'game-1',
      'title': 'Zelda',
      'platforms': ['Switch', 'switch'],
      'identifiers': ['IGDB:1'],
      'company_roles': ['developer', 'publisher'],
      'age_ratings': ['E10+'],
    });
    final boardgame = BoardGameWorkDto.fromJson({
      'id': 'boardgame-1',
      'title': 'Catan',
      'platforms': ['Base Game'],
      'identifiers': ['BGG:13'],
      'contributors': ['Klaus Teuber'],
      'mechanics': ['dice rolling'],
      'categories': ['economic'],
      'families': ['catan'],
      'expansions': ['Seafarers'],
      'rankings': ['BGG Rank #1'],
    });
    final music = MusicReleaseDto.fromJson({
      'id': 'music-1',
      'title': 'The Dark Side of the Moon',
      'subtitle': 'Pink Floyd',
      'release_type': 'album',
      'release_status': 'released',
      'release_date': '1973-03-01',
      'track_count': 1,
      'publisher': 'Harvest Records',
      'studio': 'Abbey Road',
      'catalog_number': 'SHVL 804',
      'barcode': '1234567890123',
      'country_code': 'GB',
      'language': 'en',
      'media': [
        {
          'id': 'media-1',
          'title': 'Disc 1',
          'media_number': 1,
          'media_type': 'album',
          'track_count': 1,
          'packaging': 'digipak',
          'tracks': [
            {
              'id': 'track-1',
              'title': 'Speak to Me',
              'position': '1',
              'duration_ms': 90000,
            }
          ],
        }
      ],
    });

    expect(game.platforms, ['Switch']);
    expect(game.identifiers, ['IGDB:1']);
    expect(boardgame.contributors, ['Klaus Teuber']);
    expect(boardgame.rankings, ['BGG Rank #1']);
    expect(music.media.first.tracks.first.title, 'Speak to Me');
    expect(game.toCatalogItem().title, 'Zelda');
    expect(boardgame.toCatalogItem().title, 'Catan');
    expect(music.toCatalogItem().title, 'The Dark Side of the Moon');
  });
}
