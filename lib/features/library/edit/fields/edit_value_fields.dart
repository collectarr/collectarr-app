import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

// Text, currency and date fields of library edit dialogs.

/// The canonical labelled text field used across every library edit dialog.
///
/// Kinds previously each declared a private `_field` helper that produced an
/// identical [TextFormField]; this widget is the single source of truth so
/// styling, validation wiring and hint behaviour stay uniform everywhere.
class LibraryEditTextField extends StatelessWidget {
  const LibraryEditTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.keyboardType,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final TextInputType? keyboardType;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return LibraryFormField(
      label: label,
      child: LibraryTextFormControl(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        expands: expands,
        keyboardType: keyboardType,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}

class LibraryCurrencyField extends StatelessWidget {
  const LibraryCurrencyField({
    super.key,
    required this.controller,
    this.label = 'Currency',
    this.enabled = true,
    this.onChanged,
    this.currencyCodes = kCurrencyCodes,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final ValueChanged<String?>? onChanged;
  final List<String> currencyCodes;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final normalized = value.text.trim().toUpperCase();
        final items = <String>{
          for (final code in currencyCodes) code.trim().toUpperCase(),
          if (normalized.isNotEmpty) normalized,
        }.toList(growable: false);
        return LibraryDropdownPickField<String>(
          label: label,
          value: normalized.isEmpty ? null : normalized,
          enabled: enabled,
          options: [
            for (final code in items)
              LibraryFieldOption<String>(
                value: code,
                label: '${currencySymbol(code)} $code',
              ),
          ],
          openPicker: (
                  {required label, required selectedValue, required options}) =>
              showPickListSelectDialog(
            context: context,
            label: label,
            options: options,
            selectedValue: selectedValue,
          ),
          onChanged: enabled
              ? (selected) {
                  final next = selected?.trim().toUpperCase() ?? '';
                  if (controller.text != next) controller.text = next;
                  onChanged?.call(selected);
                }
              : (_) {},
        );
      },
    );
  }
}

Future<DateTime?> showLibraryDateEntryDialog(
  BuildContext context, {
  required String label,
  DateTime? initialDate,
}) {
  return showAppDialog<DateTime?>(
    context: context,
    builder: (dialogContext) {
      var selectedDate = initialDate;
      return StatefulBuilder(
        builder: (context, setDialogState) => AccentAlertDialog(
          headerIcon: AppIcons.inlineEdit,
          title: Text(label),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: LibraryPartialDateField.fullDate(
              label: label,
              date: selectedDate,
              onDateChanged: (value) => setDialogState(() {
                selectedDate = value;
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedDate == null
                  ? null
                  : () => Navigator.of(dialogContext).pop(selectedDate),
              child: const Text('Select'),
            ),
          ],
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Sold summary – Paid → Sold for → Profit/Loss
// ---------------------------------------------------------------------------

String? emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? parseDate(String value) {
  final normalized = emptyToNull(value);
  return normalized == null ? null : DateTime.tryParse(normalized);
}

int? parseInt(String value) {
  final normalized = emptyToNull(value);
  return normalized == null ? null : int.tryParse(normalized);
}

int? parseMoneyCents(String value, {int? fallback}) {
  final normalized = emptyToNull(value)?.replaceAll(',', '.');
  if (normalized == null) {
    return fallback;
  }
  final parsed = double.tryParse(normalized);
  return parsed == null ? fallback : (parsed * 100).round();
}

String? optionalIntValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim()) == null ? 'Enter a number' : null;
}

String? optionalMoneyValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized) == null
      ? 'Enter a valid price, for example 3.99'
      : null;
}
