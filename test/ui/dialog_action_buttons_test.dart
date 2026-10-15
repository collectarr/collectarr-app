import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('panel footer keeps measured action geometry and neutral Cancel',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
            body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                    width: 600,
                    child: DialogActionFooter(actions: [
                      DialogActionButton(label: 'Cancel', onPressed: () {}),
                      DialogActionButton(
                          label: 'OK', primary: true, onPressed: () {}),
                    ]))))));
    final cancel = find.widgetWithText(FilledButton, 'Cancel');
    final ok = find.widgetWithText(FilledButton, 'OK');
    expect(tester.getSize(cancel), const Size(100, 32));
    expect(tester.getSize(ok), const Size(100, 32));
    expect(tester.getTopLeft(ok).dx - tester.getTopRight(cancel).dx, 5);
    expect(tester.getSize(find.byType(DialogActionFooter)).height, 53);
    expect(
        tester.widget<FilledButton>(cancel).style!.backgroundColor!.resolve({}),
        const Color(0xff494949));
    expect(tester.widget<FilledButton>(ok).style!.backgroundColor!.resolve({}),
        const Color(0xff5eb1de));
    expect(tester.takeException(), isNull);
  });
}
