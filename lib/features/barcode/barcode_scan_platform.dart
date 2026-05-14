import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

String normalizeScannedBarcode(String value) {
  return value.trim().replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();
}

bool barcodeScannerCameraSupported({
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
}) {
  if (isWeb) {
    return true;
  }
  return switch (platform ?? defaultTargetPlatform) {
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
  TargetPlatform? platform,
}) {
  if (isWeb) {
    return 'Camera access is unavailable in this browser. Enter the barcode manually.';
  }
  return switch (platform ?? defaultTargetPlatform) {
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
