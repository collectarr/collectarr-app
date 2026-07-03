import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toolbar search exposes inline actions and filter chip', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Spider-Man');
    var lastSearch = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search comics...',
              onSearch: (value) => lastSearch = value,
              onScanBarcode: () {},
              onScanCover: () {},
              selectedFilterLabel: 'Owned',
              onClearFilter: () {},
              selectionColor: Colors.cyan,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    expect(find.byIcon(Icons.image_search), findsOneWidget);
    expect(find.text('Owned'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(lastSearch, 'Spider-Man');
    controller.dispose();
  });

  testWidgets('toolbar search renders search scope selector', (tester) async {
    final controller = TextEditingController(text: 'Lupus');
    LibrarySearchTarget selected = LibrarySearchTarget.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search music...',
              onSearch: (_) {},
              onChanged: (_) {},
              selectionColor: Colors.orange,
              searchTarget: selected,
              searchTargetOptions: const [
                LibrarySearchTarget.all,
                LibrarySearchTarget.mediaOnly,
                LibrarySearchTarget.tracksOnly,
              ],
              onSearchTargetChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('library-search-target-button')),
        findsOneWidget);
    expect(find.text('Albums & Tracks'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('library-search-target-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tracks').last);
    await tester.pumpAndSettle();

    expect(selected, LibrarySearchTarget.tracksOnly);
    controller.dispose();
  });

  testWidgets('toolbar search toggles clear action and applies suggestion', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Spider');
    var cleared = false;
    String? pickedSuggestionId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search comics...',
              onSearch: (_) {},
              onClearSearch: () {
                cleared = true;
              },
              searchActive: true,
              suggestions: const [
                LibraryToolbarSearchSuggestion(
                  id: 'item-1',
                  title: 'Spider-Man #1',
                  subtitle: '#1 • Marvel',
                ),
              ],
              onSuggestionSelected: (value) => pickedSuggestionId = value.id,
              selectionColor: Colors.cyan,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Spider-Man #1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(cleared, isTrue);

    await tester.tap(find.text('Spider-Man #1'));
    await tester.pump();
    expect(pickedSuggestionId, 'item-1');

    controller.dispose();
  });
}
