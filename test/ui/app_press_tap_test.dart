import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/app_press_tap.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<({int Function() taps, int Function() clicks})> pump(
      WidgetTester tester) async {
    var taps = 0;
    var clicks = 0;
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
            alignment: Alignment.topLeft,
            child: AppPressTap(
                onTap: () => taps++,
                builder: (_, onReleaseTap) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onReleaseTap,
                    child: SizedBox(
                        width: 100,
                        height: 40,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: AppClickTarget(
                                onClick: () => clicks++,
                                builder: (_, __) => const SizedBox(
                                    width: 20, height: 20)))))))));
    return (taps: () => taps, clicks: () => clicks);
  }

  testWidgets('a mouse press taps at once and not again on release',
      (tester) async {
    final r = await pump(tester);
    final gesture = await tester.startGesture(const Offset(5, 20),
        kind: PointerDeviceKind.mouse);
    expect(r.taps(), 1);
    await gesture.up();
    expect(r.taps(), 1);
  });

  testWidgets('a touch tap taps on release', (tester) async {
    final r = await pump(tester);
    final gesture = await tester.startGesture(const Offset(5, 20));
    expect(r.taps(), 0);
    await gesture.up();
    expect(r.taps(), 1);
  });

  testWidgets('a nested click target keeps the press to itself',
      (tester) async {
    final r = await pump(tester);
    final gesture = await tester.startGesture(const Offset(90, 20),
        kind: PointerDeviceKind.mouse);
    await gesture.up();
    expect(r.clicks(), 1);
    expect(r.taps(), 0);
  });
}
