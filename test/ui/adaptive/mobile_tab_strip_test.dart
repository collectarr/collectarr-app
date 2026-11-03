import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final compact in [true, false]) {
    testWidgets('mobile tab hit area is at least 48 dp (compact: $compact)',
        (tester) async {
      var selected = 'first';
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: StatefulBuilder(
        builder: (context, update) => MobileTabStrip<String>(
          compact: compact,
          color: Colors.blue,
          tabs: const [
            (value: 'first', label: 'First'),
            (value: 'second', label: 'Second')
          ],
          selected: selected,
          onSelected: (value) => update(() => selected = value),
        ),
      ))));
      final target = find
          .ancestor(of: find.text('Second'), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
      await tester.tapAt(tester.getTopLeft(target) + const Offset(5, 2));
      await tester.pump();
      expect(selected, 'second');
    });
  }
}
