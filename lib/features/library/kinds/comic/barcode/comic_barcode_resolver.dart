import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/barcode/identifier_resolver.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';

final class ComicBarcodeResolver implements IdentifierResolver<String> {
  const ComicBarcodeResolver();

  @override
  String? resolve(ScannedCode code) {
    return isValidRetailBarcode(code.value) ? code.value : null;
  }
}
