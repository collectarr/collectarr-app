import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/workspace/chrome/compact_filter_surface.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'CompactFilterSurface renders quick filter chips and triggers filter changes',
      (tester) async {
    LibraryFilterSelection currentSelection = LibraryFilterSelection.none;
    bool filterDialogOpened = false;
    bool clearAllTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LibraryAccentScope(
                kind: 'comic',
                accent: Colors.deepOrange,
                animationsEnabled: true,
                child: CompactFilterSurface(
                  selection: currentSelection,
                  onFilterChanged: (newSelection) {
                    setState(() => currentSelection = newSelection);
                  },
                  onOpenFilterDialog: () => filterDialogOpened = true,
                  onClearAll: () => clearAllTriggered = true,
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('compact_filter_all_dialog_chip')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('quick_filter_all')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick_filter_owned')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick_filter_wishlist')), findsOneWidget);

    // Tap Owned filter chip
    await tester.tap(find.byKey(const ValueKey('quick_filter_owned')));
    await tester.pumpAndSettle();
    expect(currentSelection.ownershipFilter, LibraryOwnershipFilter.owned);
    expect(
        find.byKey(const ValueKey('compact_filter_clear_all')), findsOneWidget);

    // Tap Filter Dialog Chip
    await tester
        .tap(find.byKey(const ValueKey('compact_filter_all_dialog_chip')));
    await tester.pumpAndSettle();
    expect(filterDialogOpened, isTrue);

    // Tap Clear
    await tester
        .ensureVisible(find.byKey(const ValueKey('compact_filter_clear_all')));
    await tester.tap(find.byKey(const ValueKey('compact_filter_clear_all')));
    await tester.pumpAndSettle();
    expect(clearAllTriggered, isTrue);
    expect(currentSelection.hasActiveFilters, isFalse);
  });

  testWidgets(
      'CompactFilterSurface displays removable chips for active deep filters',
      (tester) async {
    LibraryFilterSelection selection = const LibraryFilterSelection(
      series: 'Batman',
      missingCover: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LibraryAccentScope(
                kind: 'comic',
                accent: Colors.deepOrange,
                animationsEnabled: true,
                child: CompactFilterSurface(
                  selection: selection,
                  onFilterChanged: (s) => setState(() => selection = s),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('active_filter_series')), findsOneWidget);
    expect(find.text('Series: Batman'), findsOneWidget);
    expect(find.byKey(const ValueKey('active_filter_missing_cover')),
        findsOneWidget);

    // Delete series filter
    final deleteIconFinder = find.descendant(
      of: find.byKey(const ValueKey('active_filter_series')),
      matching: find.byIcon(Icons.cancel),
    );
    await tester.ensureVisible(deleteIconFinder);
    await tester.tap(deleteIconFinder);
    await tester.pumpAndSettle();

    expect(selection.series, isNull);
    expect(find.byKey(const ValueKey('active_filter_series')), findsNothing);
  });
}
