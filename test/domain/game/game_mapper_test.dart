import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';

void main() {
  test('game work dto preserves typed collections', () {
    final dto = GameWorkDto.fromJson({
      'id': 'game-1',
      'title': 'Zelda',
      'platforms': ['Switch', 'switch'],
      'identifiers': ['IGDB:1'],
      'company_roles': ['developer', 'publisher'],
      'age_ratings': ['E10+'],
    });

    expect(dto.platforms, ['Switch']);
    expect(dto.identifiers, ['IGDB:1']);
    expect(dto.companyRoles, ['developer', 'publisher']);
    expect(dto.ageRatings, ['E10+']);
  });
}
