part of 'admin_page.dart';

// Provider/catalog/ingest widgets

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.value,
    required this.providers,
    required this.isLoading,
    required this.onChanged,
  });

  final String value;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected =
        providers.any((provider) => provider.name == value) ? value : null;
    if (providers.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Provider',
          prefixIcon: const Icon(Icons.extension_outlined),
          border: const OutlineInputBorder(),
          hintText:
              isLoading ? 'Loading providers...' : 'No searchable providers',
        ),
      );
    }
    return DropdownButtonFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: _kAdminDropdownColor,
      borderRadius: kAppMenuBorderRadius,
      hint: Text(isLoading ? 'Loading providers...' : 'Select provider'),
      decoration: const InputDecoration(
        labelText: 'Provider',
        prefixIcon: Icon(Icons.extension_outlined),
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

class _ProviderKindSelector extends StatelessWidget {
  const _ProviderKindSelector({
    required this.value,
    required this.kinds,
    required this.kindLabels,
    required this.isLoading,
    required this.onChanged,
  });

  final String? value;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kinds.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Media kind',
          prefixIcon: const Icon(Icons.category_outlined),
          border: const OutlineInputBorder(),
          hintText: isLoading ? 'Loading kinds...' : 'No provider kinds',
        ),
      );
    }
    final selected = value != null && kinds.contains(value) ? value! : '';
    return DropdownButtonFormField<String>(
      key: ValueKey('provider-kind-$selected'),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: _kAdminDropdownColor,
      borderRadius: kAppMenuBorderRadius,
      decoration: const InputDecoration(
        labelText: 'Media kind',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('All media', overflow: TextOverflow.ellipsis),
        ),
        for (final kind in kinds)
          DropdownMenuItem(
            value: kind,
            child: Text(_providerKindLabel(kind, kindLabels),
                overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CatalogItemList extends StatelessWidget {
  const _CatalogItemList({
    required this.items,
    required this.hasSearched,
    required this.inspectingItemId,
    required this.updatingItemId,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
  });

  final List<AdminMetadataItem> items;
  final bool hasSearched;
  final String? inspectingItemId;
  final String? updatingItemId;
  final ValueChanged<AdminMetadataItem> onInspect;
  final ValueChanged<AdminMetadataItem> onEdit;
  final ValueChanged<AdminMetadataItem> onInspectCovers;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _MessageRow(
        message: hasSearched
            ? 'No catalog items matched the current search.'
            : 'Search by title or choose a category to load catalog results.',
        isError: false,
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return _CatalogItemTile(
          item: item,
          isInspecting: inspectingItemId == item.id,
          isUpdating: updatingItemId == item.id,
          onInspect: () => onInspect(item),
          onEdit: () => onEdit(item),
          onInspectCovers: () => onInspectCovers(item),
        );
      },
    );
  }
}

class _CatalogItemTile extends StatelessWidget {
  const _CatalogItemTile({
    required this.item,
    required this.isInspecting,
    required this.isUpdating,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
  });

  final AdminMetadataItem item;
  final bool isInspecting;
  final bool isUpdating;
  final VoidCallback onInspect;
  final VoidCallback onEdit;
  final VoidCallback onInspectCovers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cover = SizedBox(
              width: 58,
              height: 82,
              child: LibraryCoverImage(
                title: item.title,
                itemNumber: item.itemNumber,
                imageUrl: item.displayCoverUrl,
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: item.kind),
                    if (item.publisher != null)
                      _MiniChip(label: item.publisher!),
                    if (item.barcode != null) _MiniChip(label: item.barcode!),
                    if (item.displayCoverUrl == null)
                      const _MiniChip(label: 'missing cover'),
                  ],
                ),
              ],
            );
            final buttons = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isInspecting || isUpdating ? null : onInspect,
                  icon: isInspecting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                  label: const Text('Inspect'),
                ),
                OutlinedButton.icon(
                  onPressed: isUpdating ? null : onInspectCovers,
                  icon: const Icon(Icons.image_search_outlined),
                  label: const Text('Covers'),
                ),
                FilledButton.tonalIcon(
                  onPressed: isUpdating ? null : onEdit,
                  icon: isUpdating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            );
            if (constraints.maxWidth < 680) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 12),
                      Expanded(child: details),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buttons,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cover,
                const SizedBox(width: 12),
                Expanded(child: details),
                const SizedBox(width: 12),
                buttons,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProviderIngestJobPanel extends StatelessWidget {
  const _ProviderIngestJobPanel({
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

  @override
  Widget build(BuildContext context) {
    final filterValue = statusFilter ?? '';
    final providerFilterValue = providerFilter ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null) ...[
          _ProviderIngestJobSummaryBar(summary: summary!),
          const SizedBox(height: 12),
        ],
        _ProviderIngestJobRefreshStrip(
          autoRefresh: autoRefresh,
          isPolling: isPolling,
          refreshedAt: refreshedAt,
          onAutoRefreshChanged: onAutoRefreshChanged,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: filterValue,
                isExpanded: true,
                dropdownColor: _kAdminDropdownColor,
                borderRadius: kAppMenuBorderRadius,
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
              child: DropdownButtonFormField<String>(
                initialValue: providerFilterValue,
                isExpanded: true,
                dropdownColor: _kAdminDropdownColor,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Provider filter',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text(
                      'All providers',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final provider in providers)
                    DropdownMenuItem(
                      value: provider.name,
                      child: Text(
                        provider.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              child: _ProviderSelector(
                value: selectedProvider,
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
              icon: actionJobId == 'new'
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_task_outlined),
              label: const Text('Queue current ID'),
            ),
            FilledButton.tonalIcon(
              onPressed: isRunningJobs ? null : onRunPending,
              icon: isRunningJobs
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_play_outlined),
              label: const Text('Run queued'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (jobs.isEmpty)
          const _MessageRow(
            message: 'No persistent ingest jobs for this filter.',
            isError: false,
          )
        else
          for (final job in jobs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProviderIngestJobTile(
                job: job,
                isActing: actionJobId == job.id,
                onRun: () => onRun(job),
                onRetry: () => onRetry(job),
                onRefresh: onRefresh,
              ),
            ),
      ],
    );
  }
}

class _ProviderIngestJobRefreshStrip extends StatelessWidget {
  const _ProviderIngestJobRefreshStrip({
    required this.autoRefresh,
    required this.isPolling,
    required this.refreshedAt,
    required this.onAutoRefreshChanged,
    required this.onRefresh,
  });

  final bool autoRefresh;
  final bool isPolling;
  final DateTime? refreshedAt;
  final ValueChanged<bool> onAutoRefreshChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
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
            _MiniChip(label: autoRefresh ? 'active jobs' : 'manual'),
            if (isPolling)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Refreshing jobs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            if (refreshedAt != null)
              _MiniChip(
                  label: 'Last refreshed ${_formatDateTime(refreshedAt!)}'),
            OutlinedButton.icon(
              onPressed: isPolling ? null : onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh jobs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderIngestJobSummaryBar extends StatelessWidget {
  const _ProviderIngestJobSummaryBar({required this.summary});

  final AdminProviderIngestJobSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          icon: Icons.pending_actions_outlined,
          label: '${summary.queued} queued',
        ),
        _StatusChip(
          icon: Icons.sync_outlined,
          label: '${summary.running} running',
        ),
        _StatusChip(
          icon: Icons.error_outline,
          label: '${summary.failed} failed',
        ),
        _StatusChip(
          icon: Icons.check_circle_outline,
          label: '${summary.done} done',
        ),
        if (summary.dueQueued > 0)
          _StatusChip(
            icon: Icons.timer_outlined,
            label: '${summary.dueQueued} due',
          ),
        if (summary.staleRunning > 0)
          _StatusChip(
            icon: Icons.running_with_errors_outlined,
            label: '${summary.staleRunning} stale',
          ),
        if (summary.nextRunAt != null)
          _StatusChip(
            icon: Icons.schedule_outlined,
            label: 'next ${_formatDateTime(summary.nextRunAt!)}',
          ),
        if (summary.latestFailureAt != null)
          _StatusChip(
            icon: Icons.report_problem_outlined,
            label: 'failed ${_formatDateTime(summary.latestFailureAt!)}',
          ),
      ],
    );
  }
}

