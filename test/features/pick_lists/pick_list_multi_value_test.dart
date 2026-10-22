import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tags are stored as a list, so a tag may contain a comma', () {
    const personal = GamePersonalData(tags: ['Zelda, Link', 'rpg']);
    final restored = GamePersonalData.fromJson(personal.toJson());
    expect(restored.tags, ['Zelda, Link', 'rpg']);
    expect(GamePersonalData.fromJson(const {}).tags, isEmpty);
  });

  test('renaming a value in a list trims, merges and drops repeats', () {
    expect(
      replacePickListValueInList(
        [' rpg ', 'Action', '', 'action rpg'],
        {'action'},
        'Action RPG',
      ),
      ['rpg', 'Action RPG'],
    );
    expect(replacePickListValueInList(['old'], {'old'}, ' '), isEmpty);
  });

  test('text boundaries split and join at commas', () {
    expect(splitPickListValues(' a, b ,,a'), ['a', 'b']);
    expect(joinPickListValues(['a', 'b']), 'a, b');
  });
}
