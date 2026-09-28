import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/features/admin/admin_kind_labels.dart';
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
    required this.catalogItemIntegrity,
    required this.metadataContractDrift,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final AdminCatalogItemIntegrityReport? catalogItemIntegrity;
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
                icon: Icons.image_outlined,
                label: '${summary.missingCoverItems} missing covers',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Ingests ──
          _DashboardSection(
            title: 'Data quality',
            children: [
              AdminStatusChip(
                icon: Icons.join_inner_outlined,
                label: '${summary.duplicateCandidateGroups} duplicate groups',
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
              icon: catalogItemIntegrity == null
                  ? Icons.hourglass_empty
                  : catalogItemIntegrity!.isValid
                      ? Icons.verified_outlined
                      : Icons.warning_amber_outlined,
              label: catalogItemIntegrity == null
                  ? 'Catalog Item validation loading…'
                  : catalogItemIntegrity!.isValid
                      ? 'Catalog Item schemas valid'
                      : 'Invalid Catalog Items: ${catalogItemIntegrity!.invalidItems}',
            ),
            AdminStatusChip(
              icon: catalogItemIntegrity == null
                  ? Icons.hourglass_empty
                  : catalogItemIntegrity!.invalidItems > 0
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
              label: catalogItemIntegrity == null
                  ? 'Catalog Item validation loading…'
                  : 'Validated ${catalogItemIntegrity!.scannedItems} Catalog Items',
            ),
            if (catalogItemIntegrity?.topIssue != null)
              AdminStatusChip(
                icon: Icons.rule_folder_outlined,
                label: 'Top issue: ${catalogItemIntegrity!.topIssue}',
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

String _statsKindLabel(String kind) {
  final mediaKind = catalogMediaKindFromApiValue(kind);
  return adminKindLabelForType(mediaKind, plural: true) ??
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
    required this.catalogItemIntegrity,
    required this.metadataContractDrift,
    required this.dashboardErrorMessage,
    required this.onReindexSearch,
    required this.onRefreshDashboard,
  });

  final bool isReindexing;
  final bool isLoadingDashboard;
  final LocalDatabase db;
  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final AdminCatalogItemIntegrityReport? catalogItemIntegrity;
  final SharedMetadataContractDrift? metadataContractDrift;
  final String? dashboardErrorMessage;
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
            catalogItemIntegrity: catalogItemIntegrity,
            metadataContractDrift: metadataContractDrift,
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
