import 'package:collectarr_app/ui/app_reorderable_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final zoom in [1.0, 1.5, 0.75]) {
    testWidgets('a dragged child stays under the pointer at ${zoom}x zoom',
        (tester) async {
      await tester.pumpWidget(_Harness(zoom: zoom));

      Offset centerOf(String label) => tester.getCenter(find.text(label));
      final gesture = await tester.startGesture(centerOf('Gamma'));
      final grab = centerOf('Gamma');
      final target = centerOf('Alpha') + Offset(10 * zoom, 0);
      for (var step = 1; step <= 6; step++) {
        final pointer = Offset.lerp(grab, target, step / 6)!;
        await gesture.moveTo(pointer);
        await tester.pump(const Duration(milliseconds: 50));
        expect(centerOf('Gamma').dx, moreOrLessEquals(pointer.dx, epsilon: 1));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      final state = tester.state<_HarnessState>(find.byType(_Harness));
      expect(state.labels, ['Gamma', 'Alpha', 'Beta']);
    });
  }

  testWidgets('a tap selects without reordering', (tester) async {
    await tester.pumpWidget(const _Harness(zoom: 1));

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    final state = tester.state<_HarnessState>(find.byType(_Harness));
    expect(state.tapped, 'Beta');
    expect(state.labels, ['Alpha', 'Beta', 'Gamma']);
  });
}

class _Harness extends StatefulWidget {
  const _Harness({required this.zoom});

  final double zoom;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final labels = ['Alpha', 'Beta', 'Gamma'];
  String? tapped;

  @override
  Widget build(BuildContext context) {
    // Scales the whole app like AppZoomWrapper, overlay included.
    return MaterialApp(
      builder: (context, child) => Transform.scale(
        scale: widget.zoom,
        alignment: Alignment.topLeft,
        child: child,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 600,
            height: 32,
            child: AppReorderableRow(
              onReorderItem: (oldIndex, newIndex) => setState(() {
                labels.insert(newIndex, labels.removeAt(oldIndex));
              }),
              children: [
                for (final label in labels)
                  GestureDetector(
                    key: ValueKey(label),
                    onTap: () => tapped = label,
                    child: SizedBox(
                      width: 100,
                      child: Center(child: Text(label)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
