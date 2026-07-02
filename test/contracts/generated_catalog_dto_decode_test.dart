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

    expect(game.platforms, ['Switch']);
    expect(game.identifiers, ['IGDB:1']);
    expect(boardgame.contributors, ['Klaus Teuber']);
    expect(boardgame.rankings, ['BGG Rank #1']);
    expect(game.toCatalogItem().title, 'Zelda');
    expect(boardgame.toCatalogItem().title, 'Catan');
  });
}
