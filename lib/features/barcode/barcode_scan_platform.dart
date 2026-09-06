import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scanned_code.dart';

String normalizeScannedBarcode(String value) {
  return normalizeScannedCode(value);
}

ScannedCode? scannedCodeFromBarcode(Barcode barcode) {
  final rawValue = barcode.rawValue;
  if (rawValue == null) return null;
  return ScannedCode.tryFromRaw(
    rawValue,
    symbology: scannedCodeSymbologyFromFormat(barcode.format),
  );
}

ScannedCodeSymbology scannedCodeSymbologyFromFormat(BarcodeFormat format) {
  return switch (format) {
    BarcodeFormat.ean8 => ScannedCodeSymbology.ean8,
    BarcodeFormat.ean13 => ScannedCodeSymbology.ean13,
    BarcodeFormat.upcA => ScannedCodeSymbology.upcA,
    BarcodeFormat.upcE => ScannedCodeSymbology.upcE,
    BarcodeFormat.code128 => ScannedCodeSymbology.code128,
    BarcodeFormat.code39 => ScannedCodeSymbology.code39,
    BarcodeFormat.itf14 => ScannedCodeSymbology.itf14,
    BarcodeFormat.qrCode => ScannedCodeSymbology.qrCode,
    _ => ScannedCodeSymbology.unknown,
  };
}

bool barcodeScannerCameraSupported({
  bool isWeb = kIsWeb,
  TargetPlatform? devicePlatform,
}) {
  if (isWeb) {
    return true;
  }
  return switch (devicePlatform ?? defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS =>
      true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows =>
      false,
  };
}

String barcodeScannerUnavailableMessage({
  bool isWeb = kIsWeb,
  TargetPlatform? devicePlatform,
}) {
  if (isWeb) {
    return 'Camera access is unavailable in this browser. Enter the barcode manually.';
  }
  return switch (devicePlatform ?? defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.fuchsia =>
      'Camera scanning is not available on this platform. Enter the barcode manually.',
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS =>
      'Camera unavailable. Enter the barcode manually.',
  };
}

String barcodeScannerErrorMessage(MobileScannerErrorCode code) {
  return switch (code) {
    MobileScannerErrorCode.permissionDenied =>
      'Camera permission denied. Enter the barcode manually.',
    MobileScannerErrorCode.unsupported =>
      'Camera scanning is not available on this device. Enter the barcode manually.',
    MobileScannerErrorCode.controllerAlreadyInitialized ||
    MobileScannerErrorCode.controllerDisposed ||
    MobileScannerErrorCode.controllerInitializing ||
    MobileScannerErrorCode.controllerNotAttached ||
    MobileScannerErrorCode.controllerUninitialized ||
    MobileScannerErrorCode.genericError =>
      'Camera unavailable. Enter the barcode manually.',
  };
}
