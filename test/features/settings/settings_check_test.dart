import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final disabledAnimations in [false, true]) {
    testWidgets(
        'settings checking and unchecking respects disabledAnimations=$disabledAnimations',
        (tester) async {
      var value = false;
      await tester.pumpWidget(MaterialApp(
        theme: buildAppShellTheme(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disabledAnimations),
          child: Scaffold(
              body: StatefulBuilder(
            builder: (context, setState) => SettingsCheck(
                label: 'Setting',
                value: value,
                onChanged: (next) => setState(() => value = next)),
          )),
        ),
      ));
      for (final expected in [true, false]) {
        await tester.tap(find.text('Setting'));
        await tester.pump();
        expect(value, expected);
        expect(tester.widget<AppCheckMark>(find.byType(AppCheckMark)).value,
            expected);
        final tween = tester.widget<TweenAnimationBuilder<double>>(
            find.descendant(
                of: find.byType(AppCheckMark),
                matching: find.byType(TweenAnimationBuilder<double>)));
        expect(tween.duration,
            disabledAnimations ? Duration.zero : appCheckToggleDuration);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(AppCheckMark)), const Size(13, 13));
        expect(tester.getSize(find.byType(SettingsCheck)).height, 25);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disabled settings checks retain their value', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: buildAppShellTheme(),
        home: const Scaffold(
            body: SettingsCheck(
                label: 'Disabled', value: true, onChanged: null))));
    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<AppCheckMark>(find.byType(AppCheckMark)).value, isTrue);
    expect(tester.takeException(), isNull);
  });
}
