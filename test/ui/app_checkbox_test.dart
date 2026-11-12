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
    double progress() => (tester
            .widget<CustomPaint>(find.descendant(
                of: find.byType(AppCheckMark),
                matching: find.byType(CustomPaint)))
            .painter! as dynamic)
        .progress as double;
    await tester.pump(appCheckToggleDuration ~/ 2);
    expect(progress(), inExclusiveRange(0, 1));
    await tester.pump(appCheckToggleDuration);
    expect(progress(), 1.0);
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
    final mark = tester.widget<CustomPaint>(find.descendant(
        of: find.byType(AppCheckMark), matching: find.byType(CustomPaint)));
    expect((mark.painter! as dynamic).progress, 1.0);
  });

  testWidgets('without onChanged the box ignores taps', (tester) async {
    await tester
        .pumpWidget(_host(const AppCheckbox(value: false, onChanged: null)));
    await tester.tap(find.byType(AppCheckbox));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
