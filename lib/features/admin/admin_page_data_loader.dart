import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';

/// Loads the independent Admin page datasets without owning widget state.
class AdminPageDataLoader {
  const AdminPageDataLoader(this.api);

  final ApiClient api;

  Future<AdminDashboardData> loadDashboard({
    String? ingestJobStatus,
    String? ingestJobProvider,
    String? ingestJobQuery,
  }) async {
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
      api.adminProviderIngestHistory(),
      api.adminProviderIngestJobSummary(),
      api.adminProviderIngestJobs(
        status: ingestJobStatus,
        provider: ingestJobProvider,
        query: ingestJobQuery,
        limit: 8,
      ),
      api.adminDuplicateCandidates(limit: 5),
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
      ingestHistory: results[9] as List<AdminProviderIngestHistoryEntry>,
      ingestJobSummary: results[10] as AdminProviderIngestJobSummary,
      ingestJobs: results[11] as List<AdminProviderIngestJob>,
      duplicateCandidates: results[12] as List<AdminDuplicateCandidate>,
    );
  }

  Future<AdminIngestJobsData> loadIngestJobs({
    String? status,
    String? provider,
    String? query,
  }) async {
    final results = await Future.wait<Object>([
      api.adminProviderIngestHistory(),
      api.adminProviderIngestJobSummary(),
      api.adminProviderIngestJobs(
        status: status,
        provider: provider,
        query: query,
        limit: 8,
      ),
    ]);
    return AdminIngestJobsData(
      history: results[0] as List<AdminProviderIngestHistoryEntry>,
      summary: results[1] as AdminProviderIngestJobSummary,
      jobs: results[2] as List<AdminProviderIngestJob>,
    );
  }

  Future<AdminProposalData> loadProposals({
    required String status,
    String? provider,
  }) async {
    final results = await Future.wait<Object>([
      api.adminMetadataProposalSummary(),
      api.adminMetadataProposals(status: status, provider: provider),
    ]);
    return AdminProposalData(
      summary: results[0] as AdminMetadataProposalSummary,
      proposals: results[1] as List<AdminMetadataProposal>,
    );
  }

  Future<List<AdminProviderStatus>> loadProviders() =>
      api.adminProviderStatuses();

  Future<List<AdminReleaseMediaMappingRule>> loadReleaseMappingRules() =>
      api.adminReleaseMediaMappingRules();
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
    required this.ingestHistory,
    required this.ingestJobSummary,
    required this.ingestJobs,
    required this.duplicateCandidates,
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
  final List<AdminProviderIngestHistoryEntry> ingestHistory;
  final AdminProviderIngestJobSummary ingestJobSummary;
  final List<AdminProviderIngestJob> ingestJobs;
  final List<AdminDuplicateCandidate> duplicateCandidates;
}

class AdminIngestJobsData {
  const AdminIngestJobsData({
    required this.history,
    required this.summary,
    required this.jobs,
  });

  final List<AdminProviderIngestHistoryEntry> history;
  final AdminProviderIngestJobSummary summary;
  final List<AdminProviderIngestJob> jobs;
}

class AdminProposalData {
  const AdminProposalData({
    required this.summary,
    required this.proposals,
  });

  final AdminMetadataProposalSummary summary;
  final List<AdminMetadataProposal> proposals;
}
