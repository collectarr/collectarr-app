import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/barcode/barcode_camera_view.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/ui/app_close_button.dart';
import 'package:flutter/material.dart';

class BarcodeScanSheet extends StatefulWidget {
  const BarcodeScanSheet({
    super.key,
    this.title = 'Scan barcode',
    this.description,
    this.manualLabel = 'Manual barcode / UPC / ISBN',
    this.submitLabel = 'Lookup barcode',
    this.leadingIcon = Icons.qr_code_scanner,
    @visibleForTesting this.cameraSupported,
    @visibleForTesting this.devicePlatform,
  });

  final String title;
  final String? description;
  final String manualLabel;
  final String submitLabel;
  final IconData leadingIcon;
  final bool? cameraSupported;
  final TargetPlatform? devicePlatform;

  @override
  State<BarcodeScanSheet> createState() => _BarcodeScanSheetState();
}

class _BarcodeScanSheetState extends State<BarcodeScanSheet> {
  final _manualController = TextEditingController();
  late final bool _cameraSupported;
  bool _hasReturned = false;

  @override
  void initState() {
    super.initState();
    _cameraSupported = widget.cameraSupported ??
        barcodeScannerCameraSupported(devicePlatform: widget.devicePlatform);
  }

  @override
  void dispose() {
    _manualController.dispose();
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
                Icon(widget.leadingIcon),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                AppCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                    size: 40,
                    iconSize: 24,
                    icon: Icons.close),
              ],
            ),
            if (widget.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            if (_cameraSupported)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 260,
                  child: ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: BarcodeCameraView(
                      symbologies: const {
                        ScannedCodeSymbology.ean13,
                        ScannedCodeSymbology.ean8,
                        ScannedCodeSymbology.upcA,
                        ScannedCodeSymbology.upcE,
                        ScannedCodeSymbology.code128,
                        ScannedCodeSymbology.code39,
                        ScannedCodeSymbology.itf14,
                        ScannedCodeSymbology.qrCode,
                      },
                      onCodes: _onCodes,
                    ),
                  ),
                ),
              )
            else
              BarcodeScannerFallback(
                message: barcodeScannerUnavailableMessage(
                  devicePlatform: widget.devicePlatform,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: widget.manualLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
              onSubmitted: (_) => _submitManual(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: appPalette(context).utilityAction,
                  foregroundColor: Colors.white),
              onPressed: _submitManual,
              icon: const Icon(Icons.search),
              label: Text(widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _onCodes(List<ScannedCode> codes) {
    if (_hasReturned) {
      return;
    }
    _hasReturned = true;
    Navigator.of(context).pop(codes.first);
  }

  void _submitManual() {
    final scannedCode = ScannedCode.tryFromRaw(_manualController.text);
    if (scannedCode == null || _hasReturned) {
      return;
    }
    _hasReturned = true;
    Navigator.of(context).pop(scannedCode);
  }
}
