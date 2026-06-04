import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A batch barcode scanner that stays open and collects multiple barcodes.
/// Returns a list of scanned barcode strings when the user confirms.
class BarcodeBatchScanSheet extends StatefulWidget {
  const BarcodeBatchScanSheet({
    super.key,
    this.title = 'Batch Scan',
    @visibleForTesting this.cameraSupported,
    @visibleForTesting this.platform,
  });

  final String title;
  final bool? cameraSupported;
  final TargetPlatform? platform;

  @override
  State<BarcodeBatchScanSheet> createState() => _BarcodeBatchScanSheetState();
}

class _BarcodeBatchScanSheetState extends State<BarcodeBatchScanSheet> {
  final List<String> _scannedBarcodes = [];
  late final bool _cameraSupported;
  MobileScannerController? _scannerController;
  String? _lastScanned;

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
        ],
      );
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final newBarcodes = <String>[];
    String? lastScanned;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      final value = rawValue == null ? null : normalizeScannedBarcode(rawValue);
      if (value != null &&
          value.isNotEmpty &&
          value != _lastScanned &&
          !_scannedBarcodes.contains(value) &&
          !newBarcodes.contains(value)) {
        newBarcodes.add(value);
        lastScanned = value;
      }
    }
    if (newBarcodes.isEmpty) {
      return;
    }
    setState(() {
      _scannedBarcodes.addAll(newBarcodes);
      _lastScanned = lastScanned;
    });
  }

  void _removeBarcode(int index) {
    setState(() => _scannedBarcodes.removeAt(index));
  }

  void _done() {
    Navigator.of(context).pop(_scannedBarcodes);
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_scannedBarcodes.isNotEmpty)
                  Badge(
                    label: Text(_scannedBarcodes.length.toString()),
                    child: const Icon(Icons.inventory_2_outlined),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(<String>[]),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Point camera at barcodes. Each unique barcode is added automatically.',
              style: TextStyle(fontSize: 12, color: kAppTextMuted),
            ),
            if (_lastScanned != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Last scanned: $_lastScanned',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (_cameraSupported)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 200,
                  child: MobileScanner(
                    controller: _scannerController!,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (_scannedBarcodes.isNotEmpty) ...[
              Text(
                '${_scannedBarcodes.length} barcode(s) scanned:',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _scannedBarcodes.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        children: [
                          Text(
                            '${i + 1}.',
                            style:
                                TextStyle(fontSize: 11, color: kAppTextMuted),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _scannedBarcodes[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: kClzMonospaceFontFamily,
                                fontFamilyFallback: kClzMonospaceFontFallback,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _removeBarcode(i),
                            child: Icon(Icons.close,
                                size: 14, color: kAppTextMuted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _scannedBarcodes.isNotEmpty ? _done : null,
              icon: const Icon(Icons.check),
              label: Text(_scannedBarcodes.isEmpty
                  ? 'Scan barcodes to continue'
                  : 'Look up ${_scannedBarcodes.length} barcode(s)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the batch scan sheet and returns the list of scanned barcodes.
Future<List<String>?> showBarcodeBatchScanSheet(BuildContext context) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kAppPanel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const BarcodeBatchScanSheet(),
  );
}
