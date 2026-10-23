import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'AppZoomWrapper fills parent window on zoom out and reset without shrinking',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: AppZoomWrapper(
          child: Container(
            key: const ValueKey('inner_container'),
            color: Colors.blue,
          ),
        ),
      ),
    );

    // Initial scale 1.0: inner container is 1920 x 1080
    expect(tester.getSize(find.byKey(const ValueKey('inner_container'))),
        const Size(1920, 1080));

    // Simulate 3x zoom out to 70% (like in user screenshot)
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.minus);
    await tester.sendKeyEvent(LogicalKeyboardKey.minus);
    await tester.sendKeyEvent(LogicalKeyboardKey.minus);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    // Scale is now 0.70 -> inner container fills full scaled viewport
    final innerSize =
        tester.getSize(find.byKey(const ValueKey('inner_container')));
    expect(innerSize.width, closeTo(1920 / 0.7, 0.1));
    expect(innerSize.height, closeTo(1080 / 0.7, 0.1));
    expect(find.text('70%'), findsOneWidget);

    // Reset with Ctrl + 0
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    // Reset scale is 1.0 -> 1920 x 1080
    final resetSize =
        tester.getSize(find.byKey(const ValueKey('inner_container')));
    expect(resetSize, const Size(1920, 1080));
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Ctrl + wheel zooms over a scrollable instead of scrolling it',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: AppZoomWrapper(
        child: ListView.builder(
          controller: controller,
          itemCount: 100,
          itemBuilder: (_, index) =>
              SizedBox(height: 40, child: Text('$index')),
        ),
      ),
    ));

    final center = tester.getCenter(find.byType(ListView));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendEventToBinding(PointerScrollEvent(
        position: center, scrollDelta: const Offset(0, -100)));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(find.text('105%'), findsOneWidget);
    expect(controller.offset, 0);

    await tester.sendEventToBinding(PointerScrollEvent(
        position: center, scrollDelta: const Offset(0, 100)));
    await tester.pump();
    expect(controller.offset, greaterThan(0));
  });

  testWidgets('the Web Ctrl + wheel scale signal zooms in and out',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
        const MaterialApp(home: AppZoomWrapper(child: SizedBox.expand())));

    // Flutter Web sends Ctrl + wheel as a scale signal, not a scroll.
    const center = Offset(400, 300);
    await tester.sendEventToBinding(
        const PointerScaleEvent(position: center, scale: 1.65));
    await tester.pump();
    expect(find.text('105%'), findsOneWidget);

    await tester.sendEventToBinding(
        const PointerScaleEvent(position: center, scale: 0.6));
    await tester.sendEventToBinding(
        const PointerScaleEvent(position: center, scale: 0.6));
    await tester.pump();
    expect(find.text('95%'), findsOneWidget);
  });
}
