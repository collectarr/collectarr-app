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
                  const _ProviderImportCapabilityChip(label: 'JSON / CSV import'),
              ],
            ),
          ],
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
