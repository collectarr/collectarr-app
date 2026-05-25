import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/provider_import_history_store.dart';
import 'package:collectarr_app/features/settings/tmdb_import_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _providerImportHistoryProvider = FutureProvider.autoDispose
    .family<List<ProviderImportHistoryEntry>, ProviderImportId>((ref, provider) async {
  return const ProviderImportHistoryStore().read(provider: provider, limit: 8);
});

final _tmdbPendingImportsProvider =
    FutureProvider.autoDispose<List<TmdbPendingImportRecord>>((ref) async {
  return const TmdbPendingImportStore().read(limit: 6);
});

class ProviderImportsDialog extends ConsumerStatefulWidget {
  const ProviderImportsDialog({
    super.key,
    required this.initialTmdbSettings,
  });

  final TmdbImportSettings initialTmdbSettings;

  @override
  ConsumerState<ProviderImportsDialog> createState() =>
      _ProviderImportsDialogState();
}

class _ProviderImportsDialogState
    extends ConsumerState<ProviderImportsDialog> {
  ProviderImportId _selectedProvider = ProviderImportId.tmdb;

  void _refreshShellData() {
    ref.invalidate(_providerImportHistoryProvider(_selectedProvider));
    if (_selectedProvider == ProviderImportId.tmdb) {
      ref.invalidate(_tmdbPendingImportsProvider);
    }
  }

  Future<void> _clearSelectedHistory() async {
    await const ProviderImportHistoryStore().clear(provider: _selectedProvider);
    _refreshShellData();
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = providerImportDescriptors.firstWhere(
      (candidate) => candidate.id == _selectedProvider,
    );
    final history = ref.watch(_providerImportHistoryProvider(_selectedProvider));
    final tmdbPendingImports = _selectedProvider == ProviderImportId.tmdb
        ? ref.watch(_tmdbPendingImportsProvider)
        : const AsyncValue<List<TmdbPendingImportRecord>>.data(
            <TmdbPendingImportRecord>[],
          );
    final viewSize = MediaQuery.sizeOf(context);
    final dialogWidth =
        (viewSize.width - 48).clamp(360.0, 1180.0).toDouble();
    final dialogHeight =
        (viewSize.height - 72).clamp(440.0, 720.0).toDouble();
    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      title: const Text('Provider imports'),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<ProviderImportId>(
                showSelectedIcon: false,
                multiSelectionEnabled: false,
                selected: {_selectedProvider},
                segments: [
                  for (final descriptor in providerImportDescriptors)
                    ButtonSegment<ProviderImportId>(
                      value: descriptor.id,
                      icon: const Icon(Icons.movie_outlined, size: 18),
                      label: Text(descriptor.title),
                    ),
                ],
                onSelectionChanged: (selection) {
                  final provider = selection.firstOrNull;
                  if (provider == null || provider == _selectedProvider) {
                    return;
                  }
                  setState(() {
                    _selectedProvider = provider;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sidebar = _ProviderImportSidebar(
                    descriptor: descriptor,
                    history: history.value ?? const <ProviderImportHistoryEntry>[],
                    historyLoading: history.isLoading,
                    pendingImports: tmdbPendingImports.value ??
                        const <TmdbPendingImportRecord>[],
                    pendingLoading: tmdbPendingImports.isLoading,
                    onClearHistory: _clearSelectedHistory,
                    onRefresh: _refreshShellData,
                  );
                  final workspace = DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: switch (_selectedProvider) {
                        ProviderImportId.tmdb => TmdbImportWorkspace(
                            initialSettings: widget.initialTmdbSettings,
                            onImportRecorded: _refreshShellData,
                            onStateChanged: _refreshShellData,
                          ),
                      },
                    ),
                  );
                  if (constraints.maxWidth >= 980) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: workspace),
                        const SizedBox(width: 12),
                        SizedBox(width: 320, child: sidebar),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 280, child: sidebar),
                      const SizedBox(height: 12),
                      Expanded(child: workspace),
                    ],
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

class _ProviderImportSidebar extends StatelessWidget {
  const _ProviderImportSidebar({
    required this.descriptor,
    required this.history,
    required this.historyLoading,
    required this.pendingImports,
    required this.pendingLoading,
    required this.onClearHistory,
    required this.onRefresh,
  });

  final ProviderImportDescriptor descriptor;
  final List<ProviderImportHistoryEntry> history;
  final bool historyLoading;
  final List<TmdbPendingImportRecord> pendingImports;
  final bool pendingLoading;
  final VoidCallback onClearHistory;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${descriptor.title} overview',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh provider import activity',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            Text(
              descriptor.summary,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (descriptor.supportsAccountSync)
                  const _ProviderImportCapabilityChip(label: 'Account sync'),
                if (descriptor.supportsFileImport)
                  const _ProviderImportCapabilityChip(label: 'File import'),
                _ProviderImportCapabilityChip(
                  label: history.isEmpty && !historyLoading
                      ? 'No recent activity'
                      : '${history.length} recent imports',
                ),
                if (descriptor.id == ProviderImportId.tmdb)
                  _ProviderImportCapabilityChip(
                    label: pendingImports.isEmpty && !pendingLoading
                        ? 'No pending local rows'
                        : '${pendingImports.length} pending rows',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ProviderImportSectionCard(
                    title: 'Recent activity',
                    trailing: history.isEmpty
                        ? null
                        : TextButton(
                            onPressed: onClearHistory,
                            child: const Text('Clear'),
                          ),
                    child: historyLoading
                        ? const _ProviderImportLoadingState()
                        : history.isEmpty
                            ? const _ProviderImportEmptyState(
                                title: 'No imports recorded yet.',
                                message:
                                    'Run a preview and import from the workspace to populate recent TMDB activity here.',
                              )
                            : Column(
                                children: [
                                  for (final entry in history)
                                    _ProviderImportHistoryTile(entry: entry),
                                ],
                              ),
                  ),
                  if (descriptor.id == ProviderImportId.tmdb) ...[
                    const SizedBox(height: 12),
                    _ProviderImportSectionCard(
                      title: 'Pending reconciliation',
                      child: pendingLoading
                          ? const _ProviderImportLoadingState()
                          : pendingImports.isEmpty
                              ? const _ProviderImportEmptyState(
                                  title: 'No pending local TMDB items.',
                                  message:
                                      'Unmatched TMDB rows kept locally will show up here until they reconcile to real Core items.',
                                )
                              : Column(
                                  children: [
                                    for (final record in pendingImports)
                                      _TmdbPendingImportTile(record: record),
                                  ],
                                ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderImportSectionCard extends StatelessWidget {
  const _ProviderImportSectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProviderImportHistoryTile extends StatelessWidget {
  const _ProviderImportHistoryTile({required this.entry});

  final ProviderImportHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = entry.status == ProviderImportHistoryStatus.failed
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.tertiaryContainer;
    final onTone = entry.status == ProviderImportHistoryStatus.failed
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onTertiaryContainer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.collectionLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        entry.status == ProviderImportHistoryStatus.failed
                            ? 'Failed'
                            : 'Success',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: onTone,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.sourceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                entry.message,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ProviderImportCapabilityChip(label: 'Rows ${entry.rows}'),
                  _ProviderImportCapabilityChip(
                    label: 'Matched ${entry.matched}',
                  ),
                  if (entry.unmatched > 0)
                    _ProviderImportCapabilityChip(
                      label: 'Unmatched ${entry.unmatched}',
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatImportTimestamp(entry.createdAt),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TmdbPendingImportTile extends StatelessWidget {
  const _TmdbPendingImportTile({required this.record});

  final TmdbPendingImportRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                record.entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                record.entry.collection.label,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Queued ${_formatImportTimestamp(record.createdAt)}',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderImportCapabilityChip extends StatelessWidget {
  const _ProviderImportCapabilityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label),
    );
  }
}

class _ProviderImportLoadingState extends StatelessWidget {
  const _ProviderImportLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ProviderImportEmptyState extends StatelessWidget {
  const _ProviderImportEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(message, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

String _formatImportTimestamp(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}
