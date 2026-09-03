import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'add_schema.dart';
import '../../edit/schema/edit_schema.dart' show EditOption;

class AddSchemaRenderer<TDraft> extends StatefulWidget {
  const AddSchemaRenderer({
    super.key,
    required this.schema,
    required this.draft,
    required this.onSubmit,
    this.onCancel,
    this.title,
    this.submitLabel = 'Add',
    this.showFooter = true,
  });

  final AddSchema<TDraft> schema;
  final TDraft draft;
  final FutureOr<void> Function(TDraft draft) onSubmit;
  final VoidCallback? onCancel;
  final String? title;
  final String submitLabel;
  final bool showFooter;

  @override
  State<AddSchemaRenderer<TDraft>> createState() =>
      _AddSchemaRendererState<TDraft>();
}

class _AddSchemaRendererState<TDraft> extends State<AddSchemaRenderer<TDraft>> {
  late final Map<String, TextEditingController> _textControllers;
  bool _isSubmitting = false;
  String? _submitError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
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
    final visibleSections = widget.schema.sections
        .where((section) => section.isVisible(widget.draft))
        .toList(growable: false);
    if (visibleSections.isEmpty) {
      return const Center(child: Text('No add fields'));
    }

    final schemaTitle = widget.title ?? widget.schema.title?.call(widget.draft);
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
              if (schemaTitle != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    schemaTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _buildSections(context, visibleSections),
                ),
              ),
              if (widget.showFooter) _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSections(
    BuildContext context,
    List<AddSectionSpec<TDraft>> sections,
  ) {
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
    List<AddFieldSpec<TDraft>> fields,
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

  Widget _buildField(BuildContext context, AddFieldSpec<TDraft> field) {
    if (field is TextAddField<TDraft>) {
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
    if (field is NumberAddField<TDraft>) {
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
    if (field is DateAddField<TDraft>) {
      return _buildDateField(context, field);
    }
    if (field is MoneyAddField<TDraft>) {
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
    if (field is ToggleAddField<TDraft>) {
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
    if (field is SelectAddField<TDraft, dynamic>) {
      return _buildSelectField<dynamic>(context, field);
    }
    if (field is VocabularyAddField<TDraft, dynamic>) {
      return _buildSelectField<dynamic>(context, field);
    }
    if (field is MultiVocabularyAddField<TDraft, dynamic>) {
      return _buildMultiSelectField<dynamic>(context, field);
    }
    if (field is ImageAddField<TDraft, dynamic>) {
      return _buildImageField<dynamic>(context, field);
    }
    if (field is ReadOnlyAddField<TDraft, dynamic>) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          errorText: field.validate(widget.draft),
        ),
        child: Text(field.displayValue(widget.draft)),
      );
    }
    if (field is CustomAddField<TDraft>) {
      return field.builder(context, widget.draft);
    }
    return const SizedBox.shrink();
  }

  Widget _buildDateField(
    BuildContext context,
    DateAddField<TDraft> field,
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
    AddFieldSpec<TDraft> baseField,
  ) {
    late TValue? Function(TDraft draft) value;
    late void Function(TDraft draft, TValue? value) setValue;
    late List<EditOption<TValue>> options;
    if (baseField is SelectAddField<TDraft, TValue>) {
      value = (draft) => baseField.currentValue(draft);
      setValue = (draft, nextValue) => baseField.updateValue(draft, nextValue);
      options = baseField.options;
    } else if (baseField is VocabularyAddField<TDraft, TValue>) {
      value = (draft) => baseField.currentValue(draft);
      setValue = (draft, nextValue) => baseField.updateValue(draft, nextValue);
      options = baseField.options;
    } else {
      return const SizedBox.shrink();
    }
    final onManage = baseField is VocabularyAddField<TDraft, TValue>
        ? baseField.onManage
        : null;
    return DropdownButtonFormField<TValue>(
      initialValue: value(widget.draft),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: baseField.label,
        errorText: baseField.validate(widget.draft),
        suffixIcon: onManage == null
            ? null
            : IconButton(
                tooltip: 'Manage ${baseField.label}',
                onPressed: () async {
                  await onManage(widget.draft);
                  if (mounted) {
                    setState(() => _validationError = null);
                  }
                },
                icon: const Icon(Icons.tune),
              ),
      ),
      items: [
        for (final option in options)
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
    AddFieldSpec<TDraft> baseField,
  ) {
    final field = baseField as MultiVocabularyAddField<TDraft, TValue>;
    final selected = field.currentValues(widget.draft);
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
                      field.updateValues(widget.draft, next);
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
    AddFieldSpec<TDraft> baseField,
  ) {
    final field = baseField as ImageAddField<TDraft, TValue>;
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
                field.updateValue(widget.draft, selected);
                setState(() => _validationError = null);
              },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose'),
            ),
        ],
      ),
    );
  }

  Widget? _fieldError(AddFieldSpec<TDraft> field) {
    final error = field.validate(widget.draft);
    return error == null ? null : Text(error);
  }

  Widget _buildFooter(BuildContext context) {
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
            if (_submitError != null)
              Text(
                _submitError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final schemaError = widget.schema.validate?.call(widget.draft);
    final fieldError = _firstFieldError();
    if (schemaError != null || fieldError != null) {
      setState(() {
        _validationError = schemaError ?? fieldError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      await widget.onSubmit(widget.draft);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = error.toString();
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  String? _firstFieldError() {
    for (final section in widget.schema.sections) {
      if (!section.isVisible(widget.draft)) continue;
      for (final field in section.fields) {
        if (field.isVisible(widget.draft)) {
          final error = field.validate(widget.draft);
          if (error != null) return error;
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
    DateAddField<TDraft> field,
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
