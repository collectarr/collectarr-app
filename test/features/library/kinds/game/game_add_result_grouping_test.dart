import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_grouped_results.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_result_grouping.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogSearchCandidate _game(String id, String title, String platform,
        {String? edition, String? barcode, String? region}) =>
    CatalogSearchCandidate.fromApiJson(json: {
      'id': '30000000-0000-4000-8000-$id',
      'kind': 'game',
      'kind_data': {
        'title': title,
        'platforms': [platform],
        if (edition != null) 'edition_title': edition,
        if (barcode != null) 'barcode': barcode,
        if (region != null) 'release_region': region,
      },
    });

void main() {
  final results = [
    _game('000000000001', 'Brick Knight', 'PC',
        edition: 'Default US Edition', region: 'US'),
    _game('000000000002', 'Brick Knight', 'PlayStation 4',
        barcode: '2000000000022', region: 'EU'),
    _game('000000000003', 'Brick Knight', 'PC',
        barcode: '2000000000039', region: 'Region Free'),
  ];

  test('Add Games lists a game once per platform', () {
    expect(gameKindAdd.resultPolicy.grouping, same(gameAddResultGrouping));
    final groups = libraryAddResultGroups(results, gameAddResultGrouping);
    expect(groups.map((group) => group.variants.length), [2, 1]);
    expect(
        gameAddResultGrouping.variantLabel(results[0]), 'Default US Edition');
    expect(gameAddResultGrouping.variantLabel(results[1]), '2000000000022');
    expect(gameAddResultGrouping.variantBadge(results[1]), 'EU');
    expect(gameAddResultGrouping.variantBadge(results[2]), isEmpty);
  });

  testWidgets('a chosen game shows its editions beside the list',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? group;
    String? result;
    Widget pane() => ProviderScope(
            child: MaterialApp(
          home: Scaffold(
            body: LibraryAddSearchPane(
              type: const GameRegistration(),
              isBusy: false,
              error: null,
              accent: Colors.red,
              results: results,
              selectedResultId: null,
              checkedResultIds: const {},
              entryCatalogRefs: const {},
              resultPolicy:
                  LibraryAddResultPolicy(grouping: gameAddResultGrouping),
              resultPolicyState: const LibraryAddResultPolicyState(),
              onResultPolicyOptionChanged: (_, __) {},
              onSelectResult: (id) => result = id,
              onToggleResultCheck: (_) {},
              searched: true,
              selectedGroupKey: group,
              onSelectGroup: (key) => group = key,
            ),
          ),
        ));
    await tester.pumpWidget(pane());
    expect(find.text('2 Results'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('library-add-variant-grid')), findsNothing);

    await tester.tap(find.text('PC'));
    expect(group, 'brick knight|pc');
    await tester.pumpWidget(pane());
    expect(find.text('Default US Edition'), findsOneWidget);
    expect(find.text('2000000000039'), findsOneWidget);
    expect(find.text('2000000000022'), findsNothing);

    await tester.tap(find.text('Default US Edition'));
    expect(result, results[0].reference.id);
  });
}
