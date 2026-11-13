import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/barcode/identifier_resolver.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';

/// Kind-entry interpretation of a scanner value.
///
/// The barcode feature only captures and normalizes [ScannedCode]. This
/// contract identifies the owning kind without exposing kind semantics to the
/// generic scanner or lookup host.
abstract interface class LibraryBarcodeResolver
    implements IdentifierResolver<String> {
  CatalogMediaKind get kind;
}

/// Resolver for a kind whose items carry a plain retail barcode (UPC or EAN)
/// with a valid check digit.
final class RetailBarcodeResolver implements LibraryBarcodeResolver {
  const RetailBarcodeResolver(this.kind);

  @override
  final CatalogMediaKind kind;

  @override
  String? resolve(ScannedCode code) =>
      isValidRetailBarcode(code.value) ? code.value : null;
}
