import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
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

    expect(find.text(r'$'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);

    final currencyField = find.byWidgetPredicate((widget) =>
        widget is DropdownButtonFormField &&
        (widget.decoration as InputDecoration?)?.labelText == 'Currency');
    final fieldWidget =
        tester.widget<DropdownButtonFormField<String>>(currencyField);
    fieldWidget.onChanged?.call('EUR');
    await tester.pumpAndSettle();

    expect(controller.text, 'EUR');
    expect(find.text('€'), findsOneWidget);
  });
}
