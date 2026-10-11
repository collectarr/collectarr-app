import 'dart:convert';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CustomFieldEditorResult {
  const CustomFieldEditorResult(this.definition, this.display);
  final CustomFieldDefinition definition;
  final CustomFieldDisplaySettings display;
}

class CustomFieldEditorDialog extends StatefulWidget {
  const CustomFieldEditorDialog(
      {super.key,
      this.existing,
      required this.initialType,
      this.initialMediaKind,
      required this.initialDisplay,
      this.sortOrder = 0});

  final CustomFieldDefinition? existing;
  final CustomFieldValueType initialType;
  final String? initialMediaKind;
  final int sortOrder;
  final CustomFieldDisplaySettings initialDisplay;

  @override
  State<CustomFieldEditorDialog> createState() =>
      _CustomFieldEditorDialogState();
}

class _CustomFieldEditorDialogState extends State<CustomFieldEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _optionsController;
  late CustomFieldValueType _fieldType;
  String? _mediaKind;
  late String _unit;
  late final TextEditingController _pluralController;
  late CustomFieldMultiValueControl _multiControl;

  static final List<CustomFieldValueType> _fieldTypes =
      CustomFieldValueType.values;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _fieldType = widget.initialType;
    _mediaKind =
        existing == null ? widget.initialMediaKind : existing.mediaKind;
    _unit = existing?.unit ??
        (_fieldType == CustomFieldValueType.weight ? 'kg' : 'cm');
    _pluralController =
        TextEditingController(text: widget.initialDisplay.pluralName);
    _multiControl = widget.initialDisplay.multiValueControl;
    _optionsController = TextEditingController(
      text: _decodeOptions(existing?.options),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    _pluralController.dispose();
    super.dispose();
  }

  String _decodeOptions(String? json) {
    if (json == null || json.isEmpty) return '';
    try {
      final list = jsonDecode(json) as List;
      return list.join(', ');
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'custom_fields',
        message: 'Failed to decode custom field options JSON.',
        error: error,
        stackTrace: stackTrace,
      );
      return '';
    }
  }

  String? _encodeOptions() {
    if (_fieldType.hasUnit) return encodeCustomFieldOptions([_unit]);
    if (!_fieldType.supportsOptions) return null;
    final items = _optionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return items.isEmpty ? null : encodeCustomFieldOptions(items);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return AccentAlertDialog(
      title: Text(isNew ? 'Add Custom Field' : 'Edit Custom Field'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 552,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Field Name'),
                autofocus: true,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CompactSearchDropdownFormField<CustomFieldValueType>(
                initialValue: _fieldType,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(labelText: 'Field Type'),
                items: [
                  for (final type in _fieldTypes)
                    DropdownMenuItem<CustomFieldValueType>(
                      value: type,
                      child: Text(type.label),
                    ),
                ],
                onChanged: widget.existing == null
                    ? (value) {
                        if (value != null) {
                          setState(() {
                            _fieldType = value;
                            _unit = value == CustomFieldValueType.weight
                                ? 'kg'
                                : 'cm';
                          });
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              CompactSearchDropdownFormField<String>(
                initialValue: _mediaKind,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Applies to',
                  hintText: 'All libraries',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All libraries'),
                  ),
                  for (final type in defaultLibraryKindRegistry.allKinds)
                    DropdownMenuItem<String>(
                      value: type.kind.apiValue,
                      child: Text(type.identity.singularLabel),
                    ),
                ],
                onChanged: (value) => setState(() => _mediaKind = value),
              ),
              if (_fieldType.supportsOptions) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Options (comma-separated)',
                    hintText: 'Option A, Option B, Option C',
                  ),
                  maxLines: 2,
                  enabled: widget.existing == null || !_fieldType.isFixedChoice,
                  validator: (value) {
                    final options = (value ?? '')
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    if (_fieldType.isFixedChoice && options.isEmpty) {
                      return 'Add at least one option';
                    }
                    final max = _fieldType.maximumOptions;
                    if (max != null && options.length > max) {
                      return 'Maximum $max options';
                    }
                    if (options.toSet().length != options.length) {
                      return 'Options must be unique';
                    }
                    return null;
                  },
                ),
                if (_fieldType.isFixedChoice)
                  const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                          'Fixed values cannot be changed after creation. Use Pick List for values you want to manage later.')),
              ],
              if (_fieldType == CustomFieldValueType.singleSelect ||
                  _fieldType == CustomFieldValueType.multiSelect) ...[
                const SizedBox(height: 12),
                TextFormField(
                    controller: _pluralController,
                    decoration: const InputDecoration(
                        labelText: 'Field Name (Plural)')),
              ],
              if (_fieldType == CustomFieldValueType.multiSelect) ...[
                const SizedBox(height: 12),
                CompactSearchDropdownFormField<CustomFieldMultiValueControl>(
                  initialValue: _multiControl,
                  decoration: const InputDecoration(labelText: 'Control Type'),
                  items: const [
                    DropdownMenuItem(
                        value: CustomFieldMultiValueControl.dropdown,
                        child: Text('Drop-down list')),
                    DropdownMenuItem(
                        value: CustomFieldMultiValueControl.checkboxes,
                        child: Text('Checkbox list')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _multiControl = value);
                  },
                ),
              ],
              if (_fieldType.hasUnit) ...[
                const SizedBox(height: 12),
                CompactSearchDropdownFormField<String>(
                  key: ValueKey(_fieldType),
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Storage Type'),
                  items: [
                    for (final unit in _fieldType == CustomFieldValueType.weight
                        ? ['kg', 'lb']
                        : ['cm', 'in'])
                      DropdownMenuItem(value: unit, child: Text(unit))
                  ],
                  onChanged: widget.existing == null
                      ? (value) {
                          if (value != null) setState(() => _unit = value);
                        }
                      : null,
                ),
              ],
              const SizedBox(height: 20),
              const Text('Preview',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ListenableBuilder(
                listenable: Listenable.merge(
                    [_nameController, _optionsController, _pluralController]),
                builder: (context, _) => IgnorePointer(
                  child: CustomFieldsEditSection(
                    key: ValueKey(
                        '${_fieldType.name}:${_optionsController.text}:$_unit:${_multiControl.name}'),
                    displaySettings: {
                      'preview': CustomFieldDisplaySettings(
                          pluralName: _pluralController.text,
                          multiValueControl: _multiControl)
                    },
                    definitions: [
                      CustomFieldDefinition(
                          id: 'preview',
                          name: _nameController.text.trim().isEmpty
                              ? 'Field Name'
                              : _nameController.text.trim(),
                          fieldType: _fieldType.apiValue,
                          options: _encodeOptions(),
                          createdAt: DateTime.utc(2026))
                    ],
                    values: const {},
                    accent: Theme.of(context).colorScheme.primary,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isNew ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final def = CustomFieldDefinition(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      fieldType: _fieldType.apiValue,
      mediaKind: _mediaKind,
      editScope: CustomFieldTargetScope.libraryEntry.apiValue,
      sortOrder: widget.existing?.sortOrder ?? widget.sortOrder,
      options: _encodeOptions(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    Navigator.of(context).pop(CustomFieldEditorResult(
        def,
        CustomFieldDisplaySettings(
            pluralName: _pluralController.text,
            multiValueControl: _multiControl)));
  }
}
