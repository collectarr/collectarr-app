import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/settings/custom_field_preview.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_field_dialog.dart';
import 'package:collectarr_app/features/settings/custom_field_select.dart';
import 'package:collectarr_app/features/settings/custom_field_type_picker.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
  late final TextEditingController _pluralController;
  late CustomFieldValueType _fieldType;
  String? _mediaKind;
  String? _unit;
  late String _currencyCode;
  late List<String> _options;
  late CustomFieldMultiValueControl _multiControl;
  CustomFieldNumericStorage? _numericStorage;
  String? _configurationError;
  late CustomFieldMultiValueDisplay _multiDisplay;
  int _previewRevision = 0;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _pluralController =
        TextEditingController(text: widget.initialDisplay.pluralName);
    _fieldType = widget.initialType;
    _mediaKind =
        existing == null ? widget.initialMediaKind : existing.mediaKind;
    _unit = existing?.unit;
    _options = existing?.optionValues.toList() ?? [];
    _multiControl = widget.initialDisplay.multiValueControl;
    _currencyCode = widget.initialDisplay.currencyCode;
    _numericStorage =
        existing == null ? null : widget.initialDisplay.numericStorage;
    _multiDisplay = widget.initialDisplay.multiValueDisplay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pluralController.dispose();
    super.dispose();
  }

  bool get _hasNumericStorage => [
        CustomFieldValueType.currency,
        CustomFieldValueType.percentage,
        CustomFieldValueType.weight,
        CustomFieldValueType.size
      ].contains(_fieldType);
  CustomFieldDisplaySettings get _display => CustomFieldDisplaySettings(
      pluralName: _pluralController.text,
      currencyCode: _currencyCode,
      multiValueControl: _multiControl,
      numericStorage: _numericStorage ?? CustomFieldNumericStorage.decimal,
      multiValueDisplay: _multiDisplay);
  String? _encodeOptions() {
    if (_fieldType.hasUnit) {
      return _unit == null ? null : encodeCustomFieldOptions([_unit!]);
    }
    if (!_fieldType.supportsOptions) return null;
    final options =
        _options.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return options.isEmpty ? null : encodeCustomFieldOptions(options);
  }

  Widget _typeDescription(CustomFieldValueType type) {
    final choice = customFieldTypeChoices[type]!;
    return Row(children: [
      CustomFieldTypeIcon(type: type, size: 22),
      const SizedBox(width: 10),
      Expanded(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(choice.$1,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(choice.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color:
                        appPalette(context).textPrimary.withValues(alpha: .5))),
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = customFieldPalette(context);
    final isNew = widget.existing == null;
    return CustomFieldDialog(
      title: isNew ? 'Add Custom Field' : 'Edit Custom Field',
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(isNew ? 'Add' : 'Save'))
      ],
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomFieldSelect<CustomFieldValueType>(
                          label: 'Field Type',
                          value: _fieldType,
                          height: 48,
                          display: _typeDescription(_fieldType),
                          items: [
                            for (final type in customFieldTypeChoices.keys)
                              (type, _typeDescription(type))
                          ],
                          onChanged: isNew
                              ? (value) => setState(() {
                                    _fieldType = value;
                                    _options = [];
                                    _unit = null;
                                    _numericStorage = null;
                                    _configurationError = null;
                                    _previewRevision++;
                                  })
                              : null),
                      const SizedBox(height: 10),
                      CustomFieldDefinitionField(
                          label: 'Field Name',
                          labelStyle:
                              const TextStyle(fontSize: 13, height: 20 / 13),
                          child: LibraryTextFormControl(
                              key: const Key('custom_field.name'),
                              controller: _nameController,
                              decoration:
                                  const InputDecoration(hintText: 'Field Name'),
                              autofocus: true,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Required'
                                      : null)),
                      if (widget.initialMediaKind == null) ...[
                        const SizedBox(height: 10),
                        CustomFieldSelect<String>(
                            label: 'Applies to',
                            value: _mediaKind ?? 'all',
                            items: [
                              ('all', const Text('All libraries')),
                              for (final kind
                                  in defaultLibraryKindRegistry.allKinds)
                                (
                                  kind.kind.apiValue,
                                  Text(kind.identity.singularLabel)
                                )
                            ],
                            onChanged: (value) => setState(() =>
                                _mediaKind = value == 'all' ? null : value)),
                      ],
                      if (_fieldType == CustomFieldValueType.singleSelect ||
                          _fieldType == CustomFieldValueType.multiSelect) ...[
                        const SizedBox(height: 10),
                        CustomFieldDefinitionField(
                            label: 'Field Name (Plural)',
                            labelStyle:
                                const TextStyle(fontSize: 13, height: 20 / 13),
                            child: LibraryTextFormControl(
                                controller: _pluralController)),
                      ],
                      if (_hasNumericStorage) ...[
                        const SizedBox(height: 10),
                        CustomFieldSelect<CustomFieldNumericStorage>(
                            label: 'Storage Type',
                            value: _numericStorage,
                            items: const [
                              (
                                CustomFieldNumericStorage.decimal,
                                Text('Decimal')
                              ),
                              (CustomFieldNumericStorage.number, Text('Number'))
                            ],
                            onChanged: isNew
                                ? (value) => setState(() {
                                      _numericStorage = value;
                                      _configurationError = null;
                                      _previewRevision++;
                                    })
                                : null),
                      ],
                      if (_fieldType == CustomFieldValueType.currency &&
                          _numericStorage != null) ...[
                        const SizedBox(height: 10),
                        CustomFieldSelect<String>(
                            label: 'Currency',
                            value: _currencyCode,
                            items: [
                              for (final code in kCurrencyCodes)
                                (code, Text(code))
                            ],
                            onChanged: (value) =>
                                setState(() => _currencyCode = value)),
                      ],
                      if (_fieldType.hasUnit && _numericStorage != null) ...[
                        const SizedBox(height: 10),
                        CustomFieldSelect<String>(
                            label: 'Unit',
                            value: _unit,
                            items: [
                              for (final unit in _fieldType.allowedUnits)
                                (
                                  unit,
                                  Text({
                                    'g': 'Grams',
                                    'kg': 'Kilograms',
                                    'lb': 'Pounds',
                                    'oz': 'Ounces',
                                    'cm': 'Centimeters',
                                    'in': 'Inches',
                                    'mm': 'Millimeters'
                                  }[unit]!)
                                )
                            ],
                            onChanged: isNew
                                ? (value) => setState(() {
                                      _unit = value;
                                      _configurationError = null;
                                      _previewRevision++;
                                    })
                                : null),
                      ],
                      if (_fieldType == CustomFieldValueType.multiSelect) ...[
                        const SizedBox(height: 10),
                        CustomFieldSelect<CustomFieldMultiValueControl>(
                            label: 'Control Type',
                            value: _multiControl,
                            items: [
                              for (final control
                                  in CustomFieldMultiValueControl.values)
                                (control, Text(control.label))
                            ],
                            onChanged: (value) => setState(() {
                                  _multiControl = value;
                                  _previewRevision++;
                                })),
                        const SizedBox(height: 10),
                        CustomFieldSelect<CustomFieldMultiValueDisplay>(
                            label: 'Display Type',
                            value: _multiDisplay,
                            items: const [
                              (
                                CustomFieldMultiValueDisplay.separator,
                                Text('Separator')
                              ),
                              (CustomFieldMultiValueDisplay.list, Text('List'))
                            ],
                            onChanged: (value) =>
                                setState(() => _multiDisplay = value)),
                        Text(
                            'Control how multiple values are shown in the details panel.',
                            style: TextStyle(
                                fontSize: 12, color: palette.textMuted)),
                      ],
                      if (_fieldType.isFixedChoice) ...[
                        const SizedBox(height: 10),
                        _fixedValues(isNew),
                        const SizedBox(height: 8),
                        Text(
                            'These values cannot be changed once created. If you will need to modify them later, use Pick List.',
                            style: TextStyle(
                                fontSize: 12, color: palette.textMuted)),
                      ],
                    ])),
            if (_configurationError != null)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(_configurationError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
            if ((!_hasNumericStorage || _numericStorage != null) &&
                (!_fieldType.hasUnit || _unit != null))
              _preview(),
          ])),
    );
  }

  Widget _fixedValues(bool editable) => FormField<List<String>>(
        validator: (_) {
          if (_options.isEmpty ||
              _options.any((value) => value.trim().isEmpty)) {
            return 'Add at least one option';
          }
          if (_options.length > _fieldType.maximumOptions!) {
            return 'Maximum ${_fieldType.maximumOptions} options';
          }
          if (_options.map((e) => e.trim()).toSet().length != _options.length) {
            return 'Options must be unique';
          }
          return null;
        },
        builder: (state) => CustomFieldDefinitionField(
            label: 'Field Values',
            labelStyle: const TextStyle(fontSize: 13, height: 20 / 13),
            action: editable
                ? IconButton(
                    tooltip: 'Add field value',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 24, height: 20),
                    icon: const Icon(AppIcons.add, size: 14),
                    onPressed: () {
                      setState(() {
                        _options.add('');
                        _previewRevision++;
                      });
                    })
                : null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_options.isEmpty)
                    Container(
                        height: 34,
                        decoration: BoxDecoration(
                            color: appPalette(context).panelRaised,
                            border: Border.all(
                                color: appPalette(context).divider))),
                  ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: _options.length,
                      onReorderItem: (oldIndex, newIndex) => setState(() {
                            final option = _options.removeAt(oldIndex);
                            _options.insert(newIndex, option);
                            _previewRevision++;
                          }),
                      itemBuilder: (context, i) => Row(
                              key: ValueKey('option.$i.$_previewRevision'),
                              children: [
                                if (editable)
                                  ReorderableDragStartListener(
                                      index: i,
                                      child: const SizedBox(
                                          width: 24,
                                          height: 34,
                                          child: Icon(AppIcons.customFieldDrag,
                                              size: 14))),
                                Expanded(
                                    child: LibraryTextFormControl(
                                        key: ValueKey(
                                            'custom_field.option.$i.$_previewRevision'),
                                        initialValue: _options[i],
                                        enabled: editable,
                                        decoration: InputDecoration(
                                            hintText: 'Value ${i + 1}'),
                                        onChanged: (value) {
                                          _options[i] = value;
                                          setState(() {});
                                        })),
                                if (editable)
                                  IconButton(
                                      tooltip: 'Remove field value ${i + 1}',
                                      icon:
                                          const Icon(AppIcons.close, size: 14),
                                      onPressed: () => setState(() {
                                            _options.removeAt(i);
                                            _previewRevision++;
                                          })),
                              ])),
                  if (state.hasError)
                    Text(state.errorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12)),
                ])),
      );

  Widget _preview() => ListenableBuilder(
      listenable: Listenable.merge([_nameController, _pluralController]),
      builder: (context, _) => CustomFieldPreview(
          name: _nameController.text,
          type: _fieldType,
          options: _options,
          unit: _unit ?? '',
          display: _display,
          revision: _previewRevision));

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (_hasNumericStorage && _numericStorage == null) {
      setState(() => _configurationError = 'Choose a Storage Type');
      return;
    }
    if (_fieldType.hasUnit && _unit == null) {
      setState(() => _configurationError = 'Choose a Unit');
      return;
    }
    if (!valid) return;
    final definition = CustomFieldDefinition(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        fieldType: _fieldType.apiValue,
        mediaKind: _mediaKind,
        editScope: CustomFieldTargetScope.libraryEntry.apiValue,
        sortOrder: widget.existing?.sortOrder ?? widget.sortOrder,
        options: _encodeOptions(),
        createdAt: widget.existing?.createdAt ?? DateTime.now());
    Navigator.pop(context, CustomFieldEditorResult(definition, _display));
  }
}
