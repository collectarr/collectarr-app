/// Display formats chosen in Settings > Localization.
///
/// Like `Intl.defaultLocale`, the active formats are app-wide: the root
/// widget installs them from the preferences, and synchronous formatters
/// across the app read [AppFormats.current].
library;

import 'package:collectarr_app/core/models/partial_date.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int value) => value.toString().padLeft(2, '0');

enum DateDisplayFormat {
  monthDayYear('Aug 31, 2026'),
  dayMonthYear('31 Aug 2026'),
  iso('2026-08-31'),
  usNumeric('08/31/2026'),
  europeanNumeric('31/08/2026'),
  dotted('31.08.2026');

  const DateDisplayFormat(this.example);

  /// The format shown on 31 August 2026.
  final String example;

  String format(int year, int month, int day) => switch (this) {
        monthDayYear => '${_monthNames[month - 1]} ${_two(day)}, $year',
        dayMonthYear => '${_two(day)} ${_monthNames[month - 1]} $year',
        iso => '$year-${_two(month)}-${_two(day)}',
        usNumeric => '${_two(month)}/${_two(day)}/$year',
        europeanNumeric => '${_two(day)}/${_two(month)}/$year',
        dotted => '${_two(day)}.${_two(month)}.$year',
      };

  String formatYearMonth(int year, int month) => switch (this) {
        iso => '$year-${_two(month)}',
        usNumeric => '${_two(month)}/$year',
        europeanNumeric => '${_two(month)}/$year',
        dotted => '${_two(month)}.$year',
        monthDayYear || dayMonthYear => '${_monthNames[month - 1]} $year',
      };
}

/// Order of the year, month and day boxes when entering a date.
enum DateEntryOrder {
  yearMonthDay('YYYY-MM-DD'),
  dayMonthYear('DD-MM-YYYY'),
  monthDayYear('MM-DD-YYYY');

  const DateEntryOrder(this.label);

  final String label;
}

enum NumberFormatStyle {
  plain('1234567.89', '', '.'),
  commaGroups('1,234,567.89', ',', '.'),
  dotGroups('1.234.567,89', '.', ','),
  spaceGroups('1 234 567,89', ' ', ',');

  const NumberFormatStyle(this.example, this.groupSeparator, this.decimal);

  final String example;
  final String groupSeparator;
  final String decimal;
}

/// How a price names its currency, as in the reference's Currency display.
enum CurrencyDisplay {
  /// The local symbol: `$`, `€`, `kr`.
  symbol,

  /// The symbol with its country: `US$`, `JP ¥`. Not every currency has one.
  regional,

  /// The ISO code, with the symbol where the reference adds it: `USD`,
  /// `HUF Ft`.
  code,
}

/// The reference's labels for one currency.
final class _CurrencyLabels {
  const _CurrencyLabels(this.symbol, {this.regional, String? code})
      : _code = code;

  final String symbol;
  final String? regional;
  final String? _code;
}

/// Currencies in the reference's order, followed by those Collectarr adds.
/// Symbols, regional symbols and codes follow the reference's Currency
/// display options for each currency.
const Map<String, _CurrencyLabels> _currencies = {
  'USD': _CurrencyLabels(r'$', regional: r'US$'),
  'EUR': _CurrencyLabels('€'),
  'GBP': _CurrencyLabels('£'),
  'CAD': _CurrencyLabels(r'$', regional: r'CA$'),
  'AUD': _CurrencyLabels(r'$', regional: r'AU$'),
  'NZD': _CurrencyLabels(r'$', regional: r'NZ$'),
  'NOK': _CurrencyLabels('kr'),
  'SEK': _CurrencyLabels('kr'),
  'DKK': _CurrencyLabels('kr.'),
  'CHF': _CurrencyLabels('fr.'),
  'ZAR': _CurrencyLabels('R', regional: 'ZA R', code: 'ZAR R'),
  'BRL': _CurrencyLabels(r'R$', regional: r'BR R$', code: r'BRL R$'),
  'RUB': _CurrencyLabels('₽', regional: 'RU ₽', code: 'RUB ₽'),
  'PLN': _CurrencyLabels('zł', regional: 'PL zł', code: 'PLN zł'),
  'INR': _CurrencyLabels('₹', regional: 'IN ₹', code: 'INR ₹'),
  'CZK': _CurrencyLabels('Kč', regional: 'CZ Kč', code: 'CZK Kč'),
  'SGD': _CurrencyLabels(r'S$', regional: r'SG S$', code: r'SGD S$'),
  'JPY': _CurrencyLabels('¥', regional: 'JP ¥', code: 'JPY ¥'),
  'HUF': _CurrencyLabels('Ft', regional: 'HU Ft', code: 'HUF Ft'),
  'RON': _CurrencyLabels('lei', regional: 'RO lei', code: 'RON lei'),
  'TRY': _CurrencyLabels('₺', regional: 'TR ₺', code: 'TRY ₺'),
  'MXN': _CurrencyLabels(r'$', regional: r'MX$'),
};

