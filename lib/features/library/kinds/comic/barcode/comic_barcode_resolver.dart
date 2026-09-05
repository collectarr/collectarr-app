import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';

final class ComicBarcodeResolver implements LibraryBarcodeResolver {
  const ComicBarcodeResolver();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  String? resolve(ScannedCode code) {
    if (isValidRetailBarcode(code.value)) {
      return code.value;
    }

    // Comic UPCs may carry the five-digit issue/supplement add-on after the
    // twelve-digit UPC-A value. The add-on is part of the scanned identifier,
    // but only the UPC-A portion has a retail check digit.
    if (code.value.length == 17 &&
        isValidRetailBarcode(code.value.substring(0, 12)) &&
        RegExp(r'^\d{5}$').hasMatch(code.value.substring(12))) {
      return code.value;
    }
    return null;
  }
}
