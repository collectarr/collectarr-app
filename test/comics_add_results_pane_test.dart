import 'package:collectarr_app/features/comics/comics_add_results_pane.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('provider result filters hide variants', (tester) async {
    await tester.pumpWidget(
      _host(
        includeVariants: false,
        hideInShelf: false,
      ),
    );

    expect(find.text('#1 | Standard cover'), findsWidgets);
    expect(find.text('Variant cover'), findsNothing);
  });

  testWidgets('provider result filters hide local shelf candidates',
      (tester) async {
    const localCandidate = ProviderCandidate(
      provider: 'gcd',
      providerItemId: '2663120',
      title: 'Absolute Batman #1',
      kind: 'comic',
    );

    await tester.pumpWidget(
      _host(
        includeVariants: true,
        hideInShelf: true,
        ownedItemIds: {localCandidate.localCatalogId},
      ),
    );

    expect(find.text('Standard cover'), findsNothing);
    expect(find.text('#1 | Jim Lee Variant'), findsWidgets);
  });

  testWidgets('provider results render variants directly under the series',
      (tester) async {
    await tester.pumpWidget(
      _host(
        includeVariants: true,
        hideInShelf: false,
        providerResults: const [
          ProviderCandidate(
            provider: 'gcd',
            providerItemId: '2663120',
            title: 'Absolute Batman (2024 series) #1 [Nick Dragotta Cover]',
            kind: 'comic',
            summary: 'December 2024 · 48 pages',
          ),
          ProviderCandidate(
            provider: 'gcd',
            providerItemId: '2665653',
            title:
                'Absolute Batman (2024 series) #1 [Jim Lee Cardstock Variant Cover]',
            kind: 'comic',
            summary: 'December 2024 · variant',
          ),
        ],
      ),
    );

    expect(find.text('Absolute Batman (2024 series)'), findsOneWidget);
    expect(
        find.text('#1 | Standard cover | Nick Dragotta Cover'), findsWidgets);
    expect(find.text('#1 | Jim Lee Cardstock Variant Cover'), findsWidgets);
    expect(find.text('1 issue'), findsOneWidget);
    expect(find.textContaining('December 2024'), findsNothing);
    expect(find.text('propose'), findsNothing);
  });

  testWidgets('provider results group multiple issues below a series',
      (tester) async {
    await tester.pumpWidget(
      _host(
        includeVariants: true,
        hideInShelf: false,
        providerResults: const [
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: '498453',
            title: 'Over the Garden Wall #1 [Regular Cover]',
            kind: 'comic',
          ),
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: '498453-b',
            title: 'Over the Garden Wall #1 [Veronica Fish Variant Cover]',
            kind: 'comic',
            summary: 'April 2016 · variant',
          ),
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: '507300',
            title: 'Over the Garden Wall #2 [Regular Cover]',
            kind: 'comic',
          ),
        ],
      ),
    );

    expect(find.text('Over the Garden Wall'), findsOneWidget);
    expect(find.text('#1 | Standard cover | Regular Cover'), findsWidgets);
    expect(find.text('#2 | Standard cover | Regular Cover'), findsWidgets);
    expect(find.text('2 issues | 3 covers | 1 variant'), findsOneWidget);
    expect(find.text('#1 | Veronica Fish Variant Cover'), findsWidgets);
  });

  testWidgets('provider issue sorting can be descending', (tester) async {
    await tester.pumpWidget(
      _host(
        includeVariants: true,
        hideInShelf: false,
        issueSortAscending: false,
        providerResults: const [
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: 'one',
            title: 'Over the Garden Wall #1 [Regular Cover]',
            kind: 'comic',
          ),
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: 'two',
            title: 'Over the Garden Wall #2 [Regular Cover]',
            kind: 'comic',
          ),
        ],
      ),
    );

    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('provider-row-comicvine-two')))
          .dy,
      lessThan(
        tester
            .getTopLeft(
                find.byKey(const ValueKey('provider-row-comicvine-one')))
            .dy,
      ),
    );
  });

  testWidgets('add issue mode renders provider candidates as a flat list',
      (tester) async {
    await tester.pumpWidget(
      _host(
        mode: LibraryAddMode.addIssue,
        includeVariants: true,
        hideInShelf: false,
        providerResults: const [
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: 'one',
            title: 'Over the Garden Wall #1 [Regular Cover]',
            kind: 'comic',
          ),
          ProviderCandidate(
            provider: 'comicvine',
            providerItemId: 'one-b',
            title: 'Over the Garden Wall #1 [Veronica Fish Variant Cover]',
            kind: 'comic',
            summary: 'variant',
          ),
        ],
      ),
    );

    expect(find.text('Over the Garden Wall'), findsWidgets);
    expect(find.text('#1 | Standard cover | Regular Cover'), findsWidgets);
    expect(find.text('#1 | Veronica Fish Variant Cover'), findsWidgets);
    expect(find.text('variant'), findsOneWidget);
  });

  testWidgets('provider rows support independent multi-select checks',
      (tester) async {
    var toggledId = '';

    await tester.pumpWidget(
      _host(
        includeVariants: true,
        hideInShelf: false,
        checkedProviderIds: const {'2665653'},
        onToggleProviderCheck: (id) => toggledId = id,
      ),
    );

    final row = find.byKey(const ValueKey('provider-row-gcd-2663120'));
    expect(row, findsOneWidget);

    await tester.tap(find.descendant(of: row, matching: find.byType(Checkbox)));
    expect(toggledId, '2663120');
  });
}

