import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/barcode/identifier_resolver.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';

final class MangaIdentifierResolver implements IdentifierResolver<String> {
  const MangaIdentifierResolver();

  @override
  String? resolve(ScannedCode code) {
    return isValidIsbn(code.value) || isValidRetailBarcode(code.value)
        ? code.value
        : null;
  }
}
