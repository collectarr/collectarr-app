import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    this.readOnly = false,
    this.action,
  });

  final String label;
  final int? amountMinorUnits;
  final String currency;
  final ValueChanged<int?> onChanged;
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool readOnly;
  final Widget? action;

  // The reference's locked field: a light fill with grey text, in any theme.
  static const _readOnlyFill = Color(0xFFEDEDED);
  static const _readOnlyText = Color(0xFF777777);
  static const _readOnlyPrefix = Color(0xFF999999);

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: label,
        action: action,
        child: LibraryTextFormControl(
          key: fieldKey,
          controller: controller,
          initialValue: controller == null ? _formattedAmount : null,
          readOnly: readOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: readOnly
              ? context.libraryTextTheme.controlText
                  .copyWith(color: _readOnlyText)
              : null,
          decoration: InputDecoration(
            // Follows Settings > Localization > Currency display. As in the
            // reference, the currency stays visible while the field is empty.
            prefixText: '${AppFormats.current.currencyName(_currencyCode)} ',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: readOnly ? true : null,
            fillColor: readOnly ? _readOnlyFill : null,
            hoverColor: readOnly ? _readOnlyFill : null,
            prefixStyle:
                readOnly ? const TextStyle(color: _readOnlyPrefix) : null,
          ),
          validator: _validate,
          onChanged: _handleChanged,
        ),
      );

  String get _currencyCode {
    final value = currency.trim().toUpperCase();
    return value.isEmpty ? AppFormats.current.currency : value;
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

/// A Value amount with the lock in its label row. A locked amount stays as
/// entered and shows it as the reference does.
final class LibraryLockableMoneyField extends StatelessWidget {
  const LibraryLockableMoneyField({
    super.key,
    required this.amountMinorUnits,
    required this.currency,
    required this.locked,
    required this.onLockedChanged,
    required this.onChanged,
    this.fieldKey,
    this.lockedMessage = 'Unlock the value',
  });

  final int? amountMinorUnits;
  final String currency;
  final bool locked;
  final ValueChanged<bool> onLockedChanged;
  final ValueChanged<int?> onChanged;
  final Key? fieldKey;
  final String lockedMessage;

  @override
  Widget build(BuildContext context) => LibraryMoneyAmountField(
        fieldKey: fieldKey,
        label: 'Value',
        amountMinorUnits: amountMinorUnits,
        currency: currency,
        readOnly: locked,
        onChanged: onChanged,
        action: Tooltip(
          message: locked ? lockedMessage : 'Lock the value',
          child: GestureDetector(
            onTap: () => onLockedChanged(!locked),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Icon(
                locked ? AppIcons.lock : AppIcons.lockOpen,
                size: 14,
                color: appPalette(context).textMuted,
              ),
            ),
          ),
        ),
      );
}
