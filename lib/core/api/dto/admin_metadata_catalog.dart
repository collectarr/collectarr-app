part of 'admin_metadata.dart';

// Catalog summary, ingest jobs, search, audit log models

class AdminCatalogSummary {
  const AdminCatalogSummary({
    required this.items,
    this.itemsByKind = const <String, int>{},
    required this.series,
    required this.volumes,
    required this.editions,
    required this.variants,
    required this.imageAssets,
    required this.imageCacheEntries,
    required this.pendingProposals,
    required this.missingCoverItems,
    required this.duplicateCandidateGroups,
  });

  final int items;
  final Map<String, int> itemsByKind;
  final int series;
  final int volumes;
  final int editions;
  final int variants;
  final int imageAssets;
  final int imageCacheEntries;
  final int pendingProposals;
  final int missingCoverItems;
  final int duplicateCandidateGroups;

  int get coverCoveragePercent =>
      items == 0 ? 100 : (((items - missingCoverItems) * 100) / items).round();

  String get coverCoverageLabel => '$coverCoveragePercent% covers';

  factory AdminCatalogSummary.fromJson(Map<String, dynamic> json) {
    final byKind = json['items_by_kind'];
    return AdminCatalogSummary(
      items: json['items'] as int? ?? 0,
      itemsByKind: byKind is Map<String, dynamic>
          ? byKind.map(
              (key, value) => MapEntry(
                key,
                (value as num?)?.toInt() ?? 0,
              ),
            )
          : const <String, int>{},
      series: json['series'] as int? ?? 0,
      volumes: json['volumes'] as int? ?? 0,
      editions: json['editions'] as int? ?? 0,
      variants: json['variants'] as int? ?? 0,
      imageAssets: json['image_assets'] as int? ?? 0,
      imageCacheEntries: json['image_cache_entries'] as int? ?? 0,
      pendingProposals: json['pending_proposals'] as int? ?? 0,
      missingCoverItems: json['missing_cover_items'] as int? ?? 0,
      duplicateCandidateGroups: json['duplicate_candidate_groups'] as int? ?? 0,
    );
  }
}

class AdminNormalizedMetadataDriftReport {
  const AdminNormalizedMetadataDriftReport({
    required this.expectedSchemaVersion,
    required this.scannedEntities,
    required this.entitiesWithNormalized,
    required this.driftedEntities,
    required this.typedScannedItems,
    required this.typedDriftedItems,
    this.schemaIssueCount = 0,
    this.blockingIssueCount = 0,
    required this.releaseGateOk,
    this.issueCounts = const <String, int>{},
  });

  final int expectedSchemaVersion;
  final int scannedEntities;
  final int entitiesWithNormalized;
  final int driftedEntities;
  final int typedScannedItems;
  final int typedDriftedItems;
  final int schemaIssueCount;
  final int blockingIssueCount;
  final bool releaseGateOk;
  final Map<String, int> issueCounts;

  bool get hasDrift => driftedEntities > 0 || typedDriftedItems > 0;

  String? get topIssue {
    if (issueCounts.isEmpty) {
      return null;
    }
    final entries = issueCounts.entries.toList(growable: false)
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.compareTo(right.key);
      });
    return entries.first.key;
  }

  factory AdminNormalizedMetadataDriftReport.fromJson(
      Map<String, dynamic> json) {
    final issueCounts = json['issue_counts'];
    return AdminNormalizedMetadataDriftReport(
      expectedSchemaVersion: json['expected_schema_version'] as int? ?? 0,
      scannedEntities: json['scanned_entities'] as int? ?? 0,
      entitiesWithNormalized: json['entities_with_normalized'] as int? ?? 0,
      driftedEntities: json['drifted_entities'] as int? ?? 0,
      typedScannedItems: json['typed_scanned_items'] as int? ?? 0,
      typedDriftedItems: json['typed_drifted_items'] as int? ?? 0,
      schemaIssueCount: json['schema_issue_count'] as int? ?? 0,
      blockingIssueCount: json['blocking_issue_count'] as int? ?? 0,
      releaseGateOk: json['release_gate_ok'] as bool? ??
          ((json['blocking_issue_count'] as int? ?? 0) == 0 &&
              (json['typed_drifted_items'] as int? ?? 0) == 0),
      issueCounts: issueCounts is Map<String, dynamic>
          ? issueCounts.map(
              (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
            )
          : const <String, int>{},
    );
  }
}

class AdminSearchStatus {
  const AdminSearchStatus({
    required this.ok,
    required this.indexName,
    this.documentCount,
    this.isEmpty,
    this.error,
  });

  final bool ok;
  final String indexName;
  final int? documentCount;
  final bool? isEmpty;
  final String? error;

  factory AdminSearchStatus.fromJson(Map<String, dynamic> json) {
    return AdminSearchStatus(
      ok: json['ok'] as bool? ?? false,
      indexName: json['index_name'] as String? ?? 'items',
      documentCount: json['document_count'] as int?,
      isEmpty: json['is_empty'] as bool?,
      error: json['error'] as String?,
    );
  }
}

class AdminSearchReindexResult {
  const AdminSearchReindexResult({
    required this.ok,
    required this.indexName,
    required this.indexedDocuments,
    this.error,
  });

  final bool ok;
  final String indexName;
  final int indexedDocuments;
  final String? error;

  factory AdminSearchReindexResult.fromJson(Map<String, dynamic> json) {
    return AdminSearchReindexResult(
      ok: json['ok'] as bool? ?? false,
      indexName: json['index_name'] as String? ?? 'items',
      indexedDocuments: json['indexed_documents'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }
}

class AdminSearchHistoryEntry {
  const AdminSearchHistoryEntry({
    required this.timestamp,
    required this.ok,
    required this.indexName,
    required this.indexedDocuments,
    this.error,
  });

  final DateTime timestamp;
  final bool ok;
  final String indexName;
  final int indexedDocuments;
  final String? error;

  factory AdminSearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AdminSearchHistoryEntry(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      ok: json['ok'] as bool? ?? false,
      indexName: json['index_name'] as String? ?? 'items',
      indexedDocuments: json['indexed_documents'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }
}

class AdminAuditLogEntry {
  const AdminAuditLogEntry({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.actorUserId,
    this.actorEmail,
    this.entityId,
    this.detailsJson = const {},
  });

  final String id;
  final String action;
  final String? actorUserId;
  final String? actorEmail;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> detailsJson;
  final DateTime createdAt;

  String get displayEntity =>
      entityId == null ? entityType : '$entityType ${_shortModelId(entityId!)}';

  String get displayActor => actorEmail ?? 'system';

  String get detailsSummary {
    final fields = detailsJson['fields'];
    if (fields is List && fields.isNotEmpty) {
      return 'fields: ${fields.join(', ')}';
    }
    final sourceItemIds = detailsJson['source_item_ids'];
    if (sourceItemIds is List && sourceItemIds.isNotEmpty) {
      return '${sourceItemIds.length} source items';
    }
    final keys = detailsJson.keys.take(3).join(', ');
    return keys.isEmpty ? 'no details' : keys;
  }

  factory AdminAuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AdminAuditLogEntry(
      id: json['id']?.toString() ?? '',
      action: json['action'] as String? ?? '',
      actorUserId: json['actor_user_id']?.toString(),
      actorEmail: json['actor_email'] as String?,
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id']?.toString(),
      detailsJson: (json['details_json'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      createdAt: _parseDateTime(json['created_at'] as String?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

DateTime _adminDateTimeFromJson(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