class _ProviderIngestJobTile extends StatelessWidget {
  const _ProviderIngestJobTile({
    required this.job,
    required this.isActing,
    required this.onRun,
    required this.onRetry,
    required this.onRefresh,
  });

  final AdminProviderIngestJob job;
  final bool isActing;
  final VoidCallback onRun;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
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
                  color: job.isFailed ? colorScheme.error : colorScheme.primary,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    job.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _MiniChip(label: job.status),
                _MiniChip(label: '${job.attempts}/${job.maxAttempts} attempts'),
                if (job.nextRunAt != null)
                  _MiniChip(label: 'next ${_formatDateTime(job.nextRunAt!)}'),
                if (job.itemId != null)
                  _MiniChip(label: 'item ${_shortId(job.itemId!)}'),
                if (job.lastError != null && job.lastError!.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      job.lastError!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => _ProviderIngestJobDetailDialog(
                      job: job,
                      isActing: isActing,
                      onRun: onRun,
                      onRetry: onRetry,
                      onRefresh: onRefresh,
                    ),
                  ),
                  icon: const Icon(Icons.timeline_outlined),
                  label: const Text('Details'),
                ),
                if (job.isQueued)
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onRun,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_outlined),
                    label: const Text('Run'),
                  ),
                if (job.isFailed)
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onRetry,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.replay_outlined),
                    label: const Text('Retry'),
                  ),
              ],
            ),
            if (job.isRunning) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ] else if (job.isQueued && job.nextRunAt != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Waiting until ${_formatDateTime(job.nextRunAt!)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  const _SearchHistoryList({required this.history});

  final List<AdminSearchHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const _MessageRow(
        message: 'No search reindex runs yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      entry.ok
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: entry.ok ? colorScheme.primary : colorScheme.error,
                    ),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _MiniChip(label: entry.indexName),
                    _MiniChip(label: '${entry.indexedDocuments} docs'),
                    if (entry.error != null && entry.error!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          entry.error!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                        ),
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

class _ProviderIngestJobDetailDialog extends StatelessWidget {
  const _ProviderIngestJobDetailDialog({
    required this.job,
    required this.isActing,
    required this.onRun,
    required this.onRetry,
    required this.onRefresh,
  });

  final AdminProviderIngestJob job;
  final bool isActing;
  final VoidCallback onRun;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Ingest job: ${job.displayTitle}'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(label: job.status),
                  _MiniChip(
                      label: '${job.attempts}/${job.maxAttempts} attempts'),
                  if (job.itemId != null)
                    _MiniChip(label: 'item ${_shortId(job.itemId!)}'),
                  if (job.nextRunAt != null)
                    _MiniChip(label: 'next ${_formatDateTime(job.nextRunAt!)}'),
                ],
              ),
              const SizedBox(height: 12),
              _IngestTimelineRow(
                icon: Icons.key_outlined,
                label: 'Job ID',
                value: job.id,
              ),
              _IngestTimelineRow(
                icon: Icons.hub_outlined,
                label: 'Provider item',
                value: '${job.provider} ${job.providerItemId}',
              ),
              _IngestTimelineRow(
                icon: Icons.info_outline,
                label: 'Current state',
                value: _ingestJobStateDescription(job),
              ),
              _IngestTimelineRow(
                icon: Icons.replay_circle_filled_outlined,
                label: 'Attempts left',
                value:
                    '${_ingestJobAttemptsRemaining(job)} of ${job.maxAttempts}',
              ),
              _IngestTimelineRow(
                icon: Icons.add_task_outlined,
                label: 'Queued',
                value: _formatDateTime(job.createdAt),
              ),
              _IngestTimelineRow(
                icon: Icons.update_outlined,
                label: 'Last update',
                value: _formatDateTime(job.updatedAt),
              ),
              if (job.nextRunAt != null)
                _IngestTimelineRow(
                  icon: Icons.schedule_outlined,
                  label: 'Backoff / next run',
                  value: _formatDateTime(job.nextRunAt!),
                ),
              if (job.itemId != null)
                _IngestTimelineRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Canonical item',
                  value: job.itemId!,
                ),
              if (job.isFailed)
                const _IngestTimelineRow(
                  icon: Icons.error_outline,
                  label: 'Error queue',
                  value: 'persistent failed job',
                ),
              if (job.lastError != null && job.lastError!.isNotEmpty) ...[
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(job.lastError!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onRefresh();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh list'),
        ),
        if (job.isQueued)
          FilledButton.tonalIcon(
            onPressed: isActing
                ? null
                : () {
                    Navigator.of(context).pop();
                    onRun();
                  },
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Run now'),
          ),
        if (job.isFailed)
          FilledButton.tonalIcon(
            onPressed: isActing
                ? null
                : () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Retry'),
          ),
      ],
    );
  }
}

