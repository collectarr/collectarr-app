import 'package:flutter/foundation.dart';

enum ScannedCodeSymbology {
  ean8,
  ean13,
  upcA,
  upcE,
  code128,
  code39,
  itf14,
  qrCode,
  unknown,
}

/// Raw scanner output normalized into a generic, kind-agnostic value.
///
/// The barcode feature owns capture and normalization. Interpretation as an
/// ISBN, UPC, product code, or another domain identifier belongs to a kind.
@immutable
final class ScannedCode {
  const ScannedCode({
    required this.rawValue,
    required this.value,
    required this.symbology,
  });

  final String rawValue;
  final String value;
  final ScannedCodeSymbology symbology;

  static ScannedCode? tryFromRaw(
    String rawValue, {
    ScannedCodeSymbology symbology = ScannedCodeSymbology.unknown,
  }) {
    final value = normalizeScannedCode(rawValue);
    if (value.isEmpty) return null;
    return ScannedCode(
      rawValue: rawValue,
      value: value,
      symbology: symbology,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedCode &&
          value == other.value &&
          symbology == other.symbology;

  @override
  int get hashCode => Object.hash(value, symbology);
}

String normalizeScannedCode(String value) {
  return value.trim().replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();
}
