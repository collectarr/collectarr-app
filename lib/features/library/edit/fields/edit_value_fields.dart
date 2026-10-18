import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class LibraryDateFieldButton extends StatefulWidget {
  const LibraryDateFieldButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showLabel = true,
    this.errorText,
    this.fieldKeyPrefix,
    this.focusNode,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool showLabel;
  final String? errorText;
  final String? fieldKeyPrefix;
  final FocusNode? focusNode;

  @override
  State<LibraryDateFieldButton> createState() => _LibraryDateFieldButtonState();
}

class _LibraryDateFieldButtonState extends State<LibraryDateFieldButton> {
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;
  DateTime? _lastEmittedValue;

  @override
  void initState() {
    super.initState();
    final initial = widget.value?.toLocal();
    _yearController = TextEditingController(
      text: initial?.year.toString() ?? '',
    );
    _monthController = TextEditingController(
      text: initial?.month.toString().padLeft(2, '0') ?? '',
    );
    _dayController = TextEditingController(
      text: initial?.day.toString().padLeft(2, '0') ?? '',
    );
    _lastEmittedValue = widget.value;
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LibraryDateFieldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) {
      return;
    }
    _syncFromValue(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final labelStyle = TextStyle(
      color: palette.textPrimary.withValues(alpha: 0.7),
      fontSize: 13,
      fontWeight: kAppBoldFontWeight,
    );
    final scaledLabelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize ?? 13) * 1.2;
    final fieldTopPadding = (scaledLabelHeight / 2).clamp(8.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: widget.showLabel ? fieldTopPadding : 0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: LibraryMetrics.defaultFieldHeight,
                ),
                child: Row(
                  children: [
                    for (final (position, part)
                        in dateEntryPartOrder(AppFormats.current.dateEntry)
                            .indexed) ...[
                      if (position > 0) _dateConnector(palette),
                      Expanded(
                        flex: part == 0 ? 3 : 2,
                        child: _datePartField(
                          palette: palette,
                          key: _partKey(['year', 'month', 'day'][part]),
                          controller: [
                            _yearController,
                            _monthController,
                            _dayController
                          ][part],
                          hintText: ['YYYY', 'MM', 'DD'][part],
                          focusNode: position == 0 ? widget.focusNode : null,
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Pick with calendar',
                      onPressed: () => _pickWithCalendar(context),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      constraints: const BoxConstraints.tightFor(
                        width: LibraryMetrics.defaultFieldHeight,
                        height: LibraryMetrics.defaultFieldHeight,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      splashRadius: LibraryMetrics.defaultFieldHeight / 2,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showLabel)
              Positioned(
                left: 10,
                top: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(widget.label, style: labelStyle),
                ),
              ),
          ],
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _datePartField({
    Key? key,
    required AppThemePalette palette,
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
  }) {
    final outline = OutlineInputBorder(
      borderSide: BorderSide(color: palette.divider),
      borderRadius: BorderRadius.circular(kAppInputBorderRadius),
    );
    return LibraryTextFormControl(
      key: key,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(hintText.length),
      ],
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        filled: true,
        fillColor: palette.surface,
        border: outline,
        enabledBorder: outline,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: palette.utilityAction, width: 1.5),
          borderRadius: BorderRadius.circular(kAppInputBorderRadius),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
      onChanged: (_) {
        _emitValueIfPossible();
      },
    );
  }

  Key? _partKey(String part) {
    final prefix = widget.fieldKeyPrefix;
    return prefix == null ? null : ValueKey('$prefix-$part');
  }

  Future<void> _pickWithCalendar(BuildContext context) async {
    final now = DateTime.now();
    final initial = _selectedDate ?? widget.value ?? now;
    final picked = await showAppAnchoredCalendar(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      _syncFromValue(picked);
      widget.onChanged(picked);
    }
  }

  DateTime? get _selectedDate {
    final yearText = _yearController.text.trim();
    final monthText = _monthController.text.trim();
    final dayText = _dayController.text.trim();
    if (yearText.isEmpty && monthText.isEmpty && dayText.isEmpty) {
      return null;
    }
    final year = int.tryParse(yearText);
    final month = int.tryParse(monthText);
    final day = int.tryParse(dayText);
    if (year == null || month == null || day == null) {
      return null;
    }
    final picked = DateTime(year, month, day);
    if (picked.year != year || picked.month != month || picked.day != day) {
      return null;
    }
    return picked;
  }

  void _syncFromValue(DateTime? value) {
    final local = value?.toLocal();
    _yearController.text = local?.year.toString() ?? '';
    _monthController.text = local?.month.toString().padLeft(2, '0') ?? '';
    _dayController.text = local?.day.toString().padLeft(2, '0') ?? '';
    _lastEmittedValue = value;
  }

  void _emitValueIfPossible() {
    final rawYear = _yearController.text.trim();
    final rawMonth = _monthController.text.trim();
    final rawDay = _dayController.text.trim();
    if (rawYear.isEmpty && rawMonth.isEmpty && rawDay.isEmpty) {
      if (_lastEmittedValue != null) {
        _lastEmittedValue = null;
        widget.onChanged(null);
      }
      return;
    }
    final selected = _selectedDate;
    if (selected != null && selected != _lastEmittedValue) {
      _lastEmittedValue = selected;
      widget.onChanged(selected);
      return;
    }
    if (selected == null) {
      return;
    }
  }

  Widget _dateConnector(AppThemePalette palette) => Container(
        width: 8,
        height: 1,
        color: palette.divider,
      );
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
            child: LibraryDateFieldButton(
              label: label,
              value: selectedDate,
              onChanged: (value) => setDialogState(() {
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
