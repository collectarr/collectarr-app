import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk remove action can open a dialog after popup selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionControls(
            selectedCount: 2,
            callbacks: (
              onClearSelection: () {},
              onBulkEdit: () {},
              onBulkMoveToOwned: () {},
              onBulkMoveToWishlist: () {},
              onBulkRemove: () {
                showDialog<void>(
                  context: tester.element(find.byType(LibrarySelectionControls)),
                  builder: (context) => const AlertDialog(
                    content: Text('Remove dialog opened'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Bulk actions'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove selected'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Remove dialog opened'), findsOneWidget);
  });
}