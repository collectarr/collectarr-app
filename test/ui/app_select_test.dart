import 'package:collectarr_app/ui/app_select.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('select opens a compact list below the field and picks a value',
      (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
            body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                    width: 200,
                    child: AppSelect<String>(
                        value: null,
                        hint: const Text('Select a list...'),
                        decoration: const InputDecoration(),
                        options: const [('a', 'Alpha'), ('b', 'Beta')],
                        onChanged: (value) => picked = value))))));
    expect(find.text('Select a list...'), findsOneWidget);
    final field = tester.getRect(find.byType(InputDecorator));
    await tester.tap(find.text('Select a list...'));
    await tester.pumpAndSettle();
    final alpha = tester.getRect(find.widgetWithText(MenuItemButton, 'Alpha'));
    final beta = tester.getRect(find.widgetWithText(MenuItemButton, 'Beta'));
    expect(alpha.height, 25);
    expect(beta.top - alpha.top, 25);
    expect(alpha.width, greaterThan(185));
    expect(alpha.top, greaterThanOrEqualTo(field.bottom - 1));
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(picked, 'b');
    expect(find.text('Alpha'), findsNothing);
  });
}
