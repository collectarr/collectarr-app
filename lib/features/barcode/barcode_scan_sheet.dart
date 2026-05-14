import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanSheet extends StatefulWidget {
  const BarcodeScanSheet({
    super.key,
    @visibleForTesting this.cameraSupported,
    @visibleForTesting this.platform,
  });

  final bool? cameraSupported;
  final TargetPlatform? platform;

  @override
  State<BarcodeScanSheet> createState() => _BarcodeScanSheetState();
}

class _BarcodeScanSheetState extends State<BarcodeScanSheet> {
  final _manualController = TextEditingController();
  late final bool _cameraSupported;
  MobileScannerController? _scannerController;
  bool _hasReturned = false;

  @override
  void initState() {
    super.initState();
    _cameraSupported = widget.cameraSupported ??
        barcodeScannerCameraSupported(platform: widget.platform);
    if (_cameraSupported) {
      _scannerController = MobileScannerController(
        formats: const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.itf14,
          BarcodeFormat.qrCode,
        ],
      );
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_scanner),
                const SizedBox(width: 8),
                Text(
                  'Scan barcode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_cameraSupported)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 260,
                  child: ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: MobileScanner(
                      controller: _scannerController!,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) => _ScannerFallback(
                        message: barcodeScannerErrorMessage(error.errorCode),
                      ),
                    ),
                  ),
                ),
              )
            else
              _ScannerFallback(
                message: barcodeScannerUnavailableMessage(
                  platform: widget.platform,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Manual barcode / UPC / ISBN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              onSubmitted: (_) => _submitManual(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _submitManual,
              icon: const Icon(Icons.search),
              label: const Text('Lookup barcode'),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasReturned) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      final value = rawValue == null ? null : normalizeScannedBarcode(rawValue);
      if (value != null && value.isNotEmpty) {
        _hasReturned = true;
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  void _submitManual() {
    final value = normalizeScannedBarcode(_manualController.text);
    if (value.isEmpty || _hasReturned) {
      return;
    }
    _hasReturned = true;
    Navigator.of(context).pop(value);
  }
}

class _ScannerFallback extends StatelessWidget {
  const _ScannerFallback({required this.message});

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
