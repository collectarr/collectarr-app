import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_selection_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'dart:async';

/// A section within an edit dialog that renders editors for all custom fields.
///
/// Manages a map of field-definition-id → current value. The caller passes
/// [definitions] and [values] in; on save the caller reads [currentValues].
class CustomFieldsEditSection extends StatefulWidget {
  const CustomFieldsEditSection({
    super.key,
    required this.definitions,
    required this.values,
    required this.accent,
    required this.onChanged,
    this.mediaKind,
    this.onCustomValueChanged,
    this.displaySettings = const {},
  });

  final List<CustomFieldDefinition> definitions;
  final Map<String, String?> values; // definitionId → value
  final Color accent;
  final ValueChanged<Map<String, String?>> onChanged;
  final String? mediaKind;
  final void Function(String fieldDefinitionId, String? value)?
      onCustomValueChanged;
  final Map<String, CustomFieldDisplaySettings> displaySettings;

  @override
  State<CustomFieldsEditSection> createState() =>
      _CustomFieldsEditSectionState();
}

class _CustomFieldsEditSectionState extends State<CustomFieldsEditSection> {
  late final Map<String, String?> _values;
  late final Map<String, CustomFieldDisplaySettings> _display;

  @override
  void initState() {
    super.initState();
    _values = Map.of(widget.values);
    _display = Map.of(widget.displaySettings);
    unawaited(_loadDisplay());
  }

  Future<void> _loadDisplay() async {
    for (final definition in widget.definitions) {
      if (definition.valueType != CustomFieldValueType.singleSelect &&
          definition.valueType != CustomFieldValueType.multiSelect) {
        continue;
      }
      if (_display.containsKey(definition.id)) continue;
      final display = await CustomFieldDisplaySettings.read(definition.id);
      if (!mounted) return;
      setState(() => _display[definition.id] = display);
    }
  }

