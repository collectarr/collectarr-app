import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LibraryBucketManagerEntry {
  const LibraryBucketManagerEntry({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}

bool libraryGroupModeSupportsBucketManagement(
  LibraryKindRuntime type,
  String mode,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.supportsBucketManagement ??
      false;
}

String libraryBucketManagerListLabel(
  String mode,
  LibraryKindRuntime type,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.resolvedBucketManagerListLabel ??
      genericGroupModeSidebarTitle(mode, type);
}

Future<void> showLibraryBucketManagerDialog({
  required BuildContext context,
  required LibraryKindRuntime type,
  required String groupMode,
  required Color accent,
  required List<LibraryBucketManagerEntry> entries,
  required Future<int> Function(String currentLabel, String nextLabel)
      onRenameBucket,
  required Future<int> Function(String currentLabel, String targetLabel)
      onMergeBucket,
  required Future<int> Function(String currentLabel) onDeleteBucket,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _LibraryBucketManagerDialog(
      type: type,
      groupMode: groupMode,
      accent: accent,
      entries: entries,
      onRenameBucket: onRenameBucket,
      onMergeBucket: onMergeBucket,
      onDeleteBucket: onDeleteBucket,
    ),
  );
}

class _LibraryBucketManagerDialog extends StatefulWidget {
  const _LibraryBucketManagerDialog({
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.entries,
    required this.onRenameBucket,
    required this.onMergeBucket,
    required this.onDeleteBucket,
  });

  final LibraryKindRuntime type;
  final String groupMode;
  final Color accent;
  final List<LibraryBucketManagerEntry> entries;
  final Future<int> Function(String currentLabel, String nextLabel)
      onRenameBucket;
  final Future<int> Function(String currentLabel, String targetLabel)
      onMergeBucket;
  final Future<int> Function(String currentLabel) onDeleteBucket;

  @override
  State<_LibraryBucketManagerDialog> createState() =>
      _LibraryBucketManagerDialogState();
}

class _LibraryBucketManagerDialogState
    extends State<_LibraryBucketManagerDialog> {
  final _searchController = TextEditingController();
  bool _submitting = false;
  List<LibraryBucketManagerEntry> _sortedEntries = [];

  @override
  void initState() {
    super.initState();
    _sortedEntries = List.from(widget.entries)
      ..sort((left, right) => left.label.toLowerCase().compareTo(
            right.label.toLowerCase(),
          ));
  }

  @override
  void didUpdateWidget(covariant _LibraryBucketManagerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.entries, oldWidget.entries)) {
      _sortedEntries = List.from(widget.entries)
        ..sort((left, right) => left.label.toLowerCase().compareTo(
              right.label.toLowerCase(),
            ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final filteredEntries = _filteredEntries();
    final title =
        'Manage ${genericGroupModeSidebarTitle(widget.groupMode, widget.type)}';
    final listLabel = libraryBucketManagerListLabel(
      widget.groupMode,
      widget.type,
    );
    return LibraryDialogScaffold(
      title: Text(title),
      onClose: _submitting ? null : () => Navigator.of(context).pop(),
      maxWidth: 760,
      maxHeight: 760,
      padding: EdgeInsets.zero,
      footer: LibraryActionFooter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.highlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: palette.divider),
                  ),
                  child: Text(
                    '${widget.entries.length} ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toUpperCase()}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.divider),
                    borderRadius: BorderRadius.zero,
                    color: palette.panelRaised,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        listLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              color: palette.panel,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Name',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      'Count',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} found.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textMuted,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        final rowColor = index.isEven
                            ? Colors.transparent
                            : palette.panel.withValues(alpha: 0.35);
                        return ColoredBox(
                          color: rowColor,
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Rename ${entry.label}',
                                onPressed: _submitting
                                    ? null
                                    : () => _renameEntry(entry),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                              ),
                              IconButton(
                                tooltip: 'Merge ${entry.label}',
                                onPressed:
                                    _submitting || widget.entries.length < 2
                                        ? null
                                        : () => _mergeEntry(entry),
                                icon: const Icon(Icons.merge_type_outlined,
                                    size: 18),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    entry.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  '${entry.count}',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete ${entry.label}',
                                onPressed: _submitting
                                    ? null
                                    : () => _deleteEntry(entry),
                                icon: const Icon(Icons.close, size: 18),
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
    );
  }

  List<LibraryBucketManagerEntry> _filteredEntries() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = [
      for (final entry in _sortedEntries)
        if (query.isEmpty || entry.label.toLowerCase().contains(query)) entry,
    ];
    return filtered;
  }

  Future<void> _renameEntry(LibraryBucketManagerEntry entry) async {
    final controller = TextEditingController(text: entry.label);
    final nextLabel = await showDialog<String>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text(
            'Rename ${genericGroupModeLabel(widget.groupMode, widget.type)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New label',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          DialogActionButtons.cancel(
            onPressed: () => Navigator.of(context).pop(),
          ),
          DialogActionButtons.save(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || nextLabel == null || nextLabel.trim().isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onRenameBucket(entry.label, nextLabel.trim());
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Renamed ${entry.label} across $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  Future<void> _deleteEntry(LibraryBucketManagerEntry entry) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            title: Text('Delete ${entry.label}?'),
            content: Text(
              'Remove this ${genericGroupModeLabel(widget.groupMode, widget.type).toLowerCase()} value from all items currently bucketed under it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onDeleteBucket(entry.label);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Deleted ${entry.label} from $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  Future<void> _mergeEntry(LibraryBucketManagerEntry entry) async {
    final candidates = [
      for (final candidate in widget.entries)
        if (candidate.label != entry.label) candidate,
    ]..sort(
        (left, right) => left.label.toLowerCase().compareTo(
              right.label.toLowerCase(),
            ),
      );
    if (candidates.isEmpty) {
      return;
    }
    var targetLabel = candidates.first.label;
    final confirmedTarget = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AccentAlertDialog(
          title: Text('Merge ${entry.label} into...'),
          content: DropdownButtonFormField<String>(
            initialValue: targetLabel,
            decoration: const InputDecoration(
              labelText: 'Target bucket',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final candidate in candidates)
                DropdownMenuItem<String>(
                  value: candidate.label,
                  child: Text(candidate.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => targetLabel = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(targetLabel),
              child: const Text('Merge'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmedTarget == null || confirmedTarget == entry.label) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onMergeBucket(entry.label, confirmedTarget);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Merged ${entry.label} into $confirmedTarget across $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }
}