class _IngestTimelineRow extends StatelessWidget {
  const _IngestTimelineRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _AdminAuditLogList extends StatelessWidget {
  const _AdminAuditLogList({required this.logs});

  final List<AdminAuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const _MessageRow(
        message: 'No admin audit events yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final log in logs.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.manage_history_outlined,
                        color: colorScheme.primary),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        log.action,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _MiniChip(label: log.displayActor),
                    _MiniChip(label: log.displayEntity),
                    _MiniChip(label: _formatDateTime(log.createdAt)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Text(
                        log.detailsSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

class _ProviderIngestHistoryList extends StatelessWidget {
  const _ProviderIngestHistoryList({
    required this.history,
    required this.retryingHistoryId,
    required this.onRetry,
  });

  final List<AdminProviderIngestHistoryEntry> history;
  final int? retryingHistoryId;
  final ValueChanged<AdminProviderIngestHistoryEntry> onRetry;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const _MessageRow(
        message: 'No provider ingest attempts yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      entry.isFailed
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: entry.isFailed
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        entry.displayTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _MiniChip(label: entry.status),
                    _MiniChip(label: '${entry.attempts} attempts'),
                    _MiniChip(label: _formatDateTime(entry.timestamp)),
                    if (entry.itemId != null)
                      _MiniChip(label: 'item ${_shortId(entry.itemId!)}'),
                    if (entry.error != null && entry.error!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Text(
                          entry.error!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                        ),
                      ),
                    if (entry.isFailed)
                      OutlinedButton.icon(
                        onPressed: retryingHistoryId == entry.id
                            ? null
                            : () => onRetry(entry),
                        icon: retryingHistoryId == entry.id
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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

class _DuplicateCandidateList extends StatelessWidget {
  const _DuplicateCandidateList({
    required this.candidates,
    required this.inspectingItemId,
    required this.actionItemId,
    required this.onInspect,
    required this.onIgnore,
    required this.onMerge,
  });

  final List<AdminDuplicateCandidate> candidates;
  final String? inspectingItemId;
  final String? actionItemId;
  final ValueChanged<AdminDuplicateCandidate> onInspect;
  final ValueChanged<AdminDuplicateCandidate> onIgnore;
  final ValueChanged<AdminDuplicateCandidate> onMerge;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const _MessageRow(
        message: 'No duplicate candidates detected.',
        isError: false,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final candidate in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DuplicateCandidateTile(
              candidate: candidate,
              isInspecting: candidate.itemIds.contains(inspectingItemId),
              isActing: candidate.itemIds.contains(actionItemId),
              onInspect: () => onInspect(candidate),
              onIgnore: () => onIgnore(candidate),
              onMerge: () => onMerge(candidate),
            ),
          ),
      ],
    );
  }
}

class _DuplicateCandidateTile extends StatelessWidget {
  const _DuplicateCandidateTile({
    required this.candidate,
    required this.isInspecting,
    required this.isActing,
    required this.onInspect,
    required this.onIgnore,
    required this.onMerge,
  });

  final AdminDuplicateCandidate candidate;
  final bool isInspecting;
  final bool isActing;
  final VoidCallback onInspect;
  final VoidCallback onIgnore;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.join_inner_outlined, color: colorScheme.primary),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                candidate.displayTitle,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _MiniChip(label: candidate.kind),
            _MiniChip(label: '${candidate.count} items'),
            _MiniChip(label: '${candidate.duplicateScore}% match'),
            _MiniChip(label: candidate.reason),
            if (candidate.hasProviderConflicts)
              const _MiniChip(label: 'provider conflict'),
            if (candidate.hasCoverConflicts)
              const _MiniChip(label: 'cover conflict'),
            if (candidate.preferredTargetItemId != null)
              _MiniChip(
                label: 'Target ${_shortId(candidate.preferredTargetItemId!)}',
              ),
            OutlinedButton.icon(
              onPressed: isInspecting || isActing || candidate.itemIds.isEmpty
                  ? null
                  : onInspect,
              icon: isInspecting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.visibility_outlined),
              label: const Text('Inspect'),
            ),
            OutlinedButton.icon(
              onPressed:
                  isActing || candidate.itemIds.length < 2 ? null : onIgnore,
              icon: const Icon(Icons.visibility_off_outlined),
              label: const Text('Ignore'),
            ),
            FilledButton.tonalIcon(
              onPressed:
                  isActing || candidate.itemIds.length < 2 ? null : onMerge,
              icon: isActing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.merge_type_outlined),
              label: const Text('Merge into first'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderStatusList extends StatelessWidget {
  const _ProviderStatusList({required this.providers});

  final List<AdminProviderStatus> providers;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const _MessageRow(
        message: 'Provider status not loaded.',
        isError: false,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final provider in providers)
          _ProviderStatusTile(provider: provider),
      ],
    );
  }
}

class _ProviderStatusTile extends StatelessWidget {
  const _ProviderStatusTile({required this.provider});

