import 'dart:convert';

import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Server diagnostics that were previously only available in the deprecated web
/// admin: a backend health probe and a barcode lookup. Migrated into the Flutter
/// admin dashboard so it stays the single admin surface.
class AdminDiagnosticsPanel extends ConsumerStatefulWidget {
  const AdminDiagnosticsPanel({super.key});

  @override
  ConsumerState<AdminDiagnosticsPanel> createState() =>
      _AdminDiagnosticsPanelState();
}

class _AdminDiagnosticsPanelState extends ConsumerState<AdminDiagnosticsPanel> {
  final TextEditingController _barcodeController = TextEditingController();

  bool _isCheckingHealth = false;
  String? _healthResult;
  bool _healthOk = false;

  bool _isLookingUp = false;
  String? _barcodeResult;
  String? _barcodeError;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _healthResult = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.health();
      if (!mounted) return;
      setState(() {
        _isCheckingHealth = false;
        _healthOk = true;
        _healthResult = const JsonEncoder.withIndent('  ').convert(result);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingHealth = false;
        _healthOk = false;
        _healthResult = e.toString();
      });
    }
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() {
        _barcodeError = 'Enter a barcode to look up.';
        _barcodeResult = null;
      });
      return;
    }
    setState(() {
      _isLookingUp = true;
      _barcodeError = null;
      _barcodeResult = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.lookupBarcode(barcode);
      if (!mounted) return;
      setState(() {
        _isLookingUp = false;
        _barcodeResult = const JsonEncoder.withIndent('  ').convert(result);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLookingUp = false;
        _barcodeError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Health check',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _isCheckingHealth ? null : _checkHealth,
            icon: _isCheckingHealth
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.favorite_outline, size: 18),
            label: const Text('Run health check'),
          ),
        ),
        if (_healthResult != null) ...[
          const SizedBox(height: 8),
          _ResultBox(
            text: _healthResult!,
            isError: !_healthOk,
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Barcode lookup',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  hintText: 'UPC / EAN / ISBN',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(color: palette.textSecondary),
                ),
                onSubmitted: (_) => _lookupBarcode(),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _isLookingUp ? null : _lookupBarcode,
              icon: _isLookingUp
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_scanner_outlined, size: 18),
              label: const Text('Look up'),
            ),
          ],
        ),
        if (_barcodeError != null) ...[
          const SizedBox(height: 8),
          _ResultBox(text: _barcodeError!, isError: true),
        ],
        if (_barcodeResult != null) ...[
          const SizedBox(height: 8),
          _ResultBox(text: _barcodeResult!, isError: false),
        ],
      ],
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
