import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:flutter/material.dart';

// Dashboard widgets

class AdminPanel extends StatelessWidget {
  const AdminPanel({
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
    required this.normalizedMetadataDrift,
    required this.metadataContractDrift,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final int configuredProviders;
  final int registeredProviders;
  final String selectedProviderLabel;
  final AdminProviderIngestResult? lastIngest;
  final AdminNormalizedMetadataDriftReport? normalizedMetadataDrift;
  final SharedMetadataContractDrift? metadataContractDrift;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    final searchStatus = this.searchStatus;
    if (errorMessage != null && summary == null && searchStatus == null) {
      return AdminMessageRow(message: errorMessage!, isError: true);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Providers ──
        _DashboardSection(
          title: 'Providers',
          children: [
            AdminStatusChip(
              icon: Icons.extension_outlined,
              label: '$configuredProviders live',
            ),
            AdminStatusChip(
              icon: Icons.manage_search_outlined,
              label: '$registeredProviders registered',
            ),
            AdminStatusChip(
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
              AdminStatusChip(
                icon: Icons.library_books_outlined,
                label: '${summary.items} items',
              ),
              AdminStatusChip(
                icon: Icons.category_outlined,
                label: '${summary.series} series',
              ),
              AdminStatusChip(
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
              AdminStatusChip(
                icon: Icons.image_search_outlined,
                label: summary.coverCoverageLabel,
              ),
              AdminStatusChip(
                icon: Icons.hub_outlined,
                label: summary.providerCoverageLabel,
              ),
              AdminStatusChip(
                icon: Icons.image_outlined,
                label: '${summary.missingCoverItems} missing covers',
              ),
              AdminStatusChip(
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
              AdminStatusChip(
                icon: Icons.join_inner_outlined,
                label: '${summary.duplicateCandidateGroups} duplicate groups',
              ),
              AdminStatusChip(
                icon: summary.providerIngestFailures == 0
                    ? Icons.download_done_outlined
                    : Icons.error_outline,
                label: '${summary.providerIngestFailures} failures',
              ),
              AdminStatusChip(
                icon: Icons.download_for_offline_outlined,
                label: '${summary.providerIngestSuccesses} ok',
              ),
              AdminStatusChip(
                icon: Icons.pending_actions_outlined,
                label: '${summary.pendingProposals} pending',
              ),
              if (lastIngest != null)
                AdminStatusChip(
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
            child: AdminStatusChip(
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
              const AdminStatusChip(
                icon: Icons.manage_search_outlined,
                label: 'Loading…',
              )
            else
              AdminStatusChip(
                icon: searchStatus.ok
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                label: searchStatus.ok
                    ? '${searchStatus.documentCount ?? '-'} docs'
                    : 'Unavailable',
              ),
            if (lastReindex != null)
              AdminStatusChip(
                icon: lastReindex!.ok
                    ? Icons.published_with_changes_outlined
                    : Icons.error_outline,
                label: lastReindex!.ok
                    ? 'Reindexed ${lastReindex!.indexedDocuments}'
                    : 'Reindex failed',
              ),
          ],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Metadata contract',
          children: [
            AdminStatusChip(
              icon: metadataContractDrift == null
                  ? Icons.hourglass_empty
                  : metadataContractDrift!.isInSync
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_outlined,
              label: metadataContractDrift == null
                  ? 'Loading…'
                  : metadataContractDrift!.isInSync
                      ? 'Shared contract in sync'
                      : 'Drift: ${metadataContractDrift!.mismatchCount}',
            ),
            AdminStatusChip(
              icon: normalizedMetadataDrift == null
                  ? Icons.hourglass_empty
                  : normalizedMetadataDrift!.releaseGateOk
                      ? Icons.verified_outlined
                      : Icons.warning_amber_outlined,
              label: normalizedMetadataDrift == null
                  ? 'Release gate loading…'
                  : normalizedMetadataDrift!.releaseGateOk
                      ? 'Release gate: pass'
                      : 'Release gate: fail (${normalizedMetadataDrift!.driftedEntities + normalizedMetadataDrift!.typedDriftedItems})',
            ),
            AdminStatusChip(
              icon: normalizedMetadataDrift == null
                  ? Icons.hourglass_empty
                  : normalizedMetadataDrift!.hasDrift
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
              label: normalizedMetadataDrift == null
                  ? 'Normalized drift loading…'
                  : normalizedMetadataDrift!.hasDrift
                      ? 'Normalized drift: ${normalizedMetadataDrift!.driftedEntities + normalizedMetadataDrift!.typedDriftedItems}'
                      : 'Normalized drift clear',
            ),
            if (normalizedMetadataDrift?.topIssue != null)
              AdminStatusChip(
                icon: Icons.rule_folder_outlined,
                label: 'Top issue: ${normalizedMetadataDrift!.topIssue}',
              ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          AdminStatusChip(icon: Icons.error_outline, label: errorMessage!),
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
        return AdminMessageRow(message: errorMessage!, isError: true);
      }
      return const AdminStatusChip(
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
                  AdminStatusChip(
                    icon: Icons.category_outlined,
                    label: 'No kind stats yet',
                  ),
                ]
              : [
                  for (final row in byKind)
                    AdminStatusChip(
                      icon: Icons.category_outlined,
                      label: '${_statsKindLabel(row.key)}: ${row.value}',
                    ),
                ],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Storage',
          children: [
            AdminStatusChip(
              icon: Icons.image_outlined,
              label: '${summary?.imageAssets ?? 0} image assets',
            ),
            AdminStatusChip(
              icon: Icons.storage_outlined,
              label: '${summary?.imageCacheEntries ?? 0} cache entries',
            ),
            if (cache != null) ...[
              AdminStatusChip(
                icon: Icons.data_usage_outlined,
                label: '${cache.usagePercent.toStringAsFixed(1)}% cache usage',
              ),
              AdminStatusChip(
                icon: Icons.sd_storage_outlined,
                label:
                    '${_statsFormatBytes(cache.totalSizeBytes)} / ${_statsFormatBytes(cache.maxSizeBytes)}',
              ),
              AdminStatusChip(
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
          AdminMessageRow(message: errorMessage!, isError: true),
        ],
      ],
    );
  }
}

class _ProposalSummaryChips extends StatelessWidget {
  const _ProposalSummaryChips({required this.summary});

  final AdminMetadataProposalSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AdminStatusChip(
          icon: Icons.pending_actions_outlined,
          label: '${summary?.pending ?? 0} pending',
        ),
        AdminStatusChip(
          icon: Icons.task_alt_outlined,
          label: '${summary?.approved ?? 0} approved',
        ),
        AdminStatusChip(
          icon: Icons.block_outlined,
          label: '${summary?.rejected ?? 0} rejected',
        ),
        AdminStatusChip(
          icon: Icons.insights_outlined,
          label: '${summary?.total ?? 0} total',
        ),
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
      return AdminMessageRow(message: errorMessage!, isError: true);
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
          children: [_ProposalSummaryChips(summary: summary)],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Recent trend',
          children: [
            AdminStatusChip(
              icon: Icons.trending_up_outlined,
              label: '$recentApprovals recent approve',
            ),
            AdminStatusChip(
              icon: Icons.trending_down_outlined,
              label: '$recentRejections recent reject',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const AdminMessageRow(
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
  final mediaKind = catalogMediaKindFromApiValue(kind);
  return _adminKindLabelForType(mediaKind, plural: true) ??
      (kind.isEmpty ? 'Unknown' : kind);
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

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({
    super.key,
    required this.isReindexing,
    required this.isLoadingDashboard,
    required this.db,
    required this.summary,
    required this.searchStatus,
    required this.lastReindex,
    required this.configuredProviders,
    required this.registeredProviders,
    required this.selectedProviderLabel,
    required this.lastIngest,
    required this.normalizedMetadataDrift,
    required this.metadataContractDrift,
    required this.dashboardErrorMessage,
    required this.proposalSummary,
    required this.proposalHistory,
    required this.onReindexSearch,
    required this.onRefreshDashboard,
  });

  final bool isReindexing;
  final bool isLoadingDashboard;
  final LocalDatabase db;
  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final int configuredProviders;
  final int registeredProviders;
  final String selectedProviderLabel;
  final AdminProviderIngestResult? lastIngest;
  final AdminNormalizedMetadataDriftReport? normalizedMetadataDrift;
  final SharedMetadataContractDrift? metadataContractDrift;
  final String? dashboardErrorMessage;
  final AdminMetadataProposalSummary? proposalSummary;
  final List<AdminAuditLogEntry> proposalHistory;
  final VoidCallback onReindexSearch;
  final VoidCallback onRefreshDashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminPanel(
          icon: Icons.dashboard_customize_outlined,
          title: 'Metadata dashboard',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Reindex search',
                onPressed: isReindexing ? null : onReindexSearch,
                icon: isReindexing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.manage_search_outlined),
              ),
              IconButton(
                tooltip: 'Refresh dashboard',
                onPressed: isLoadingDashboard ? null : onRefreshDashboard,
                icon: isLoadingDashboard
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          child: _DashboardSummary(
            summary: summary,
            searchStatus: searchStatus,
            lastReindex: lastReindex,
            configuredProviders: configuredProviders,
            registeredProviders: registeredProviders,
            selectedProviderLabel: selectedProviderLabel,
            lastIngest: lastIngest,
            normalizedMetadataDrift: normalizedMetadataDrift,
            metadataContractDrift: metadataContractDrift,
            errorMessage: dashboardErrorMessage,
          ),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.pending_actions_outlined,
          title: 'Metadata proposal activity',
          child: _DashboardProposalActivity(
            summary: proposalSummary,
            history: proposalHistory,
            errorMessage: dashboardErrorMessage,
          ),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.account_tree_outlined,
          title: 'Collection schema',
          child: CollectionSchemaManagementPanel(db: db),
        ),
      ],
    );
  }
}

class AdminStatsTab extends StatelessWidget {
  const AdminStatsTab({
    super.key,
    required this.isLoadingDashboard,
    required this.summary,
    required this.imageCacheStats,
    required this.dashboardErrorMessage,
    required this.onRefreshDashboard,
  });

  final bool isLoadingDashboard;
  final AdminCatalogSummary? summary;
  final AdminImageCacheStats? imageCacheStats;
  final String? dashboardErrorMessage;
  final VoidCallback onRefreshDashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminPanel(
          icon: Icons.bar_chart_outlined,
          title: 'Catalog stats',
          trailing: IconButton(
            tooltip: 'Refresh stats',
            onPressed: isLoadingDashboard ? null : onRefreshDashboard,
            icon: isLoadingDashboard
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          child: _DashboardStatsOverview(
            summary: summary,
            imageCacheStats: imageCacheStats,
            errorMessage: dashboardErrorMessage,
          ),
        ),
      ],
    );
  }
}
