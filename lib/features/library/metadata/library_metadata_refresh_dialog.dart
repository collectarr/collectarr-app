import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxRefreshTargets = 100;

class LibraryMetadataRefreshResult {
  const LibraryMetadataRefreshResult({
    required this.targets,
    required this.matched,
    required this.cached,
    required this.failed,
  });

  final int targets;
  final int matched;
  final int cached;
  final int failed;
}

Future<LibraryMetadataRefreshResult?> showLibraryMetadataRefreshDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required Color accent,
  required List<LibraryWorkspaceEntry> allEntries,
  required List<LibraryWorkspaceEntry> shownEntries,
  required LibraryWorkspaceEntry? selectedEntry,
}) {
  return showDialog<LibraryMetadataRefreshResult>(
    context: context,
    builder: (context) => LibraryMetadataRefreshDialog(
      type: type,
      accent: accent,
      allEntries: allEntries,
      shownEntries: shownEntries,
      selectedEntry: selectedEntry,
    ),
  );
}

class LibraryMetadataRefreshDialog extends ConsumerStatefulWidget {
  const LibraryMetadataRefreshDialog({
    super.key,
    required this.type,
    required this.accent,
    required this.allEntries,
    required this.shownEntries,
    required this.selectedEntry,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibraryWorkspaceEntry> allEntries;
  final List<LibraryWorkspaceEntry> shownEntries;
  final LibraryWorkspaceEntry? selectedEntry;

  @override
  ConsumerState<LibraryMetadataRefreshDialog> createState() =>
      _LibraryMetadataRefreshDialogState();
}

class _LibraryMetadataRefreshDialogState
    extends ConsumerState<LibraryMetadataRefreshDialog> {
  late _RefreshScope _scope;
  var _rows = const <_RefreshRow>[];
  var _running = false;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _scope = widget.selectedEntry == null
        ? _RefreshScope.missing
        : _RefreshScope.selected;
    _rows = _initialRows();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final targets = _targetEntries();
    final visibleTargets = targets.take(_maxRefreshTargets).toList();
    final overLimit = targets.length > visibleTargets.length;
    final summary = _summary();
    return LibraryDialogScaffold(
      title: Row(
        children: [
          Icon(Icons.sync, color: widget.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Refresh ${widget.type.pluralLabel.toLowerCase()} metadata',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onClose: _running ? null : () => Navigator.of(context).pop(),
      maxWidth: 720,
      maxHeight: 820,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Collectarr Core for fresher metadata and cache the returned snapshots locally on this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 14),
              _RefreshSourcePanel(
                type: widget.type,
                accent: widget.accent,
              ),
              if (widget.type.supportedMetadataProviders.isEmpty) ...[
                const SizedBox(height: 8),
                _RefreshNotice(
                  icon: Icons.warning_amber_outlined,
                  text:
                      'No metadata provider is configured for this media type. Refresh may only find existing Core catalog records; manual add remains available.',
                ),
              ],
              const SizedBox(height: 12),
              SegmentedButton<_RefreshScope>(
                segments: [
                  ButtonSegment(
                    value: _RefreshScope.selected,
                    enabled: widget.selectedEntry != null,
                    icon: const Icon(Icons.ads_click, size: 16),
                    label: const Text('Selected'),
                  ),
                  ButtonSegment(
                    value: _RefreshScope.missing,
                    icon: const Icon(Icons.manage_search, size: 16),
                    label: const Text('Missing'),
                  ),
                  ButtonSegment(
                    value: _RefreshScope.shown,
                    icon: const Icon(Icons.filter_alt_outlined, size: 16),
                    label: const Text('Shown'),
                  ),
                  ButtonSegment(
                    value: _RefreshScope.all,
                    icon: const Icon(Icons.library_books_outlined, size: 16),
                    label: const Text('All'),
                  ),
                ],
                selected: {_scope},
                onSelectionChanged: _running
                    ? null
                    : (values) => setState(() {
                          _scope = values.single;
                          _finished = false;
                          _rows = _initialRows();
                        }),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RefreshStat(label: 'Targets', value: targets.length),
                  _RefreshStat(label: 'Limit', value: visibleTargets.length),
                  _RefreshStat(label: 'Matched', value: summary.matched),
                  _RefreshStat(label: 'Cached', value: summary.cached),
                  _RefreshStat(label: 'Failed', value: summary.failed),
                ],
              ),
              if (overLimit) ...[
                const SizedBox(height: 8),
                _RefreshNotice(
                  icon: Icons.speed,
                  text:
                      'This run will refresh the first $_maxRefreshTargets targets to keep manual refreshes predictable.',
                ),
              ],
              const SizedBox(height: 12),
              _RefreshTargetList(
                rows: _rows,
                targets: visibleTargets,
                accent: widget.accent,
              ),
            ],
          ),
        ),
      ),
      footer: LibraryActionFooter(
        child: Row(
          children: [
            TextButton(
              onPressed: _running ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed:
                  _running || visibleTargets.isEmpty ? null : () => _runRefresh(),
              icon: _running
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(_finished ? 'Run again' : 'Refresh'),
            ),
            if (_finished) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_summary().result),
                child: const Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_RefreshRow> _initialRows() {
    return [
      for (final entry in _targetEntries().take(_maxRefreshTargets))
        _RefreshRow.waiting(
          entry: entry,
          message: _describeSearch(entry),
        ),
    ];
  }

  Future<void> _runRefresh() async {
    final targets = _targetEntries().take(_maxRefreshTargets).toList();
    if (targets.isEmpty) {
      return;
    }
    setState(() {
      _running = true;
      _finished = false;
      _rows = [
        for (final entry in targets)
          _RefreshRow.waiting(entry: entry, message: _describeSearch(entry)),
      ];
    });

    final api = ref.read(apiClientProvider);
    final catalog = CatalogCacheRepository(ref.read(localDatabaseProvider));
    for (final entry in targets) {
      if (!mounted) {
        return;
      }
      _updateRow(
        entry.id,
        (row) => row.copyWith(
          status: _RefreshRowStatus.running,
          message: 'Searching Core...',
        ),
      );
      try {
        final results = await searchAndCacheLibraryMetadata(
          api: api,
          type: widget.type,
          catalog: catalog,
          input: _inputForEntry(entry),
        );
        _updateRow(
          entry.id,
          (row) => row.copyWith(
            status: results.isEmpty
                ? _RefreshRowStatus.missing
                : _RefreshRowStatus.matched,
            cached: results.length,
            message:
                results.isEmpty ? 'No Core match' : '${results.length} cached',
          ),
        );
      } catch (error) {
        _updateRow(
          entry.id,
          (row) => row.copyWith(
            status: _RefreshRowStatus.failed,
            message: _shortError(
              ConnectionDiagnostics.metadataError(error, api.baseUrl),
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _running = false;
        _finished = true;
      });
    }
  }

  void _updateRow(
      String entryId, _RefreshRow Function(_RefreshRow row) update) {
    setState(() {
      _rows = [
        for (final row in _rows) row.entry.id == entryId ? update(row) : row,
      ];
    });
  }

  List<LibraryWorkspaceEntry> _targetEntries() {
    final values = switch (_scope) {
      _RefreshScope.selected => [
          if (widget.selectedEntry != null) widget.selectedEntry!,
        ],
      _RefreshScope.missing => widget.allEntries
          .where((entry) => entry.hasMissingCover || entry.hasMissingMetadata)
          .toList(growable: false),
      _RefreshScope.shown => widget.shownEntries,
      _RefreshScope.all => widget.allEntries,
    };
    return _dedupe(values);
  }

  LibraryMetadataSearchInput _inputForEntry(LibraryWorkspaceEntry entry) {
    final barcode = entry.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      return LibraryMetadataSearchInput(
        query: entry.title,
        barcode: barcode,
        limit: 5,
      );
    }
    return LibraryMetadataSearchInput(
      query: entry.title,
      issueNumber: entry.itemNumber,
      publisher: entry.publisher,
      year: entry.releaseYear ?? entry.releaseDate?.year,
      limit: 5,
    );
  }

  String _describeSearch(LibraryWorkspaceEntry entry) {
    final barcode = entry.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      return 'Barcode $barcode';
    }
    final parts = [
      entry.title,
      if (entry.itemNumber != null && entry.itemNumber!.isNotEmpty)
        '#${entry.itemNumber}',
      if (entry.releaseYear != null) entry.releaseYear.toString(),
    ];
    return parts.join(' ');
  }

  _RefreshSummary _summary() => _RefreshSummary.fromRows(_rows);
}

enum _RefreshScope { selected, missing, shown, all }

enum _RefreshRowStatus { waiting, running, matched, missing, failed }

class _RefreshRow {
  const _RefreshRow({
    required this.entry,
    required this.status,
    required this.message,
    this.cached = 0,
  });

  factory _RefreshRow.waiting({
    required LibraryWorkspaceEntry entry,
    required String message,
  }) {
    return _RefreshRow(
      entry: entry,
      status: _RefreshRowStatus.waiting,
      message: message,
    );
  }

  final LibraryWorkspaceEntry entry;
  final _RefreshRowStatus status;
  final String message;
  final int cached;

  _RefreshRow copyWith({
    _RefreshRowStatus? status,
    String? message,
    int? cached,
  }) {
    return _RefreshRow(
      entry: entry,
      status: status ?? this.status,
      message: message ?? this.message,
      cached: cached ?? this.cached,
    );
  }
}

class _RefreshSummary {
  const _RefreshSummary({
    required this.targets,
    required this.matched,
    required this.cached,
    required this.failed,
  });

  factory _RefreshSummary.fromRows(List<_RefreshRow> rows) {
    return _RefreshSummary(
      targets: rows.length,
      matched:
          rows.where((row) => row.status == _RefreshRowStatus.matched).length,
      cached: rows.fold<int>(0, (total, row) => total + row.cached),
      failed:
          rows.where((row) => row.status == _RefreshRowStatus.failed).length,
    );
  }

  final int targets;
  final int matched;
  final int cached;
  final int failed;

  LibraryMetadataRefreshResult get result => LibraryMetadataRefreshResult(
        targets: targets,
        matched: matched,
        cached: cached,
        failed: failed,
      );
}

class _RefreshSourcePanel extends StatelessWidget {
  const _RefreshSourcePanel({
    required this.type,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.hub_outlined, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Source: Collectarr Core search',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _providerSummary(type),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshTargetList extends StatelessWidget {
  const _RefreshTargetList({
    required this.rows,
    required this.targets,
    required this.accent,
  });

  final List<_RefreshRow> rows;
  final List<LibraryWorkspaceEntry> targets;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final values = rows.isEmpty
        ? [
            for (final entry in targets)
              _RefreshRow.waiting(entry: entry, message: entry.title),
          ]
        : rows;
    if (values.isEmpty) {
      return const _RefreshNotice(
        icon: Icons.check_circle_outline,
        text: 'No items match this scope.',
      );
    }
    return Material(
      color: palette.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: palette.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: values.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final row = values[index];
            return ListTile(
              dense: true,
              leading: Icon(
                _statusIcon(row.status),
                color: _statusColor(context, row.status, accent),
              ),
              title: Text(
                row.entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                row.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing:
                  row.entry.hasMissingCover || row.entry.hasMissingMetadata
                      ? const Icon(Icons.priority_high, size: 16)
                      : null,
            );
          },
        ),
      ),
    );
  }
}

class _RefreshStat extends StatelessWidget {
  const _RefreshStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshNotice extends StatelessWidget {
  const _RefreshNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: kAppAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<LibraryWorkspaceEntry> _dedupe(Iterable<LibraryWorkspaceEntry> values) {
  final seen = <String>{};
  final result = <LibraryWorkspaceEntry>[];
  for (final value in values) {
    if (seen.add(value.id)) {
      result.add(value);
    }
  }
  return result;
}

String _providerSummary(LibraryTypeConfig type) {
  if (type.supportedMetadataProviders.isEmpty) {
    return 'No providers are registered for this media type yet; existing Core catalog rows can still be searched.';
  }
  final labels = type.supportedMetadataProviders
      .map((provider) => provider.label)
      .join(', ');
  return 'Core may use: $labels.';
}

String _shortError(Object error) {
  final text = error.toString();
  if (text.length <= 96) {
    return text;
  }
  return '${text.substring(0, 96)}...';
}

IconData _statusIcon(_RefreshRowStatus status) {
  return switch (status) {
    _RefreshRowStatus.waiting => Icons.radio_button_unchecked,
    _RefreshRowStatus.running => Icons.sync,
    _RefreshRowStatus.matched => Icons.check_circle,
    _RefreshRowStatus.missing => Icons.search_off,
    _RefreshRowStatus.failed => Icons.error_outline,
  };
}

Color _statusColor(BuildContext context, _RefreshRowStatus status, Color accent) {
  final palette = appPalette(context);
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    _RefreshRowStatus.waiting => palette.textMuted,
    _RefreshRowStatus.running => accent,
    _RefreshRowStatus.matched => Colors.green,
    _RefreshRowStatus.missing => colorScheme.secondary,
    _RefreshRowStatus.failed => colorScheme.error,
  };
}
