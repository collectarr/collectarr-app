import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame work dto preserves typed collections', () {
    final dto = BoardGameWorkDto.fromJson({
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

    expect(dto.platforms, ['Base Game']);
    expect(dto.identifiers, ['BGG:13']);
    expect(dto.contributors, ['Klaus Teuber']);
    expect(dto.mechanics, ['dice rolling']);
    expect(dto.categories, ['economic']);
    expect(dto.families, ['catan']);
    expect(dto.expansions, ['Seafarers']);
    expect(dto.rankings, ['BGG Rank #1']);
  });
}
