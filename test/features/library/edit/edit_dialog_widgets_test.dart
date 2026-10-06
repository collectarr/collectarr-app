import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
