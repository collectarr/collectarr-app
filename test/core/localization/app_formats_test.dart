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
        formats
            .formatPartialDate(const PartialDate(year: 2014, month: 3, day: 5)),
        '05/03/2014');
    expect(formats.formatPartialDate(null), '');
  });

  test('numbers and prices follow the number and currency formats', () {
    for (final style in NumberFormatStyle.values) {
      expect(AppFormats(number: style).formatNumber(1234567.89, decimals: 2),
          style.example);
    }
    // The reference's default for USD is the regional symbol, followed by a
    // space and the amount.
    expect(const AppFormats().formatMoney(1250, 'usd'), r'US$ 12.50');
    expect(
        const AppFormats(
                currencyDisplay: CurrencyDisplay.symbol,
                number: NumberFormatStyle.dotGroups)
            .formatMoney(-123456, 'EUR'),
        '-€ 1.234,56');
    expect(const AppFormats().formatMoney(null, 'USD'), '');
  });

  test('currency display choices follow the reference for each currency', () {
    // Recorded from the reference's Settings > Currency display (2026-10-26).
    const reference = {
      'USD': [r'$', r'US$', 'USD'],
      'EUR': ['€', 'EUR'],
      'GBP': ['£', 'GBP'],
      'CAD': [r'$', r'CA$', 'CAD'],
      'AUD': [r'$', r'AU$', 'AUD'],
      'NZD': [r'$', r'NZ$', 'NZD'],
      'NOK': ['kr', 'NOK'],
      'SEK': ['kr', 'SEK'],
      'DKK': ['kr.', 'DKK'],
      'CHF': ['fr.', 'CHF'],
      'ZAR': ['R', 'ZA R', 'ZAR R'],
      'BRL': [r'R$', r'BR R$', r'BRL R$'],
      'RUB': ['₽', 'RU ₽', 'RUB ₽'],
      'PLN': ['zł', 'PL zł', 'PLN zł'],
      'INR': ['₹', 'IN ₹', 'INR ₹'],
      'CZK': ['Kč', 'CZ Kč', 'CZK Kč'],
      'SGD': [r'S$', r'SG S$', r'SGD S$'],
      'JPY': ['¥', 'JP ¥', 'JPY ¥'],
      'HUF': ['Ft', 'HU Ft', 'HUF Ft'],
    };
    for (final MapEntry(key: code, value: labels) in reference.entries) {
      expect([
        for (final display in currencyDisplaysFor(code))
          currencyLabel(code, display),
      ], labels, reason: code);
      expect(
          defaultCurrencyDisplay(code),
          labels.length == 3
              ? CurrencyDisplay.regional
              : CurrencyDisplay.symbol,
          reason: code);
    }
    expect(kCurrencyCodes.take(reference.length), reference.keys);
  });

  test('a price in a currency without a regional symbol uses its symbol', () {
    expect(
        const AppFormats(currencyDisplay: CurrencyDisplay.regional)
            .formatMoney(3400, 'DKK'),
        'kr. 34.00');
    expect(
        const AppFormats(currencyDisplay: CurrencyDisplay.code)
            .formatMoney(1569, 'HUF'),
        'HUF Ft 15.69');
  });
}