  final AdminProviderStatus provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    provider.isConfigured
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: provider.isConfigured
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(provider.status),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (provider.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  provider.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: provider.kind),
                  if (provider.requiresUserKey)
                    const _MiniChip(label: 'key required'),
                  if (provider.nonCommercialOnly)
                    const _MiniChip(label: 'non-commercial'),
                  if (provider.requiresAttribution)
                    const _MiniChip(label: 'attribution'),
                  if (provider.allowsImageMirroring)
                    const _MiniChip(label: 'image mirror ok'),
                  if (provider.licenseName != null)
                    _MiniChip(label: provider.licenseName!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderResultsList extends StatelessWidget {
  const _ProviderResultsList({
    required this.results,
    required this.ingestingProviderItemId,
    required this.canIngestProvider,
    required this.onApproveProposal,
    required this.onIngest,
    this.activeProposalId,
    this.activeProposalTitle,
  });

  final List<ProviderCandidate> results;
  final String? ingestingProviderItemId;
  final bool Function(String provider) canIngestProvider;
  final ValueChanged<ProviderCandidate> onApproveProposal;
  final ValueChanged<ProviderCandidate> onIngest;
  final String? activeProposalId;
  final String? activeProposalTitle;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final candidate = results[index];
        final isIngesting = ingestingProviderItemId == candidate.providerItemId;
        return _ProviderResultTile(
          candidate: candidate,
          isIngesting: isIngesting,
          canIngest: canIngestProvider(candidate.provider),
          activeProposalId: activeProposalId,
          activeProposalTitle: activeProposalTitle,
          onApproveProposal: () => onApproveProposal(candidate),
          onIngest: () => onIngest(candidate),
        );
      },
    );
  }
}

