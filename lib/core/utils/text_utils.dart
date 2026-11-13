import 'package:flutter/services.dart';

/// Blocks newline characters in text fields.
final TextInputFormatter noNewlineFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'[\r\n]'));

/// Formats a [DateTime] as a local `yyyy-MM-dd` string.
String formatCompactDate(DateTime d) {
  final local = d.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

/// The date as `yyyy-MM-dd`, or empty when there is none.
String formatIsoDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
