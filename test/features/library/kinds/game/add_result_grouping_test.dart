import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/panes/grouped_results.dart';
import 'package:collectarr_app/features/library/add/panes/mode_bar.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/add/panes/search_pane.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/game/add/preview.dart';
import 'package:collectarr_app/features/library/kinds/game/add/result_grouping.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogSearchCandidate _game(String id, String title, String platform,
        {String? edition, String? barcode, String? region, String? gameId}) =>
    CatalogSearchCandidate.fromApiJson(json: {
      'id': '30000000-0000-4000-8000-$id',
      'kind': 'game',
      'kind_data': {
        'title': title,
        'platforms': [platform],
        if (edition != null) 'edition_title': edition,
        if (barcode != null) 'barcode': barcode,
        if (region != null) 'release_region': region,
        if (gameId != null) 'game_id': gameId,
      },
    });

/// No platform icons loaded by the user, without a database.
final _noLoadedIcons = [
  listValueImageProvider.overrideWith((ref, key) => Stream.value(null))
];

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

  test('Add Games groups editions by their Core Game ID', () {
    const remaster = '40000000-0000-4000-8000-000000000001';
    const original = '40000000-0000-4000-8000-000000000002';
    final linked = [
      _game('000000000011', 'Brick Knight', 'PC',
          region: 'US', gameId: remaster),
      _game('000000000012', 'Brick Knight', 'PC',
          region: 'EU', gameId: remaster),
      _game('000000000013', 'Brick Knight', 'PC',
          region: 'US', gameId: original),
    ];
    final groups = libraryAddResultGroups(linked, gameAddResultGrouping);
    expect(groups.map((group) => group.variants.length), [2, 1]);
    expect(gameAddResultGroupKey(linked[0]),
        isNot(gameAddItemGroupKey(linked[0])));
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
        overrides: _noLoadedIcons,
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

    // Regions narrow the editions in place; one without editions is dimmed.
    Material segment(String value) =>
        tester.widget(find.byKey(ValueKey('library-add-facet-$value')));
    expect(segment('eu').color, const Color(0xff555555));
    await tester.tap(find.byKey(const ValueKey('library-add-facet-eu')));
    await tester.pump();
    expect(find.text('2000000000039'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('library-add-facet-us')));
    await tester.pump();
    expect(find.text('Default US Edition'), findsOneWidget);
    expect(find.text('2000000000039'), findsNothing);
    expect(find.text('2 Results'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('the confirm sheet shows platform, year, edition and region',
      (tester) async {
    final item = CatalogSearchCandidate.fromApiJson(json: {
      'id': '30000000-0000-4000-8000-000000000009',
      'kind': 'game',
      'kind_data': {
        'title': 'Brick Knight',
        'platforms': ['PC'],
        'edition_title': 'Default US Edition',
        'release_region': 'US',
        'release_date_parts': {'year': 2008},
      },
    });
    await tester.pumpWidget(ProviderScope(
      overrides: _noLoadedIcons,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildGameAddPreview(
              context,
              LibraryAddPreviewPaneRequest(
                type: const GameRegistration(),
                accent: Colors.red,
                item: item,
                isFetchingPreview: false,
                searched: true,
              ),
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Brick Knight'), findsOneWidget);
    expect(find.text('PC'), findsOneWidget);
    expect(find.text(' (2008)'), findsOneWidget);
    expect(find.text('Default US Edition'), findsOneWidget);
    expect(find.text('US'), findsOneWidget);
    expect(gameKindAdd.chrome.confirmSheetSize, const Size(730, 369));
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  testWidgets('clicking a title suggestion picks it', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final query = TextEditingController(text: 'brick knight');
    addTearDown(query.dispose);
    final identifier = TextEditingController();
    addTearDown(identifier.dispose);
    CatalogSearchCandidate? picked;
    await tester.pumpWidget(ProviderScope(
      overrides: _noLoadedIcons,
      child: MaterialApp(
        home: Scaffold(
          body: LibraryAddModeBar(
            type: const GameRegistration(),
            accent: Colors.red,
            isWideLayout: true,
            mode: LibraryAddDialogMode.search,
            queryController: query,
            identifierController: identifier,
            isSearching: false,
            onModeChanged: (_) {},
            onSearch: () {},
            onQueryChanged: (_) {},
            suggestions: results,
            showSuggestions: true,
            onSelectSuggestion: (item) => picked = item,
            onDismissSuggestions: () {},
            canScanCover: false,
            isScanningCover: false,
            onScanCover: () {},
            onLookupIdentifier: () {},
            onScanBarcode: () {},
            onSearchCode: () {},
            onManual: () {},
            showAdvanced: false,
            onToggleAdvanced: () {},
            advancedFilterState: const {},
            onAdvancedFilterChanged: (_, __) {},
            advancedFilterDescriptors: const [],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // The list must take hits where it is drawn, not where it is laid out.
    await tester.tap(find.text('Brick Knight').first);
    expect(picked, same(results.first));
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'title suggestions start with Search for and show each game platform',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final query = TextEditingController(text: 'brick knight');
    addTearDown(query.dispose);
    final identifier = TextEditingController();
    addTearDown(identifier.dispose);
    var searched = false;
    final suggestions = [
      for (final group
          in libraryAddResultGroups(results, gameAddResultGrouping))
        group.first
    ];
    await tester.pumpWidget(ProviderScope(
      overrides: _noLoadedIcons,
      child: MaterialApp(
        home: Scaffold(
          body: LibraryAddModeBar(
            type: const GameRegistration(),
            accent: Colors.red,
            isWideLayout: true,
            mode: LibraryAddDialogMode.search,
            queryController: query,
            identifierController: identifier,
            isSearching: false,
            onModeChanged: (_) {},
            onSearch: () => searched = true,
            onQueryChanged: (_) {},
            suggestions: suggestions,
            suggestionDetail: gameAddResultGrouping.groupDetail,
            showSuggestions: true,
            onSelectSuggestion: (_) {},
            onDismissSuggestions: () {},
            canScanCover: false,
            isScanningCover: false,
            onScanCover: () {},
            onLookupIdentifier: () {},
            onScanBarcode: () {},
            onSearchCode: () {},
            onManual: () {},
            showAdvanced: false,
            onToggleAdvanced: () {},
            advancedFilterState: const {},
            onAdvancedFilterChanged: (_, __) {},
            advancedFilterDescriptors: const [],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Search for "brick knight"'), findsOneWidget);
    expect(find.text('Or pick from these suggestions:'), findsOneWidget);
    // One row per game and platform, under it the platform, not the
    // edition's publisher, year and barcode.
    expect(find.text('Brick Knight'), findsNWidgets(2));
    expect(find.text('PC'), findsOneWidget);
    expect(find.text('PlayStation 4'), findsOneWidget);
    // A real tap: the list must take hits where it is drawn.
    await tester.tap(find.text('Search for "brick knight"'));
    expect(searched, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  group('the Platform listing', () {
    Widget listing(
      List<CatalogSearchCandidate> results, {
      required VoidCallback onLoadMore,
      bool loadsOnScroll = true,
      ValueChanged<String>? onSelect,
      ValueChanged<String>? onCheck,
    }) =>
        ProviderScope(
          overrides: _noLoadedIcons,
          child: MaterialApp(
            home: Scaffold(
              body: LibraryAddSearchPane(
                type: const GameRegistration(),
                isBusy: false,
                error: null,
                accent: Colors.red,
                results: results,
                isListing: true,
                totalResults: 27105,
                hasMoreResults: true,
                listingLoadsOnScroll: loadsOnScroll,
                onLoadMoreResults: onLoadMore,
                selectedResultId: null,
                checkedResultIds: const {},
                entryCatalogRefs: const {},
                resultPolicy:
                    LibraryAddResultPolicy(grouping: gameAddResultGrouping),
                resultPolicyState: const LibraryAddResultPolicyState(),
                onResultPolicyOptionChanged: (_, __) {},
                onSelectResult: onSelect ?? (_) {},
                onToggleResultCheck: onCheck ?? (_) {},
                searched: true,
              ),
            ),
          ),
        );

    testWidgets('shows the total and one row per item, loading more nearby',
        (tester) async {
      var loads = 0;
      String? selected;
      String? checked;
      await tester.pumpWidget(listing(
        [_game('a', 'Amber Quest', 'PC')],
        onLoadMore: () => loads++,
        onSelect: (id) => selected = id,
        onCheck: (id) => checked = id,
      ));
      await tester.pump();

      expect(find.text('27105 Results'), findsOneWidget);
      expect(find.text('Amber Quest'), findsOneWidget);
      expect(loads, greaterThan(0));

      await tester.tap(find.text('Amber Quest'));
      expect(selected, isNotNull);
      await tester.tap(find.byType(LibraryAddResultCheckbox));
      expect(checked, selected);
    });

    testWidgets('leaves further pages to the button when told not to scroll',
        (tester) async {
      var loads = 0;
      await tester.pumpWidget(listing(
        [_game('a', 'Amber Quest', 'PC')],
        onLoadMore: () => loads++,
        loadsOnScroll: false,
      ));
      await tester.pump();

      expect(loads, 0);
      expect(find.byType(LibraryAddSearchResultsFooter), findsOneWidget);
    });
  });
}
