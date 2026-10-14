import 'package:collectarr_app/features/library/add/panes/library_add_status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status choices do not add; prefill opens after menu dismisses',
      (tester) async {
    var status = LibraryCollectionStatusScope.inCollection;
    var added = false;
    var prefill = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: StatefulBuilder(
          builder: (context, setState) => LibraryAddStatusButton(
                collectionStatus: status,
                onAdd: () => added = true,
                onStatusChanged: (value) => setState(() => status = value),
                onPrefillSettings: () => prefill = true,
              )),
    )));
    await tester.tap(find.byTooltip('Choose collection status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('For Sale'));
    await tester.pumpAndSettle();
    expect(find.text('Add as For Sale'), findsOneWidget);
    expect(added, isFalse);
    await tester.tap(find.byTooltip('Choose collection status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pre-fill Settings'));
    await tester.pumpAndSettle();
    expect(prefill, isTrue);
    expect(added, isFalse);
    expect(status, LibraryCollectionStatusScope.forSale);
  });
}
