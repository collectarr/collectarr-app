import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showReadingQueueDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String mediaKind,
  required Iterable<OwnedItemSummary> ownedItems,
  Iterable<TrackingEntry> trackingEntries = const [],
  required Map<String, dynamic> catalogItemsById,
  ValueChanged<String>? onSelectItem,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReadingQueueDialog(
      db: db,
      mediaKind: mediaKind,
      ownedItems: ownedItems.toList(growable: false),
      trackingEntries: trackingEntries.toList(growable: false),
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
    required this.trackingEntries,
    required this.catalogItemsById,
    this.onSelectItem,
  });

  final LocalDatabase db;
  final String mediaKind;
  final List<OwnedItemSummary> ownedItems;
  final List<TrackingEntry> trackingEntries;
  final Map<String, dynamic> catalogItemsById;
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
      for (final item in widget.ownedItems) item.ref.id.value: item,
    };
    final trackingByOwnedId = {
      for (final entry in widget.trackingEntries)
        if (!entry.isDeleted && entry.ownedItemId != null)
          entry.ownedItemId!: entry,
    };
    final trackingByItemId = {
      for (final entry in widget.trackingEntries)
        if (!entry.isDeleted) entry.itemId: entry,
    };
    final entries = <_ReadingQueueDialogEntry>[];
    for (final queuedId in queueIds) {
      final summary = ownedById[queuedId];
      if (summary == null) {
        continue;
      }
      final catalogId = summary.catalogRef?.id;
      if (catalogId == null) {
        continue;
      }
      final catalogItem = typedCatalogItemFromUnknown(
        widget.catalogItemsById[catalogId],
      );
      if (catalogItem == null || catalogItem.kind != widget.mediaKind) {
        continue;
      }
      entries.add(
        _ReadingQueueDialogEntry(
          summary: summary,
          catalogItem: catalogItem,
          trackingEntry: trackingByOwnedId[summary.ref.id.value] ??
              trackingByItemId[catalogId],
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
      entry.summary.ref.id.value,
      newPosition,
    );
    await _load();
  }

  Future<void> _remove(_ReadingQueueDialogEntry entry) async {
    await ReadingQueueRepository(widget.db)
        .removeFromQueue(entry.summary.ref.id.value);
    await _load();
  }

  Future<void> _reorderFilteredEntries(int oldIndex, int newIndex) async {
    final filteredEntries = _filteredEntries;
    if (filteredEntries.isEmpty ||
        oldIndex < 0 ||
        oldIndex >= filteredEntries.length) {
      return;
    }
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final movedEntry = filteredEntries[oldIndex];
    final filteredWithoutMoved = [...filteredEntries]..removeAt(oldIndex);
    final clampedIndex = adjustedNewIndex.clamp(0, filteredWithoutMoved.length);
    final reorderedFiltered = [...filteredWithoutMoved]
      ..insert(clampedIndex, movedEntry);

    final fullWithoutMoved = [..._entries]..removeWhere((entry) =>
        entry.summary.ref.id.value == movedEntry.summary.ref.id.value);
    final predecessor =
        clampedIndex > 0 ? reorderedFiltered[clampedIndex - 1] : null;
    final successor = clampedIndex < reorderedFiltered.length - 1
        ? reorderedFiltered[clampedIndex + 1]
        : null;

    int targetIndex;
    if (predecessor != null) {
      targetIndex = fullWithoutMoved.indexWhere((entry) =>
              entry.summary.ref.id.value == predecessor.summary.ref.id.value) +
          1;
    } else if (successor != null) {
      targetIndex = fullWithoutMoved.indexWhere((entry) =>
          entry.summary.ref.id.value == successor.summary.ref.id.value);
    } else {
      targetIndex = 0;
    }

    await _moveToPosition(movedEntry, targetIndex);
  }

  void _openItem(_ReadingQueueDialogEntry entry) {
    Navigator.of(context).pop();
    widget.onSelectItem?.call(entry.catalogItem.id);
  }

  List<_ReadingQueueDialogEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _entries
        .where((entry) => _matchesQuery(entry, query))
        .toList(growable: false);
  }

  bool _matchesQuery(_ReadingQueueDialogEntry entry, String query) {
    final fields = [
      entry.label,
      entry.trackingEntry?.statusStorageValue,
      entry.summary.notes,
      entry.summary.hasNotes ? 'notes' : null,
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
    return LibraryDialogScaffold(
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
      accent: Theme.of(context).colorScheme.primary,
      maxWidth: 620,
      maxHeight: 560,
      footer: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
      body: SizedBox(
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
                          hintText: 'Title, status, notes',
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
                                  final readStatus = entry
                                      .trackingEntry?.statusStorageValue
                                      ?.trim();
                                  if (readStatus != null &&
                                      readStatus.isNotEmpty) {
                                    details.add(readStatus);
                                  }
                                  if (entry.summary.hasNotes) {
                                    details.add('Has notes');
                                  }
                                  final queuePosition = _entries.indexWhere(
                                          (e) =>
                                              e.summary.ref.id.value ==
                                              entry.summary.ref.id.value) +
                                      1;
                                  return Material(
                                    key: ValueKey(entry.summary.ref.id.value),
                                    color: Colors.transparent,
                                    child: ListTile(
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: Icon(Icons.drag_indicator),
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Remove from queue',
                                            onPressed: () => _remove(entry),
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ReadingQueueDialogEntry {
  const _ReadingQueueDialogEntry({
    required this.summary,
    required this.catalogItem,
    this.trackingEntry,
  });

  final OwnedItemSummary summary;
  final CatalogItem catalogItem;
  final TrackingEntry? trackingEntry;

  String get label {
    final payload = catalogItem.payload;
    final rawNum =
        (payload['item_number'] ?? payload['itemNumber'])?.toString();
    final itemNumber = rawNum?.trim();
    if (itemNumber == null || itemNumber.isEmpty) {
      return catalogItem.title;
    }
    return '${catalogItem.title} #$itemNumber';
  }
}
