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

    expect(find.text('Absolute Batman #1'), findsWidgets);
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
    expect(find.text('Jim Lee Variant'), findsWidgets);
  });

  testWidgets('provider results render variants under the issue root',
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
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Standard cover | Nick Dragotta Cover'), findsWidgets);
    expect(find.text('Jim Lee Cardstock Variant Cover'), findsWidgets);
    expect(find.text('1 standard cover | 1 variant cover'), findsOneWidget);
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
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('2 issues | 3 covers | 1 variant'), findsOneWidget);
    expect(find.text('Veronica Fish Variant Cover'), findsWidgets);
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
      tester.getTopLeft(find.text('#2')).dy,
      lessThan(tester.getTopLeft(find.text('#1')).dy),
    );
  });
}

Widget _host({
  required bool includeVariants,
  required bool hideInShelf,
  Set<String> ownedItemIds = const {},
  bool issueSortAscending = true,
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
          mode: LibraryAddMode.addSeries,
          serverResults: const [],
          providerResults: providerResults,
          pullListRows: const [],
          ownedItemIds: ownedItemIds,
          wishlistItemIds: const {},
          selectedServerId: null,
          selectedProviderId: null,
          checkedServerIds: const {},
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
