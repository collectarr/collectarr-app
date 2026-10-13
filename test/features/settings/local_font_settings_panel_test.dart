import 'package:collectarr_app/core/fonts/local_font_controller.dart';
import 'package:collectarr_app/features/settings/local_font_settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
      'unsupported discovery retains manual import and local enable toggle',
      (tester) async {
    final c =
        LocalFontController(registerFont: (_, __) async {}, canDiscover: false);
    await c.initialize(discover: false);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: LocalFontSettingsPanel(controller: c))));
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Use installed Gilroy'))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Import local fonts'))
            .onPressed,
        isNotNull);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(c.enabled, false);
    expect(find.text('Active font: Plus Jakarta Sans'), findsOneWidget);
    expect(tester.takeException(), isNull);
    c.dispose();
  });
  testWidgets('permission denial is visible without losing controls',
      (tester) async {
    final c = LocalFontController(
        registerFont: (_, __) async {},
        canDiscover: true,
        discoverFonts: () async =>
            throw const FormatException('Permission denied'));
    await c.initialize(discover: false);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: LocalFontSettingsPanel(controller: c))));
    await tester.tap(find.text('Use installed Gilroy'));
    await tester.pumpAndSettle();
    expect(find.text('Permission denied'), findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Import local fonts'))
            .onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
    c.dispose();
  });
}
