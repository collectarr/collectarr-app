import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';
import 'package:flutter/material.dart';

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
    _tabOrder = List.generate(_totalTabCount, (index) => index);
    if (widget.showTabBar && _totalTabCount > 0) {
      _loadSavedTabOrder();
    }
  }

  int get _totalTabCount => widget.schema.tabs.length + widget.extraTabs.length;

  Future<void> _loadSavedTabOrder() async {
    final order = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: _totalTabCount,
    );
    if (!mounted) return;
    if (order != null) {
      setState(() => _tabOrder = order);
      return;
    }

    // Preserve an existing schema-only order when kind-owned tabs were added
    // later; place those new tabs after the saved schema tabs.
    if (widget.extraTabs.isEmpty) return;
    final schemaOrder = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: widget.schema.tabs.length,
    );
    if (!mounted || schemaOrder == null) return;
    setState(() {
      _tabOrder = [
        ...schemaOrder,
        for (var index = widget.schema.tabs.length;
            index < _totalTabCount;
            index++)
          index,
      ];
    });
  }

  Future<void> _saveTabOrder() {
    return saveLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      order: _tabOrder,
    );
  }

  List<int> _orderedVisibleTabIndexes() {
    final schemaTabCount = widget.schema.tabs.length;
    final visible = <int>{
      for (var index = 0; index < schemaTabCount; index++)
        if (widget.schema.tabs[index].isVisible(widget.draft)) index,
      for (var index = 0; index < widget.extraTabs.length; index++)
        schemaTabCount + index,
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
    if (oldWidget.schema.tabs.length != widget.schema.tabs.length ||
        oldWidget.extraTabs.length != widget.extraTabs.length) {
      _tabOrder = List.generate(_totalTabCount, (index) => index);
      _selectedTabIndex = 0;
      if (widget.showTabBar && _totalTabCount > 0) {
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

    final totalTabCount = visibleTabIndexes.length;
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
    final sourceIndex = visibleTabIndexes[selectedIndex];
    if (sourceIndex < widget.schema.tabs.length) {
      return _buildTabContent(context, widget.schema.tabs[sourceIndex]);
    }
    return widget.extraTabs[sourceIndex - widget.schema.tabs.length].content;
  }

  Widget _buildTabBar(
    BuildContext context,
    List<int> tabIndexes,
    int selectedIndex,
  ) {
    final tabs = [
      for (final index in tabIndexes) _tabForSourceIndex(index),
    ];
    return LibraryEditTabStripFrame(
      child: LibraryEditReorderableTabStrip(
        tabs: tabs,
        accent: widget.tabAccent ?? Theme.of(context).colorScheme.primary,
        selectedIndex: selectedIndex,
        onSelect: (index) => setState(() => _selectedTabIndex = index),
        allowReorder: true,
        onReorderItem: (oldIndex, newIndex) =>
            _onReorderTab(oldIndex, newIndex, tabIndexes),
      ),
    );
  }

  EditTab _tabForSourceIndex(int index) {
    if (index < widget.schema.tabs.length) {
      final tab = widget.schema.tabs[index];
      return EditTab(
        icon: tab.icon ?? Icons.edit_outlined,
        label: tab.label,
      );
    }
    final tab = widget.extraTabs[index - widget.schema.tabs.length];
    return EditTab(icon: tab.icon, label: tab.label);
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

  Widget _buildField(LibraryFieldSpec<TDraft> field) =>
      LibraryFieldSpecControlBuilder<TDraft>(
        context: context,
        draft: widget.draft,
        mode: LibraryFieldSpecControlMode.edit,
        controllerFor: _controllerFor,
        mediaKind: widget.mediaKind,
        onChanged: () {
          if (mounted) setState(() => _validationError = null);
        },
      ).build(field);

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
}
