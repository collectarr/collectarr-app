import 'dart:convert';
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
    return switch (def.fieldType) {
      'bool' => SwitchListTile(
          value: value == 'true',
          onChanged: (v) => _update(def.id, v.toString()),
          title: Text(def.name),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      'select' => DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: def.name),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('—')),
            for (final option in _selectOptions(def))
              DropdownMenuItem<String>(value: option, child: Text(option)),
          ],
          onChanged: (v) => _update(def.id, v),
        ),
      'date' => _DateCustomField(
          label: def.name,
          value: value,
          onChanged: (v) => _update(def.id, v),
        ),
      _ => TextFormField(
          initialValue: value ?? '',
          decoration: InputDecoration(labelText: def.name),
          keyboardType:
              def.fieldType == 'number' ? TextInputType.number : null,
          onChanged: (v) {
            final trimmed = v.trim();
            _update(def.id, trimmed.isEmpty ? null : trimmed);
          },
        ),
    };
  }

  List<String> _selectOptions(CustomFieldDefinition def) {
    if (def.options == null || def.options!.isEmpty) return const [];
    try {
      return (jsonDecode(def.options!) as List).cast<String>();
    } catch (_) {
      return const [];
    }
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
    return OutlinedButton.icon(
      onPressed: () async {
        final now = DateTime.now();
        final initial = value != null ? DateTime.tryParse(value!) : null;
        final picked = await showDatePicker(
          context: context,
          initialDate: initial ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 10),
        );
        if (picked != null) {
          onChanged(formatDate(picked));
        }
      },
      icon: const Icon(Icons.event),
      label: Text(
        value == null || value!.isEmpty ? 'Set $label' : '$label: $value',
      ),
    );
  }
}
