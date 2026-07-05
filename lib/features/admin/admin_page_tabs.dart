part of 'admin_page.dart';

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
        _AdminPanel(
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
        _AdminPanel(
          icon: Icons.pending_actions_outlined,
          title: 'Metadata proposal activity',
          child: _DashboardProposalActivity(
            summary: proposalSummary,
            history: proposalHistory,
            errorMessage: dashboardErrorMessage,
          ),
        ),
        const SizedBox(height: 12),
        _AdminPanel(
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
        _AdminPanel(
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
