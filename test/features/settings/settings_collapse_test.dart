import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(bool expanded, {bool disableAnimations = false}) => MaterialApp(
    home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
            body: Align(
                alignment: Alignment.topLeft,
                child: SettingsCollapse(
                    expanded: expanded,
                    child: const SizedBox(
                        width: 200, height: 100, child: TextField()))))));

void main() {
  testWidgets('folding eases the height away and takes the options out',
      (tester) async {
    await tester.pumpWidget(_host(true));
    final collapse = find.byType(SettingsCollapse);
    expect(tester.getSize(collapse).height, 100);

    await tester.pumpWidget(_host(false));
    await tester.pump(const Duration(milliseconds: 125));
    expect(tester.getSize(collapse).height, inExclusiveRange(0, 100));
    await tester.pumpAndSettle();
    expect(tester.getSize(collapse).height, 0);
    expect(
        tester.widget<ExcludeFocus>(find.byType(ExcludeFocus).last).excluding,
        isTrue);

    await tester.pumpWidget(_host(true));
    await tester.pumpAndSettle();
    expect(tester.getSize(collapse).height, 100);
  });

  testWidgets('without animations the options fold at once', (tester) async {
    await tester.pumpWidget(_host(true, disableAnimations: true));
    await tester.pumpWidget(_host(false, disableAnimations: true));
    await tester.pump();
    expect(tester.getSize(find.byType(SettingsCollapse)).height, 0);
  });
}