class _ProviderResultTile extends StatelessWidget {
  const _ProviderResultTile({
    required this.candidate,
    required this.isIngesting,
    required this.canIngest,
    required this.onApproveProposal,
    required this.onIngest,
    this.activeProposalId,
    this.activeProposalTitle,
  });

  final ProviderCandidate candidate;
  final bool isIngesting;
  final bool canIngest;
  final VoidCallback onApproveProposal;
  final VoidCallback onIngest;
  final String? activeProposalId;
  final String? activeProposalTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final cover = SizedBox(
          width: 64,
          height: 88,
          child: LibraryCoverImage(
            title: candidate.title,
            imageUrl: candidate.imageUrl,
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniChip(label: candidate.provider),
                _MiniChip(label: candidate.kind),
                _MiniChip(label: 'Provider match'),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              candidate.providerItemId,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
            ),
            if (candidate.summary != null &&
                candidate.summary!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                candidate.summary!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
        final button = FilledButton.tonalIcon(
          onPressed: isIngesting || !canIngest ? null : onIngest,
          icon: isIngesting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  canIngest
                      ? Icons.download_for_offline_outlined
                      : Icons.search_outlined,
                ),
          label: Text(canIngest ? 'Ingest' : 'Search only'),
        );
        final proposalButton = activeProposalId == null
            ? null
            : FilledButton.icon(
                onPressed: isIngesting || !canIngest ? null : onApproveProposal,
                icon: isIngesting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.task_alt_outlined),
                label: const Text('Approve proposal'),
              );
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 12),
                          Expanded(child: details),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (proposalButton != null) proposalButton,
                            button,
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 12),
                      Expanded(child: details),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (proposalButton != null) proposalButton,
                          button,
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

