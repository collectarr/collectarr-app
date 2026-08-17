import 'package:collectarr_app/features/library/workspace/chrome/compact_selection_action_bar.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'CompactSelectionActionBar renders selection count and handles actions',
      (tester) async {
    bool exitTapped = false;
    bool toggleAllTapped = false;
    bool editTapped = false;
    bool deleteTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactSelectionActionBar(
              selectedCount: 3,
              totalCount: 10,
              isAllSelected: false,
              onExitSelection: () => exitTapped = true,
              onToggleSelectAll: () => toggleAllTapped = true,
              onBulkEdit: () => editTapped = true,
              onBulkDelete: () => deleteTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('3 selected'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.byKey(const ValueKey('selection_bar_close')), findsOneWidget);
    expect(find.byKey(const ValueKey('selection_bar_edit')), findsOneWidget);
    expect(find.byKey(const ValueKey('selection_bar_delete')), findsOneWidget);

    // Tap Exit
    await tester.tap(find.byKey(const ValueKey('selection_bar_close')));
    await tester.pumpAndSettle();
    expect(exitTapped, isTrue);

    // Tap Select all
    await tester.tap(find.byKey(const ValueKey('selection_bar_toggle_all')));
    await tester.pumpAndSettle();
    expect(toggleAllTapped, isTrue);

    // Tap Edit
    await tester.tap(find.byKey(const ValueKey('selection_bar_edit')));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);

    // Tap Delete
    await tester.tap(find.byKey(const ValueKey('selection_bar_delete')));
    await tester.pumpAndSettle();
    expect(deleteTapped, isTrue);
  });
}
