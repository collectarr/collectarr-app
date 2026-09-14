import 'scanned_code.dart';

/// Structural contract for a kind-owned identifier interpreter.
///
/// The resolver may interpret a [ScannedCode], but generic barcode UI never
/// decides what the returned identifier means.
abstract interface class IdentifierResolver<TIdentifier> {
  TIdentifier? resolve(ScannedCode code);
}
