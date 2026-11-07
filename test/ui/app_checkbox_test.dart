import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
    home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child))));

void main() {
  testWidgets('tapping toggles the value and the tick draws in',
      (tester) async {
    var value = false;
    await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) => _host(AppCheckbox(
            value: value, onChanged: (next) => setState(() => value = next)))));

    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();
    expect(value, isTrue);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(appCheckToggleDuration);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the tick appears at once when animations are off',
      (tester) async {
    var value = false;
    await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) => _host(
            AppCheckboxTile(
                label: 'Consoles',
                value: value,
                onChanged: (next) => setState(() => value = next)),
            disableAnimations: true)));

    await tester.tap(find.text('Consoles'));
    await tester.pump();
    expect(value, isTrue);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('without onChanged the box ignores taps', (tester) async {
    await tester.pumpWidget(
        _host(const AppCheckbox(value: false, onChanged: null)));
    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
