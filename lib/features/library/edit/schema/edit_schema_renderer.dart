import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema_validation.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/schema/library_schema_text_controller_store.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_schema.dart';

/// A kind-entry tab mounted alongside schema tabs without widening the edit
/// draft model. The tab content may manage its own independent mutations.
final class EditSchemaExtraTab {
  const EditSchemaExtraTab({
    required this.id,
    required this.label,
    required this.content,
    this.icon = Icons.extension_outlined,
    this.validate,
  });

  final String id;
  final String label;
  final IconData icon;
  final Widget content;

  /// Validates an extra tab even when it has not been mounted yet.
  final String? Function()? validate;
}

class EditSchemaRenderer<TModel, TDraft> extends StatefulWidget {
  factory EditSchemaRenderer({
    Key? key,
    required EditSchema<TModel, TDraft> schema,
    required TModel model,
    required TDraft draft,
    required FutureOr<void> Function(TDraft draft) onSave,
    VoidCallback? onCancel,
    String? title,
    bool showTitle = true,
    int initialTabIndex = 0,
    bool showTabBar = true,
    bool showFooter = true,
    bool fillAvailableHeight = false,
    bool tabNavigationEnabled = true,
    Color? tabAccent,
    String? tabOrderKey,
    List<EditSchemaExtraTab> extraTabs = const [],
    String? mediaKind,
  }) =>
      EditSchemaRenderer<TModel, TDraft>._(
        key: key,
        schema: schema,
        model: model,
        draft: draft,
        onSave: onSave,
        onCancel: onCancel,
        title: title,
        showTitle: showTitle,
        initialTabIndex: initialTabIndex,
        showTabBar: showTabBar,
        showFooter: showFooter,
        fillAvailableHeight: fillAvailableHeight,
        tabNavigationEnabled: tabNavigationEnabled,
        tabAccent: tabAccent,
        tabOrderKey: tabOrderKey,
        extraTabs: extraTabs,
        mediaKind: mediaKind,
      );

  const EditSchemaRenderer.embedded({
    super.key,
    required this.schema,
    required this.model,
    required this.draft,
    this.title,
    this.showTitle = true,
    this.initialTabIndex = 0,
    this.showTabBar = true,
    this.tabNavigationEnabled = true,
    this.tabAccent,
    this.tabOrderKey,
    this.extraTabs = const [],
    this.mediaKind,
  })  : onSave = null,
        onCancel = null,
        showFooter = false,
        fillAvailableHeight = false;

  const EditSchemaRenderer._({
    super.key,
    required this.schema,
    required this.model,
    required this.draft,
    required this.onSave,
    required this.onCancel,
    required this.title,
    required this.showTitle,
    required this.initialTabIndex,
    required this.showTabBar,
    required this.showFooter,
    required this.fillAvailableHeight,
    required this.tabNavigationEnabled,
    required this.tabAccent,
    required this.tabOrderKey,
    required this.extraTabs,
    required this.mediaKind,
  });