  void _update(String definitionId, String? value) {
    setState(() => _values[definitionId] = value);
    widget.onChanged(_values);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.definitions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text('No custom fields defined. Add them in Settings ? Data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kEditTextMuted, fontSize: 14)),
      );
    }
    return EditSection(
      title: 'Custom Fields',
      accent: widget.accent,
      child: Column(
        children: [
          for (var i = 0; i < widget.definitions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildField(widget.definitions[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildField(CustomFieldDefinition def) {
    final value = _values[def.id];
    final mediaKind = def.mediaKind ?? widget.mediaKind;
    if (def.supportsOptions &&
        !def.valueType.isFixedChoice &&
        mediaKind != null) {
      return LibraryVocabularyOptionsLoader(
          listName: 'customField:${def.id}',
          mediaKind: mediaKind,
          builtIns: def.optionValues,
          selected: def.valueType.isMultiValue
              ? parseCustomFieldMultiValues(value)
              : [if (value != null) value],
          builder: (options) => _buildFieldWithOptions(def, value, options));
    }
    return _buildFieldWithOptions(def, value, def.optionValues);
  }

  Widget _buildFieldWithOptions(
      CustomFieldDefinition def, String? value, List<String> choices) {
    return switch (def.valueType) {
      CustomFieldValueType.boolean => LibrarySwitchField(
          value: value == 'true',
          onChanged: (selected) => _update(def.id, selected.toString()),
          label: def.name,
        ),
      CustomFieldValueType.singleSelect => LibraryDropdownPickField<String>(
          label: def.name,
          value: value,
          options: [
            for (final option in choices)
              LibraryFieldOption<String>(value: option, label: option),
          ],
          clearOptionLabel: '—',
          helperText: _scopeLabel(def.targetScope),
          allowCustomValue: true,
          openPicker: (
              {required label, required selectedValue, required options}) {
            final db = ProviderScope.containerOf(context, listen: false)
                .read(localDatabaseProvider);
            return showPickListSelectDialog(
              context: context,
              label: label,
              pluralLabel: _display[def.id]?.pluralName,
              options: options,
              selectedValue: selectedValue,
              listName: 'customField:${def.id}',
              mediaKind: def.mediaKind ?? widget.mediaKind,
              allowUserValues: true,
              db: db,
            );
          },
          onChanged: (v) {
            _update(def.id, v);
            final normalized = v?.trim();
            final isConfiguredOption = normalized != null &&
                def.optionValues.any(
                  (option) =>
                      option.trim().toLowerCase() == normalized.toLowerCase(),
                );
            widget.onCustomValueChanged?.call(
              def.id,
              normalized != null && normalized.isNotEmpty && !isConfiguredOption
                  ? normalized
                  : null,
            );
          },
        ),
      CustomFieldValueType.multiSelect => _multiValueField(def, value, choices),
      CustomFieldValueType.fixedButtons => LibraryFormField(
          label: def.name,
          child: Wrap(spacing: 4, runSpacing: 4, children: [
            for (final option in choices)
              ChoiceChip(
                label: Text(option),
                selected: value == option,
                onSelected: (selected) {
                  _update(def.id, selected ? option : null);
                },
              ),
          ]),
        ),
      CustomFieldValueType.fixedList => LibrarySelectField<String>(
          label: def.name,
          value: value,
          items: [
            const DropdownMenuItem(value: null, child: Text('None')),
            for (final option in choices)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (selected) => _update(def.id, selected),
        ),
      CustomFieldValueType.date => _DateCustomField(
          label: def.name,
          value: value,
          onChanged: (v) => _update(def.id, v),
        ),
      CustomFieldValueType.time => _TimeCustomField(
          label: def.name,
          value: value,
          onChanged: (v) => _update(def.id, v),
        ),
      CustomFieldValueType.duration => _textField(
          def,
          keyboardType: TextInputType.datetime,
          validator: (value) => value == null ||
                  value.isEmpty ||
                  RegExp(r'^\d+:([0-5]\d)$').hasMatch(value)
              ? null
              : 'Use hours:minutes (for example 27:15)',
        ),
      CustomFieldValueType.longText => _textField(
          def,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
        ),
      CustomFieldValueType.number ||
      CustomFieldValueType.decimal ||
      CustomFieldValueType.percentage ||
      CustomFieldValueType.weight ||
      CustomFieldValueType.size ||
      CustomFieldValueType.currency =>
        _textField(
          def,
          keyboardType: def.valueType == CustomFieldValueType.number
              ? TextInputType.number
              : const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
          suffixText:
              def.valueType == CustomFieldValueType.percentage ? '%' : def.unit,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final pattern = def.valueType == CustomFieldValueType.number
                  ? RegExp(r'^-?\d*$')
                  : RegExp(r'^-?\d*(\.\d{0,2})?$');
              return pattern.hasMatch(newValue.text) ? newValue : oldValue;
            }),
          ],
        ),
      CustomFieldValueType.url => _textField(
          def,
          keyboardType: TextInputType.url,
        ),
      CustomFieldValueType.person => _textField(
          def,
          textCapitalization: TextCapitalization.words,
        ),
      _ => _textField(
          def,
          keyboardType: def.valueType == CustomFieldValueType.number
              ? TextInputType.number
              : null,
        ),
    };
  }

  Widget _multiValueField(
      CustomFieldDefinition def, String? value, List<String> choices) {
    final selected = parseCustomFieldMultiValues(value).toSet();
    final options = [
      for (final choice in choices)
        LibraryFieldOption<String>(value: choice, label: choice)
    ];
    Future<Set<String>?> openPicker() => showAppDialog<Set<String>>(
          context: context,
          builder: (_) => PickListSelectionDialog(
            label: def.name,
            pluralLabel: _display[def.id]?.pluralName,
            options: choices,
            selectedValues: selected.toList(),
            multiple: true,
            listName: 'customField:${def.id}',
            mediaKind: def.mediaKind ?? widget.mediaKind,
            allowUserValues: true,
            db: ProviderScope.containerOf(context, listen: false)
                .read(localDatabaseProvider),
          ),
        );
    if (_display[def.id]?.multiValueControl ==
        CustomFieldMultiValueControl.checkboxes) {
      return LibraryFormField(
        label: def.name,
        action: IconButton(
            tooltip: 'Manage values',
            icon: const Icon(Icons.list_alt, size: 16),
            onPressed: () async {
              final result = await openPicker();
              if (result != null && mounted) {
                _update(def.id, encodeCustomFieldMultiValues(result));
              }
            }),
        child: Column(children: [
          for (final choice in choices)
            CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(choice),
                value: selected.contains(choice),
                onChanged: (checked) {
                  if (checked == true) {
                    selected.add(choice);
                  } else {
                    selected.remove(choice);
                  }
                  _update(def.id, encodeCustomFieldMultiValues(selected));
                }),
        ]),
      );
    }
    return LibraryMultiValuePickField<String>(
      label: def.name,
      value: selected,
      options: options,
      onChanged: (values) =>
          _update(def.id, encodeCustomFieldMultiValues(values)),
      onOpenPicker: (
              {required label,
              required selectedValues,
              required options,
              searchHint,
              customValueHint}) =>
          openPicker(),
    );
  }

  Widget _textField(
    CustomFieldDefinition def, {
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    final value = _values[def.id];
    return LibraryFormField(
      label: def.name,
      child: LibraryTextFormControl(
        initialValue: value ?? '',
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters ??
            (def.valueType == CustomFieldValueType.text
                ? [LengthLimitingTextInputFormatter(250)]
                : null),
        validator: validator,
        decoration: InputDecoration(
            suffixText: suffixText, helperText: _scopeLabel(def.targetScope)),
        onChanged: (input) {
          final trimmed = input.trim();
          _update(def.id, trimmed.isEmpty ? null : trimmed);
        },
      ),
    );
  }

  String _scopeLabel(CustomFieldTargetScope scope) {
    return switch (scope) {
      CustomFieldTargetScope.libraryEntry => 'Collection item',
      CustomFieldTargetScope.all => 'All',
    };
  }
}

class _DateCustomField extends StatelessWidget {
  const _DateCustomField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LibraryFormField(
      label: label,
      action: IconButton(
        tooltip: 'Pick date',
        padding: EdgeInsets.zero,
        iconSize: 16,
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(value ?? '') ?? DateTime.now(),
            firstDate: DateTime(1),
            lastDate: DateTime(9999),
          );
          if (date != null) {
            onChanged(PartialDate.fromDateTime(date).isoString);
          }
        },
        icon: const Icon(Icons.calendar_month),
      ),
      child: LibraryPartialDateInput(
        value: PartialDate.tryParse(value),
        onChanged: (date) => onChanged(date?.isoString),
      ),
    );
  }
}

class _TimeCustomField extends StatelessWidget {
  const _TimeCustomField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final parsed = _parseTimeOfDay(value);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        constraints: const BoxConstraints(
          minHeight: LibraryMetrics.defaultFieldHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: LibraryMetrics.defaultFieldHeight - 2,
        child: Row(
          children: [
            Expanded(
              child: Text(
                parsed == null ? 'No time set' : _formatTimeOfDay(parsed),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize:
                    const Size(0, LibraryMetrics.defaultFieldHeight - 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: parsed ?? const TimeOfDay(hour: 12, minute: 0),
                );
                if (picked == null || !context.mounted) {
                  return;
                }
                onChanged(_formatTimeOfDay(picked));
              },
              child: const Text('Pick time'),
            ),
            if (parsed != null)
              IconButton(
                tooltip: 'Clear time',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: LibraryMetrics.defaultFieldHeight - 8,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

TimeOfDay? _parseTimeOfDay(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
  if (match == null) {
    return null;
  }
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTimeOfDay(TimeOfDay value) {
  return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
