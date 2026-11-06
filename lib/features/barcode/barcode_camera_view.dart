import 'package:camera/camera.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart' as zxing;
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;

/// The camera preview that reports the codes it sees: ZXing on Android, where
/// mobile_scanner would bring in Google's closed ML Kit, and the local copy of
/// mobile_scanner, which has no Android part, on the web and Apple platforms.
class BarcodeCameraView extends StatefulWidget {
  const BarcodeCameraView({
    super.key,
    required this.symbologies,
    required this.onCodes,
  });

  final Set<ScannedCodeSymbology> symbologies;
  final ValueChanged<List<ScannedCode>> onCodes;

  @override
  State<BarcodeCameraView> createState() => _BarcodeCameraViewState();
}

class _BarcodeCameraViewState extends State<BarcodeCameraView> {
  static final bool _useZxing =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  scanner.MobileScannerController? _controller;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    if (!_useZxing) {
      _controller = scanner.MobileScannerController(formats: [
        for (final symbology in widget.symbologies)
          _mobileScannerFormat(symbology),
      ]);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onZxingCode(zxing.Code code) {
    final text = code.text;
    if (!code.isValid || text == null) return;
    final scanned = ScannedCode.tryFromRaw(
      text,
      symbology: scannedCodeSymbologyFromZxingFormat(code.format),
    );
    if (scanned != null) widget.onCodes([scanned]);
  }

  void _onCapture(scanner.BarcodeCapture capture) {
    final codes = [
      for (final barcode in capture.barcodes)
        if (scannedCodeFromBarcode(barcode) case final code?) code,
    ];
    if (codes.isNotEmpty) widget.onCodes(codes);
  }

  @override
  Widget build(BuildContext context) {
    final cameraError = _cameraError;
    if (cameraError != null) {
      return BarcodeScannerFallback(message: cameraError);
    }
    if (_useZxing) {
      return zxing.ReaderWidget(
        codeFormat: widget.symbologies.fold(zxing.Format.none,
            (mask, symbology) => mask | _zxingFormat(symbology)),
        onScan: _onZxingCode,
        onControllerCreated: (_, error) {
          if (error != null && mounted) {
            setState(() => _cameraError = barcodeCameraErrorMessage(error));
          }
        },
        tryHarder: true,
        tryDownscale: true,
        showScannerOverlay: false,
        showFlashlight: false,
        showToggleCamera: false,
        showGallery: false,
        cropPercent: 0.9,
        scanDelay: const Duration(milliseconds: 200),
        scanDelaySuccess: const Duration(milliseconds: 500),
      );
    }
    return scanner.MobileScanner(
      controller: _controller!,
      onDetect: _onCapture,
      errorBuilder: (context, error) => BarcodeScannerFallback(
        message: barcodeScannerErrorMessage(error.errorCode),
      ),
    );
  }
}

/// Why ZXing's camera could not start, in the words of the other scanners.
String barcodeCameraErrorMessage(Exception error) =>
    error is CameraException && error.code.startsWith('CameraAccess')
        ? 'Camera permission denied. Enter the barcode manually.'
        : 'Camera unavailable. Enter the barcode manually.';

int _zxingFormat(ScannedCodeSymbology symbology) => switch (symbology) {
      ScannedCodeSymbology.ean8 => zxing.Format.ean8,
      ScannedCodeSymbology.ean13 => zxing.Format.ean13,
      ScannedCodeSymbology.upcA => zxing.Format.upca,
      ScannedCodeSymbology.upcE => zxing.Format.upce,
      ScannedCodeSymbology.code128 => zxing.Format.code128,
      ScannedCodeSymbology.code39 => zxing.Format.code39,
      ScannedCodeSymbology.itf14 => zxing.Format.itf,
      ScannedCodeSymbology.qrCode => zxing.Format.qrCode,
      ScannedCodeSymbology.unknown => zxing.Format.none,
    };

scanner.BarcodeFormat _mobileScannerFormat(ScannedCodeSymbology symbology) =>
    switch (symbology) {
      ScannedCodeSymbology.ean8 => scanner.BarcodeFormat.ean8,
      ScannedCodeSymbology.ean13 => scanner.BarcodeFormat.ean13,
      ScannedCodeSymbology.upcA => scanner.BarcodeFormat.upcA,
      ScannedCodeSymbology.upcE => scanner.BarcodeFormat.upcE,
      ScannedCodeSymbology.code128 => scanner.BarcodeFormat.code128,
      ScannedCodeSymbology.code39 => scanner.BarcodeFormat.code39,
      ScannedCodeSymbology.itf14 => scanner.BarcodeFormat.itf14,
      ScannedCodeSymbology.qrCode => scanner.BarcodeFormat.qrCode,
      ScannedCodeSymbology.unknown => scanner.BarcodeFormat.unknown,
    };

ScannedCodeSymbology scannedCodeSymbologyFromZxingFormat(int? format) =>
    switch (format) {
      zxing.Format.ean8 => ScannedCodeSymbology.ean8,
      zxing.Format.ean13 => ScannedCodeSymbology.ean13,
      zxing.Format.upca => ScannedCodeSymbology.upcA,
      zxing.Format.upce => ScannedCodeSymbology.upcE,
      zxing.Format.code128 => ScannedCodeSymbology.code128,
      zxing.Format.code39 => ScannedCodeSymbology.code39,
      zxing.Format.itf => ScannedCodeSymbology.itf14,
      zxing.Format.qrCode => ScannedCodeSymbology.qrCode,
      _ => ScannedCodeSymbology.unknown,
    };

/// Shown in place of the preview when the camera cannot be used.
class BarcodeScannerFallback extends StatelessWidget {
  const BarcodeScannerFallback({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_outlined,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
