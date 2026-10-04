import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
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
      decoration: (decoration ?? InputDecoration(labelText: label)).copyWith(
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      isExpanded: isExpanded,
      validator: validator,
    );
  }
}

class LibrarySwitchField extends StatelessWidget {
  const LibrarySwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        errorText: errorText,
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: kLibraryFormControlHeight - 2,
        child: MergeSemantics(
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Switch.adaptive(
                value: value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
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
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, current, _) {
          final values = splitPickListValues(current.text);
          return LibraryMultiValuePickField<String>(
            label: label,
            value: values.toSet(),
            options: [
              for (final option in options)
                LibraryFieldOption<String>(value: option, label: option),
            ],
            enabled: enabled,
            allowCustomValueEntry: true,
            hintText: hint,
            errorText: validator?.call(current.text),
            onChanged: (next) {
              final text = joinPickListValues(next) ?? '';
              controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
              onChanged?.call(text.isEmpty ? null : text);
            },
            onOpenPicker: ({
              required label,
              required selectedValues,
              required options,
              searchHint,
              customValueHint,
            }) =>
                showLibraryMultiValueOptionsDialog<String>(
              context: context,
              label: label,
              options: options,
              selectedValues: selectedValues,
              searchHint: searchHint,
              customValueHint: customValueHint ?? 'Add value',
            ),
          );
        },
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, current, _) {
        final selectedValue = current.text.trim();
        return LibraryDropdownPickField<String>(
          label: label,
          value: selectedValue.isEmpty ? null : selectedValue,
          enabled: enabled,
          options: [
            for (final option in options)
              LibraryFieldOption<String>(value: option, label: option),
          ],
          helperText: hint,
          errorText: validator?.call(current.text),
          allowCustomValue: true,
          manageTooltip: manageTooltip,
          onManage: onManage,
          openPicker: onManage != null
              ? null
              : ({
                  required label,
                  required selectedValue,
                  required options,
                }) =>
                  showPickListSelectDialog(
                    context: context,
                    label: label,
                    options: options,
                    selectedValue: selectedValue,
                    allowUserValues: true,
                  ),
          onChanged: (value) {
            final text = value ?? '';
            controller.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
            onChanged?.call(value);
          },
        );
      },
    );
  }
}
