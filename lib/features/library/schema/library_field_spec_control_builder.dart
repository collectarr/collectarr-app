import 'dart:async';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_edit_contributors.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/widgets/multi_pick_list_select_dialog.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_field_spec.dart';

enum LibraryFieldSpecControlMode { add, edit }

typedef LibraryVocabularyValueChanged = void Function({
  required String fieldId,
  required String? listName,
  required String? value,
});

typedef LibraryVocabularyValuesChanged = void Function({
  required String fieldId,
  required String? listName,
  required Set<String> values,
});

/// Builds the controls described by a field spec for both Add and Edit forms.
///
/// The two form renderers still own their layout and submission lifecycle.
/// This builder centralizes the input behavior while keeping the different
/// single-select interactions explicit: Add uses an inline searchable menu;
/// Edit uses the full pick-list dialog.
final class LibraryFieldSpecControlBuilder<TDraft>
    implements LibraryFieldSpecVisitor<TDraft, Widget> {
  const LibraryFieldSpecControlBuilder({
    required this.context,
    required this.draft,
    required this.mode,
    required this.controllerFor,
    required this.onChanged,
    this.onVocabularyValueChanged,
    this.onVocabularyValuesChanged,
    this.mediaKind,
  });

  final BuildContext context;
  final TDraft draft;
  final LibraryFieldSpecControlMode mode;
  final TextEditingController Function(String id, String initialValue)
      controllerFor;
  final VoidCallback onChanged;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final String? mediaKind;

  Widget build(LibraryFieldSpec<TDraft> field) => field.accept(this);

  @override
  Widget visitText(LibraryTextFieldSpec<TDraft> field) {
    final controller = controllerFor(field.id, field.value(draft));
    return TextFormField(
      controller: controller,
      maxLines: field.maxLines,
      obscureText: field.obscureText,
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(draft),
      ),
      onChanged: (value) {
        field.setValue(draft, value);
        onChanged();
      },
    );
  }

  @override
  Widget visitNumber(LibraryNumberFieldSpec<TDraft> field) {
    final controller = controllerFor(
      field.id,
      field.value(draft)?.toString() ?? '',
    );
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(draft),
      ),
      onChanged: (value) {
        field.setValue(draft, _parseNumber(value));
        onChanged();
      },
    );
  }

  @override
  Widget visitDate(LibraryDateFieldSpec<TDraft> field) {
    final value = field.value(draft);
    return LibraryDateFieldButton(
      label: field.label,
      value: value,
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
        onChanged();
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
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: field.label,
        suffixText: field.currency(draft),
        errorText: field.validate(draft),
      ),
      onChanged: (value) {
        field.setCents(draft, _parseMoneyCents(value));
        onChanged();
      },
    );
  }

  @override
  Widget visitToggle(LibraryToggleFieldSpec<TDraft> field) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(field.label),
      value: field.value(draft),
      onChanged: (value) {
        field.setValue(draft, value);
        onChanged();
      },
      subtitle: _fieldError(field),
    );
  }

  @override
  Widget visitSelect<TValue>(LibrarySelectFieldSpec<TDraft, TValue> field) =>
      _buildSelectField(field);

  @override
  Widget visitVocabulary<TValue>(
    LibraryVocabularyFieldSpec<TDraft, TValue> field,
  ) =>
      _buildSelectField(
        field,
        onManage: field.onManage,
        vocabularyKey: field.pickListKey,
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
        labelText: field.label,
        errorText: field.validate(draft),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value?.toString() ?? 'No image selected')),
          if (field.select != null)
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await field.select!(draft);
                if (!context.mounted) return;
                field.updateValue(draft, selected);
                onChanged();
              },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose'),
            ),
        ],
      ),
    );
  }

  @override
  Widget visitReadOnly<TValue>(
    LibraryReadOnlyFieldSpec<TDraft, TValue> field,
  ) =>
      InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(draft),
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
  }) {
    if (mode == LibraryFieldSpecControlMode.add) {
      return CompactSearchDropdownFormField<TValue>(
        initialValue: field.currentValue(draft),
        isExpanded: true,
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(draft),
          suffixIcon: onManage == null
              ? null
              : IconButton(
                  tooltip: 'Manage ${field.label}',
                  onPressed: () async {
                    await onManage(draft);
                    if (context.mounted) onChanged();
                  },
                  icon: const Icon(Icons.tune),
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
          onChanged();
        },
      );
    }

    final currentValue = field.currentValue(draft);
    final resolvedOptions = <LibraryFieldOption<TValue>>[
      if (currentValue != null &&
          !field.options.any((option) => option.value == currentValue))
        LibraryFieldOption<TValue>(
          value: currentValue,
          label: currentValue.toString(),
        ),
      ...field.options,
    ];
    final vocabulary = _vocabularyForField(
      field,
      explicitKey: vocabularyKey,
    );
    final pickListName = vocabulary?.key;
    return LibraryDropdownPickField<TValue>(
      label: field.label,
      value: currentValue,
      options: resolvedOptions,
      errorText: field.validate(draft),
      allowCustomValue: vocabulary?.allowCustomValues ?? false,
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
          allowUserValues: vocabulary?.allowCustomValues ?? false,
          db: db,
        );
      },
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
          listName: vocabulary?.key,
          value: vocabulary?.allowCustomValues == true &&
                  textValue != null &&
                  textValue.isNotEmpty &&
                  !isBuiltIn
              ? textValue
              : null,
        );
        onChanged();
      },
    );
  }

  VocabularyDefinition<dynamic>? _vocabularyForField<TValue>(
    LibrarySingleValueField<TDraft, TValue> field, {
    String? explicitKey,
  }) {
    final apiValue = mediaKind;
    if (apiValue == null) return null;
    final kind = catalogMediaKindFromApiValue(apiValue);
    if (kind.isUnknown) return null;
    final vocabularies = libraryEditCapabilitiesForKind(kind)
        .presentationCapability
        .vocabularies;
    if (vocabularies == null) return null;
    if (explicitKey != null) {
      for (final definition in vocabularies.definitions) {
        if (definition.key == explicitKey) return definition;
      }
    }
    final suffixMatch = vocabularies.definitionForSuffix(field.id);
    if (suffixMatch != null) return suffixMatch;

    // Some field IDs differ from their vocabulary suffix. Match the complete
    // built-in option set only when exactly one vocabulary owns it.
    final optionValues = field.options.map((option) => option.value).toList();
    if (optionValues.isEmpty || optionValues.any((value) => value is! String)) {
      return null;
    }
    final optionSet = optionValues.cast<String>().toSet();
    final matches = <VocabularyDefinition<dynamic>>[];
    for (final definition in vocabularies.definitions) {
      final builtIns = definition.builtIns.whereType<String>().toSet();
      if (builtIns.isNotEmpty &&
          builtIns.length == definition.builtIns.length &&
          builtIns.length == optionSet.length &&
          builtIns.containsAll(optionSet)) {
        matches.add(definition);
      }
    }
    return matches.length == 1 ? matches.single : null;
  }

  Widget _buildMultiSelectField<TValue>(
    LibraryMultiVocabularyFieldSpec<TDraft, TValue> field,
  ) {
    final selected = field.currentValues(draft);
    return LibraryMultiValuePickField<TValue>(
      label: field.label,
      value: selected,
      options: field.options,
      errorText: field.validate(draft),
      allowCustomValueEntry: mode == LibraryFieldSpecControlMode.edit &&
          field.allowCustomValues &&
          field.pickListKey != null &&
          TValue == String,
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
        onChanged();
      },
      onOpenPicker: (
          {required label, required selectedValues, required options}) async {
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
        );
      },
    );
  }

  Widget? _fieldError(LibraryFieldSpec<TDraft> field) {
    final error = field.validate(draft);
    return error == null ? null : Text(error);
  }
}

num? _parseNumber(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  return num.tryParse(normalized);
}

int? _parseMoneyCents(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  return amount == null ? null : (amount * 100).round();
}
