import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
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
    this.showTitle = true,
    this.initialTabIndex = 0,
    this.showTabBar = true,
    this.showFooter = true,
    this.tabAccent,
    this.tabOrderKey,
  });

  final EditSchema<TModel, TDraft> schema;
  final TModel model;
  final TDraft draft;
  final FutureOr<void> Function(TDraft draft) onSave;
  final VoidCallback? onCancel;
  final String? title;
  final bool showTitle;
  final int initialTabIndex;
  final bool showTabBar;
  final bool showFooter;
  final Color? tabAccent;
  final String? tabOrderKey;

  @override
  State<EditSchemaRenderer<TModel, TDraft>> createState() =>
      EditSchemaRendererState<TModel, TDraft>();
}

class EditSchemaRendererState<TModel, TDraft>
    extends State<EditSchemaRenderer<TModel, TDraft>> {
  late final Map<String, TextEditingController> _textControllers;
  late List<int> _tabOrder;
  late int _selectedTabIndex;
  bool _isSaving = false;
  String? _saveError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _textControllers = {};
    _tabOrder = List.generate(widget.schema.tabs.length, (index) => index);
    if (widget.showTabBar && widget.schema.tabs.isNotEmpty) {
      _loadSavedTabOrder();
    }
  }

  Future<void> _loadSavedTabOrder() async {
    final order = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: widget.schema.tabs.length,
    );
    if (!mounted || order == null) return;
    setState(() => _tabOrder = order);
  }

  Future<void> _saveTabOrder() {
    return saveLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      order: _tabOrder,
    );
  }

  List<int> _orderedVisibleTabIndexes() {
    final visible = <int>{
      for (var index = 0; index < widget.schema.tabs.length; index++)
        if (widget.schema.tabs[index].isVisible(widget.draft)) index,
    };
    final ordered = <int>[
      for (final index in _tabOrder)
        if (visible.contains(index)) index,
    ];
    for (final index in visible) {
      if (!ordered.contains(index)) ordered.add(index);
    }
    return ordered;
  }

  void _onReorderTab(
    int oldIndex,
    int newIndex,
    List<int> visibleTabIndexes,
  ) {
    if (oldIndex < 0 ||
        oldIndex >= visibleTabIndexes.length ||
        newIndex < 0 ||
        newIndex >= visibleTabIndexes.length ||
        oldIndex == newIndex) {
      return;
    }
    final selectedSourceIndex = _selectedTabIndex < visibleTabIndexes.length
        ? visibleTabIndexes[_selectedTabIndex]
        : null;
    final visibleOrder = List<int>.of(visibleTabIndexes)
      ..removeAt(oldIndex)
      ..insert(newIndex, visibleTabIndexes[oldIndex]);
    final visibleSet = visibleTabIndexes.toSet();
    final hiddenOrder = [
      for (final index in _tabOrder)
        if (!visibleSet.contains(index)) index,
    ];
    setState(() {
      _tabOrder = [...visibleOrder, ...hiddenOrder];
      if (selectedSourceIndex != null) {
        _selectedTabIndex = visibleOrder.indexOf(selectedSourceIndex);
      }
    });
    _saveTabOrder();
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EditSchemaRenderer<TModel, TDraft> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schema.tabs.length != widget.schema.tabs.length) {
      _tabOrder = List.generate(widget.schema.tabs.length, (index) => index);
      _selectedTabIndex = 0;
      if (widget.showTabBar && widget.schema.tabs.isNotEmpty) {
        _loadSavedTabOrder();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabIndexes = _orderedVisibleTabIndexes();
    if (visibleTabIndexes.isEmpty) {
      return const Center(child: Text('No editable sections'));
    }

    final selectedIndex = math.min(
      _selectedTabIndex,
      visibleTabIndexes.length - 1,
    );
    if (selectedIndex != _selectedTabIndex) {
      _selectedTabIndex = selectedIndex;
    }

    // This renderer is also used directly by kind-owned dialogs. `showDialog`
    // supplies the route and barrier, but it does not add a Material surface
    // for arbitrary builder output. Keep the renderer self-contained so its
    // TextFields, dropdowns, and input decorators are valid in every host.
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.hasBoundedHeight
              ? math.min(constraints.maxHeight, 720.0)
              : 720.0;
          return SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showTitle && widget.title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
                if (widget.showTabBar)
                  _buildTabBar(context, visibleTabIndexes, selectedIndex),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!widget.showFooter) _buildFeedback(context),
                        _buildTabContent(
                          context,
                          widget.schema.tabs[visibleTabIndexes[selectedIndex]],
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showFooter) _buildFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    List<int> tabIndexes,
    int selectedIndex,
  ) {
    final tabs = [
      for (final index in tabIndexes)
        EditTab(
          icon: widget.schema.tabs[index].icon ?? Icons.edit_outlined,
          label: widget.schema.tabs[index].label,
        ),
    ];
    return LibraryEditTabStripFrame(
      child: LibraryEditReorderableTabStrip(
        tabs: tabs,
        accent: widget.tabAccent ?? Theme.of(context).colorScheme.primary,
        selectedIndex: selectedIndex,
        onSelect: (index) => setState(() => _selectedTabIndex = index),
        onReorderItem: (oldIndex, newIndex) =>
            _onReorderTab(oldIndex, newIndex, tabIndexes),
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

  Widget _buildFeedback(BuildContext context) {
    if (_validationError == null && _saveError == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
        ],
      ),
    );
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

  /// Runs the same validation/save lifecycle as the built-in renderer footer.
  ///
  /// This is used by [LibraryEditSchemaDialog] so the shared edit shell can
  /// own the visible Save button without duplicating schema behavior.
  Future<void> save() => _save();

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
