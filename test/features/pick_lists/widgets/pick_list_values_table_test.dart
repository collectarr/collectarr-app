import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_values_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PickListValue value(String name) => PickListValue(
      id: name.toLowerCase(), listName: 'game.format', value: name);

  Future<void> pump(WidgetTester tester, PickListTableMode mode) =>
      tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: PickListValuesTable(
                  values: [value('Alpha'), value('Zeta')],
                  usageCounts: const {},
                  mode: mode,
                  selectedIds: const {'zeta'}))));

  double top(WidgetTester tester, String name) =>
      tester.getTopLeft(find.text(name).first).dy;

  testWidgets('a single choice lists the current value first', (tester) async {
    await pump(tester, PickListTableMode.singleSelect);
    expect(top(tester, 'Zeta'), lessThan(top(tester, 'Alpha')));
  });

  testWidgets('lists with images add an Image column', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PickListValuesTable(
                values: [value('Alpha')],
                usageCounts: const {},
                mode: PickListTableMode.singleSelect,
                imageCell: (value) => Text('image of ${value.value}')))));

    expect(find.text('Image'), findsOneWidget);
    expect(find.text('image of Alpha'), findsOneWidget);
  });

  testWidgets('a multiple choice keeps the sort order', (tester) async {
    await pump(tester, PickListTableMode.multiSelect);
    expect(top(tester, 'Alpha'), lessThan(top(tester, 'Zeta')));
  });
}
