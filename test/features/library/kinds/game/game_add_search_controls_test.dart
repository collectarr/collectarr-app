import 'package:collectarr_app/features/library/kinds/game/add/game_add_search_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release regions map to the reference Add Games regions', () {
    expect(gameAddRegionFor('NTSC-U/C (US/Canada)'), GameAddRegion.us);
    expect(gameAddRegionFor('PAL (Europe/Australia)'), GameAddRegion.eu);
    expect(gameAddRegionFor('NTSC-J (Japan)'), GameAddRegion.jp);
    expect(gameAddRegionFor('Australia'), GameAddRegion.au);
    expect(gameAddRegionFor('Region Free'), GameAddRegion.other);
    expect(gameAddRegionFor(null), isNull);
  });
}
