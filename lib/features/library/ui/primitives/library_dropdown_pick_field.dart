import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';

typedef LibraryDropdownPickHandler = Future<String?> Function({
  required String label,
  required String? selectedValue,
  required List<String> options,
});

/// Single-value dropdown used throughout library edit dialogs.
///
/// The inline caret filters nearby values. The list action opens the full
/// searchable pick list and can provide create/manage actions for persistent
/// vocabularies.
class LibraryDropdownPickField<TValue> extends StatefulWidget {
  const LibraryDropdownPickField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.allowCustomValue = false,
    this.openPicker,
    this.clearOptionLabel,
    this.enabled = true,
  });

  final String label;
  final TValue? value;
  final List<LibraryFieldOption<TValue>> options;
  final ValueChanged<TValue?> onChanged;
  final String? errorText;
  final String? helperText;
  final bool allowCustomValue;
  final LibraryDropdownPickHandler? openPicker;
  final String? clearOptionLabel;
  final bool enabled;

  @override
  State<LibraryDropdownPickField<TValue>> createState() =>
      _LibraryDropdownPickFieldState<TValue>();
}

class _LibraryDropdownPickFieldState<TValue>
    extends State<LibraryDropdownPickField<TValue>> {
  late final TextEditingController _controller;

  List<LibraryFieldOption<TValue>> get _resolvedOptions {
    final values = [...widget.options];
    final current = widget.value;
    if (current != null && !values.any((option) => option.value == current)) {
      values.insert(
        0,
        LibraryFieldOption<TValue>(value: current, label: current.toString()),
      );
    }
    return values;
  }

  List<String> get _labels => [
        for (final option in _resolvedOptions)
          if (option.enabled) option.label,
        if (widget.clearOptionLabel != null) widget.clearOptionLabel!,
      ];

  String? get _currentLabel {
    final current = widget.value;
    if (current == null) return null;
    for (final option in _resolvedOptions) {
      if (option.value == current) return option.label;
    }
    return current.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentLabel ?? '');
  }

  @override
  void didUpdateWidget(covariant LibraryDropdownPickField<TValue> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.options != widget.options) {
      final next = _currentLabel ?? '';
      if (_controller.text != next) _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectLabel(String? label, {bool fromPicker = false}) {
    if (label == widget.clearOptionLabel) {
      widget.onChanged(null);
      return;
    }
    if (label == null || label.isEmpty) {
      widget.onChanged(null);
      return;
    }
    for (final option in _resolvedOptions) {
      if (option.label == label && option.enabled) {
        widget.onChanged(option.value);
        return;
      }
    }
    if ((widget.allowCustomValue || fromPicker) && TValue == String) {
      widget.onChanged(label as TValue);
    }
  }

  Future<void> _openPicker() async {
    final picker = widget.openPicker;
    if (picker == null) return;
    final selected = await picker(
      label: widget.label,
      selectedValue: _currentLabel,
      options: _labels,
    );
    if (selected == null || !mounted) return;
    _controller.value = TextEditingValue(
      text: selected,
      selection: TextSelection.collapsed(offset: selected.length),
    );
    _selectLabel(selected, fromPicker: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleValuePickField(
      controller: _controller,
      label: widget.label,
      options: _labels,
      validator: (_) => widget.errorText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      readOnly: true,
      showPickerListAction: true,
      manageTooltip: 'Select ${widget.label}',
      enabled: widget.enabled,
      onChanged: _selectLabel,
      onManage: _openPicker,
    );
  }
}
