import 'package:flutter/foundation.dart';

@immutable
class Money {
  const Money._(this.cents, this.currency);

  final int cents;
  final String currency;

  static const String defaultCurrency = 'USD';

  static Money? fromCents(int? cents, [String? currency]) {
    if (cents == null) return null;
    final normalizedCurrency = (currency?.trim().isEmpty ?? true)
        ? defaultCurrency
        : currency!.trim().toUpperCase();
    return Money._(cents, normalizedCurrency);
  }

  static Money? fromAmount(double? amount, [String? currency]) {
    if (amount == null) return null;
    return fromCents((amount * 100).round(), currency);
  }

  static Money? parse(String? text, [String? currency]) {
    if (text == null || text.trim().isEmpty) return null;
    final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return null;
    return fromAmount(parsed, currency);
  }

  double toAmount() => cents / 100.0;

  String format({bool includeCurrencySymbol = true}) {
    final amountStr = toAmount().toStringAsFixed(2);
    if (!includeCurrencySymbol) {
      return amountStr;
    }
    final symbol = switch (currency) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'RON' => 'lei ',
      _ => '$currency ',
    };
    return '$symbol$amountStr';
  }

  Money operator +(Money other) {
    assert(
      currency == other.currency,
      'Cannot add money with different currencies: $currency vs ${other.currency}',
    );
    return Money._(cents + other.cents, currency);
  }

  Money operator -(Money other) {
    assert(
      currency == other.currency,
      'Cannot subtract money with different currencies: $currency vs ${other.currency}',
    );
    return Money._(cents - other.cents, currency);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          cents == other.cents &&
          currency == other.currency;

  @override
  int get hashCode => cents.hashCode ^ currency.hashCode;

  @override
  String toString() => format();
}

@immutable
class OwnedItemId {
  const OwnedItemId(this.value);

  final String value;

  static OwnedItemId? fromRaw(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return OwnedItemId(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
