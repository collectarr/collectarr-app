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
              onBulkMoveToEntry: () {},
              onBulkMoveToWishlist: () {},
              onExportXml: null,
              onMerge: null,
              onMoveToCollection: null,
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
  testWidgets(
      'selection More refreshes merge eligibility and dispatches after closing',
      (tester) async {
    var allowsMerge = false;
    await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
                    body: Column(children: [
                  TextButton(
                      onPressed: () => setState(() => allowsMerge = true),
                      child: const Text('Select another album')),
                  SizedBox(
                      height: 32,
                      child: LibrarySelectionControls(
                          onAccent: true,
                          accent: Colors.orange,
                          callbacks: (
                            onClearSelection: () {},
                            onSelectAll: () {},
                            onBulkEdit: null,
                            onPrintToPdf: null,
                            onExportCsvTxt: null,
                            onExportXml: null,
                            onMerge: allowsMerge
                                ? () => showDialog<void>(
                                    context: context,
                                    builder: (_) => const AlertDialog(
                                        content: Text('Merge dialog opened')))
                                : null,
                            onBulkDuplicate: null,
                            onBulkLoan: null,
                            onTransferFieldData: null,
                            onBulkUpdateValues: null,
                            onBulkUpdateKeyInfo: null,
                            onBulkMoveToEntry: null,
                            onBulkMoveToWishlist: null,
                            onMoveToCollection: null,
                            onBulkRemove: null,
                            onBulkRefreshMetadata: null,
                          ))),
                ])))));
    final item = find.ancestor(
        of: find.text('Merge Albums'),
        matching: find.byWidgetPredicate((widget) => widget is PopupMenuItem));
    await tester.tap(find.byTooltip('More selection actions'));
    await tester.pumpAndSettle();
    expect(tester.widget<PopupMenuItem<dynamic>>(item).enabled, isFalse);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select another album'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More selection actions'));
    await tester.pumpAndSettle();
    expect(tester.widget<PopupMenuItem<dynamic>>(item).enabled, isTrue);
    await tester.tap(find.text('Merge Albums'));
    await tester.pumpAndSettle();
    expect(find.text('Merge dialog opened'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
