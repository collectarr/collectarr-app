part of 'admin_page.dart';

// Dashboard widgets

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({
    required this.summary,
    required this.searchStatus,
    required this.lastReindex,
    required this.configuredProviders,
    required this.registeredProviders,
    required this.selectedProviderLabel,
    required this.lastIngest,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final int configuredProviders;
  final int registeredProviders;
  final String selectedProviderLabel;
  final AdminProviderIngestResult? lastIngest;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    final searchStatus = this.searchStatus;
    if (errorMessage != null && summary == null && searchStatus == null) {
      return _MessageRow(message: errorMessage!, isError: true);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Providers ──
        _DashboardSection(
          title: 'Providers',
          children: [
            _StatusChip(
              icon: Icons.extension_outlined,
              label: '$configuredProviders live',
            ),
            _StatusChip(
              icon: Icons.manage_search_outlined,
              label: '$registeredProviders registered',
            ),
            _StatusChip(
              icon: Icons.source_outlined,
              label: selectedProviderLabel,
            ),
          ],
        ),
        if (summary != null) ...[
          const SizedBox(height: 12),
          // ── Catalog ──
          _DashboardSection(
            title: 'Catalog',
            children: [
              _StatusChip(
                icon: Icons.library_books_outlined,
                label: '${summary.items} items',
              ),
              _StatusChip(
                icon: Icons.category_outlined,
                label: '${summary.series} series',
              ),
              _StatusChip(
                icon: Icons.link_outlined,
                label: '${summary.providerLinks} provider links',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Coverage ──
          _DashboardSection(
            title: 'Coverage',
            children: [
              _StatusChip(
                icon: Icons.image_search_outlined,
                label: summary.coverCoverageLabel,
              ),
              _StatusChip(
                icon: Icons.hub_outlined,
                label: summary.providerCoverageLabel,
              ),
              _StatusChip(
                icon: Icons.image_outlined,
                label: '${summary.missingCoverItems} missing covers',
              ),
              _StatusChip(
                icon: Icons.link_off_outlined,
                label: '${summary.missingProviderLinkItems} missing IDs',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Ingests ──
          _DashboardSection(
            title: 'Ingests',
            children: [
              _StatusChip(
                icon: Icons.join_inner_outlined,
                label: '${summary.duplicateCandidateGroups} duplicate groups',
              ),
              _StatusChip(
                icon: summary.providerIngestFailures == 0
                    ? Icons.download_done_outlined
                    : Icons.error_outline,
                label: '${summary.providerIngestFailures} failures',
              ),
              _StatusChip(
                icon: Icons.download_for_offline_outlined,
                label: '${summary.providerIngestSuccesses} ok',
              ),
              _StatusChip(
                icon: Icons.pending_actions_outlined,
                label: '${summary.pendingProposals} pending',
              ),
              if (lastIngest != null)
                _StatusChip(
                  icon: lastIngest!.created
                      ? Icons.add_circle_outline
                      : Icons.fact_check_outlined,
                  label: lastIngest!.created ? 'Last: new' : 'Last: exists',
                ),
            ],
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: _StatusChip(
              icon: Icons.hourglass_empty,
              label: 'Catalog metrics loading',
            ),
          ),
        const SizedBox(height: 12),
        // ── Search ──
        _DashboardSection(
          title: 'Search index',
          children: [
            if (searchStatus == null)
              const _StatusChip(
                icon: Icons.manage_search_outlined,
                label: 'Loading…',
              )
            else
              _StatusChip(
                icon: searchStatus.ok
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                label: searchStatus.ok
                    ? '${searchStatus.documentCount ?? '-'} docs'
                    : 'Unavailable',
              ),
            if (lastReindex != null)
              _StatusChip(
                icon: lastReindex!.ok
                    ? Icons.published_with_changes_outlined
                    : Icons.error_outline,
                label: lastReindex!.ok
                    ? 'Reindexed ${lastReindex!.indexedDocuments}'
                    : 'Reindex failed',
              ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _StatusChip(icon: Icons.error_outline, label: errorMessage!),
        ],
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}

class _DashboardStatsOverview extends StatelessWidget {
  const _DashboardStatsOverview({
    required this.summary,
    required this.imageCacheStats,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminImageCacheStats? imageCacheStats;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (summary == null && imageCacheStats == null) {
      if (errorMessage != null) {
        return _MessageRow(message: errorMessage!, isError: true);
      }
      return const _StatusChip(
        icon: Icons.hourglass_empty,
        label: 'Stats loading',
      );
    }
    final byKind = (summary?.itemsByKind ?? const <String, int>{})
        .entries
        .where((entry) => entry.value > 0)
        .toList(growable: false)
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.compareTo(right.key);
      });
    final cache = imageCacheStats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardSection(
          title: 'Items by kind',
          children: byKind.isEmpty
              ? const [
                  _StatusChip(
                    icon: Icons.category_outlined,
                    label: 'No kind stats yet',
                  ),
                ]
              : [
                  for (final row in byKind)
                    _StatusChip(
                      icon: Icons.category_outlined,
                      label: '${_statsKindLabel(row.key)}: ${row.value}',
                    ),
                ],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Storage',
          children: [
            _StatusChip(
              icon: Icons.image_outlined,
              label: '${summary?.imageAssets ?? 0} image assets',
            ),
            _StatusChip(
              icon: Icons.storage_outlined,
              label: '${summary?.imageCacheEntries ?? 0} cache entries',
            ),
            if (cache != null) ...[
              _StatusChip(
                icon: Icons.data_usage_outlined,
                label: '${cache.usagePercent.toStringAsFixed(1)}% cache usage',
              ),
              _StatusChip(
                icon: Icons.sd_storage_outlined,
                label:
                    '${_statsFormatBytes(cache.totalSizeBytes)} / ${_statsFormatBytes(cache.maxSizeBytes)}',
              ),
              _StatusChip(
                icon: cache.mirroringEnabled
                    ? Icons.check_circle_outline
                    : Icons.block_outlined,
                label: cache.mirroringEnabled
                    ? 'Mirroring enabled'
                    : 'Mirroring disabled',
              ),
            ],
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _MessageRow(message: errorMessage!, isError: true),
        ],
      ],
    );
  }
}

class _DashboardProposalActivity extends StatelessWidget {
  const _DashboardProposalActivity({
    required this.summary,
    required this.history,
    required this.errorMessage,
  });

  final AdminMetadataProposalSummary? summary;
  final List<AdminAuditLogEntry> history;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && summary == null && history.isEmpty) {
      return _MessageRow(message: errorMessage!, isError: true);
    }

    final recentApprovals = history
        .where((entry) => entry.action.contains('metadata_proposal.approve'))
        .length;
    final recentRejections = history
        .where((entry) => entry.action.contains('metadata_proposal.reject'))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardSection(
          title: 'Backlog',
          children: [
            _StatusChip(
              icon: Icons.pending_actions_outlined,
              label: '${summary?.pending ?? 0} pending',
            ),
            _StatusChip(
              icon: Icons.task_alt_outlined,
              label: '${summary?.approved ?? 0} approved',
            ),
            _StatusChip(
              icon: Icons.block_outlined,
              label: '${summary?.rejected ?? 0} rejected',
            ),
            _StatusChip(
              icon: Icons.insights_outlined,
              label: '${summary?.total ?? 0} total',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Recent trend',
          children: [
            _StatusChip(
              icon: Icons.trending_up_outlined,
              label: '$recentApprovals recent approve',
            ),
            _StatusChip(
              icon: Icons.trending_down_outlined,
              label: '$recentRejections recent reject',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const _MessageRow(
            message: 'No proposal review activity recorded yet.',
            isError: false,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            entry.action.contains('reject')
                                ? Icons.block_outlined
                                : Icons.task_alt_outlined,
                          ),
                          Text(
                            _proposalAuditActionLabel(entry.action),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          _MiniChip(label: entry.actorEmail ?? 'unknown actor'),
                          _MiniChip(label: _formatDateTime(entry.createdAt)),
                          if ((entry.entityId?.isNotEmpty ?? false))
                            _MiniChip(label: _shortId(entry.entityId!)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

String _statsKindLabel(String kind) {
  return switch (kind) {
    'boardgame' => 'Board games',
    'tv' => 'TV',
    'anime' => 'Anime',
    'manga' => 'Manga',
    'comic' => 'Comics',
    'book' => 'Books',
    'game' => 'Games',
    'movie' => 'Movies',
    'music' => 'Music',
    _ => kind.isEmpty ? 'Unknown' : kind,
  };
}

String _statsFormatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
