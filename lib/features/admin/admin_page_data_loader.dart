import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';

/// Loads the independent Admin page datasets without owning widget state.
class AdminPageDataLoader {
  const AdminPageDataLoader(this.api);

  final ApiClient api;

  Future<AdminDashboardData> loadDashboard() async {
    final results = await Future.wait<Object>([
      api.adminCatalogSummary(),
      api.adminNormalizedMetadataDrift(),
      api.metadataNormalizedManifest(),
      api.adminImageCacheStats(),
      api.adminSearchStatus(),
      api.adminSearchHistory(),
      api.adminAuditLogs(limit: 8),
      api.adminMetadataProposalSummary(),
      api.adminAuditLogs(entityType: 'metadata_proposal', limit: 6),
    ]);
    return AdminDashboardData(
      summary: results[0] as AdminCatalogSummary,
      normalizedMetadataDrift: results[1] as AdminNormalizedMetadataDriftReport,
      normalizedManifest: results[2] as MetadataNormalizedManifest,
      imageCacheStats: results[3] as AdminImageCacheStats,
      searchStatus: results[4] as AdminSearchStatus,
      searchHistory: results[5] as List<AdminSearchHistoryEntry>,
      auditLogs: results[6] as List<AdminAuditLogEntry>,
      proposalSummary: results[7] as AdminMetadataProposalSummary,
      proposalHistory: results[8] as List<AdminAuditLogEntry>,
    );
  }

  Future<AdminProposalData> loadProposals({
    required String status,
  }) async {
    final results = await Future.wait<Object>([
      api.adminMetadataProposalSummary(),
      api.adminMetadataProposals(status: status),
    ]);
    return AdminProposalData(
      summary: results[0] as AdminMetadataProposalSummary,
      proposals: results[1] as List<AdminMetadataProposal>,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.summary,
    required this.normalizedMetadataDrift,
    required this.normalizedManifest,
    required this.imageCacheStats,
    required this.searchStatus,
    required this.searchHistory,
    required this.auditLogs,
    required this.proposalSummary,
    required this.proposalHistory,
  });

  final AdminCatalogSummary summary;
  final AdminNormalizedMetadataDriftReport normalizedMetadataDrift;
  final MetadataNormalizedManifest normalizedManifest;
  final AdminImageCacheStats imageCacheStats;
  final AdminSearchStatus searchStatus;
  final List<AdminSearchHistoryEntry> searchHistory;
  final List<AdminAuditLogEntry> auditLogs;
  final AdminMetadataProposalSummary proposalSummary;
  final List<AdminAuditLogEntry> proposalHistory;
}

class AdminProposalData {
  const AdminProposalData({
    required this.summary,
    required this.proposals,
  });

  final AdminMetadataProposalSummary summary;
  final List<AdminMetadataProposal> proposals;
}
