import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Result returned when the user selects a smart list to load.
class SmartListLoadResult {
  const SmartListLoadResult({
    required this.filterSelection,
    this.quickView,
    this.sortRules,
    this.sortColumn,
    this.sortAscending,
    this.searchQuery,
  });

  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
  final List<LibrarySortRule>? sortRules;
  final LibrarySortColumn? sortColumn;
  final bool? sortAscending;
  final String? searchQuery;
}

/// Shows the smart lists dialog and returns a [SmartListLoadResult] if the user
/// picks a saved list, or null if cancelled.
Future<SmartListLoadResult?> showSmartListsDialog({
  required BuildContext context,
  required LocalDatabase db,
  String? mediaKind,
  required LibraryFilterSelection currentFilter,
  LibraryQuickView? currentQuickView,
  List<LibrarySortRule>? currentSortRules,
  LibrarySortColumn? currentSortColumn,
  bool? currentSortAscending,
  String? currentSearchQuery,
  List<CustomFieldDefinition> customFieldDefinitions = const [],
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
      customFieldDefinitions: customFieldDefinitions,
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
    this.customFieldDefinitions = const [],
  });

  final LocalDatabase db;
  final String? mediaKind;
  final LibraryFilterSelection currentFilter;
  final LibraryQuickView? currentQuickView;
  final List<LibrarySortRule>? currentSortRules;
  final LibrarySortColumn? currentSortColumn;
  final bool? currentSortAscending;
  final String? currentSearchQuery;
  final List<CustomFieldDefinition> customFieldDefinitions;

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
    final lists = await repo.getAll(mediaKind: widget.mediaKind);
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
      title: 'Save Smart List',
      confirmLabel: 'Save',
      hintText: 'e.g. Unread Marvel',
    );
    if (name == null || name.isEmpty) return;

    final repo = SmartListRepository(widget.db);
    await repo.create(_currentViewSmartList(name: name));
    await _load();
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
      builder: (ctx) => AlertDialog(
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

  SmartList _currentViewSmartList({required String name, String? id}) {
    return SmartList(
      id: id ?? '',
      name: name,
      mediaKind: widget.mediaKind,
      filterSelection: widget.currentFilter,
      quickView: widget.currentQuickView,
      sortRules: widget.currentSortRules,
      sortColumn: widget.currentSortColumn,
      sortAscending: widget.currentSortAscending,
      searchQuery: widget.currentSearchQuery,
    );
  }

  Future<void> _rename(SmartList list) async {
    final name = await _promptForName(
      title: 'Rename Smart List',
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
        mediaKind: list.mediaKind,
        filterSelection: list.filterSelection,
        quickView: list.quickView,
        sortRules: list.sortRules,
        sortColumn: list.sortColumn,
        sortAscending: list.sortAscending,
        searchQuery: list.searchQuery,
      ),
    );
    await _load();
  }

  Future<void> _overwriteFromCurrentView(SmartList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: const Text('Overwrite Smart List'),
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
    await repo.update(_currentViewSmartList(name: list.name, id: list.id));
    await _load();
  }

  Future<void> _delete(SmartList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: const Text('Delete Smart List'),
        content: Text('Delete "${list.name}"?'),
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
    return AlertDialog(
      backgroundColor: palette.panel,
      title: Row(
        children: [
          const Icon(Icons.auto_awesome_mosaic, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Smart Lists')),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Save current view as smart list',
            onPressed: _saveCurrentAsSmartList,
          ),
        ],
      ),
      content: SizedBox(
        width: 760,
        height: 380,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
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
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: palette.divider),
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
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  title: Text(list.name),
                                  subtitle: _buildSubtitle(list),
                                  dense: true,
                                  selected: selected,
                                  onTap: () =>
                                      setState(() => _selectedListId = list.id),
                                  trailing: PopupMenuButton<_SmartListAction>(
                                    icon: const Icon(Icons.more_horiz, size: 18),
                                    tooltip: 'Smart list actions',
                                    onSelected: (action) async {
                                      switch (action) {
                                        case _SmartListAction.load:
                                          _load_(list);
                                        case _SmartListAction.rename:
                                          await _rename(list);
                                        case _SmartListAction.overwrite:
                                          await _overwriteFromCurrentView(list);
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
                                        child: Text('Overwrite with current view'),
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

  Widget? _buildSubtitle(SmartList list) {
    final parts = <String>[];
    if (list.filterSelection.hasActiveFilters) {
      parts.add('${list.filterSelection.activeFilterCount} filter(s)');
    }
    if (list.quickView != null) parts.add(list.quickView!.label);
    if (list.searchQuery != null) parts.add('"${list.searchQuery}"');
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
    required this.onOverwriteFromCurrentView,
    required this.onDelete,
  });

  final SmartList list;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final VoidCallback onLoad;
  final Future<void> Function() onRename;
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
                          Chip(label: Text('Quick view: ${list.quickView!.label}')),
                        if (sortSummary != null)
                          Chip(
                            label: Text(
                              'Sort: $sortSummary',
                            ),
                          ),
                        if (list.searchQuery != null && list.searchQuery!.isNotEmpty)
                          Chip(label: Text('Search: ${list.searchQuery!}')),
                        if (list.mediaKind != null)
                          Chip(label: Text('Kind: ${list.mediaKind!}')),
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
                          for (final chip in criteriaChips) Chip(label: Text(chip)),
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
      if (filter.ownershipFilter != LibraryOwnershipFilter.all)
        'Ownership: ${libraryOwnershipFilterLabel(filter.ownershipFilter)}',
      if (filter.trackingStatusFilter != LibraryTrackingStatusFilter.all)
        'Tracking: ${libraryTrackingStatusFilterLabel(filter.trackingStatusFilter)}',
      if (filter.loanStatusFilter != LibraryLoanStatusFilter.all)
        'Loan: ${libraryLoanStatusFilterLabel(filter.loanStatusFilter)}',
      if (filter.hasActiveDateRange)
        'Date: ${_dateRangeLabel(filter)}',
      if (filter.customFieldDefinitionId != null)
        'Custom: ${_customFieldChipLabel(filter)}',
      if (filter.series != null && filter.series!.isNotEmpty)
        'Series: ${filter.series!}',
      if (filter.location != null && filter.location!.isNotEmpty)
        'Location: ${filter.location!}',
      if (filter.tag != null && filter.tag!.isNotEmpty)
        'Tag: ${filter.tag!}',
      if (filter.publisher != null && filter.publisher!.isNotEmpty)
        'Publisher: ${filter.publisher!}',
      if (filter.condition != null && filter.condition!.isNotEmpty)
        'Condition: ${filter.condition!}',
      if (filter.grade != null && filter.grade!.isNotEmpty)
        'Grade: ${filter.grade!}',
      if (filter.releaseYear != null && filter.releaseYear!.isNotEmpty)
        'Year: ${filter.releaseYear!}',
      if (filter.country != null && filter.country!.isNotEmpty)
        'Country: ${filter.country!}',
      if (filter.language != null && filter.language!.isNotEmpty)
        'Language: ${filter.language!}',
      if (filter.missingCover) 'Missing cover',
      if (filter.missingMetadata) 'Missing metadata',
    ];
  }

  String _dateRangeLabel(LibraryFilterSelection filter) {
    final field = libraryDateRangeFieldLabel(filter.dateRangeField);
    final from = filter.dateFrom == null
        ? null
        : _formatDateChip(filter.dateFrom!);
    final to = filter.dateTo == null
        ? null
        : _formatDateChip(filter.dateTo!);
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
      .map((rule) => '${rule.column.name} ${rule.ascending ? 'asc' : 'desc'}')
      .join(', ');
}
