import 'package:collectarr_app/features/library/add/panes/search_pane.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/contribution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Add Toys lists toy types as tiles and adds them with tick boxes', () {
    final browse = gameToyKindAdd.search.browse;
    expect(browse?.label, 'List');
    expect(browse?.tiles?.prompt, 'Choose your toy type');
    expect(browse?.tiles?.sectionLabel, 'Series');
    expect(browse?.tiles?.imageList, 'toy_type');
  });

  test('Add Manually follows the reference for toys', () {
    expect(gameToyKindAdd.chrome.dialogTitle, 'Add Toys');
    expect(gameToyKindAdd.manualChrome.footer, isNotNull);
    expect(gameToyKindAdd.manualChrome.extraTargets, isEmpty);
    expect(gameToyKindAdd.resultPolicy.resultsBuilder,
        same(buildLibraryAddResultsWithoutTickBoxes));
  });
}
