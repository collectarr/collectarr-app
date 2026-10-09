import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/smart_list.dart';
import 'package:collectarr_app/features/library/config/presentation/library_sort_presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

/// Result returned when the user selects a smart list to load.
class SmartListLoadResult {
  const SmartListLoadResult({
    required this.filterSelection,
    this.quickView,
    this.sortRules,
    this.sortColumn,
    this.sortAscending,
    this.searchQuery,
    this.target,
  });

  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
  final List<LibrarySortRule>? sortRules;
  final String? sortColumn;
  final bool? sortAscending;
  final String? searchQuery;
  final SmartListCriteriaTarget? target;
}

/// Shows the smart lists dialog and returns a [SmartListLoadResult] if the user
/// picks a saved list, or null if cancelled.
Future<SmartListLoadResult?> showSmartListsDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String mediaKind,
  required LibraryFilterSelection currentFilter,
  LibraryQuickView? currentQuickView,
  List<LibrarySortRule>? currentSortRules,
  String? currentSortColumn,
  bool? currentSortAscending,
  String? currentSearchQuery,
  required SmartListCriteriaTarget currentTarget,
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  bool collectionManager = false,
  bool allowCurrentViewUpdate = true,
}) {
  return showDialog<SmartListLoadResult>(
    context: context,
    builder: (_) => _SmartListsDialog(
      db: db,
      mediaKind: mediaKind,
      currentFilter: currentFilter,
      currentQuickView: currentQuickView,
      currentSortRules: currentSortRules,
      currentSortColumn: currentSortColumn,
      currentSortAscending: currentSortAscending,
      currentSearchQuery: currentSearchQuery,
      currentTarget: currentTarget,
      customFieldDefinitions: customFieldDefinitions,
      collectionManager: collectionManager,
      allowCurrentViewUpdate: allowCurrentViewUpdate,
    ),
  );
}

class _SmartListsDialog extends StatefulWidget {
  const _SmartListsDialog({
    required this.db,
    required this.mediaKind,
    required this.currentFilter,
    this.currentQuickView,
    this.currentSortRules,
    this.currentSortColumn,
    this.currentSortAscending,
    this.currentSearchQuery,
    required this.currentTarget,
    this.customFieldDefinitions = const [],
    this.collectionManager = false,
    this.allowCurrentViewUpdate = true,
  });

  final LocalDatabase db;
  final String mediaKind;
  final LibraryFilterSelection currentFilter;
  final LibraryQuickView? currentQuickView;
  final List<LibrarySortRule>? currentSortRules;
  final String? currentSortColumn;
  final bool? currentSortAscending;
  final String? currentSearchQuery;
  final SmartListCriteriaTarget currentTarget;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final bool collectionManager;
  final bool allowCurrentViewUpdate;

  @override
  State<_SmartListsDialog> createState() => _SmartListsDialogState();
}

