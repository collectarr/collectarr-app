import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<int Function()> pump(WidgetTester tester) async {
    var clicks = 0;
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
            alignment: Alignment.topLeft,
            child: AppClickTarget(
                onClick: () => clicks++,
                builder: (_, __) => const SizedBox(
                    key: Key('target'), width: 80, height: 30)))));
    return () => clicks;
  }

  testWidgets('clicks on press, even if the pointer then leaves the target',
      (tester) async {
    final clicks = await pump(tester);
    final gesture = await tester.startGesture(const Offset(5, 15),
        kind: PointerDeviceKind.mouse);
    expect(clicks(), 1);
    await gesture.moveTo(const Offset(200, 15));
    await gesture.up();
    expect(clicks(), 1);
  });
}
