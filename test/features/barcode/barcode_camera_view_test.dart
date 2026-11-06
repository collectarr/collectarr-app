import 'package:camera/camera.dart';
import 'package:collectarr_app/features/barcode/barcode_camera_view.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

void main() {
  test('ZXing formats map to the scanned symbologies', () {
    const formats = {
      Format.ean8: ScannedCodeSymbology.ean8,
      Format.ean13: ScannedCodeSymbology.ean13,
      Format.upca: ScannedCodeSymbology.upcA,
      Format.upce: ScannedCodeSymbology.upcE,
      Format.code128: ScannedCodeSymbology.code128,
      Format.code39: ScannedCodeSymbology.code39,
      Format.itf: ScannedCodeSymbology.itf14,
      Format.qrCode: ScannedCodeSymbology.qrCode,
    };
    formats.forEach((format, symbology) {
      expect(scannedCodeSymbologyFromZxingFormat(format), symbology);
    });
    expect(scannedCodeSymbologyFromZxingFormat(Format.aztec),
        ScannedCodeSymbology.unknown);
    expect(scannedCodeSymbologyFromZxingFormat(null),
        ScannedCodeSymbology.unknown);
  });

  test('a denied camera permission asks for the barcode by hand', () {
    expect(barcodeCameraErrorMessage(CameraException('CameraAccessDenied', '')),
        contains('permission denied'));
    expect(barcodeCameraErrorMessage(CameraException('other', '')),
        contains('Camera unavailable'));
  });
}
