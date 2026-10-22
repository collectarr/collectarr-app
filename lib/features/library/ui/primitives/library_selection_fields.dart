import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
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
          minHeight: LibraryMetrics.defaultFieldHeight,
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
          minHeight: LibraryMetrics.defaultFieldHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: LibraryMetrics.defaultFieldHeight - 2,
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
        builder: (context, current, _) => _vocabularyValuesField(
          context,
          label: label,
          values: splitPickListValues(current.text),
          options: options,
          enabled: enabled,
          hint: hint,
          errorText: validator?.call(current.text),
          onChanged: (next) {
            final text = joinPickListValues(next) ?? '';
            controller.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
            onChanged?.call(text.isEmpty ? null : text);
          },
        ),
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

/// Holds the values of a multi-value pick list field, such as Tags.
class LibraryValuesController extends ValueNotifier<List<String>> {
  LibraryValuesController([super.value = const []]);
}

/// Multi-value pick list field whose values are kept as a list.
class LibraryMultiVocabularyField extends StatelessWidget {
  const LibraryMultiVocabularyField({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.onChanged,
  });

  final String label;
  final List<String> options;
  final LibraryValuesController controller;
  final String? hint;
  final bool enabled;
  final ValueChanged<List<String>>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: controller,
      builder: (context, values, _) => _vocabularyValuesField(
        context,
        label: label,
        values: values,
        options: options,
        enabled: enabled,
        hint: hint,
        onChanged: (next) {
          controller.value = mergePickListValues(builtInValues: next);
          onChanged?.call(controller.value);
        },
      ),
    );
  }
}

Widget _vocabularyValuesField(
  BuildContext context, {
  required String label,
  required List<String> values,
  required List<String> options,
  required bool enabled,
  String? hint,
  String? errorText,
  required ValueChanged<List<String>> onChanged,
}) {
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
    errorText: errorText,
    onChanged: (next) => onChanged(next.toList()),
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
}

/// Two equal, compact choices for a labelled yes/no value.
class LibraryBooleanButtonField extends StatelessWidget {
  const LibraryBooleanButtonField(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.width = 270});
  final double? width;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LibraryFormField(
        label: label,
        labelStyle: const TextStyle(fontSize: 13, height: 20 / 13),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                width: width,
                height: 34,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    border: Border.all(color: palette.divider),
                    borderRadius: BorderRadius.circular(3)),
                child: Row(children: [
                  for (final option in [false, true])
                    Expanded(
                        child: Semantics(
                            button: true,
                            selected: value == option,
                            child: Material(
                                color: value == option
                                    ? palette.divider
                                    : palette.field,
                                child: InkWell(
                                    mouseCursor: SystemMouseCursors.click,
                                    onTap: () => onChanged(option),
                                    child: Center(
                                        child: Text(option ? 'Yes' : 'No',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: value == option
                                                    ? palette.textPrimary
                                                    : palette.textMuted)))))))
                ]))));
  }
}

/// Flat equal-width options; clicking the current option clears the value.
class LibraryFixedChoiceButtonField extends StatelessWidget {
  const LibraryFixedChoiceButtonField(
      {super.key,
      required this.label,
      required this.value,
      required this.options,
      required this.onChanged});
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LibraryFormField(
        label: label,
        labelStyle: const TextStyle(fontSize: 13, height: 20 / 13),
        child: Container(
            height: 34,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                border: Border.all(color: palette.divider),
                borderRadius: BorderRadius.circular(3)),
            child: Row(children: [
              for (final option in options)
                Expanded(
                    child: Semantics(
                        button: true,
                        selected: value == option,
                        child: Material(
                            color: value == option
                                ? palette.divider
                                : palette.field,
                            child: InkWell(
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () =>
                                    onChanged(value == option ? null : option),
                                child: Center(
                                    child: Text(option,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: value == option
                                                ? palette.textPrimary
                                                : palette.textMuted)))))))
            ])));
  }
}
