import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  final List<CustomFieldDefinition> definitions;
  final Map<String, String?> values; // definitionId → value
  final Color accent;
  final ValueChanged<Map<String, String?>> onChanged;
  final String? mediaKind;
  final void Function(String fieldDefinitionId, String? value)?
      onCustomValueChanged;

  @override
  State<CustomFieldsEditSection> createState() =>
      _CustomFieldsEditSectionState();
}

class _CustomFieldsEditSectionState extends State<CustomFieldsEditSection> {
  late final Map<String, String?> _values;

  @override
  void initState() {
    super.initState();
    _values = Map.of(widget.values);
  }

  void _update(String definitionId, String? value) {
    _values[definitionId] = value;
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
    if (def.supportsOptions && mediaKind != null) {
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
      CustomFieldValueType.multiSelect => _MultiSelectCustomField(
          label: def.name,
          helperText: _scopeLabel(def.targetScope),
          options: choices,
          value: value,
          onChanged: (v) => _update(def.id, v),
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
      CustomFieldValueType.longText => _textField(
          def,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
        ),
      CustomFieldValueType.number ||
      CustomFieldValueType.currency =>
        _textField(
          def,
          keyboardType: def.valueType == CustomFieldValueType.number
              ? TextInputType.number
              : const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
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

  Widget _textField(
    CustomFieldDefinition def, {
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
        decoration: InputDecoration(helperText: _scopeLabel(def.targetScope)),
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
    return LibraryDateFieldButton(
      label: label,
      value: value != null ? DateTime.tryParse(value!) : null,
      onChanged: (picked) {
        onChanged(picked == null ? null : formatDate(picked));
      },
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
          minHeight: kLibraryFormControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: kLibraryFormControlHeight - 2,
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
                minimumSize: const Size(0, kLibraryFormControlHeight - 8),
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
                  height: kLibraryFormControlHeight - 8,
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

class _MultiSelectCustomField extends StatelessWidget {
  const _MultiSelectCustomField({
    required this.label,
    required this.helperText,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String helperText;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = parseCustomFieldMultiValues(value);
    final selectedSet = selected.toSet();
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText.isEmpty ? null : helperText,
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: kLibraryFormControlHeight - 2,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in options)
                      FilterChip(
                        label: Text(option),
                        selected: selectedSet.contains(option),
                        onSelected: (isSelected) {
                          final next = {...selectedSet};
                          if (isSelected) {
                            next.add(option);
                          } else {
                            next.remove(option);
                          }
                          onChanged(encodeCustomFieldMultiValues(next));
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    if (options.isEmpty)
                      Text(
                        'No options configured',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (selected.isNotEmpty)
              IconButton(
                tooltip: 'Clear selections',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.clear_all, size: 18),
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: kLibraryFormControlHeight - 8,
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
