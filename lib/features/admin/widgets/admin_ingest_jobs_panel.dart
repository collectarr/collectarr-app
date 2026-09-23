import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';

final class AdminIngestJobsPanel extends StatelessWidget {
  const AdminIngestJobsPanel({
    required this.jobs,
    required this.summary,
    required this.autoRefresh,
    required this.isPolling,
    required this.refreshedAt,
    required this.statusFilter,
    required this.providerFilter,
    required this.selectedProvider,
    required this.providers,
    required this.isLoadingProviders,
    required this.providerItemIdController,
    required this.queryController,
    required this.isRunningJobs,
    required this.actionJobId,
    required this.onProviderChanged,
    required this.onAutoRefreshChanged,
    required this.onStatusFilterChanged,
    required this.onProviderFilterChanged,
    required this.onApplyFilters,
    required this.onRefresh,
    required this.onQueueCurrent,
    required this.onRunPending,
    required this.onRun,
    required this.onRetry,
    required this.onShowDetails,
    super.key,
  });

  final List<AdminProviderIngestJob> jobs;
  final AdminProviderIngestJobSummary? summary;
  final bool autoRefresh;
  final bool isPolling;
  final DateTime? refreshedAt;
  final String? statusFilter;
  final String? providerFilter;
  final String selectedProvider;
  final List<AdminProviderStatus> providers;
  final bool isLoadingProviders;
  final TextEditingController providerItemIdController;
  final TextEditingController queryController;
  final bool isRunningJobs;
  final String? actionJobId;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<bool> onAutoRefreshChanged;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String?> onProviderFilterChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onRefresh;
  final VoidCallback onQueueCurrent;
  final VoidCallback onRunPending;
  final ValueChanged<AdminProviderIngestJob> onRun;
  final ValueChanged<AdminProviderIngestJob> onRetry;
  final ValueChanged<AdminProviderIngestJob> onShowDetails;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(label: '${summary!.queued} queued'),
              _StatusChip(label: '${summary!.running} running'),
              _StatusChip(label: '${summary!.failed} failed'),
              _StatusChip(label: '${summary!.done} done'),
              if (summary!.dueQueued > 0)
                _StatusChip(label: '${summary!.dueQueued} due'),
              if (summary!.staleRunning > 0)
                _StatusChip(label: '${summary!.staleRunning} stale'),
            ],
          ),
          const SizedBox(height: 12),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: autoRefresh,
                      onChanged: onAutoRefreshChanged,
                    ),
                    const SizedBox(width: 6),
                    const Text('Auto refresh'),
                  ],
                ),
                _StatusChip(label: autoRefresh ? 'active jobs' : 'manual'),
                if (isPolling)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Refreshing jobs'),
                    ],
                  ),
                if (refreshedAt != null)
                  _StatusChip(label: 'Last refreshed ${_date(refreshedAt!)}'),
                OutlinedButton.icon(
                  onPressed: isPolling ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh jobs'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: CompactSearchDropdownFormField<String>(
                initialValue: statusFilter ?? '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status filter',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All jobs')),
                  DropdownMenuItem(value: 'queued', child: Text('Queued')),
                  DropdownMenuItem(value: 'running', child: Text('Running')),
                  DropdownMenuItem(value: 'failed', child: Text('Failed')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: onStatusFilterChanged,
              ),
            ),
            SizedBox(
              width: 190,
              child: CompactSearchDropdownFormField<String>(
                initialValue: providerFilter ?? '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Provider filter',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All providers'),
                  ),
                  for (final entry in providers)
                    DropdownMenuItem(
                      value: entry.name,
                      child: Text(entry.displayName,
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: onProviderFilterChanged,
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: queryController,
                decoration: const InputDecoration(
                  labelText: 'Job search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onApplyFilters(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onApplyFilters,
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Apply filters'),
            ),
            SizedBox(
              width: 220,
              child: _ProviderPicker(
                selectedProvider: selectedProvider,
                providers: providers,
                isLoading: isLoadingProviders,
                onChanged: onProviderChanged,
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: providerItemIdController,
                decoration: const InputDecoration(
                  labelText: 'Job provider item ID',
                  prefixIcon: Icon(Icons.tag_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: actionJobId == 'new' ? null : onQueueCurrent,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Queue current ID'),
            ),
            FilledButton.tonalIcon(
              onPressed: isRunningJobs ? null : onRunPending,
              icon: const Icon(Icons.playlist_play_outlined),
              label: const Text('Run queued'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (jobs.isEmpty)
          const Text('No persistent ingest jobs for this filter.')
        else
          for (final job in jobs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        job.isFailed
                            ? Icons.error_outline
                            : job.isDone
                                ? Icons.check_circle_outline
                                : job.isRunning
                                    ? Icons.sync_outlined
                                    : Icons.pending_actions_outlined,
                        color: job.isFailed ? colors.error : colors.primary,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(job.displayTitle,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      _StatusChip(label: job.status),
                      _StatusChip(
                          label: '${job.attempts}/${job.maxAttempts} attempts'),
                      if (job.nextRunAt != null)
                        _StatusChip(label: 'next ${_date(job.nextRunAt!)}'),
                      if (job.itemId != null)
                        _StatusChip(label: 'item ${_shortId(job.itemId!)}'),
                      if (job.lastError != null && job.lastError!.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            job.lastError!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => onShowDetails(job),
                        icon: const Icon(Icons.timeline_outlined),
                        label: const Text('Details'),
                      ),
                      if (job.isQueued)
                        OutlinedButton.icon(
                          onPressed:
                              actionJobId == job.id ? null : () => onRun(job),
                          icon: actionJobId == job.id
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_outlined),
                          label: const Text('Run'),
                        ),
                      if (job.isFailed)
                        OutlinedButton.icon(
                          onPressed:
                              actionJobId == job.id ? null : () => onRetry(job),
                          icon: actionJobId == job.id
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.replay_outlined),
                          label: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

final class _ProviderPicker extends StatelessWidget {
  const _ProviderPicker({
    required this.selectedProvider,
    required this.providers,
    required this.isLoading,
    required this.onChanged,
  });

  final String selectedProvider;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = providers.any((p) => p.name == selectedProvider)
        ? selectedProvider
        : null;
    if (providers.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Provider',
          hintText: isLoading ? 'Loading providers...' : 'No providers',
          border: const OutlineInputBorder(),
        ),
      );
    }
    return CompactSearchDropdownFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Provider',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final provider in providers)
          DropdownMenuItem(
            value: provider.name,
            child: Text(provider.displayName, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

String _date(DateTime value) => value.toLocal().toString().substring(0, 16);

String _shortId(String value) =>
    value.length <= 12 ? value : '${value.substring(0, 8)}...';
