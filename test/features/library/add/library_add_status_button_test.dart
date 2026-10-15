import 'package:collectarr_app/features/library/add/panes/library_add_status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

void main() {
  testWidgets('Add action follows each destination status color',
      (tester) async {
    for (final (status, color) in [
      (LibraryCollectionStatusScope.inCollection, const Color(0xff2aa4cc)),
      (LibraryCollectionStatusScope.forSale, const Color(0xff2d7427)),
      (LibraryCollectionStatusScope.wishList, const Color(0xffff9b00)),
      (LibraryCollectionStatusScope.onOrder, const Color(0xff13627f)),
      (LibraryCollectionStatusScope.sold, const Color(0xffa63131)),
      (LibraryCollectionStatusScope.notInCollection, const Color(0xff605c5c)),
    ]) {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: LibraryAccentScope(
        kind: 'music',
        accent: Colors.orange,
        animationsEnabled: false,
        child: LibraryAddStatusButton(
            collectionStatus: status, onAdd: () {}, onStatusChanged: (_) {}),
      ))));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.style!.backgroundColor!.resolve({}), color);
      expect(button.style!.backgroundColor!.resolve({WidgetState.disabled}),
          color.withValues(alpha: 0.55));
    }
  });
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
