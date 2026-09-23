import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';

/// Typed dropdown chrome shared by Library surfaces.
class LibrarySelectField<T> extends StatelessWidget {
  const LibrarySelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.decoration,
    this.enabled = true,
    this.isExpanded = true,
    this.validator,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration? decoration;
  final bool enabled;
  final bool isExpanded;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return CompactSearchDropdownFormField<T>(
      initialValue: value,
      decoration: decoration ?? InputDecoration(labelText: label),
      items: items,
      onChanged: enabled ? onChanged : null,
      isExpanded: isExpanded,
      validator: validator,
    );
  }
}

/// Vocabulary-aware single or multi-value field.
///
/// The control owns selection mechanics while callers provide vocabulary
/// values and persistence callbacks; no kind-specific semantics live here.
class LibraryVocabularyField extends StatelessWidget {
  const LibraryVocabularyField({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
    this.hint,
    this.validator,
    this.enabled = true,
    this.multiSelect = false,
    this.onChanged,
    this.onManage,
    this.manageTooltip,
  });

  final String label;
  final List<String> options;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool multiSelect;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onManage;
  final String? manageTooltip;

  @override
  Widget build(BuildContext context) {
    if (multiSelect) {
      return TagPickListField(
        controller: controller,
        options: options,
        label: label,
        hint: hint,
        validator: validator,
        enabled: enabled,
      );
    }
    if (onManage != null) {
      return SingleValuePickField(
        controller: controller,
        options: options,
        label: label,
        hint: hint,
        validator: validator,
        onChanged: onChanged,
        onManage: onManage,
        manageTooltip: manageTooltip,
        enabled: enabled,
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, current, _) => LibraryDropdownPickField<String>(
        label: label,
        value: current.text.trim().isEmpty ? null : current.text.trim(),
        enabled: enabled,
        options: [
          for (final option in options)
            LibraryFieldOption<String>(value: option, label: option),
        ],
        helperText: hint,
        errorText: validator?.call(current.text),
        allowCustomValue: true,
        openPicker: (
            {required label, required selectedValue, required options}) {
          return showPickListSelectDialog(
            context: context,
            label: label,
            options: options,
            selectedValue: selectedValue,
            allowUserValues: true,
          );
        },
        onChanged: (value) {
          controller.text = value ?? '';
          onChanged?.call(value);
        },
      ),
    );
  }
}
