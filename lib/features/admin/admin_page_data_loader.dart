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
      api.adminCatalogItemIntegrity(),
      api.metadataNormalizedManifest(),
      api.adminImageCacheStats(),
      api.adminSearchStatus(),
      api.adminSearchHistory(),
      api.adminAuditLogs(limit: 8),
      api.adminDuplicateCandidates(limit: 5),
    ]);
    return AdminDashboardData(
      summary: results[0] as AdminCatalogSummary,
      catalogItemIntegrity: results[1] as AdminCatalogItemIntegrityReport,
      normalizedManifest: results[2] as MetadataNormalizedManifest,
      imageCacheStats: results[3] as AdminImageCacheStats,
      searchStatus: results[4] as AdminSearchStatus,
      searchHistory: results[5] as List<AdminSearchHistoryEntry>,
      auditLogs: results[6] as List<AdminAuditLogEntry>,
      duplicateCandidates: results[7] as List<AdminDuplicateCandidate>,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.summary,
    required this.catalogItemIntegrity,
    required this.normalizedManifest,
    required this.imageCacheStats,
    required this.searchStatus,
    required this.searchHistory,
    required this.auditLogs,
    required this.duplicateCandidates,
  });

  final AdminCatalogSummary summary;
  final AdminCatalogItemIntegrityReport catalogItemIntegrity;
  final MetadataNormalizedManifest normalizedManifest;
  final AdminImageCacheStats imageCacheStats;
  final AdminSearchStatus searchStatus;
  final List<AdminSearchHistoryEntry> searchHistory;
  final List<AdminAuditLogEntry> auditLogs;
  final List<AdminDuplicateCandidate> duplicateCandidates;
}
