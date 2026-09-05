import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test('normalizes scanned and manually entered barcodes', () {
    expect(normalizeScannedBarcode(' 7596-060 83060 '), '759606083060');
    expect(normalizeScannedBarcode('x-12 34'), 'X1234');
  });

  test('keeps raw value and symbology at the scanner boundary', () {
    final code = ScannedCode.tryFromRaw(
      ' 7596-060 83060 ',
      symbology: ScannedCodeSymbology.ean13,
    );

    expect(code?.rawValue, ' 7596-060 83060 ');
    expect(code?.value, '759606083060');
    expect(code?.symbology, ScannedCodeSymbology.ean13);
  });

  test('camera scanner is enabled only on supported plugin platforms', () {
    expect(
      barcodeScannerCameraSupported(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      barcodeScannerCameraSupported(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      barcodeScannerCameraSupported(
        isWeb: false,
        platform: TargetPlatform.macOS,
      ),
      isTrue,
    );
    expect(
      barcodeScannerCameraSupported(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
    expect(
      barcodeScannerCameraSupported(
        isWeb: false,
        platform: TargetPlatform.windows,
      ),
      isFalse,
    );
    expect(
      barcodeScannerCameraSupported(
        isWeb: false,
        platform: TargetPlatform.linux,
      ),
      isFalse,
    );
  });

  test('scanner messages distinguish permission and unsupported states', () {
    expect(
      barcodeScannerErrorMessage(MobileScannerErrorCode.permissionDenied),
      contains('permission denied'),
    );
    expect(
      barcodeScannerErrorMessage(MobileScannerErrorCode.unsupported),
      contains('not available on this device'),
    );
    expect(
      barcodeScannerUnavailableMessage(
        isWeb: false,
        platform: TargetPlatform.windows,
      ),
      contains('not available on this platform'),
    );
  });
}
