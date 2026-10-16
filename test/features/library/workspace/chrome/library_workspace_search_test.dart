import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              onRandomPick: () {},
              selectedFilterLabel: 'Entry',
              onClearFilter: () {},
              selectionColor: Colors.cyan,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(AppIcons.search), findsOneWidget);
    expect(find.byKey(const ValueKey('library-search-barcode-glyph')),
        findsOneWidget);
    expect(find.byIcon(AppIcons.camera), findsOneWidget);
    expect(find.byIcon(AppIcons.dice), findsOneWidget);
    expect(find.text('Entry'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.search));
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
          body: Padding(
            padding: const EdgeInsets.only(left: 100),
            child: SizedBox(
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
      ),
    );

    expect(find.byKey(const ValueKey('library-search-target-button')),
        findsOneWidget);
    expect(
      find.byKey(const ValueKey('library-search-target-icon-all')),
      findsOneWidget,
    );
    expect(find.text('Albums & Tracks'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey('library-search-target-button')));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<LibrarySearchTarget>), findsNWidgets(3));
    // The list opens left-aligned under the button, as in the reference.
    final button = tester
        .getRect(find.byKey(const ValueKey('library-search-target-button')));
    final firstItem =
        tester.getRect(find.byType(PopupMenuItem<LibrarySearchTarget>).first);
    expect(firstItem.left, button.left - 4);
    expect(firstItem.top, button.bottom + 2);
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
    String? searched;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              child: LibraryToolbarSearch(
                controller: controller,
                hintText: 'Search comics...',
                onSearch: (value) => searched = value,
                onClearSearch: () {
                  cleared = true;
                },
                searchActive: true,
                suggestions: const [
                  LibraryToolbarSearchSuggestion(
                    id: 'item-1',
                    title: 'Spider-Man #1',
                    label: 'Amazing Spider-Man - Spider-Man #1',
                    subtitle: '1963',
                  ),
                ],
                onSuggestionSelected: (value) => pickedSuggestionId = value.id,
                selectionColor: Colors.cyan,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(find.text('Amazing Spider-Man - Spider-Man #1'), findsWidgets);
    expect(find.text('1963'), findsOneWidget);
    expect(find.text('View all results'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pump();
    expect(cleared, isTrue);

    await tester.tap(find.text('1963'));
    await tester.pump();
    expect(pickedSuggestionId, 'item-1');
    expect(find.text('View all results'), findsNothing);
    expect(searched, isNull);

    controller.dispose();
  });

  testWidgets('toolbar search can fill the band width when capped higher', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 380,
            child: LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search comics...',
              onSearch: (_) {},
              selectionColor: Colors.cyan,
              maxWidth: 380,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LibraryToolbarSearch)).width, 380);
    expect(tester.getSize(find.byType(TextField)).width, 380);
  });
}