class _SmartListsDialogState extends State<_SmartListsDialog> {
  List<SmartList> _lists = [];
  bool _loading = true;
  String? _selectedListId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = SmartListRepository(widget.db);
    final lists = await repo.getAll(
      mediaKind: widget.mediaKind,
      target: widget.currentTarget,
    );
    if (mounted) {
      final currentSelection = _selectedListId;
      setState(() {
        _lists = lists;
        _selectedListId = lists.any((list) => list.id == currentSelection)
            ? currentSelection
            : (lists.isEmpty ? null : lists.first.id);
        _loading = false;
      });
    }
  }

  Future<void> _saveCurrentAsSmartList() async {
    final name = await _promptForName(
      title: widget.collectionManager ? 'Add Collection' : 'Save Smart List',
      confirmLabel: widget.collectionManager ? 'Add' : 'Save',
      hintText:
          widget.collectionManager ? 'e.g. Favorites' : 'e.g. Unread Marvel',
    );
    if (name == null || name.isEmpty) return;

    final kinds = widget.collectionManager
        ? <String>{widget.mediaKind}
        : await _chooseKinds({widget.mediaKind});
    if (kinds == null || kinds.isEmpty) return;

    final repo = SmartListRepository(widget.db);
    await repo.create(_currentViewSmartList(name: name, kinds: kinds));
    await _load();
  }

  Future<Set<String>?> _chooseKinds(Set<String> initialKinds) {
    final selectedKinds = Set<String>.of(initialKinds);
    return showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AccentAlertDialog(
          backgroundColor: appPalette(context).panel,
          title: const Text('Smart List kinds'),
          content: SizedBox(
            width: 420,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in CatalogMediaKind.values)
                  if (!kind.isUnknown)
                    FilterChip(
                      label: Text(kind.apiValue),
                      selected: selectedKinds.contains(kind.apiValue),
                      onSelected: (selected) => setDialogState(() {
                        if (selected) {
                          selectedKinds.add(kind.apiValue);
                        } else {
                          selectedKinds.remove(kind.apiValue);
                        }
                      }),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedKinds.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, selectedKinds),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForName({
    required String title,
    required String confirmLabel,
    required String hintText,
    String? initialValue,
  }) async {
    final nameCtrl = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: Text(title),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: hintText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  SmartList _currentViewSmartList({
    required String name,
    String? id,
    Set<String>? kinds,
  }) {
    return SmartList(
      id: id ?? '',
      name: name,
      target: widget.currentTarget,
      kinds: kinds == null
          ? [widget.mediaKind]
          : [
              for (final kind in CatalogMediaKind.values)
                if (kinds.contains(kind.apiValue)) kind.apiValue,
            ],
      filterSelection: widget.currentFilter,
      quickView: widget.currentQuickView,
      sortRules: widget.currentSortRules ??
          (widget.currentSortColumn == null
              ? null
              : [
                  LibrarySortRule(
                    column: widget.currentSortColumn!,
                    ascending: widget.currentSortAscending ?? true,
                  ),
                ]),
      searchQuery: widget.currentSearchQuery,
    );
  }

  Future<void> _rename(SmartList list) async {
    final name = await _promptForName(
      title:
          widget.collectionManager ? 'Rename Collection' : 'Rename Smart List',
      confirmLabel: 'Rename',
      hintText: 'e.g. Unread Marvel',
      initialValue: list.name,
    );
    if (name == null || name.isEmpty || name == list.name) {
      return;
    }

    final repo = SmartListRepository(widget.db);
    await repo.update(
      SmartList(
        id: list.id,
        name: name,
        target: list.target,
        kinds: list.kinds,
        filterSelection: list.filterSelection,
        quickView: list.quickView,
        sortRules: list.sortRules,
        searchQuery: list.searchQuery,
      ),
    );
    await _load();
  }

  Future<void> _editKinds(SmartList list) async {
    final result = await _chooseKinds(list.kinds.toSet());
    if (result == null || result.isEmpty) return;

    await SmartListRepository(widget.db).update(
      SmartList(
        id: list.id,
        name: list.name,
        target: list.target,
        kinds: [
          for (final kind in CatalogMediaKind.values)
            if (result.contains(kind.apiValue)) kind.apiValue,
        ],
        filterSelection: list.filterSelection,
        quickView: list.quickView,
        sortRules: list.sortRules,
        searchQuery: list.searchQuery,
      ),
    );
    await _load();
  }

  Future<void> _overwriteFromCurrentView(SmartList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: Text(widget.collectionManager
            ? 'Update Collection'
            : 'Overwrite Smart List'),
        content: Text(
          'Replace "${list.name}" with the current filters, search, sort and quick view?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final repo = SmartListRepository(widget.db);
    await repo.update(_currentViewSmartList(
      name: list.name,
      id: list.id,
      kinds: list.kinds.toSet(),
    ));
    await _load();
  }

  Future<void> _delete(SmartList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: Text(widget.collectionManager
            ? 'Delete Collection'
            : 'Delete Smart List'),
        content: Text(
          widget.collectionManager
              ? 'Delete the "${list.name}" collection tab?'
              : 'Delete "${list.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final repo = SmartListRepository(widget.db);
    await repo.delete(list.id);
    await _load();
  }

  void _load_(SmartList list) {
    Navigator.pop(
      context,
      SmartListLoadResult(
        filterSelection: list.filterSelection,
        quickView: list.quickView,
        sortRules: list.sortRules,
        sortColumn: list.sortColumn,
        sortAscending: list.sortAscending,
        searchQuery: list.searchQuery,
        target: list.target,
      ),
    );
  }

  SmartList? get _selectedList {
    final id = _selectedListId;
    if (id == null) {
      return null;
    }
    for (final list in _lists) {
      if (list.id == id) {
        return list;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedList = _selectedList;
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      title: Row(
        children: [
          Icon(
            widget.collectionManager
                ? Icons.collections_bookmark
                : Icons.auto_awesome_mosaic,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.collectionManager ? 'Manage Collections' : 'Smart Lists',
            ),
          ),
          if (!widget.collectionManager)
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Save current view as smart list',
              onPressed: _saveCurrentAsSmartList,
            ),
        ],
      ),
      content: SizedBox(
        width: widget.collectionManager ? 640 : 760,
        height: 380,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : widget.collectionManager
                ? _buildCollectionManager(palette)
                : _lists.isEmpty
                    ? Center(
                        child: Text(
                          'No saved smart lists.\n'
                          'Apply filters, then tap + to save\n'
                          'the current view as a smart list.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.textMuted),
                        ),
                      )
                    : Row(
                        children: [
                          SizedBox(
                            width: 310,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: palette.panelRaised,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: palette.divider),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListView.separated(
                                  itemCount: _lists.length,
                                  separatorBuilder: (_, __) => Divider(
                                      height: 1, color: palette.divider),
                                  itemBuilder: (context, i) {
                                    final list = _lists[i];
                                    final selected = list.id == _selectedListId;
                                    return ListTile(
                                      leading: Icon(
                                        selected
                                            ? Icons.bookmark_added
                                            : Icons.filter_list,
                                        size: 20,
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                      title: Text(list.name),
                                      subtitle: _buildSubtitle(list),
                                      dense: true,
                                      selected: selected,
                                      onTap: () => setState(
                                          () => _selectedListId = list.id),
                                      trailing:
                                          PopupMenuButton<_SmartListAction>(
                                        icon: const Icon(Icons.more_horiz,
                                            size: 18),
                                        tooltip: 'Smart list actions',
                                        onSelected: (action) async {
                                          switch (action) {
                                            case _SmartListAction.load:
                                              _load_(list);
                                            case _SmartListAction.rename:
                                              await _rename(list);
                                            case _SmartListAction.overwrite:
                                              await _overwriteFromCurrentView(
                                                  list);
                                            case _SmartListAction.delete:
                                              await _delete(list);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem<_SmartListAction>(
                                            value: _SmartListAction.load,
                                            child: Text('Load'),
                                          ),
                                          PopupMenuItem<_SmartListAction>(
                                            value: _SmartListAction.rename,
                                            child: Text('Rename'),
                                          ),
                                          PopupMenuItem<_SmartListAction>(
                                            value: _SmartListAction.overwrite,
                                            child: Text(
                                                'Overwrite with current view'),
                                          ),
                                          PopupMenuItem<_SmartListAction>(
                                            value: _SmartListAction.delete,
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: selectedList == null
                                ? const SizedBox.shrink()
                                : _SmartListDetailsPane(
                                    list: selectedList,
                                    customFieldDefinitions:
                                        widget.customFieldDefinitions,
                                    onLoad: () => _load_(selectedList),
                                    onRename: () => _rename(selectedList),
                                    onEditKinds: () => _editKinds(selectedList),
                                    onOverwriteFromCurrentView: () =>
                                        _overwriteFromCurrentView(selectedList),
                                    onDelete: () => _delete(selectedList),
                                  ),
                          ),
                        ],
                      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildCollectionManager(AppThemePalette palette) {
    return Column(
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: Color(0xFF464950),
            border: Border(
              bottom: BorderSide(color: Color(0xFF383838)),
            ),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saveCurrentAsSmartList,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add Collection'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5EB1DE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
        Expanded(
          child: _lists.isEmpty
              ? Center(
                  child: Text(
                    'No collections yet. Add one to create a collection tab.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.textMuted),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: ListView.separated(
                    itemCount: _lists.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: palette.divider),
                    itemBuilder: (context, index) {
                      final list = _lists[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.collections_bookmark_outlined),
                        title: Text(list.name),
                        subtitle: _buildSubtitle(list),
                        dense: true,
                        minVerticalPadding: 7,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Rename collection',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _rename(list),
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                              ),
                            ),
                            if (widget.allowCurrentViewUpdate)
                              PopupMenuButton<_SmartListAction>(
                                tooltip: 'Collection actions',
                                icon: const Icon(Icons.more_horiz, size: 18),
                                onSelected: (action) async {
                                  if (action == _SmartListAction.overwrite) {
                                    await _overwriteFromCurrentView(list);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem<_SmartListAction>(
                                    value: _SmartListAction.overwrite,
                                    child: Text('Use current view'),
                                  ),
                                ],
                              ),
                            IconButton(
                              tooltip: 'Delete collection',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _delete(list),
                              icon: const Icon(Icons.delete_outline, size: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget? _buildSubtitle(SmartList list) {
    final parts = <String>[];
    if (list.filterSelection.hasActiveFilters) {
      parts.add('${list.filterSelection.activeFilterCount} filter(s)');
    }
    if (list.quickView != null) parts.add(list.quickView!.label);
    if (list.searchQuery != null) parts.add('"${list.searchQuery}"');
    if (list.isDegraded) parts.add('unavailable fields preserved');
    final sortSummary = _smartListSortSummary(list.effectiveSortRules);
    if (sortSummary != null) parts.add('sort: $sortSummary');
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: TextStyle(color: appPalette(context).textMuted, fontSize: 12),
    );
  }
}

class _SmartListDetailsPane extends StatelessWidget {
  const _SmartListDetailsPane({
    required this.list,
    required this.customFieldDefinitions,
    required this.onLoad,
    required this.onRename,
    required this.onEditKinds,
    required this.onOverwriteFromCurrentView,
    required this.onDelete,
  });

  final SmartList list;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final VoidCallback onLoad;
  final Future<void> Function() onRename;
  final Future<void> Function() onEditKinds;
  final Future<void> Function() onOverwriteFromCurrentView;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final criteriaChips = _criteriaChips(list);
    final sortSummary = _smartListSortSummary(list.effectiveSortRules);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saved view details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (list.quickView != null)
                          Chip(
                              label:
                                  Text('Quick view: ${list.quickView!.label}')),
                        if (sortSummary != null)
                          Chip(
                            label: Text(
                              'Sort: $sortSummary',
                            ),
                          ),
                        if (list.searchQuery != null &&
                            list.searchQuery!.isNotEmpty)
                          Chip(label: Text('Search: ${list.searchQuery!}')),
                        Chip(label: Text('Target: ${list.target.value}')),
                        for (final kind in list.kinds)
                          Chip(label: Text('Kind: $kind')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (criteriaChips.isEmpty)
                      Text(
                        'No filters saved. This list only stores search, sort, or quick view settings.',
                        style: TextStyle(color: palette.textMuted),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final chip in criteriaChips)
                            Chip(label: Text(chip)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onLoad,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Load'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onRename(),
                  icon: const Icon(Icons.drive_file_rename_outline),
                  label: const Text('Rename'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onEditKinds(),
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('Kinds'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onOverwriteFromCurrentView(),
                  icon: const Icon(Icons.save_as_outlined),
                  label: const Text('Use current view'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onDelete(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _criteriaChips(SmartList list) {
    final filter = list.filterSelection;
    return [
      if (filter.entriesFilter != LibraryEntryPolicyFilter.all)
        'EntryPolicy: ${libraryEntryPolicyFilterLabel(filter.entriesFilter, mediaType: list.kinds.first)}',
      if (filter.trackingStatusFilter != LibraryTrackingStatusFilter.all)
        'Tracking: ${libraryTrackingStatusFilterLabel(filter.trackingStatusFilter, mediaType: list.kinds.first)}',
      if (filter.loanStatusFilter != LibraryLoanStatusFilter.all)
        'Loan: ${libraryLoanStatusFilterLabel(filter.loanStatusFilter, mediaType: list.kinds.first)}',
      if (filter.hasActiveDateRange) 'Date: ${_dateRangeLabel(filter)}',
      if (filter.customFieldDefinitionId != null)
        'Custom: ${_customFieldChipLabel(filter)}',
      for (final entry in filter.fieldValues.entries)
        if (entry.value?.isNotEmpty == true)
          '${libraryFallbackLabelForId(entry.key)}: ${entry.value}',
      if (filter.missingCover) 'Missing cover',
      if (filter.missingMetadata) 'Missing metadata',
    ];
  }

  String _dateRangeLabel(LibraryFilterSelection filter) {
    final field = libraryDateRangeFieldLabel(
      filter.dateRangeField,
      mediaType: list.kinds.first,
    );
    final from =
        filter.dateFrom == null ? null : _formatDateChip(filter.dateFrom!);
    final to = filter.dateTo == null ? null : _formatDateChip(filter.dateTo!);
    if (from != null && to != null) {
      return '$field $from-$to';
    }
    if (from != null) {
      return '$field from $from';
    }
    return '$field until $to';
  }

  String _customFieldChipLabel(LibraryFilterSelection filter) {
    final definitionId = filter.customFieldDefinitionId;
    String? name;
    for (final definition in customFieldDefinitions) {
      if (definition.id == definitionId) {
        name = definition.name;
        break;
      }
    }
    final fieldLabel = name ?? 'Field';
    final value = filter.customFieldValue;
    if (value == null || value.isEmpty) {
      return '$fieldLabel has value';
    }
    return '$fieldLabel = $value';
  }

  String _formatDateChip(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

enum _SmartListAction {
  load,
  rename,
  overwrite,
  delete,
}

String? _smartListSortSummary(List<LibrarySortRule> rules) {
  if (rules.isEmpty) {
    return null;
  }
  return rules
      .map((rule) => '${rule.column} ${rule.ascending ? 'asc' : 'desc'}')
      .join(', ');
}
