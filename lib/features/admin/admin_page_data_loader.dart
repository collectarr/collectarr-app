import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';

/// Loads the independent Admin page datasets without owning widget state.
class AdminPageDataLoader {
  const AdminPageDataLoader(this.api);

  final ApiClient api;

  Future<AdminDashboardData> loadDashboard() async {
    final results = await Future.wait<Object>([
      api.adminCatalogSummary(),
      api.adminCatalogItemIntegrity(),
      api.adminImageCacheStats(),
      api.adminSearchStatus(),
      api.adminSearchHistory(),
      api.adminAuditLogs(limit: 8),
      api.adminDuplicateCandidates(limit: 5),
    ]);
    return AdminDashboardData(
      summary: results[0] as AdminCatalogSummary,
      catalogItemIntegrity: results[1] as AdminCatalogItemIntegrityReport,
      imageCacheStats: results[2] as AdminImageCacheStats,
      searchStatus: results[3] as AdminSearchStatus,
      searchHistory: results[4] as List<AdminSearchHistoryEntry>,
      auditLogs: results[5] as List<AdminAuditLogEntry>,
      duplicateCandidates: results[6] as List<AdminDuplicateCandidate>,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.summary,
    required this.catalogItemIntegrity,
    required this.imageCacheStats,
    required this.searchStatus,
    required this.searchHistory,
    required this.auditLogs,
    required this.duplicateCandidates,
  });

  final AdminCatalogSummary summary;
  final AdminCatalogItemIntegrityReport catalogItemIntegrity;
  final AdminImageCacheStats imageCacheStats;
  final AdminSearchStatus searchStatus;
  final List<AdminSearchHistoryEntry> searchHistory;
  final List<AdminAuditLogEntry> auditLogs;
  final List<AdminDuplicateCandidate> duplicateCandidates;
}
