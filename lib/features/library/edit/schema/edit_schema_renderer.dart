import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_edit_contributors.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_schema.dart';

/// A kind-owned tab mounted alongside schema tabs without widening the edit
/// draft model. The tab content may manage its own independent mutations.
final class EditSchemaExtraTab {
  const EditSchemaExtraTab({
    required this.label,
    required this.content,
    this.icon = Icons.extension_outlined,
  });

  final String label;
  final IconData icon;
  final Widget content;
}

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
    this.extraTabs = const [],
    this.mediaKind,
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
  final List<EditSchemaExtraTab> extraTabs;
  final String? mediaKind;

  @override
  State<EditSchemaRenderer<TModel, TDraft>> createState() =>
      EditSchemaRendererState<TModel, TDraft>();
}

class EditSchemaRendererState<TModel, TDraft>
    extends State<EditSchemaRenderer<TModel, TDraft>>
    implements LibraryFieldSpecVisitor<TDraft, Widget> {
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
    if (visibleTabIndexes.isEmpty && widget.extraTabs.isEmpty) {
      return const Center(child: Text('No editable sections'));
    }

    final totalTabCount = visibleTabIndexes.length + widget.extraTabs.length;
    final selectedIndex = math.min(
      _selectedTabIndex,
      totalTabCount - 1,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 720),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              children: [
                if (!widget.showFooter) _buildFeedback(context),
                _buildSelectedContent(
                    context, visibleTabIndexes, selectedIndex),
              ],
            ),
          ),
          if (widget.showFooter) _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildSelectedContent(
    BuildContext context,
    List<int> visibleTabIndexes,
    int selectedIndex,
  ) {
    if (selectedIndex < visibleTabIndexes.length) {
      return _buildTabContent(
        context,
        widget.schema.tabs[visibleTabIndexes[selectedIndex]],
      );
    }
    return widget.extraTabs[selectedIndex - visibleTabIndexes.length].content;
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
      ...[
        for (final tab in widget.extraTabs)
          EditTab(icon: tab.icon, label: tab.label),
      ],
    ];
    return LibraryEditTabStripFrame(
      child: LibraryEditReorderableTabStrip(
        tabs: tabs,
        accent: widget.tabAccent ?? Theme.of(context).colorScheme.primary,
        selectedIndex: selectedIndex,
        onSelect: (index) => setState(() => _selectedTabIndex = index),
        allowReorder: widget.extraTabs.isEmpty,
        onReorderItem: widget.extraTabs.isEmpty
            ? (oldIndex, newIndex) =>
                _onReorderTab(oldIndex, newIndex, tabIndexes)
            : null,
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
    List<LibraryFieldSpec<TDraft>> fields,
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
              SizedBox(width: width, child: _buildField(field)),
          ],
        );
      },
    );
  }

  Widget _buildField(LibraryFieldSpec<TDraft> field) => field.accept(this);

  @override
  Widget visitText(LibraryTextFieldSpec<TDraft> field) {
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

  @override
  Widget visitNumber(LibraryNumberFieldSpec<TDraft> field) {
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

  @override
  Widget visitDate(LibraryDateFieldSpec<TDraft> field) =>
      _buildDateField(field);

  @override
  Widget visitMoney(LibraryMoneyFieldSpec<TDraft> field) {
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

  @override
  Widget visitToggle(LibraryToggleFieldSpec<TDraft> field) {
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

  @override
  Widget visitSelect<TValue>(LibrarySelectFieldSpec<TDraft, TValue> field) =>
      _buildSelectField(field);

  @override
  Widget visitVocabulary<TValue>(
    LibraryVocabularyFieldSpec<TDraft, TValue> field,
  ) =>
      _buildSelectField(
        field,
        vocabularyKey: field.pickListKey,
      );

  @override
  Widget visitMultiVocabulary<TValue>(
    LibraryMultiVocabularyFieldSpec<TDraft, TValue> field,
  ) =>
      _buildMultiSelectField(field);

  @override
  Widget visitImage<TValue>(LibraryImageFieldSpec<TDraft, TValue> field) =>
      _buildImageField(field);

  @override
  Widget visitReadOnly<TValue>(LibraryReadOnlyFieldSpec<TDraft, TValue> field) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.label,
        errorText: field.validate(widget.draft),
      ),
      child: Text(field.displayValue(widget.draft)),
    );
  }

  @override
  Widget visitCustom(LibraryCustomFieldSpec<TDraft> field) =>
      field.builder(context, widget.draft);

  Widget _buildDateField(LibraryDateFieldSpec<TDraft> field) {
    final value = field.value(widget.draft);
    return LibraryDateFieldButton(
      label: field.label,
      value: value,
      errorText: field.validate(widget.draft),
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
        field.setValue(widget.draft, selected);
        setState(() => _validationError = null);
      },
    );
  }

  Widget _buildSelectField<TValue>(
    LibrarySingleValueField<TDraft, TValue> field, {
    String? vocabularyKey,
  }) {
    final currentValue = field.currentValue(widget.draft);
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
      errorText: field.validate(widget.draft),
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
          mediaKind: widget.mediaKind,
          allowUserValues: vocabulary?.allowCustomValues ?? false,
          db: db,
        );
      },
      onChanged: (value) {
        field.updateValue(widget.draft, value);
        setState(() => _validationError = null);
      },
    );
  }

  VocabularyDefinition<dynamic>? _vocabularyForField<TValue>(
    LibrarySingleValueField<TDraft, TValue> field, {
    String? explicitKey,
  }) {
    final mediaKind = widget.mediaKind;
    if (mediaKind == null) return null;
    final kind = catalogMediaKindFromApiValue(mediaKind);
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

    // Some fields have UI-specific IDs such as `anime_type` while their
    // vocabulary uses `anime.format`. Their schema options are built directly
    // from the vocabulary's built-ins, so an exact value match identifies the
    // owning pick list without coupling the renderer to kind names.
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
    LibraryImageFieldSpec<TDraft, TValue> field,
  ) {
    final value = field.currentValue(widget.draft);
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

  Widget? _fieldError(LibraryFieldSpec<TDraft> field) {
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
}
