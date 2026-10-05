import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_edit_contributors.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/widgets/multi_pick_list_select_dialog.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';

import 'library_field_spec.dart';

enum LibraryFieldSpecControlMode { add, edit }

/// Builds the controls described by a field spec for both Add and Edit forms.
///
/// The owning Add or Edit shell manages submission and draft lifecycle. This
/// builder centralizes input behavior while keeping the different single-
/// select interactions explicit: Add uses an inline searchable menu; Edit
/// uses the full pick-list dialog.
final class LibraryFieldSpecControlBuilder<TDraft>
    implements LibraryFieldSpecVisitor<TDraft, Widget> {
  const LibraryFieldSpecControlBuilder({
    required this.context,
    required this.draft,
    required this.mode,
    required this.controllerFor,
    this.onChanged,
    this.onVocabularyValueChanged,
    this.onVocabularyValuesChanged,
    this.mediaKind,
    this.focusNodeFor,
  });

  final BuildContext context;
  final TDraft draft;
  final LibraryFieldSpecControlMode mode;
  final TextEditingController Function(String id, String initialValue)
      controllerFor;
  final VoidCallback? onChanged;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final String? mediaKind;
  final FocusNode? Function(String fieldId)? focusNodeFor;

  FocusNode? _focusNode(String fieldId) => focusNodeFor?.call(fieldId);

  Widget build(LibraryFieldSpec<TDraft> field) {
    final child = field.accept(this);
    final external = field is LibraryTextFieldSpec<TDraft> ||
        field is LibraryNumberFieldSpec<TDraft> ||
        field is LibraryMoneyFieldSpec<TDraft> ||
        field is LibraryPartialDateFieldSpec<TDraft> ||
        field is LibraryDateFieldSpec<TDraft> ||
        field is LibrarySelectFieldSpec<TDraft, Object?> ||
        field is LibraryImageFieldSpec<TDraft, Object?> ||
        field is LibraryReadOnlyFieldSpec<TDraft, Object?> ||
        (mode == LibraryFieldSpecControlMode.add &&
            field is LibraryVocabularyFieldSpec<TDraft, Object?>);
    final labelled = external
        ? LibraryFormField(
            label: field.label,
            action: field is LibraryTextFieldSpec<TDraft> &&
                    field.actions.isNotEmpty
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    for (final action in field.actions)
                      Tooltip(
                        message: action.label,
                        child: InkWell(
                          onTap: () {
                            final controller =
                                controllerFor(field.id, field.value(draft));
                            final text = action.transform(controller.text);
                            controller.value = TextEditingValue(
                              text: text,
                              selection:
                                  TextSelection.collapsed(offset: text.length),
                            );
                            field.setValue(draft, text);
                            onChanged?.call();
                          },
                          child: SizedBox(
                            width: 22,
                            height: 16,
                            child: Icon(action.icon, size: 16),
                          ),
                        ),
                      ),
                  ])
                : field is LibraryPartialDateFieldSpec<TDraft>
                    ? Tooltip(
                        message: 'Choose ${field.label}',
                        child: InkWell(
                          onTap: () async {
                            final value = field.value(draft);
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: value?.asDateTime ??
                                  DateTime(value?.year ?? now.year,
                                      value?.month ?? 1),
                              firstDate: DateTime(1),
                              lastDate: DateTime(9999, 12, 31),
                            );
                            if (!context.mounted || picked == null) return;
                            field.updateValue(
                                draft, PartialDate.fromDateTime(picked));
                            onChanged?.call();
                          },
                          child: const SizedBox(
                            width: 22,
                            height: 16,
                            child: Icon(Icons.calendar_month, size: 16),
                          ),
                        ),
                      )
                    : null,
            child: child,
          )
        : child;
    final focusNode = _focusNode(field.id);
    final hasControlFocus = field is LibraryTextFieldSpec<TDraft> ||
        field is LibraryNumberFieldSpec<TDraft> ||
        field is LibraryMoneyFieldSpec<TDraft> ||
        field is LibraryDateFieldSpec<TDraft> ||
        field is LibraryPartialDateFieldSpec<TDraft> ||
        field is LibrarySingleValueField<TDraft, dynamic>;
    final hasFieldValidator = field.validator != null &&
        field is! LibraryTextFieldSpec<TDraft> &&
        field is! LibraryNumberFieldSpec<TDraft> &&
        field is! LibraryMoneyFieldSpec<TDraft>;
    Widget result = labelled;
    if (hasFieldValidator) {
      result = FormField<void>(
        key: ValueKey<String>('library-field-validator-${field.id}'),
        validator: (_) => field.validate(draft),
        builder: (_) => labelled,
      );
    }
    if (focusNode != null && !hasControlFocus) {
      result = Focus(focusNode: focusNode, child: result);
    }
    return result;
  }

  @override
  Widget visitText(LibraryTextFieldSpec<TDraft> field) {
    final controller = controllerFor(field.id, field.value(draft));
    return LibraryTextFormControl(
      controller: controller,
      focusNode: _focusNode(field.id),
      maxLines: field.maxLines,
      obscureText: field.obscureText,
      validator: (_) => field.validate(draft),
      decoration: _controlDecoration(
        InputDecoration(errorText: field.validate(draft)),
      ),
      onChanged: (value) {
        field.setValue(draft, value);
        onChanged?.call();
      },
    );
  }

  @override
  Widget visitNumber(LibraryNumberFieldSpec<TDraft> field) {
    final controller = controllerFor(
      field.id,
      field.value(draft)?.toString() ?? '',
    );
    return LibraryTextFormControl(
      controller: controller,
      focusNode: _focusNode(field.id),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (_) => libraryNumberFieldError(field, controller.text, draft),
      decoration: _controlDecoration(
        InputDecoration(
          errorText: libraryNumberFieldError(field, controller.text, draft),
        ),
      ),
      onChanged: (value) {
        field.setValue(draft, _parseNumber(value));
        onChanged?.call();
      },
    );
  }

  @override
  Widget visitDate(LibraryDateFieldSpec<TDraft> field) {
    final value = field.value(draft);
    return LibraryDateFieldButton(
      label: field.label,
      showLabel: false,
      value: value,
      focusNode: _focusNode(field.id),
      errorText: field.validate(draft),
      onChanged: (picked) {
        var selected = picked;
        if (picked != null && field.includeTime && value != null) {
          selected = DateTime(
            picked.year,
            picked.month,
            picked.day,
            value.hour,
            value.minute,
          );
        }
        field.setValue(draft, selected);
        onChanged?.call();
      },
    );
  }

  @override
  Widget visitPartialDate(LibraryPartialDateFieldSpec<TDraft> field) {
    return LibraryPartialDateInput(
      value: field.value(draft),
      focusNode: _focusNode(field.id),
      onChanged: (value) {
        field.updateValue(draft, value);
        onChanged?.call();
      },
    );
  }

  @override
  Widget visitMoney(LibraryMoneyFieldSpec<TDraft> field) {
    final cents = field.cents(draft);
    final controller = controllerFor(
      field.id,
      cents == null ? '' : (cents / 100).toStringAsFixed(2),
    );
    return LibraryTextFormControl(
      controller: controller,
      focusNode: _focusNode(field.id),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (_) => field.validate(draft),
      decoration: _controlDecoration(
        InputDecoration(
          suffixText: field.currency(draft),
          errorText: field.validate(draft),
        ),
      ),
      onChanged: (value) {
        field.setCents(draft, _parseMoneyCents(value));
        onChanged?.call();
      },
    );
  }

  @override
  Widget visitToggle(LibraryToggleFieldSpec<TDraft> field) =>
      LibrarySwitchField(
        label: field.label,
        value: field.value(draft),
        errorText: field.validate(draft),
        onChanged: (value) {
          field.setValue(draft, value);
          onChanged?.call();
        },
      );

  @override
  Widget visitSelect<TValue>(LibrarySelectFieldSpec<TDraft, TValue> field) =>
      _buildSelectField(field, showFieldLabel: false);

  @override
  Widget visitVocabulary<TValue>(
    LibraryVocabularyFieldSpec<TDraft, TValue> field,
  ) =>
      _buildSelectField(
        field,
        onManage: field.onManage,
        vocabularyKey: field.pickListKey,
        showFieldLabel: mode == LibraryFieldSpecControlMode.edit,
      );

  @override
  Widget visitMultiVocabulary<TValue>(
    LibraryMultiVocabularyFieldSpec<TDraft, TValue> field,
  ) =>
      _buildMultiSelectField(field);

  @override
  Widget visitImage<TValue>(LibraryImageFieldSpec<TDraft, TValue> field) {
    final value = field.currentValue(draft);
    return InputDecorator(
      decoration: InputDecoration(
        errorText: field.validate(draft),
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: kLibraryFormControlHeight - 2,
        child: Row(
          children: [
            Expanded(child: Text(value?.toString() ?? 'No image selected')),
            if (field.select != null)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, kLibraryFormControlHeight - 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () async {
                  final selected = await field.select!(draft);
                  if (!context.mounted) return;
                  field.updateValue(draft, selected);
                  onChanged?.call();
                },
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Choose'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget visitReadOnly<TValue>(
    LibraryReadOnlyFieldSpec<TDraft, TValue> field,
  ) =>
      InputDecorator(
        decoration: _controlDecoration(
          InputDecoration(
            errorText: field.validate(draft),
          ),
        ),
        child: Text(field.displayValue(draft)),
      );

  @override
  Widget visitCustom(LibraryCustomFieldSpec<TDraft> field) =>
      field.builder(context, draft);

  Widget _buildSelectField<TValue>(
    LibrarySingleValueField<TDraft, TValue> field, {
    FutureOr<void> Function(TDraft draft)? onManage,
    String? vocabularyKey,
    bool showFieldLabel = true,
    List<String>? loadedOptions,
  }) {
    final vocabulary = _vocabularyForField(vocabularyKey);
    if (TValue == String &&
        vocabularyKey != null &&
        mediaKind != null &&
        loadedOptions == null) {
      return LibraryVocabularyOptionsLoader(
        listName: vocabularyKey,
        mediaKind: mediaKind!,
        builtIns: [for (final option in field.options) option.value as String],
        selected: [
          if (field.currentValue(draft) != null)
            field.currentValue(draft) as String
        ],
        builder: (options) => _buildSelectField(field,
            onManage: onManage,
            vocabularyKey: vocabularyKey,
            showFieldLabel: showFieldLabel,
            loadedOptions: options),
      );
    }

    if (mode == LibraryFieldSpecControlMode.add &&
        vocabulary == null &&
        vocabularyKey == null) {
      return CompactSearchDropdownFormField<TValue>(
        initialValue: field.currentValue(draft),
        isExpanded: true,
        decoration: _controlDecoration(
          InputDecoration(
            labelText: '',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            errorText: field.validate(draft),
            suffixIcon: onManage == null
                ? null
                : IconButton(
                    tooltip: 'Manage ${field.label}',
                    onPressed: () async {
                      await onManage(draft);
                      if (context.mounted) onChanged?.call();
                    },
                    icon: const Icon(Icons.tune),
                  ),
          ),
        ),
        items: [
          for (final option in field.options)
            DropdownMenuItem<TValue>(
              value: option.value,
              enabled: option.enabled,
              child: Text(option.label),
            ),
        ],
        onChanged: (value) {
          field.updateValue(draft, value);
          onChanged?.call();
        },
      );
    }

    final currentValue = field.currentValue(draft);
    final resolvedOptions = <LibraryFieldOption<TValue>>[
      if (currentValue != null &&
          !field.options.any((option) => option.value == currentValue) &&
          !(loadedOptions?.contains(currentValue) ?? false))
        LibraryFieldOption<TValue>(
          value: currentValue,
          label: currentValue.toString(),
        ),
      ...field.options,
      if (TValue == String && loadedOptions != null)
        for (final value in loadedOptions)
          if (!field.options.any((option) => option.value == value))
            LibraryFieldOption<TValue>(value: value as TValue, label: value),
    ];
    final pickListName = vocabulary?.key ?? vocabularyKey;
    final allowCustomValues =
        vocabulary?.allowCustomValues ?? (vocabularyKey != null);
    return LibraryDropdownPickField<TValue>(
      label: field.label,
      showFieldLabel: showFieldLabel,
      value: currentValue,
      focusNode: _focusNode(field.id),
      options: resolvedOptions,
      errorText: field.validate(draft),
      allowCustomValue: allowCustomValues,
      openPicker: ({required label, required selectedValue, required options}) {
        final db = pickListName == null
            ? null
            : ProviderScope.containerOf(context, listen: false)
                .read(localDatabaseProvider);
        return showPickListSelectDialog(
          context: context,
          label: label,
          options: options,
          selectedValue: selectedValue,
          listName: pickListName,
          mediaKind: mediaKind,
          allowUserValues: allowCustomValues,
          db: db,
        );
      },
      onManage: mode == LibraryFieldSpecControlMode.add && onManage != null
          ? () async {
              await onManage(draft);
              if (context.mounted) onChanged?.call();
            }
          : null,
      onChanged: (value) {
        field.updateValue(draft, value);
        final textValue = value is String ? value.trim() : null;
        final isBuiltIn = textValue != null &&
            vocabulary?.builtIns.any(
                  (builtIn) =>
                      builtIn.toString().trim().toLowerCase() ==
                      textValue.toLowerCase(),
                ) ==
                true;
        onVocabularyValueChanged?.call(
          fieldId: field.id,
          listName: pickListName,
          value: allowCustomValues &&
                  textValue != null &&
                  textValue.isNotEmpty &&
                  !isBuiltIn
              ? textValue
              : null,
        );
        onChanged?.call();
      },
    );
  }

  InputDecoration _controlDecoration(InputDecoration decoration) =>
      decoration.copyWith(
        labelText: '',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
      );

  VocabularyDefinition<dynamic>? _vocabularyForField(String? vocabularyKey) {
    if (vocabularyKey == null || vocabularyKey.isEmpty) return null;
    final apiValue = mediaKind;
    if (apiValue == null) return null;
    final kind = catalogMediaKindFromApiValue(apiValue);
    if (kind.isUnknown) return null;
    final vocabularies = libraryEditCapabilitiesForKind(kind)
        .presentationCapability
        .vocabularies;
    if (vocabularies == null) return null;
    for (final definition in vocabularies.definitions) {
      if (definition.key == vocabularyKey) return definition;
    }
    return null;
  }

  Widget _buildMultiSelectField<TValue>(
    LibraryMultiVocabularyFieldSpec<TDraft, TValue> field, {
    List<String>? loadedOptions,
  }) {
    if (TValue == String &&
        field.pickListKey != null &&
        mediaKind != null &&
        loadedOptions == null) {
      return LibraryVocabularyOptionsLoader(
        listName: field.pickListKey!,
        mediaKind: mediaKind!,
        builtIns: [for (final option in field.options) option.value as String],
        selected: field.currentValues(draft).cast<String>().toList(),
        builder: (options) =>
            _buildMultiSelectField(field, loadedOptions: options),
      );
    }
    final selected = field.currentValues(draft);
    return LibraryMultiValuePickField<TValue>(
      label: field.label,
      value: selected,
      options: [
        ...field.options,
        if (TValue == String && loadedOptions != null)
          for (final value in loadedOptions)
            if (!field.options.any((option) => option.value == value))
              LibraryFieldOption<TValue>(value: value as TValue, label: value),
      ],
      errorText: field.validate(draft),
      allowCustomValueEntry: field.allowCustomValues && TValue == String,
      onChanged: (next) {
        field.updateValues(draft, next);
        final listName = field.pickListKey;
        if (TValue == String && field.allowCustomValues && listName != null) {
          final builtInValues = field.options
              .map((option) => option.value.toString().trim().toLowerCase())
              .toSet();
          onVocabularyValuesChanged?.call(
            fieldId: field.id,
            listName: listName,
            values: {
              for (final value in next.cast<String>())
                if (value.trim().isNotEmpty &&
                    !builtInValues.contains(value.trim().toLowerCase()))
                  value.trim(),
            },
          );
        }
        onChanged?.call();
      },
      onOpenPicker: (
          {required label,
          required selectedValues,
          required options,
          searchHint,
          customValueHint}) async {
        final pickListKey = field.pickListKey;
        if (TValue == String && pickListKey != null) {
          final db = ProviderScope.containerOf(context, listen: false)
              .read(localDatabaseProvider);
          final picked = await showMultiPickListSelectDialog(
            context: context,
            label: label,
            pluralLabel: field.pluralLabel,
            options: [for (final option in options) option.value as String],
            selectedValues: selectedValues.cast<String>(),
            listName: pickListKey,
            mediaKind: mediaKind,
            allowUserValues: field.allowCustomValues,
            db: db,
          );
          if (!context.mounted || picked == null) return null;
          return picked.cast<TValue>();
        }
        return showLibraryMultiValueOptionsDialog<TValue>(
          context: context,
          label: label,
          options: options,
          selectedValues: selectedValues,
          allowCustomValues: field.allowCustomValues,
          searchHint: searchHint,
          customValueHint: customValueHint ?? 'Add value',
        );
      },
    );
  }
}

String? libraryNumberFieldError<TDraft>(
  LibraryNumberFieldSpec<TDraft> field,
  String raw,
  TDraft draft,
) {
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return field.validate(draft);
  final value = num.tryParse(normalized);
  if (value == null) return 'Enter a valid number';
  final minimum = field.minimum;
  if (minimum != null && value < minimum) {
    return 'Must be at least $minimum';
  }
  final maximum = field.maximum;
  if (maximum != null && value > maximum) {
    return 'Must be at most $maximum';
  }
  final places = field.decimalPlaces;
  if (places != null && places >= 0) {
    final scale = math.pow(10, places).toDouble();
    if ((value * scale - (value * scale).round()).abs() > 1e-8) {
      return places == 0
          ? 'Enter a whole number'
          : 'Use at most $places decimal places';
    }
  }
  return field.validate(draft);
}

num? _parseNumber(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return num.tryParse(normalized);
}

int? _parseMoneyCents(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  return amount == null ? null : (amount * 100).round();
}
