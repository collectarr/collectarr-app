import 'package:collectarr_app/features/library/add/panes/library_add_confirm_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<int Function()> pumpSheet(WidgetTester tester) async {
    var dismissed = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LibraryAddConfirmSheet(
          accent: Colors.orange,
          onDismiss: () => dismissed++,
          content: const Text('Album'),
          footer: const SizedBox(height: 40, child: Text('Add to Collection')),
        ),
      ),
    ));
    return () => dismissed;
  }

  testWidgets('shows the selection under a reference-style header',
      (tester) async {
    await pumpSheet(tester);
    expect(find.text('Confirm your selection'), findsOneWidget);
    expect(find.text('Album'), findsOneWidget);
    expect(find.text('Add to Collection'), findsOneWidget);
  });

  testWidgets('the backdrop and Escape close the sheet', (tester) async {
    final dismissed = await pumpSheet(tester);
    await tester.tapAt(const Offset(400, 20));
    expect(dismissed(), 1);
    await tester.tap(find.text('Album'));
    expect(dismissed(), 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(dismissed(), 2);
  });

  testWidgets('a fixed-size sheet is centred at the bottom', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 900,
          child: LibraryAddConfirmSheet(
            accent: Colors.red,
            size: const Size(730, 369),
            onDismiss: () {},
            content: const Text('Game'),
            footer: const SizedBox(height: 54),
          ),
        ),
      ),
    ));
    final sheet =
        tester.getRect(find.byKey(const ValueKey('library-add-confirm-sheet')));
    expect(sheet.width, 730);
    expect(sheet.height, 369);
    expect(sheet.left, 235);
    expect(sheet.bottom, 900);
  });
}
