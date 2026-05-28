import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showReadingQueueDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String mediaKind,
  required Iterable<OwnedItem> ownedItems,
  required Map<String, CatalogItem> catalogItemsById,
  ValueChanged<String>? onSelectItem,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReadingQueueDialog(
      db: db,
      mediaKind: mediaKind,
      ownedItems: ownedItems.toList(growable: false),
      catalogItemsById: catalogItemsById,
      onSelectItem: onSelectItem,
    ),
  );
}

class _ReadingQueueDialog extends StatefulWidget {
  const _ReadingQueueDialog({
    required this.db,
    required this.mediaKind,
    required this.ownedItems,
    required this.catalogItemsById,
    this.onSelectItem,
  });

  final LocalDatabase db;
  final String mediaKind;
  final List<OwnedItem> ownedItems;
  final Map<String, CatalogItem> catalogItemsById;
  final ValueChanged<String>? onSelectItem;

  @override
  State<_ReadingQueueDialog> createState() => _ReadingQueueDialogState();
}

class _ReadingQueueDialogState extends State<_ReadingQueueDialog> {
  final _searchController = TextEditingController();
  List<_ReadingQueueDialogEntry> _entries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ReadingQueueRepository(widget.db);
    final queueIds = await repo.getQueue();
    final ownedById = {
      for (final item in widget.ownedItems)
        if (!item.isDeleted) item.id: item,
    };
    final entries = <_ReadingQueueDialogEntry>[];
    for (final queuedId in queueIds) {
      final ownedItem = ownedById[queuedId];
      if (ownedItem == null) {
        continue;
      }
      final catalogItem = widget.catalogItemsById[ownedItem.itemId];
      if (catalogItem == null || catalogItem.kind != widget.mediaKind) {
        continue;
      }
      entries.add(
        _ReadingQueueDialogEntry(
          ownedItem: ownedItem,
          catalogItem: catalogItem,
        ),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _moveToPosition(
    _ReadingQueueDialogEntry entry,
    int newPosition,
  ) async {
    await ReadingQueueRepository(widget.db).moveToPosition(
      entry.ownedItem.id,
      newPosition,
    );
    await _load();
  }

  Future<void> _remove(_ReadingQueueDialogEntry entry) async {
    await ReadingQueueRepository(widget.db).removeFromQueue(entry.ownedItem.id);
    await _load();
  }

  Future<void> _reorderFilteredEntries(int oldIndex, int newIndex) async {
    final filteredEntries = _filteredEntries;
    if (filteredEntries.isEmpty || oldIndex < 0 || oldIndex >= filteredEntries.length) {
      return;
    }
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final movedEntry = filteredEntries[oldIndex];
    final filteredWithoutMoved = [...filteredEntries]..removeAt(oldIndex);
    final clampedIndex = adjustedNewIndex.clamp(0, filteredWithoutMoved.length);
    final reorderedFiltered = [...filteredWithoutMoved]
      ..insert(clampedIndex, movedEntry);

    final fullWithoutMoved = [..._entries]
      ..removeWhere((entry) => entry.ownedItem.id == movedEntry.ownedItem.id);
    final predecessor = clampedIndex > 0 ? reorderedFiltered[clampedIndex - 1] : null;
    final successor = clampedIndex < reorderedFiltered.length - 1
        ? reorderedFiltered[clampedIndex + 1]
        : null;

    int targetIndex;
    if (predecessor != null) {
      targetIndex =
          fullWithoutMoved.indexWhere((entry) => entry.ownedItem.id == predecessor.ownedItem.id) + 1;
    } else if (successor != null) {
      targetIndex =
          fullWithoutMoved.indexWhere((entry) => entry.ownedItem.id == successor.ownedItem.id);
    } else {
      targetIndex = 0;
    }

    await _moveToPosition(movedEntry, targetIndex);
  }

  void _openItem(_ReadingQueueDialogEntry entry) {
    Navigator.of(context).pop();
    widget.onSelectItem?.call(entry.ownedItem.itemId);
  }

  List<_ReadingQueueDialogEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _entries.where((entry) => _matchesQuery(entry, query)).toList(growable: false);
  }

  bool _matchesQuery(_ReadingQueueDialogEntry entry, String query) {
    final fields = [
      entry.label,
      entry.catalogItem.publisher,
      entry.ownedItem.readStatus,
      entry.ownedItem.personalNotes,
    ];
    for (final field in fields) {
      final normalized = field?.trim().toLowerCase();
      if (normalized != null && normalized.contains(query)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final filteredEntries = _filteredEntries;
    return AlertDialog(
      backgroundColor: palette.panel,
      title: Row(
        children: [
          const Icon(Icons.bookmarks_outlined, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Reading Queue')),
          if (_entries.isNotEmpty)
            Text(
              '${filteredEntries.length}/${_entries.length} item${_entries.length == 1 ? '' : 's'}',
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
        ],
      ),
      content: SizedBox(
        width: 560,
        height: 460,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? Center(
                    child: Text(
                      'No queued items for this library yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Filter queue',
                          hintText: 'Title, publisher, status, notes',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_searchController.text.trim().isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Drag to reorder still works in filtered results.',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_searchController.text.trim().isNotEmpty)
                        const SizedBox(height: 8),
                      Expanded(
                        child: filteredEntries.isEmpty
                            ? Center(
                                child: Text(
                                  'No queued items match this filter.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: palette.textMuted),
                                ),
                              )
                            : ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                itemCount: filteredEntries.length,
                                onReorderItem: (oldIndex, newIndex) {
                                  unawaited(
                                    _reorderFilteredEntries(oldIndex, newIndex),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final entry = filteredEntries[index];
                                  final details = <String>[];
                                  final publisher = entry.catalogItem.publisher?.trim();
                                  if (publisher != null && publisher.isNotEmpty) {
                                    details.add(publisher);
                                  }
                                  final readStatus = entry.ownedItem.readStatus?.trim();
                                  if (readStatus != null && readStatus.isNotEmpty) {
                                    details.add(readStatus);
                                  }
                                  final notes = entry.ownedItem.personalNotes?.trim();
                                  if (notes != null && notes.isNotEmpty) {
                                    details.add('Has notes');
                                  }
                                  final queuePosition =
                                      _entries.indexWhere((e) => e.ownedItem.id == entry.ownedItem.id) + 1;
                                  return ListTile(
                                    key: ValueKey(entry.ownedItem.id),
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: palette.panelRaised,
                                      child: Text(
                                        '$queuePosition',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    title: Text(entry.label),
                                    subtitle: details.isEmpty
                                        ? null
                                        : Text(
                                            details.join(' · '),
                                            style: TextStyle(
                                              color: palette.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                    onTap: () => _openItem(entry),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Icon(Icons.drag_indicator),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Remove from queue',
                                          onPressed: () => _remove(entry),
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ReadingQueueDialogEntry {
  const _ReadingQueueDialogEntry({
    required this.ownedItem,
    required this.catalogItem,
  });

  final OwnedItem ownedItem;
  final CatalogItem catalogItem;

  String get label {
    final itemNumber = catalogItem.itemNumber?.trim();
    if (itemNumber == null || itemNumber.isEmpty) {
      return catalogItem.title;
    }
    return '${catalogItem.title} #$itemNumber';
  }
}