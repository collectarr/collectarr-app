import 'package:collectarr_app/ui/theme/app_typography.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/shell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings options are bold while the closed field stays normal',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppShellTheme(),
      home: Scaffold(
          body: SizedBox(
              width: 300,
              child: SettingsSelect<String>(
                value: 'Dark',
                values: const ['Default', 'Light', 'Dark', 'Blue'],
                labelOf: (value) => value,
                onChanged: (_) {},
              ))),
    ));
    final field = find.byType(InputDecorator);
    expect(tester.widget<Text>(find.text('Dark')).style!.fontWeight,
        kAppNormalFontWeight);
    final height = tester.getSize(field).height;
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    final options = find.descendant(
        of: find.byType(MenuItemButton), matching: find.byType(Text));
    expect(options, findsNWidgets(4));
    for (final text in tester.widgetList<Text>(options)) {
      expect(text.style!.fontWeight, kAppBoldFontWeight);
      expect(text.style!.fontSize, kAppBodyFontSize);
    }
    expect(tester.getSize(field).height, height);
    expect(
        tester
            .widget<Text>(
                find.descendant(of: field, matching: find.text('Dark')))
            .style!
            .fontWeight,
        kAppNormalFontWeight);
    await tester.tap(find.widgetWithText(MenuItemButton, 'Light'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNothing);
  });

  testWidgets('a settings select is 34 px tall on every platform',
      variant: TargetPlatformVariant.all(), (tester) async {
    await tester.pumpWidget(MaterialApp(
      // Each platform's default density: compact on desktop, standard on
      // mobile.
      theme: buildAppShellTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: SettingsSelect<String>(
              value: 'USD',
              values: const ['USD', 'EUR'],
              labelOf: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ));

    // The outline is drawn around the decorator's content, so the content
    // itself must make the 34 px.
    final decoration =
        tester.renderObject<RenderBox>(find.byType(InputDecorator));
    expect(decoration.size.height, 34);
    RenderBox? content;
    decoration.visitChildren((child) {
      child.visitChildren((inner) {
        if (inner is RenderBox && inner.size.width == decoration.size.width) {
          content = inner;
        }
      });
    });
    expect(content?.size.height, 34);
  });
}
