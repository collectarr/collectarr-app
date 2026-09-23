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
    return CompactSearchDropdownFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
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
    return CompactSearchDropdownFormField<String>(
      key: ValueKey('provider-kind-$selected'),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
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

class _SearchHistoryList extends StatelessWidget {
  const _SearchHistoryList({required this.history});

  final List<AdminSearchHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const AdminMessageRow(
        message: 'No search reindex runs yet.',
        isError: false,
      );
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(5))
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
                      entry.ok
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: entry.ok ? colors.primary : colors.error,
                    ),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _MiniChip(label: entry.indexName),
                    _MiniChip(label: '${entry.indexedDocuments} docs'),
                    if (entry.error?.isNotEmpty == true)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          entry.error!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colors.error),
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
    return AccentAlertDialog(
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
      return const AdminMessageRow(
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
      return const AdminMessageRow(
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
      return const AdminMessageRow(
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
            for (final factor in candidate.confidenceFactors.take(3))
              _MiniChip(label: _duplicateSignalLabel(factor)),
            for (final warning in candidate.mergeWarnings.take(2))
              _MiniChip(label: _duplicateSignalLabel(warning)),
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

String _duplicateSignalLabel(String signal) {
  return switch (signal) {
    'provider_ids_consistent' => 'provider IDs aligned',
    'cover_images_consistent' => 'cover assets aligned',
    'provider_links_present' => 'provider links present',
    'provider_links_present_for_all_items' => 'all items linked',
    'publisher_aligned' => 'publisher aligned',
    'release_markers_aligned' => 'release markers aligned',
    'provider_id_conflict' => 'warning: provider conflict',
    'cover_asset_conflict' => 'warning: cover conflict',
    _ => signal.replaceAll('_', ' '),
  };
}

class _ProviderStatusList extends StatelessWidget {
  const _ProviderStatusList({required this.providers});

  final List<AdminProviderStatus> providers;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const AdminMessageRow(
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
                  if (provider.imagePolicy.isNotEmpty)
                    _MiniChip(label: _imagePolicyLabel(provider.imagePolicy)),
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

String _imagePolicyLabel(String policy) {
  return switch (policy) {
    'mirrored_image' => 'mirrored image',
    'remote_image_plus_cache' => 'remote image + cache',
    'remote_image_only' => 'remote image only',
    'user_supplied_image' => 'user-supplied image',
    'fallback_generated_cover' => 'fallback generated cover',
    _ => policy.replaceAll('_', ' '),
  };
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

  final List<ProviderSearchResult> results;
  final String? ingestingProviderItemId;
  final bool Function(String provider) canIngestProvider;
  final ValueChanged<ProviderSearchResult> onApproveProposal;
  final ValueChanged<ProviderSearchResult> onIngest;
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

class _ProviderEntityScopeToggles extends StatelessWidget {
  const _ProviderEntityScopeToggles({
    required this.showMediaResults,
    required this.showReleaseResults,
    required this.onShowMediaResultsChanged,
    required this.onShowReleaseResultsChanged,
  });

  final bool showMediaResults;
  final bool showReleaseResults;
  final ValueChanged<bool> onShowMediaResultsChanged;
  final ValueChanged<bool> onShowReleaseResultsChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _ProviderEntityScopeToggle(
              label: 'Media',
              value: showMediaResults,
              onChanged: onShowMediaResultsChanged,
            ),
            _ProviderEntityScopeToggle(
              label: 'Releases',
              value: showReleaseResults,
              onChanged: onShowReleaseResultsChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderEntityScopeToggle extends StatelessWidget {
  const _ProviderEntityScopeToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 18,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseMappingRulesPanel extends StatelessWidget {
  const _ReleaseMappingRulesPanel({
    required this.rules,
    required this.kindLabels,
    required this.isLoading,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onApplyDefaults,
    this.statusMessage,
    this.errorMessage,
  });

  final List<AdminReleaseMediaMappingRule> rules;
  final Map<String, String> kindLabels;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;
  final ValueChanged<AdminReleaseMediaMappingRule> onEdit;
  final ValueChanged<AdminReleaseMediaMappingRule> onDelete;
  final VoidCallback onApplyDefaults;
  final String? statusMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Maintain release-to-media mapping rules and apply centralized prefill defaults.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: isLoading ? null : onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add mapping rule'),
            ),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onApplyDefaults,
              icon: const Icon(Icons.auto_fix_high_outlined),
              label: const Text('Apply rule defaults'),
            ),
            IconButton(
              tooltip: 'Refresh rules',
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ],
        ),
        if (statusMessage != null || errorMessage != null) ...[
          const SizedBox(height: 12),
          AdminMessageRow(
            message: errorMessage ?? statusMessage!,
            isError: errorMessage != null,
          ),
        ],
        const SizedBox(height: 12),
        if (rules.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.divider),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No mapping rules defined yet.'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final rule = rules[index];
              final providerLabel = rule.provider ?? 'all providers';
              final targetLabel =
                  kindLabels[rule.targetKind] ?? rule.targetKind;
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${rule.releaseType} -> $targetLabel',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _MiniChip(label: providerLabel),
                                _MiniChip(label: 'priority ${rule.priority}'),
                                _MiniChip(
                                    label:
                                        rule.isActive ? 'active' : 'disabled'),
                              ],
                            ),
                            if (rule.notes != null &&
                                rule.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                rule.notes!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Edit rule',
                        onPressed: () => onEdit(rule),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete rule',
                        onPressed: () => onDelete(rule),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
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

  final ProviderSearchResult candidate;
  final bool isIngesting;
  final bool canIngest;
  final VoidCallback onApproveProposal;
  final VoidCallback onIngest;
  final String? activeProposalId;
  final String? activeProposalTitle;

  String? _releaseLinkHint() {
    // Provider payload semantics belong to the selected kind integration.
    // The shared admin result tile only renders structural result data.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReleaseResult = candidate.searchRole.isCollectibleRelease;
    final entityLabel = isReleaseResult ? 'Release result' : 'Media result';
    final releaseLinkHint = isReleaseResult ? _releaseLinkHint() : null;
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
                _MiniChip(label: candidate.kind.apiValue),
                _MiniChip(label: entityLabel),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              candidate.providerItemId,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
            ),
            if (releaseLinkHint != null) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.link_outlined,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      releaseLinkHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ],
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
