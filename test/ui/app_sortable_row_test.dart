import 'package:collectarr_app/ui/app_sortable_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _tab(String label) => Container(
      key: ValueKey(label),
      width: 80,
      height: 30,
      color: Colors.blueGrey,
      alignment: Alignment.center,
      child: Text(label),
    );

double _left(WidgetTester tester, String label) =>
    tester.getTopLeft(find.byKey(ValueKey(label)).first).dx;

void main() {
  testWidgets(
      'neighbours jump at once, a dropped tab stays put while the parent '
      'catches up, and the reorder is reported once', (tester) async {
    final reorders = <(int, int)>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 40,
            // The parent never reorders its children, like a slow save.
            child: AppSortableRow(
              onReorder: (from, to) => reorders.add((from, to)),
              children: [_tab('A'), _tab('B'), _tab('C')],
            ),
          ),
        ),
      ),
    ));
    expect([_left(tester, 'A'), _left(tester, 'B'), _left(tester, 'C')],
        [0.0, 80.0, 160.0]);

    final gesture = await tester.startGesture(const Offset(40, 15));
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    // The pointer is over B: B has taken A's slot in the same frame.
    expect(_left(tester, 'B'), 0);

    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    expect(_left(tester, 'C'), 80);

    await gesture.up();
    await tester.pump();
    expect(reorders, [(0, 2)]);
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-settle and after it, the order is still B C A.
    expect(_left(tester, 'B'), 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect([_left(tester, 'B'), _left(tester, 'C'), _left(tester, 'A')],
        [0.0, 80.0, 160.0]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a plain tap is not a drag', (tester) async {
    var taps = 0;
    final reorders = <(int, int)>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: AppSortableRow(
            onReorder: (from, to) => reorders.add((from, to)),
            children: [
              GestureDetector(
                  key: const ValueKey('A'),
                  onTap: () => taps++,
                  child: const ColoredBox(
                      color: Colors.red,
                      child: SizedBox(width: 80, height: 30))),
              _tab('B'),
            ],
          ),
        ),
      ),
    ));
    await tester.tapAt(const Offset(40, 15));
    expect(taps, 1);
    expect(reorders, isEmpty);
  });
}
