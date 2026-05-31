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
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: kAppPanel,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: _SeriesDialogHeader(
        title: 'Select Series',
        subtitle: 'Choose the series entry this comic should use.',
        icon: Icons.collections_bookmark_outlined,
        accent: Theme.of(context).colorScheme.primary,
        badgeLabel: '${_entries.length} series',
      ),
      content: SizedBox(
        width: 720,
        height: 500,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.panelRaised,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search by series name or sort name',
                                isDense: true,
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (_) => _load(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _createSeries,
                            icon: const Icon(Icons.add),
                            label: const Text('New Series'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _openManager,
                            icon: const Icon(Icons.tune),
                            label: const Text('Manage Series'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _SeriesTableFrame(
                      child: _entries.isEmpty
                          ? const _SeriesEmptyState(
                              title: 'No series found',
                              subtitle:
                                  'Create a series entry or widen the search to keep your comic catalog tidy.',
                            )
                          : Column(
                              children: [
                                const _SeriesTableHeader(showActions: false),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _entries.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: palette.divider,
                                    ),
                                    itemBuilder: (context, index) {
                                      final entry = _entries[index];
                                      final selected = _selectedEntryId == entry.id;
                                      return _SeriesPickerRow(
                                        entry: entry,
                                        selected: selected,
                                        onTap: () {
                                          setState(() {
                                            _selectedEntryId = entry.id;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
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
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: kAppPanel,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: _SeriesDialogHeader(
        title: 'Manage Series',
        subtitle: 'Rename, merge, and normalize the local series registry.',
        icon: Icons.library_books_outlined,
        accent: Theme.of(context).colorScheme.primary,
        badgeLabel: '${_entries.length} entries',
      ),
      content: SizedBox(
        width: 760,
        height: 500,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.panelRaised,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by series name or sort name',
                          isDense: true,
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => _load(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _SeriesTableFrame(
                      child: _entries.isEmpty
                          ? const _SeriesEmptyState(
                              title: 'Registry is empty',
                              subtitle:
                                  'Series captured from catalog items and manual edits will appear here.',
                            )
                          : Column(
                              children: [
                                const _SeriesTableHeader(showActions: true),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _entries.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: palette.divider,
                                    ),
                                    itemBuilder: (context, index) {
                                      final entry = _entries[index];
                                      return _SeriesManagerRow(
                                        entry: entry,
                                        canMerge: _entries.length >= 2,
                                        onEdit: () => _editEntry(entry),
                                        onMerge: () => _mergeEntry(entry),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
  return showDialog<({String title, String? sortTitle})>(
    context: context,
    builder: (context) => _SeriesEditDialog(
      initialTitle: initialTitle,
      initialSortTitle: initialSortTitle,
    ),
  );
}

class _SeriesEditDialog extends StatefulWidget {
  const _SeriesEditDialog({
    this.initialTitle,
    this.initialSortTitle,
  });

  final String? initialTitle;
  final String? initialSortTitle;

  @override
  State<_SeriesEditDialog> createState() => _SeriesEditDialogState();
}

class _SeriesEditDialogState extends State<_SeriesEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _sortTitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _sortTitleController = TextEditingController(
      text: widget.initialSortTitle ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sortTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: kAppPanel,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: _SeriesDialogHeader(
        title: widget.initialTitle == null ? 'New Series' : 'Edit Series',
        subtitle: widget.initialTitle == null
            ? 'Create a reusable series entry for manual edits and catalog merges.'
            : 'Update the display name and optional sort name used across the registry.',
        icon: widget.initialTitle == null
            ? Icons.add_circle_outline
            : Icons.edit_outlined,
        accent: Theme.of(context).colorScheme.primary,
      ),
      content: SizedBox(
        width: 420,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sortTitleController,
                  decoration: const InputDecoration(labelText: 'Sort Name'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              (
                title: title,
                sortTitle: _sortTitleController.text.trim().isEmpty
                    ? null
                    : _sortTitleController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SeriesDialogHeader extends StatelessWidget {
  const _SeriesDialogHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.badgeLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: accent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeLabel != null)
              _SeriesCountChip(
                label: badgeLabel!,
                emphasized: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _SeriesTableFrame extends StatelessWidget {
  const _SeriesTableFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _SeriesTableHeader extends StatelessWidget {
  const _SeriesTableHeader({required this.showActions});

  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            const SizedBox(width: 28),
            const Expanded(flex: 4, child: _SeriesHeaderLabel('Name')),
            const Expanded(flex: 4, child: _SeriesHeaderLabel('Sort Name')),
            const SizedBox(width: 80, child: _SeriesHeaderLabel('Count')),
            if (showActions)
              const SizedBox(width: 96, child: _SeriesHeaderLabel('Actions')),
          ],
        ),
      ),
    );
  }
}

class _SeriesHeaderLabel extends StatelessWidget {
  const _SeriesHeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Text(
      label,
      style: TextStyle(
        color: palette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _SeriesPickerRow extends StatelessWidget {
  const _SeriesPickerRow({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final SeriesRegistryEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedColor = Theme.of(context).colorScheme.primary;
    return Material(
      color: selected ? selectedColor.withValues(alpha: 0.10) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? selectedColor : palette.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _SeriesRowText(
                  text: entry.title,
                  emphasized: true,
                ),
              ),
              Expanded(
                flex: 4,
                child: _SeriesRowText(
                  text: entry.sortTitle ?? entry.title,
                  muted: entry.sortTitle == null || entry.sortTitle == entry.title,
                ),
              ),
              SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SeriesCountChip(label: entry.itemCount.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeriesManagerRow extends StatelessWidget {
  const _SeriesManagerRow({
    required this.entry,
    required this.canMerge,
    required this.onEdit,
    required this.onMerge,
  });

  final SeriesRegistryEntry entry;
  final bool canMerge;
  final VoidCallback onEdit;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const SizedBox(width: 28, child: Icon(Icons.drag_indicator, size: 18)),
          Expanded(
            flex: 4,
            child: _SeriesRowText(
              text: entry.title,
              emphasized: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: _SeriesRowText(
              text: entry.sortTitle ?? entry.title,
              muted: entry.sortTitle == null || entry.sortTitle == entry.title,
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SeriesCountChip(label: entry.itemCount.toString()),
            ),
          ),
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Edit series',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Merge series',
                  onPressed: canMerge ? onMerge : null,
                  icon: const Icon(Icons.merge_type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesRowText extends StatelessWidget {
  const _SeriesRowText({
    required this.text,
    this.emphasized = false,
    this.muted = false,
  });

  final String text;
  final bool emphasized;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: muted ? palette.textMuted : palette.textPrimary,
        fontSize: 13,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

class _SeriesCountChip extends StatelessWidget {
  const _SeriesCountChip({
    required this.label,
    this.emphasized = false,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final color = emphasized
        ? Theme.of(context).colorScheme.primary
        : palette.textMuted;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: emphasized ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SeriesEmptyState extends StatelessWidget {
  const _SeriesEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 28,
              color: palette.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}