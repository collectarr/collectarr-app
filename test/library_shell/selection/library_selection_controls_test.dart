import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk remove action can open a dialog from remove button', (
    tester,
  ) async {
    final testKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionControls(
            key: testKey,
            callbacks: (
              onClearSelection: () {},
              onSelectAll: () {},
              onBulkEdit: () {},
              onPrintToPdf: null,
              onExportCsvTxt: null,
              onBulkDuplicate: null,
              onBulkLoan: null,
              onTransferFieldData: null,
              onBulkUpdateValues: null,
              onBulkUpdateKeyInfo: null,
              onBulkMoveToOwned: () {},
              onBulkMoveToWishlist: () {},
              onBulkRemove: () {
                showDialog<void>(
                  context: testKey.currentContext!,
                  builder: (context) => const AlertDialog(
                    content: Text('Remove dialog opened'),
                  ),
                );
              },
              onBulkRefreshMetadata: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Remove'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Remove dialog opened'), findsOneWidget);
  });
}