  final EditSchema<TModel, TDraft> schema;
  final TModel model;
  final TDraft draft;
  final FutureOr<void> Function(TDraft draft)? onSave;
  final VoidCallback? onCancel;
  final String? title;
  final bool showTitle;
  final int initialTabIndex;
  final bool showTabBar;
  final bool showFooter;
  final bool fillAvailableHeight;
  final bool tabNavigationEnabled;
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
  final _textControllers = LibrarySchemaTextControllerStore();
  final Map<String, FocusNode> _fieldFocusNodes = {};
  late List<int> _tabOrder;
  late int _selectedTabIndex;
  String? _selectedTabId;
  final Map<String, Map<String, ({String listName, String value})>>
      _pendingVocabularyValues = {};
  bool _isSaving = false;
  String? _saveError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _tabOrder = List.generate(_totalTabCount, (index) => index);
    final savedTabId = loadLibraryEditTabSelection(widget.tabOrderKey);
    final savedSourceIndex = _sourceIndexForTabId(savedTabId);
    final visibleIndexes = _orderedVisibleTabIndexes();
    final savedVisibleIndex = savedSourceIndex == null
        ? -1
        : visibleIndexes.indexOf(savedSourceIndex);
    _selectedTabIndex = savedVisibleIndex >= 0
        ? savedVisibleIndex
        : _boundedInitialTabIndex(visibleIndexes.length);
    _selectedTabId = savedVisibleIndex >= 0
        ? savedTabId
        : _tabIdForVisibleIndex(visibleIndexes, _selectedTabIndex);
    _rememberSelectedTab();
    if (widget.showTabBar && _totalTabCount > 0) {
      _loadSavedTabOrder();
    }
  }

  void _rememberSelectedTab() {
    final visibleIndexes = _orderedVisibleTabIndexes();
    _selectedTabId ??= _tabIdForVisibleIndex(visibleIndexes, _selectedTabIndex);
    saveLibraryEditTabSelection(
      storageKey: widget.tabOrderKey,
      tabId: _selectedTabId ?? '',
    );
  }

  int _boundedInitialTabIndex(int visibleTabCount) {
    if (visibleTabCount == 0) return 0;
    return widget.initialTabIndex.clamp(0, visibleTabCount - 1).toInt();
  }

  int? _sourceIndexForTabId(String? tabId) {
    if (tabId == null) return null;
    for (var index = 0; index < widget.schema.tabs.length; index++) {
      if (widget.schema.tabs[index].id == tabId) return index;
    }
    for (var index = 0; index < widget.extraTabs.length; index++) {
      if (widget.extraTabs[index].id == tabId) {
        return widget.schema.tabs.length + index;
      }
    }
    return null;
  }

  String? _tabIdForSourceIndex(int sourceIndex) {
    if (sourceIndex < 0 || sourceIndex >= _totalTabCount) return null;
    if (sourceIndex < widget.schema.tabs.length) {
      return widget.schema.tabs[sourceIndex].id;
    }
    return widget.extraTabs[sourceIndex - widget.schema.tabs.length].id;
  }

  String? _tabIdForVisibleIndex(List<int> visibleIndexes, int index) {
    if (index < 0 || index >= visibleIndexes.length) return null;
    return _tabIdForSourceIndex(visibleIndexes[index]);
  }

  int get _totalTabCount => widget.schema.tabs.length + widget.extraTabs.length;

  Future<void> _loadSavedTabOrder() async {
    final order = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: _totalTabCount,
    );
    if (!mounted) return;
    if (order != null) {
      setState(() {
        _tabOrder = order;
        final visibleIndexes = _orderedVisibleTabIndexes();
        final selectedSourceIndex = _sourceIndexForTabId(_selectedTabId);
        final selectedVisibleIndex = selectedSourceIndex == null
            ? -1
            : visibleIndexes.indexOf(selectedSourceIndex);
        if (selectedVisibleIndex >= 0) {
          _selectedTabIndex = selectedVisibleIndex;
        } else {
          _selectedTabIndex = _boundedInitialTabIndex(visibleIndexes.length);
          _selectedTabId =
              _tabIdForVisibleIndex(visibleIndexes, _selectedTabIndex);
        }
      });
      _rememberSelectedTab();
      return;
    }

    // Preserve an existing schema-only order when kind-entry tabs were added
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
      final visibleIndexes = _orderedVisibleTabIndexes();
      final selectedSourceIndex = _sourceIndexForTabId(_selectedTabId);
      final selectedVisibleIndex = selectedSourceIndex == null
          ? -1
          : visibleIndexes.indexOf(selectedSourceIndex);
      if (selectedVisibleIndex >= 0) {
        _selectedTabIndex = selectedVisibleIndex;
      } else {
        _selectedTabIndex = _boundedInitialTabIndex(visibleIndexes.length);
        _selectedTabId =
            _tabIdForVisibleIndex(visibleIndexes, _selectedTabIndex);
      }
    });
    _rememberSelectedTab();
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
        _selectedTabId = _tabIdForSourceIndex(selectedSourceIndex);
      }
    });
    _rememberSelectedTab();
    _saveTabOrder();
  }

  @override
  void dispose() {
    _textControllers.dispose();
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EditSchemaRenderer<TModel, TDraft> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldTabIds = [
      for (final tab in oldWidget.schema.tabs) tab.id,
      for (final tab in oldWidget.extraTabs) tab.id,
    ];
    final nextTabIds = [
      for (final tab in widget.schema.tabs) tab.id,
      for (final tab in widget.extraTabs) tab.id,
    ];
    if (!listEquals(oldTabIds, nextTabIds)) {
      _tabOrder = List.generate(_totalTabCount, (index) => index);
      final visibleIndexes = _orderedVisibleTabIndexes();
      final selectedSourceIndex = _sourceIndexForTabId(_selectedTabId);
      final selectedVisibleIndex = selectedSourceIndex == null
          ? -1
          : visibleIndexes.indexOf(selectedSourceIndex);
      _selectedTabIndex = selectedVisibleIndex >= 0
          ? selectedVisibleIndex
          : _boundedInitialTabIndex(visibleIndexes.length);
      _selectedTabId = _tabIdForVisibleIndex(visibleIndexes, _selectedTabIndex);
      _rememberSelectedTab();
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
      _selectedTabId =
          _tabIdForVisibleIndex(visibleTabIndexes, _selectedTabIndex);
      _rememberSelectedTab();
    }

    // This renderer is also used directly by kind-entry dialogs. `showDialog`
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
          if (widget.fillAvailableHeight)
            Flexible(
              fit: FlexFit.loose,
              child: _contentList(context, visibleTabIndexes, selectedIndex),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 720),
              child: _contentList(context, visibleTabIndexes, selectedIndex),
            ),
          if (widget.showFooter) _buildFooter(context),
        ],
      ),
    );
  }

  Widget _contentList(
    BuildContext context,
    List<int> visibleTabIndexes,
    int selectedIndex,
  ) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (!widget.showFooter &&
            (_validationError != null || _saveError != null))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _buildFeedback(context),
          ),
        EditTabShell(
          scrollable: false,
          children: [
            _buildSelectedContent(
              context,
              visibleTabIndexes,
              selectedIndex,
            ),
          ],
        ),
      ],
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
        onSelect: (index) => setState(() {
          _selectedTabIndex = index;
          _selectedTabId = _tabIdForVisibleIndex(tabIndexes, index);
          _rememberSelectedTab();
        }),
        allowReorder: widget.tabNavigationEnabled,
        enabled: widget.tabNavigationEnabled,
        onReorderItem: (oldIndex, newIndex) =>
            _onReorderTab(oldIndex, newIndex, tabIndexes),
      ),
    );
  }

  EditTab _tabForSourceIndex(int index) {
    if (index < widget.schema.tabs.length) {
      final tab = widget.schema.tabs[index];
      return EditTab(
        key: ValueKey<String>('schema-tab-${tab.id}'),
        icon: tab.icon ?? Icons.edit_outlined,
        label: tab.label,
      );
    }
    final extraIndex = index - widget.schema.tabs.length;
    final tab = widget.extraTabs[extraIndex];
    return EditTab(
      key: ValueKey<String>('extra-tab-${tab.id}'),
      icon: tab.icon,
      label: tab.label,
    );
  }

  Widget _buildTabContent(BuildContext context, EditTabSpec<TDraft> tab) {
    final sections = tab.sections
        .where((section) => section.isVisible(widget.draft))
        .toList(growable: false);
    return LibraryFieldSpecRenderer<TDraft>.embedded(
      schema: LibraryFormSchema<TDraft>(sections: sections),
      draft: widget.draft,
      emptyMessage: null,
      mediaKind: widget.mediaKind,
      controllerFor: _controllerFor,
      focusNodeFor: (fieldId) => _fieldFocusNode(tab.id, fieldId),
      onChanged: () {
        if (mounted) setState(() => _validationError = null);
      },
      onVocabularyValueChanged: _rememberVocabularyValue,
      onVocabularyValuesChanged: _rememberVocabularyValues,
    );
  }

  FocusNode _fieldFocusNode(String tabId, String fieldId) {
    final key = '$tabId::$fieldId';
    return _fieldFocusNodes.putIfAbsent(key, FocusNode.new);
  }

  void _rememberVocabularyValue({
    required String fieldId,
    required String? listName,
    required String? value,
  }) {
    final normalizedValue = value?.trim();
    if (listName == null ||
        normalizedValue == null ||
        normalizedValue.isEmpty) {
      _pendingVocabularyValues.remove(fieldId);
      return;
    }
    _pendingVocabularyValues[fieldId] = {
      normalizedValue.toLowerCase(): (
        listName: listName,
        value: normalizedValue,
      ),
    };
  }

  void _rememberVocabularyValues({
    required String fieldId,
    required String? listName,
    required Set<String> values,
  }) {
    if (listName == null || values.isEmpty) {
      _pendingVocabularyValues.remove(fieldId);
      return;
    }
    final pending = <String, ({String listName, String value})>{};
    for (final value in values) {
      final normalizedValue = value.trim();
      if (normalizedValue.isEmpty) continue;
      pending[normalizedValue.toLowerCase()] = (
        listName: listName,
        value: normalizedValue,
      );
    }
    if (pending.isEmpty) {
      _pendingVocabularyValues.remove(fieldId);
    } else {
      _pendingVocabularyValues[fieldId] = pending;
    }
  }

  PickListRepository? _pendingVocabularyRepository() {
    final mediaKind = widget.mediaKind;
    if (mediaKind == null || _pendingVocabularyValues.isEmpty) return null;
    final db = ProviderScope.containerOf(context, listen: false)
        .read(localDatabaseProvider);
    return PickListRepository(db);
  }

  Future<void> _savePendingVocabularyValues(
    PickListRepository? repository,
  ) async {
    final mediaKind = widget.mediaKind;
    if (repository == null || mediaKind == null) return;
    for (final fieldValues in _pendingVocabularyValues.values) {
      for (final pending in fieldValues.values) {
        await repository.addValue(
          pending.listName,
          pending.value,
          mediaKind: mediaKind,
        );
      }
    }
    _pendingVocabularyValues.clear();
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
    if (_isSaving) return;
    final onSave = widget.onSave;
    if (onSave == null) return;
    final formIsValid = Form.maybeOf(context)?.validate() ?? true;
    final schemaError = widget.schema.validate?.call(
      widget.model,
      widget.draft,
    );
    final fieldIssue = _firstFieldIssue();
    if (!formIsValid || schemaError != null || fieldIssue != null) {
      final visibleTabs = _orderedVisibleTabIndexes();
      final invalidVisibleIndex =
          fieldIssue == null ? -1 : visibleTabs.indexOf(fieldIssue.tabIndex);
      setState(() {
        _validationError = schemaError ?? fieldIssue?.error;
        if (invalidVisibleIndex >= 0) {
          _selectedTabIndex = invalidVisibleIndex;
        }
      });
      _rememberSelectedTab();
      if (schemaError == null &&
          fieldIssue?.focusKey != null &&
          invalidVisibleIndex >= 0) {
        _focusInvalidField(fieldIssue!.focusKey!);
      }
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      final repository = _pendingVocabularyRepository();
      final entry = LibraryEntryEditScope.maybeOf(context);
      if (entry != null) {
        entry.pendingChanges[this] = LibraryVocabularyEditChange([
          for (final fields in _pendingVocabularyValues.values)
            for (final pending in fields.values)
              (
                listName: pending.listName,
                value: pending.value,
                mediaKind: widget.mediaKind
              ),
        ]);
        await onSave(widget.draft);
      } else {
        await onSave(widget.draft);
        await _savePendingVocabularyValues(repository);
      }
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

  void _focusInvalidField(String key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final node = _fieldFocusNodes[key];
      if (node == null) return;
      node.requestFocus();
      final targetContext = node.context;
      if (targetContext != null) {
        unawaited(
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.25,
            duration: Duration.zero,
          ),
        );
      }
    });
  }

  ({int tabIndex, String error, String? focusKey})? _firstFieldIssue() {
    final controllers =
        LibrarySchemaTextControllerScope.readOf(context) ?? _textControllers;
    final failure = firstLibraryFormTabValidationFailure([
      for (final sourceIndex in _orderedVisibleTabIndexes())
        if (sourceIndex < widget.schema.tabs.length)
          LibraryFormValidationTab(
            id: widget.schema.tabs[sourceIndex].id,
            index: sourceIndex,
            validate: () => firstLibraryFormValidationIssue(
              schema: LibraryFormSchema<TDraft>(
                sections: widget.schema.tabs[sourceIndex].sections,
              ),
              draft: widget.draft,
              controllers: controllers,
              validateSchema: false,
            ),
          )
        else
          LibraryFormValidationTab(
            id: widget.extraTabs[sourceIndex - widget.schema.tabs.length].id,
            index: sourceIndex,
            validate: () {
              final error = widget
                  .extraTabs[sourceIndex - widget.schema.tabs.length].validate
                  ?.call();
              return error == null ? null : LibraryFormValidationIssue(error);
            },
          ),
    ]);
    if (failure == null) return null;
    return (
      tabIndex: failure.tabIndex,
      error: failure.issue.message,
      focusKey: failure.issue.fieldId == null
          ? null
          : '${failure.tabId}::${failure.issue.fieldId}',
    );
  }

  TextEditingController _controllerFor(String id, String initialValue) {
    return (LibrarySchemaTextControllerScope.maybeOf(context) ??
            _textControllers)
        .controllerFor(id, initialValue);
  }
}
