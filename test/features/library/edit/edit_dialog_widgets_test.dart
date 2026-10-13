import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'text, numeric, date and vocabulary controls share their border height',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
        theme: editDialogTheme(compactDesktop: true),
        home: Material(
            child: Column(children: [
          const LibraryTextFormControl(initialValue: 'Name'),
          const LibraryTextFormControl(
              initialValue: '1', keyboardType: TextInputType.number),
          LibraryPartialDateInput(onChanged: (_) {}),
          SingleValuePickField(
              controller: controller,
              options: const ['Studio'],
              label: 'Location',
              showInlineLabel: false),
        ]))));
    final heights = [
      for (final element in find.byType(InputDecorator).evaluate())
        tester
            .getSize(find.byElementPredicate(
                (candidate) => identical(element, candidate)))
            .height
    ];
    expect(heights, hasLength(6));
    expect(
        heights.every((height) => (height - heights.first).abs() <= 1), isTrue,
        reason: '$heights');
    expect(heights.first, greaterThanOrEqualTo(34));
    expect(tester.takeException(), isNull);
  });

  testWidgets('currency field shows symbol and updates the controller',
      (tester) async {
    final controller = TextEditingController(text: 'USD');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SizedBox(
            width: 260,
            child: LibraryCurrencyField(controller: controller),
          ),
        ),
      ),
    );

    expect(find.text(r'$ USD'), findsOneWidget);

    final pickField = find.byType(SingleValuePickField);
    expect(pickField, findsOneWidget);
    final fieldWidget = tester.widget<SingleValuePickField>(pickField);
    fieldWidget.onChanged?.call('€ EUR');
    await tester.pumpAndSettle();

    expect(controller.text, 'EUR');
    expect(find.text('€ EUR'), findsOneWidget);
  });
}
