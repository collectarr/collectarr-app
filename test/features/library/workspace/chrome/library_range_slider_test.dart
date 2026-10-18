import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the whole slider box takes presses, including the thumb ends',
      (tester) async {
    var value = 4.0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 38,
            width: 100,
            child: StatefulBuilder(
              builder: (context, setState) => LibraryRangeSlider(
                  value: value,
                  min: 4,
                  max: 24,
                  onChanged: (next) => setState(() => value = next)),
            ),
          ),
        ),
      ),
    ));

    final box = tester.getRect(find.byType(Slider));
    for (var dx = 1.0; dx < box.width; dx += 3) {
      final hit = tester.hitTestOnBinding(Offset(box.left + dx, box.center.dy));
      expect(
          hit.path.any((entry) =>
              entry.target is RenderBox &&
              entry.target.runtimeType.toString() == '_RenderSlider'),
          isTrue,
          reason: 'x=$dx is outside the slider');
    }

    // A press on the outer half of the thumb at the minimum grabs it.
    final thumbCenter = box.left + 11;
    final gesture =
        await tester.startGesture(Offset(thumbCenter - 6, box.center.dy));
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(30, 0));
    await gesture.up();
    await tester.pump();
    expect(value, greaterThan(10));
  });
}
