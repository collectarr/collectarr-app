import 'package:collectarr_app/ui/app_message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<bool?> open(WidgetTester tester, String button) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showAppMessageDialog(
              context: context,
              title: 'Export to XML',
              message: 'Click Export below to start exporting your data to XML',
              confirmLabel: 'Export'),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Export to XML'), findsOneWidget);
    expect(find.text('Click Export below to start exporting your data to XML'),
        findsOneWidget);
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('the confirming action resolves true', (tester) async {
    expect(await open(tester, 'Export'), isTrue);
  });

  testWidgets('Cancel resolves false', (tester) async {
    expect(await open(tester, 'Cancel'), isFalse);
  });
}
