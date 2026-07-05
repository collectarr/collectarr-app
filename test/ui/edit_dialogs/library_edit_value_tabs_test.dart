import 'package:collectarr_app/features/library/edit/library_edit_value_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildResponsiveFields(List<Widget> children) =>
      Wrap(children: children);

  Widget buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget buildDatePickerField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Text(label);
  }

  testWidgets('value tab renders purchase and value summary sections', (
    tester,
  ) async {
    final priceController = TextEditingController(text: '12.50');
    final currencyController = TextEditingController(text: 'USD');
    final purchaseDateController = TextEditingController(text: '2024-01-02');
    final purchaseStoreController = TextEditingController(text: 'Shop');
    final marketValueController = TextEditingController(text: '20.00');
    final sellPriceController = TextEditingController(text: '25.00');

    addTearDown(priceController.dispose);
    addTearDown(currencyController.dispose);
    addTearDown(purchaseDateController.dispose);
    addTearDown(purchaseStoreController.dispose);
    addTearDown(marketValueController.dispose);
    addTearDown(sellPriceController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryEditValueTab(
            accent: Colors.blue,
            buildResponsiveFields: buildResponsiveFields,
            buildField: buildField,
            buildDatePickerField: buildDatePickerField,
            priceController: priceController,
            currencyController: currencyController,
            purchaseDateController: purchaseDateController,
            purchaseStoreController: purchaseStoreController,
            marketValueController: marketValueController,
            sellPriceController: sellPriceController,
            onPickPurchaseDate: () {},
            lastBagBoardDate: null,
            onLastBagBoardDateChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Price paid'), findsOneWidget);
    expect(find.text('Last bag & board date'), findsOneWidget);
    expect(find.text('Manual estimate: '), findsOneWidget);
    expect(find.text('Insurance: '), findsOneWidget);
    expect(find.text('Purchase date: 2024-01-02'), findsOneWidget);
    expect(find.text('USD 12.50'), findsOneWidget);
    expect(find.text('USD 25.00'), findsOneWidget);
    expect(find.text('USD 20.00'), findsWidgets);
  });

  testWidgets('sold tab renders sold summary when sold date exists', (
    tester,
  ) async {
    final sellPriceController = TextEditingController(text: '25.00');
    final soldToController = TextEditingController(text: 'Alex');
    final priceController = TextEditingController(text: '12.50');
    final currencyController = TextEditingController(text: 'USD');

    addTearDown(sellPriceController.dispose);
    addTearDown(soldToController.dispose);
    addTearDown(priceController.dispose);
    addTearDown(currencyController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildLibraryEditSoldTab(
              context: context,
              accent: Colors.blue,
              buildResponsiveFields: buildResponsiveFields,
              buildField: buildField,
              soldAt: DateTime(2024, 1, 2),
              onSoldChanged: (_) {},
              onPickSoldDate: () {},
              sellPriceController: sellPriceController,
              soldToController: soldToController,
              priceController: priceController,
              currencyController: currencyController,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mark as sold'), findsOneWidget);
    expect(find.text('Paid: '), findsOneWidget);
    expect(find.text('Sold for: '), findsOneWidget);
    expect(find.text('+\$12.50'), findsOneWidget);
    expect(find.textContaining('Sold on 2024-01-02'), findsOneWidget);
  });
}
