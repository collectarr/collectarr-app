import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/library_filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_quick_view.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

/// Result returned when the user selects a smart list to load.
class SmartListLoadResult {
  const SmartListLoadResult({
    required this.filterSelection,
    this.quickView,
    this.sortColumn,
    this.sortAscending,
    this.searchQuery,
  });

  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
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
  LibrarySortColumn? currentSortColumn,
  bool? currentSortAscending,
  String? currentSearchQuery,
}) {
  return showDialog<SmartListLoadResult>(
    context: context,
    builder: (_) => _SmartListsDialog(
      db: db,
      mediaKind: mediaKind,
      currentFilter: currentFilter,
      currentQuickView: currentQuickView,
      currentSortColumn: currentSortColumn,
      currentSortAscending: currentSortAscending,
      currentSearchQuery: currentSearchQuery,
    ),
  );
}

class _SmartListsDialog extends StatefulWidget {
  const _SmartListsDialog({
    required this.db,
    required this.mediaKind,
    required this.currentFilter,
    this.currentQuickView,
    this.currentSortColumn,
    this.currentSortAscending,
    this.currentSearchQuery,
  });

  final LocalDatabase db;
  final String? mediaKind;
  final LibraryFilterSelection currentFilter;
  final LibraryQuickView? currentQuickView;
  final LibrarySortColumn? currentSortColumn;
  final bool? currentSortAscending;
  final String? currentSearchQuery;

  @override
  State<_SmartListsDialog> createState() => _SmartListsDialogState();
}

class _SmartListsDialogState extends State<_SmartListsDialog> {
  List<SmartList> _lists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = SmartListRepository(widget.db);
    final lists = await repo.getAll(mediaKind: widget.mediaKind);
    if (mounted) {
      setState(() {
        _lists = lists;
        _loading = false;
      });
    }
  }

  Future<void> _saveCurrentAsSmartList() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kClzPanel,
        title: const Text('Save Smart List'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Unread Marvel',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final repo = SmartListRepository(widget.db);
    await repo.create(SmartList(
      id: '', // will be generated
      name: name,
      mediaKind: widget.mediaKind,
      filterSelection: widget.currentFilter,
      quickView: widget.currentQuickView,
      sortColumn: widget.currentSortColumn,
      sortAscending: widget.currentSortAscending,
      searchQuery: widget.currentSearchQuery,
    ));
    _load();
  }

  Future<void> _delete(SmartList list) async {
    final repo = SmartListRepository(widget.db);
    await repo.delete(list.id);
    _load();
  }

  void _load_(SmartList list) {
    Navigator.pop(
      context,
      SmartListLoadResult(
        filterSelection: list.filterSelection,
        quickView: list.quickView,
        sortColumn: list.sortColumn,
        sortAscending: list.sortAscending,
        searchQuery: list.searchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kClzPanel,
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
        width: 360,
        height: 320,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _lists.isEmpty
                ? Center(
                    child: Text(
                      'No saved smart lists.\n'
                      'Apply filters, then tap + to save\n'
                      'the current view as a smart list.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kClzTextMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _lists.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: kClzDivider),
                    itemBuilder: (context, i) {
                      final list = _lists[i];
                      return ListTile(
                        leading: const Icon(
                            Icons.filter_list, size: 20),
                        title: Text(list.name),
                        subtitle: _buildSubtitle(list),
                        dense: true,
                        onTap: () => _load_(list),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => _delete(list),
                          tooltip: 'Delete',
                        ),
                      );
                    },
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
    if (list.sortColumn != null) parts.add('sort: ${list.sortColumn!.name}');
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: TextStyle(color: kClzTextMuted, fontSize: 12),
    );
  }
}
