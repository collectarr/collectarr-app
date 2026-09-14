import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';

final class BoardGameBarcodeResolver implements LibraryBarcodeResolver {
  const BoardGameBarcodeResolver();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  String? resolve(ScannedCode code) {
    return isValidRetailBarcode(code.value) ? code.value : null;
  }
}
