import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<SeriesRegistryEntry?> showSeriesPickerDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String mediaKind,
  String? selectedTitle,
  String? selectedSeriesId,
}) {
  return showDialog<SeriesRegistryEntry>(
    context: context,
    builder: (_) => _SeriesPickerDialog(
      db: db,
      mediaKind: mediaKind,
      selectedTitle: selectedTitle,
      selectedSeriesId: selectedSeriesId,
    ),
  );
}

Future<void> showSeriesManagerDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String mediaKind,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SeriesManagerDialog(
      db: db,
      mediaKind: mediaKind,
    ),
  );
}

class _SeriesPickerDialog extends StatefulWidget {
  const _SeriesPickerDialog({
    required this.db,
    required this.mediaKind,
    this.selectedTitle,
    this.selectedSeriesId,
  });

  final LocalDatabase db;
  final String mediaKind;
  final String? selectedTitle;
  final String? selectedSeriesId;

  @override
  State<_SeriesPickerDialog> createState() => _SeriesPickerDialogState();
}

class _SeriesPickerDialogState extends State<_SeriesPickerDialog> {
  late final SeriesRegistryRepository _repo;
  final _searchController = TextEditingController();

  List<SeriesRegistryEntry> _entries = const [];
  bool _loading = true;
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    _repo = SeriesRegistryRepository(widget.db);
    _selectedEntryId = widget.selectedSeriesId;
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _repo.searchEntries(
      mediaKind: widget.mediaKind,
      query: _searchController.text,
      selectedTitle: widget.selectedTitle,
      selectedSeriesId: widget.selectedSeriesId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _loading = false;
      _selectedEntryId ??= entries.isEmpty ? null : entries.first.id;
    });
  }

  Future<void> _createSeries() async {
    final result = await _showSeriesEditDialog(
      context,
      initialTitle: _searchController.text,
    );
    if (result == null) {
      return;
    }
    final entry = await _repo.upsertManualEntry(
      mediaKind: widget.mediaKind,
      title: result.title,
      sortTitle: result.sortTitle,
    );
    if (!mounted) {
      return;
    }
    _selectedEntryId = entry.id;
    await _load();
  }

  Future<void> _openManager() async {
    await showSeriesManagerDialog(
      context: context,
      db: widget.db,
      mediaKind: widget.mediaKind,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPanel,
      title: const Text('Select Series'),
      content: SizedBox(
        width: 720,
        height: 440,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            isDense: true,
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (_) => _load(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _createSeries,
                        child: const Text('New Series'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _openManager,
                        child: const Text('Manage Series'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: appPalette(context).divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: appPalette(context).divider,
                        ),
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          final selected = _selectedEntryId == entry.id;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedEntryId = entry.id;
                              });
                            },
                            title: Text(entry.title),
                            subtitle: entry.sortTitle != null &&
                                    entry.sortTitle != entry.title
                                ? Text(entry.sortTitle!)
                                : null,
                            trailing: Text(entry.itemCount.toString()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final selected = _entries.cast<SeriesRegistryEntry?>().firstWhere(
                  (entry) => entry?.id == _selectedEntryId,
                  orElse: () => null,
                );
            Navigator.of(context).pop(selected);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class _SeriesManagerDialog extends StatefulWidget {
  const _SeriesManagerDialog({
    required this.db,
    required this.mediaKind,
  });

  final LocalDatabase db;
  final String mediaKind;

  @override
  State<_SeriesManagerDialog> createState() => _SeriesManagerDialogState();
}

class _SeriesManagerDialogState extends State<_SeriesManagerDialog> {
  late final SeriesRegistryRepository _repo;
  final _searchController = TextEditingController();
  List<SeriesRegistryEntry> _entries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = SeriesRegistryRepository(widget.db);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _repo.searchEntries(
      mediaKind: widget.mediaKind,
      query: _searchController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _editEntry(SeriesRegistryEntry entry) async {
    final result = await _showSeriesEditDialog(
      context,
      initialTitle: entry.title,
      initialSortTitle: entry.sortTitle,
    );
    if (result == null) {
      return;
    }
    await _repo.renameEntry(
      entryId: entry.id,
      title: result.title,
      sortTitle: result.sortTitle,
    );
    await _load();
  }

  Future<void> _mergeEntry(SeriesRegistryEntry source) async {
    final targetId = await showDialog<String>(
      context: context,
      builder: (context) {
        String? selectedId;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kAppPanel,
              title: Text('Merge ${source.title} Into'),
              content: DropdownButtonFormField<String>(
                initialValue: null,
                decoration: const InputDecoration(labelText: 'Target series'),
                items: [
                  for (final entry in _entries.where((entry) => entry.id != source.id))
                    DropdownMenuItem<String>(
                      value: entry.id,
                      child: Text(entry.title),
                    ),
                ],
                onChanged: (value) => setState(() => selectedId = value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedId == null
                      ? null
                      : () => Navigator.of(context).pop(selectedId),
                  child: const Text('Merge'),
                ),
              ],
            );
          },
        );
      },
    );
    if (targetId == null) {
      return;
    }
    await _repo.mergeEntries(
      targetEntryId: targetId,
      sourceEntryIds: [source.id],
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPanel,
      title: const Text('Manage Series'),
      content: SizedBox(
        width: 760,
        height: 440,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => _load(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: appPalette(context).divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: appPalette(context).divider,
                        ),
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return ListTile(
                            dense: true,
                            title: Text(entry.title),
                            subtitle: entry.sortTitle != null &&
                                    entry.sortTitle != entry.title
                                ? Text(entry.sortTitle!)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(entry.itemCount.toString()),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Edit series',
                                  onPressed: () => _editEntry(entry),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Merge series',
                                  onPressed: _entries.length < 2
                                      ? null
                                      : () => _mergeEntry(entry),
                                  icon: const Icon(Icons.merge_type),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

Future<({String title, String? sortTitle})?> _showSeriesEditDialog(
  BuildContext context, {
  String? initialTitle,
  String? initialSortTitle,
}) {
  final titleController = TextEditingController(text: initialTitle ?? '');
  final sortTitleController = TextEditingController(text: initialSortTitle ?? '');
  return showDialog<({String title, String? sortTitle})>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: kAppPanel,
        title: Text(initialTitle == null ? 'New Series' : 'Edit Series'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sortTitleController,
                decoration: const InputDecoration(labelText: 'Sort Name'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                return;
              }
              Navigator.of(context).pop(
                (
                  title: title,
                  sortTitle: sortTitleController.text.trim().isEmpty
                      ? null
                      : sortTitleController.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  ).whenComplete(() {
    titleController.dispose();
    sortTitleController.dispose();
  });
}