/// The currencies offered for prices, in the reference's order.
const List<String> kCurrencyCodes = [
  'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NZD', 'NOK', 'SEK', 'DKK', 'CHF', //
  'ZAR', 'BRL', 'RUB', 'PLN', 'INR', 'CZK', 'SGD', 'JPY', 'HUF', //
  'RON', 'TRY', 'MXN',
];

String _normalizedCurrency(String? currency) =>
    currency?.trim().toUpperCase() ?? '';

/// The local symbol of [currency], or its code when it has none.
String currencySymbol(String? currency) {
  final normalized = _normalizedCurrency(currency);
  return _currencies[normalized]?.symbol ??
      (normalized.isEmpty ? '¤' : normalized);
}

/// The Currency display choices of [currency], in the reference's order.
List<CurrencyDisplay> currencyDisplaysFor(String? currency) => [
      CurrencyDisplay.symbol,
      if (_currencies[_normalizedCurrency(currency)]?.regional != null)
        CurrencyDisplay.regional,
      CurrencyDisplay.code,
    ];

/// The choice the reference makes for a newly chosen currency: the regional
/// symbol where there is one, otherwise the local symbol.
CurrencyDisplay defaultCurrencyDisplay(String? currency) =>
    currencyDisplaysFor(currency).contains(CurrencyDisplay.regional)
        ? CurrencyDisplay.regional
        : CurrencyDisplay.symbol;

/// How [currency] is named under [display]; a currency without a regional
/// symbol falls back to its local one.
String currencyLabel(String? currency, CurrencyDisplay display) {
  final normalized = _normalizedCurrency(currency);
  final labels = _currencies[normalized];
  if (labels == null) return normalized.isEmpty ? '¤' : normalized;
  return switch (display) {
    CurrencyDisplay.symbol => labels.symbol,
    CurrencyDisplay.regional => labels.regional ?? labels.symbol,
    CurrencyDisplay.code => labels._code ?? normalized,
  };
}

final class AppFormats {
  const AppFormats({
    this.date = DateDisplayFormat.monthDayYear,
    this.dateEntry = DateEntryOrder.yearMonthDay,
    this.number = NumberFormatStyle.plain,
    this.currency = 'USD',
    this.currencyDisplay = CurrencyDisplay.regional,
  });

  final DateDisplayFormat date;
  final DateEntryOrder dateEntry;
  final NumberFormatStyle number;

  /// Default currency for new prices.
  final String currency;
  final CurrencyDisplay currencyDisplay;

  AppFormats copyWith({
    DateDisplayFormat? date,
    DateEntryOrder? dateEntry,
    NumberFormatStyle? number,
    String? currency,
    CurrencyDisplay? currencyDisplay,
  }) =>
      AppFormats(
        date: date ?? this.date,
        dateEntry: dateEntry ?? this.dateEntry,
        number: number ?? this.number,
        currency: currency ?? this.currency,
        currencyDisplay: currencyDisplay ?? this.currencyDisplay,
      );

  /// The formats in use, installed by the app root from the preferences.
  static AppFormats current = const AppFormats();

  @override
  bool operator ==(Object other) =>
      other is AppFormats &&
      other.date == date &&
      other.dateEntry == dateEntry &&
      other.number == number &&
      other.currency == currency &&
      other.currencyDisplay == currencyDisplay;

  @override
  int get hashCode =>
      Object.hash(date, dateEntry, number, currency, currencyDisplay);

  String formatDate(DateTime value) {
    final local = value.toLocal();
    return date.format(local.year, local.month, local.day);
  }

  /// A date with its local time of day, as on Added and Modified dates.
  String formatDateTime(DateTime value) {
    final local = value.toLocal();
    return '${formatDate(local)} '
        '${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}';
  }

  /// A partial date as precise as it is known: a year, a month or a day.
  String formatPartialDate(PartialDate? value) {
    final year = value?.year;
    if (year == null) return '';
    final month = value!.month;
    if (month == null) return '$year';
    final day = value.day;
    return day == null
        ? date.formatYearMonth(year, month)
        : date.format(year, month, day);
  }

  String formatNumber(num value, {int decimals = 0}) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = parts.first;
    final grouped = StringBuffer();
    for (var index = 0; index < whole.length; index++) {
      if (index > 0 && (whole.length - index) % 3 == 0) {
        grouped.write(number.groupSeparator);
      }
      grouped.write(whole[index]);
    }
    final fraction = parts.length > 1 ? '${number.decimal}${parts[1]}' : '';
    return '${negative ? '-' : ''}$grouped$fraction';
  }

  /// How [currencyCode] is named in prices under the Currency display.
  String currencyName(String? currencyCode) =>
      currencyLabel(currencyCode ?? currency, currencyDisplay);

  /// A price as the reference shows it: the currency name, a space and the
  /// amount with two decimals, such as `US$ 12.50` or `HUF Ft 12.50`.
  String formatMoney(int? cents, String? currencyCode) {
    if (cents == null) return '';
    final amount = formatNumber(cents.abs() / 100, decimals: 2);
    if (currencyCode == null || currencyCode.trim().isEmpty) {
      return cents < 0 ? '-$amount' : amount;
    }
    return '${cents < 0 ? '-' : ''}${currencyName(currencyCode)} $amount';
  }
}
