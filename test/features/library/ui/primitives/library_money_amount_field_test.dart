import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppFormats.current = const AppFormats());

  Future<void> pumpField(WidgetTester tester, String currency) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LibraryMoneyAmountField(
            label: 'Purchase Price',
            amountMinorUnits: 3400,
            currency: currency,
            onChanged: (_) {},
          ),
        ),
      ));

  testWidgets('the price field names its currency as prices do',
      (tester) async {
    // As in the reference's editor: the Currency display label inside the
    // field, before the amount.
    for (final (display, currency, label) in [
      (CurrencyDisplay.regional, 'USD', r'US$ '),
      (CurrencyDisplay.regional, 'DKK', 'kr. '),
      (CurrencyDisplay.symbol, 'SEK', 'kr '),
      (CurrencyDisplay.code, 'HUF', 'HUF Ft '),
    ]) {
      AppFormats.current = AppFormats(currencyDisplay: display);
      await pumpField(tester, currency);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.prefixText, label, reason: '$currency $display');
      expect(find.text('34.00'), findsOneWidget);
    }
  });
}
