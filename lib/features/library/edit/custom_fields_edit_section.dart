import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

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
  });

  final List<CustomFieldDefinition> definitions;
  final Map<String, String?> values; // definitionId → value
  final Color accent;
  final ValueChanged<Map<String, String?>> onChanged;

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
      return EditSection(
        title: 'Custom fields',
        accent: widget.accent,
        child: Text(
          'No custom fields defined. Add them in Settings → Data.',
          style: TextStyle(
            color: kEditTextMuted,
            fontSize: 13,
          ),
        ),
      );
    }
    return EditSection(
      title: 'Custom fields',
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
    return switch (def.valueType) {
      CustomFieldValueType.boolean => SwitchListTile(
          value: value == 'true',
          onChanged: (v) => _update(def.id, v.toString()),
          title: Text(def.name),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      CustomFieldValueType.singleSelect => DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: kEditPanelRaised,
          borderRadius: kEditMenuBorderRadius,
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('—')),
            for (final option in def.optionValues)
              DropdownMenuItem<String>(value: option, child: Text(option)),
          ],
          onChanged: (v) => _update(def.id, v),
        ),
      CustomFieldValueType.multiSelect => _MultiSelectCustomField(
          label: def.name,
          helperText: _scopeLabel(def.targetScope),
          options: def.optionValues,
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
      CustomFieldValueType.longText => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
      CustomFieldValueType.number ||
      CustomFieldValueType.currency => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
      CustomFieldValueType.url => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          keyboardType: TextInputType.url,
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
      CustomFieldValueType.person => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
      _ => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(
            labelText: def.name,
            helperText: _scopeLabel(def.targetScope),
          ),
          keyboardType: def.valueType == CustomFieldValueType.number
              ? TextInputType.number
              : null,
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
    };
  }

  String _scopeLabel(CustomFieldTargetScope scope) {
    return switch (scope) {
      CustomFieldTargetScope.work => 'Work',
      CustomFieldTargetScope.edition => 'Edition',
      CustomFieldTargetScope.release => 'Release',
      CustomFieldTargetScope.issue => 'Issue',
      CustomFieldTargetScope.episode => 'Episode',
      CustomFieldTargetScope.track => 'Track',
      CustomFieldTargetScope.ownedCopy => 'Owned copy',
      CustomFieldTargetScope.trackingEntry => 'Tracking entry',
      CustomFieldTargetScope.media => 'Media',
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(parsed == null ? 'No time set' : _formatTimeOfDay(parsed)),
      trailing: Wrap(
        spacing: 8,
        children: [
          TextButton(
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
            TextButton(
              onPressed: () => onChanged(null),
              child: const Text('Clear'),
            ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        if (helperText.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            helperText,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
              ),
          ],
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => onChanged(null),
            child: const Text('Clear'),
          ),
        ],
      ],
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
