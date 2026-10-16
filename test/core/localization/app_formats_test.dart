import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dates follow the chosen display format', () {
    final day = DateTime(2026, 8, 31);
    expect(const AppFormats().formatDate(day), 'Aug 31, 2026');
    for (final format in DateDisplayFormat.values) {
      expect(AppFormats(date: format).formatDate(day), format.example);
    }
  });

  test('partial dates show only what is known', () {
    const formats = AppFormats(date: DateDisplayFormat.europeanNumeric);
    expect(formats.formatPartialDate(const PartialDate(year: 2014)), '2014');
    expect(formats.formatPartialDate(const PartialDate(year: 2014, month: 3)),
        '03/2014');
    expect(
        formats.formatPartialDate(
            const PartialDate(year: 2014, month: 3, day: 5)),
        '05/03/2014');
    expect(formats.formatPartialDate(null), '');
  });

  test('numbers and prices follow the number and currency formats', () {
    for (final style in NumberFormatStyle.values) {
      expect(AppFormats(number: style).formatNumber(1234567.89, decimals: 2),
          style.example);
    }
    expect(const AppFormats().formatMoney(1250, 'usd'), 'USD 12.50');
    expect(
        const AppFormats(
                currencyDisplay: CurrencyDisplay.symbol,
                number: NumberFormatStyle.dotGroups)
            .formatMoney(-123456, 'EUR'),
        '-€1.234,56');
    expect(const AppFormats().formatMoney(null, 'USD'), '');
  });
}
