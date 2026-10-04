import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Shared money amount control for Add and Edit forms.
///
/// Values are exchanged as integer minor units so form code never stores a
/// floating-point amount.
final class LibraryMoneyAmountField extends StatelessWidget {
  const LibraryMoneyAmountField({
    super.key,
    required this.label,
    required this.amountMinorUnits,
    required this.currency,
    required this.onChanged,
    this.controller,
    this.fieldKey,
  });

  final String label;
  final int? amountMinorUnits;
  final String currency;
  final ValueChanged<int?> onChanged;
  final TextEditingController? controller;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: label,
        child: TextFormField(
          key: fieldKey,
          controller: controller,
          initialValue: controller == null ? _formattedAmount : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '$_currencyCode ',
            constraints: const BoxConstraints(
              minHeight: kLibraryFormControlHeight,
            ),
          ),
          validator: _validate,
          onChanged: _handleChanged,
        ),
      );

  String get _currencyCode {
    final value = currency.trim().toUpperCase();
    return value.isEmpty ? 'USD' : value;
  }

  String get _formattedAmount => amountMinorUnits == null
      ? ''
      : (amountMinorUnits! / 100).toStringAsFixed(2);

  String? _validate(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final amount = _parse(value);
    if (amount == null || !amount.isFinite) return 'Enter an amount';
    if (amount < 0) return 'Amount cannot be negative';
    return null;
  }

  void _handleChanged(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      onChanged(null);
      return;
    }
    final amount = _parse(value);
    if (amount == null || !amount.isFinite || amount < 0) return;
    onChanged((amount * 100).round());
  }

  double? _parse(String value) => double.tryParse(value.replaceAll(',', '.'));
}