Widget _host({
  LibraryAddMode mode = LibraryAddMode.addSeries,
  required bool includeVariants,
  required bool hideInShelf,
  Set<String> ownedItemIds = const {},
  Set<String> checkedProviderIds = const {},
  bool issueSortAscending = true,
  ValueChanged<String>? onToggleProviderCheck,
  List<ProviderCandidate> providerResults = const [
    ProviderCandidate(
      provider: 'gcd',
      providerItemId: '2663120',
      title: 'Absolute Batman #1',
      kind: 'comic',
    ),
    ProviderCandidate(
      provider: 'gcd',
      providerItemId: '2665653',
      title: 'Absolute Batman #1 Jim Lee Variant',
      kind: 'comic',
      summary: 'December 2024 · variant',
    ),
  ],
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 520,
        child: AddComicResultPane(
          mode: mode,
          serverResults: const [],
          providerResults: providerResults,
          pullListRows: const [],
          ownedItemIds: ownedItemIds,
          wishlistItemIds: const {},
          selectedServerId: null,
          selectedProviderId: null,
          checkedServerIds: const {},
          checkedProviderIds: checkedProviderIds,
          includeVariants: includeVariants,
          hideInShelf: hideInShelf,
          issueSortAscending: issueSortAscending,
          searchedServer: true,
          searchedProvider: true,
          isSearchingServer: false,
          isSearchingProvider: false,
          selectedProvider: 'gcd',
          providerLabel: (provider) => provider == 'gcd' ? 'GCD' : provider,
          onIncludeVariantsChanged: (_) {},
          onHideInShelfChanged: (_) {},
          onIssueSortAscendingChanged: (_) {},
          onSelectServer: (_) {},
          onToggleServerCheck: (_) {},
          onToggleProviderCheck: onToggleProviderCheck ?? (_) {},
          onToggleProviderCandidatesCheck: (_) {},
          collapsedSeries: const {},
          onToggleSeriesCollapsed: (_) {},
          onToggleSeriesCheck: (_) {},
          onCheckAllVisible: (_) {},
          onClearServerChecks: () {},
          onSelectProvider: (_) {},
          onSearchPullListRow: (_) {},
        ),
      ),
    ),
  );
}
