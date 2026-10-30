import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_proposal.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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
      searchStatus: results[3] as AdminSearchStatus,
      searchHistory: results[4] as List<AdminSearchHistoryEntry>,
      auditLogs: results[5] as List<AdminAuditLogEntry>,
      proposalSummary: results[6] as AdminMetadataProposalSummary,
      proposalHistory: results[7] as List<AdminAuditLogEntry>,
    );
  }

  Future<AdminProposalData> loadProposals({
    required String status,
  }) async {
    final results = await Future.wait<Object>([
      api.adminMetadataProposals(status: status),
      api.adminCorrectionProposals(status: status),
    ]);
    final corrections = results[1] as List<CanonicalCorrectionProposal>;
    return AdminProposalData(
      proposals: results[0] as List<AdminMetadataProposal>,
      corrections: corrections,
      correctionLabels: await _correctionLabels(api, corrections),
    );
  }
}

/// Core's field labels per kind, read from one correction target of each
/// kind; a target that is gone leaves its fields under their keys.
Future<Map<CatalogMediaKind, Map<String, String>>> _correctionLabels(
    ApiClient api, List<CanonicalCorrectionProposal> corrections) async {
  final labels = <CatalogMediaKind, Map<String, String>>{};
  for (final correction in corrections) {
    if (labels.containsKey(correction.kind)) continue;
    try {
      final target = await api.getCanonicalCorrectionTarget(
        kind: correction.kind,
        entityId: correction.entityId,
        scope: correction.scope,
      );
      labels[correction.kind] = {
        for (final field in target.fieldSchema) field.key: field.label,
      };
    } on Exception {
      continue;
    }
  }
  return labels;
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.summary,
    required this.normalizedMetadataDrift,
    required this.normalizedManifest,
    required this.searchStatus,
    required this.searchHistory,
    required this.auditLogs,
    required this.proposalSummary,
    required this.proposalHistory,
  });

  final AdminCatalogSummary summary;
  final AdminNormalizedMetadataDriftReport normalizedMetadataDrift;
  final MetadataNormalizedManifest normalizedManifest;
  final AdminSearchStatus searchStatus;
  final List<AdminSearchHistoryEntry> searchHistory;
  final List<AdminAuditLogEntry> auditLogs;
  final AdminMetadataProposalSummary proposalSummary;
  final List<AdminAuditLogEntry> proposalHistory;
}

class AdminProposalData {
  const AdminProposalData({
    required this.proposals,
    required this.corrections,
    required this.correctionLabels,
  });

  final List<AdminMetadataProposal> proposals;

  /// Field corrections to existing Core items.
  final List<CanonicalCorrectionProposal> corrections;
  final Map<CatalogMediaKind, Map<String, String>> correctionLabels;
}
