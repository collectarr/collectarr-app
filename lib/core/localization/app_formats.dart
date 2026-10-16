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

enum CurrencyDisplay {
  code('USD 12.50'),
  symbol(r'$12.50');

  const CurrencyDisplay(this.example);

  final String example;
}

const List<String> kCurrencyCodes = <String>[
  'USD',
  'SGD',
  'EUR',
  'GBP',
  'RON',
  'CHF',
  'JPY',
  'CAD',
  'AUD',
  'NZD',
  'SEK',
  'NOK',
  'DKK',
  'PLN',
  'CZK',
  'HUF',
  'TRY',
  'INR',
  'BRL',
  'MXN',
];

String currencySymbol(String? currency) {
  final normalized = currency?.trim().toUpperCase() ?? '';
  return switch (normalized) {
    'USD' => r'$',
    'SGD' => r'S$',
    'EUR' => '€',
    'GBP' => '£',
    'RON' => 'lei',
    'CHF' => 'CHF',
    'JPY' => '¥',
    'CAD' => r'$',
    'AUD' => r'$',
    'NZD' => r'$',
    'SEK' => 'kr',
    'NOK' => 'kr',
    'DKK' => 'kr',
    'PLN' => 'zł',
    'CZK' => 'Kč',
    'HUF' => 'Ft',
    'TRY' => '₺',
    'INR' => '₹',
    'BRL' => r'R$',
    'MXN' => r'$',
    _ when normalized.isNotEmpty => normalized,
    _ => '¤',
  };
}

final class AppFormats {
  const AppFormats({
    this.date = DateDisplayFormat.monthDayYear,
    this.dateEntry = DateEntryOrder.yearMonthDay,
    this.number = NumberFormatStyle.plain,
    this.currency = 'USD',
    this.currencyDisplay = CurrencyDisplay.code,
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

  String formatMoney(int? cents, String? currencyCode) {
    if (cents == null) return '';
    final amount = formatNumber(cents / 100, decimals: 2);
    final code = currencyCode == null || currencyCode.isEmpty
        ? null
        : currencyCode.toUpperCase();
    if (code == null) return amount;
    return switch (currencyDisplay) {
      CurrencyDisplay.code => '$code $amount',
      CurrencyDisplay.symbol => amount.startsWith('-')
          ? '-${currencySymbol(code)}${amount.substring(1)}'
          : '${currencySymbol(code)}$amount',
    };
  }
}
