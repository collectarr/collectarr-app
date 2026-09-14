import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'edit_schema.dart';

class EditSchemaRenderer<TModel, TDraft> extends StatefulWidget {
  const EditSchemaRenderer({
    super.key,
    required this.schema,
    required this.model,
    required this.draft,
    required this.onSave,
    this.onCancel,
    this.title,
    this.initialTabIndex = 0,
    this.showTabBar = true,
    this.showFooter = true,
  });

  final EditSchema<TModel, TDraft> schema;
  final TModel model;
  final TDraft draft;
  final FutureOr<void> Function(TDraft draft) onSave;
  final VoidCallback? onCancel;
  final String? title;
  final int initialTabIndex;
  final bool showTabBar;
  final bool showFooter;

  @override
  State<EditSchemaRenderer<TModel, TDraft>> createState() =>
      _EditSchemaRendererState<TModel, TDraft>();
}

class _EditSchemaRendererState<TModel, TDraft>
    extends State<EditSchemaRenderer<TModel, TDraft>> {
  late final Map<String, TextEditingController> _textControllers;
  late int _selectedTabIndex;
  bool _isSaving = false;
  String? _saveError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _textControllers = {};
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabs = widget.schema.tabs
        .where((tab) => tab.isVisible(widget.draft))
        .toList(growable: false);
    if (visibleTabs.isEmpty) {
      return const Center(child: Text('No editable sections'));
    }

    final selectedIndex = math.min(_selectedTabIndex, visibleTabs.length - 1);
    if (selectedIndex != _selectedTabIndex) {
      _selectedTabIndex = selectedIndex;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? math.min(constraints.maxHeight, 720.0)
            : 720.0;
        return SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
              if (widget.showTabBar)
                _buildTabBar(context, visibleTabs, selectedIndex),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _buildTabContent(context, visibleTabs[selectedIndex]),
                ),
              ),
              if (widget.showFooter) _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    List<EditTabSpec<TDraft>> tabs,
    int selectedIndex,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (var index = 0; index < tabs.length; index++)
              TextButton.icon(
                onPressed: () => setState(() => _selectedTabIndex = index),
                icon: tabs[index].icon == null
                    ? const SizedBox.shrink()
                    : Icon(tabs[index].icon, size: 16),
                label: Text(tabs[index].label),
                style: TextButton.styleFrom(
                  foregroundColor: index == selectedIndex
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  shape: const RoundedRectangleBorder(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, EditTabSpec<TDraft> tab) {
    final sections = tab.sections
        .where((section) => section.isVisible(widget.draft))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          Text(section.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildFieldWrap(context, section.fields),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildFieldWrap(
    BuildContext context,
    List<EditFieldSpec<TDraft>> fields,
  ) {
    final visibleFields = fields
        .where((field) => field.isVisible(widget.draft))
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        final width =
            wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in visibleFields)
              SizedBox(width: width, child: _buildField(context, field)),
          ],
        );
      },
    );
  }

  Widget _buildField(BuildContext context, EditFieldSpec<TDraft> field) {
    if (field is TextEditField<TDraft>) {
      final controller = _controllerFor(field.id, field.value(widget.draft));
      return TextFormField(
        controller: controller,
        maxLines: field.maxLines,
        obscureText: field.obscureText,
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(widget.draft),
        ),
        onChanged: (value) {
          field.setValue(widget.draft, value);
          setState(() => _validationError = null);
        },
      );
    }
    if (field is NumberEditField<TDraft>) {
      final controller = _controllerFor(
        field.id,
        field.value(widget.draft)?.toString() ?? '',
      );
      return TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(widget.draft),
        ),
        onChanged: (value) {
          field.setValue(widget.draft, _parseNumber(value));
          setState(() => _validationError = null);
        },
      );
    }
    if (field is DateEditField<TDraft>) {
      return _buildDateField(context, field);
    }
    if (field is MoneyEditField<TDraft>) {
      final cents = field.cents(widget.draft);
      final controller = _controllerFor(
        field.id,
        cents == null ? '' : (cents / 100).toStringAsFixed(2),
      );
      return TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: field.label,
          suffixText: field.currency(widget.draft),
          errorText: field.validate(widget.draft),
        ),
        onChanged: (value) {
          field.setCents(widget.draft, _parseMoneyCents(value));
          setState(() => _validationError = null);
        },
      );
    }
    if (field is ToggleEditField<TDraft>) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        value: field.value(widget.draft),
        onChanged: (value) {
          field.setValue(widget.draft, value);
          setState(() => _validationError = null);
        },
        subtitle: _fieldError(field),
      );
    }
    if (field is SelectEditField<TDraft, dynamic>) {
      return _buildSelectField<dynamic>(context, field);
    }
    if (field is VocabularyEditField<TDraft, dynamic>) {
      return _buildSelectField<dynamic>(context, field);
    }
    if (field is MultiVocabularyEditField<TDraft, dynamic>) {
      return _buildMultiSelectField<dynamic>(context, field);
    }
    if (field is ImageEditField<TDraft, dynamic>) {
      return _buildImageField<dynamic>(context, field);
    }
    if (field is ReadOnlyEditField<TDraft, dynamic>) {
      final value = field.value(widget.draft);
      return InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(widget.draft),
        ),
        child: Text(field.displayValue(value)),
      );
    }
    if (field is CustomEditField<TDraft>) {
      return field.builder(context, widget.draft);
    }
    return const SizedBox.shrink();
  }

  Widget _buildDateField(
    BuildContext context,
    DateEditField<TDraft> field,
  ) {
    final value = field.value(widget.draft);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(widget.draft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(value == null ? 'Not set' : _formatDate(value)),
          ),
          IconButton(
            tooltip: 'Choose date',
            onPressed: () => _chooseDate(context, field),
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          if (value != null)
            IconButton(
              tooltip: 'Clear date',
              onPressed: () {
                field.setValue(widget.draft, null);
                setState(() => _validationError = null);
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectField<TValue>(
    BuildContext context,
    EditFieldSpec<TDraft> baseField,
  ) {
    late TValue? Function(TDraft draft) value;
    late void Function(TDraft draft, TValue? value) setValue;
    late List<EditOption<TValue>> options;
    if (baseField is SelectEditField<TDraft, TValue>) {
      value = (draft) => baseField.currentValue(draft);
      setValue = (draft, nextValue) => baseField.updateValue(draft, nextValue);
      options = baseField.options;
    } else if (baseField is VocabularyEditField<TDraft, TValue>) {
      value = (draft) => baseField.currentValue(draft);
      setValue = (draft, nextValue) => baseField.updateValue(draft, nextValue);
      options = baseField.options;
    } else {
      return const SizedBox.shrink();
    }
    final currentValue = value(widget.draft);
    final resolvedOptions = [
      if (currentValue != null &&
          !options.any((option) => option.value == currentValue))
        EditOption(value: currentValue, label: currentValue.toString()),
      ...options,
    ];
    return DropdownButtonFormField<TValue>(
      isExpanded: true,
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: baseField.label,
        errorText: baseField.validate(widget.draft),
      ),
      items: [
        for (final option in resolvedOptions)
          DropdownMenuItem<TValue>(
            value: option.value,
            enabled: option.enabled,
            child: Text(option.label),
          ),
      ],
      onChanged: (value) {
        setValue(widget.draft, value);
        setState(() => _validationError = null);
      },
    );
  }

  Widget _buildMultiSelectField<TValue>(
    BuildContext context,
    EditFieldSpec<TDraft> baseField,
  ) {
    final field = baseField as MultiVocabularyEditField<TDraft, TValue>;
    final selected = field.values(widget.draft);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(widget.draft),
      ),
      child: Column(
        children: [
          for (final option in field.options)
            CheckboxListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(option.label),
              value: selected.contains(option.value),
              onChanged: option.enabled
                  ? (checked) {
                      final next = {...selected};
                      if (checked ?? false) {
                        next.add(option.value);
                      } else {
                        next.remove(option.value);
                      }
                      field.setValues(widget.draft, next);
                      setState(() => _validationError = null);
                    }
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildImageField<TValue>(
    BuildContext context,
    EditFieldSpec<TDraft> baseField,
  ) {
    final field = baseField as ImageEditField<TDraft, TValue>;
    final value = field.value(widget.draft);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(widget.draft),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value?.toString() ?? 'No image selected')),
          if (field.select != null)
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await field.select!(widget.draft);
                if (!mounted) return;
                field.setValue(widget.draft, selected);
                setState(() => _validationError = null);
              },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose'),
            ),
        ],
      ),
    );
  }

  Widget? _fieldError(EditFieldSpec<TDraft> field) {
    final error = field.validate(widget.draft);
    return error == null ? null : Text(error);
  }

  Widget _buildFooter(BuildContext context) {
    final dirty =
        widget.schema.isDirty?.call(widget.model, widget.draft) ?? true;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_validationError != null)
              Text(
                _validationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_saveError != null)
              Text(
                _saveError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: !_isSaving && dirty ? _save : null,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final schemaError = widget.schema.validate?.call(
      widget.model,
      widget.draft,
    );
    final fieldError = _firstFieldError();
    if (schemaError != null || fieldError != null) {
      setState(() {
        _validationError = schemaError ?? fieldError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await widget.onSave(widget.draft);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = error.toString();
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  String? _firstFieldError() {
    for (final tab in widget.schema.tabs) {
      if (!tab.isVisible(widget.draft)) continue;
      for (final section in tab.sections) {
        if (!section.isVisible(widget.draft)) continue;
        for (final field in section.fields) {
          if (field.isVisible(widget.draft)) {
            final error = field.validate(widget.draft);
            if (error != null) return error;
          }
        }
      }
    }
    return null;
  }

  TextEditingController _controllerFor(String id, String initialValue) {
    return _textControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initialValue),
    );
  }

  Future<void> _chooseDate(
    BuildContext context,
    DateEditField<TDraft> field,
  ) async {
    final current = field.value(widget.draft);
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      initialDate: current ?? DateTime.now(),
    );
    if (!mounted || selectedDate == null) return;
    var selected = selectedDate;
    if (field.includeTime && current != null) {
      selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        current.hour,
        current.minute,
      );
    }
    field.setValue(widget.draft, selected);
    setState(() => _validationError = null);
  }

  static num? _parseNumber(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  static int? _parseMoneyCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final amount = double.tryParse(normalized);
    return amount == null ? null : (amount * 100).round();
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final time = value.hour == 0 && value.minute == 0
        ? ''
        : ' ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '${value.year}-$month-$day$time';
  }
}
