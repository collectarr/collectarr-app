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
    required this.providerLinks,
    required this.imageAssets,
    required this.imageCacheEntries,
    required this.pendingProposals,
    required this.missingCoverItems,
    required this.missingProviderLinkItems,
    required this.duplicateCandidateGroups,
    this.providerIngestSuccesses = 0,
    this.providerIngestFailures = 0,
  });

  final int items;
  final Map<String, int> itemsByKind;
  final int series;
  final int volumes;
  final int editions;
  final int variants;
  final int providerLinks;
  final int imageAssets;
  final int imageCacheEntries;
  final int pendingProposals;
  final int missingCoverItems;
  final int missingProviderLinkItems;
  final int duplicateCandidateGroups;
  final int providerIngestSuccesses;
  final int providerIngestFailures;

  int get coverCoveragePercent =>
      items == 0 ? 100 : (((items - missingCoverItems) * 100) / items).round();

  int get providerCoveragePercent => items == 0
      ? 100
      : (((items - missingProviderLinkItems) * 100) / items).round();

  String get coverCoverageLabel => '$coverCoveragePercent% covers';

  String get providerCoverageLabel => '$providerCoveragePercent% provider IDs';

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
      providerLinks: json['provider_links'] as int? ?? 0,
      imageAssets: json['image_assets'] as int? ?? 0,
      imageCacheEntries: json['image_cache_entries'] as int? ?? 0,
      pendingProposals: json['pending_proposals'] as int? ?? 0,
      missingCoverItems: json['missing_cover_items'] as int? ?? 0,
      missingProviderLinkItems:
          json['missing_provider_link_items'] as int? ?? 0,
      duplicateCandidateGroups: json['duplicate_candidate_groups'] as int? ?? 0,
      providerIngestSuccesses: json['provider_ingest_successes'] as int? ?? 0,
      providerIngestFailures: json['provider_ingest_failures'] as int? ?? 0,
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

class AdminProviderIngestHistoryEntry {
  const AdminProviderIngestHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.provider,
    required this.providerItemId,
    required this.status,
    required this.attempts,
    this.itemId,
    this.error,
  });

  final int id;
  final DateTime timestamp;
  final String provider;
  final String providerItemId;
  final String status;
  final int attempts;
  final String? itemId;
  final String? error;

  bool get isFailed => status == 'failed';

  String get displayTitle => '$provider $providerItemId';

  factory AdminProviderIngestHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AdminProviderIngestHistoryEntry(
      id: json['id'] as int? ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      provider: json['provider'] as String? ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'unknown',
      attempts: json['attempts'] as int? ?? 0,
      itemId: json['item_id']?.toString(),
      error: json['error'] as String?,
    );
  }
}

class AdminProviderIngestJob {
  const AdminProviderIngestJob({
    required this.id,
    required this.provider,
    required this.providerItemId,
    required this.status,
    required this.attempts,
    required this.maxAttempts,
    required this.createdAt,
    required this.updatedAt,
    this.nextRunAt,
    this.itemId,
    this.lastError,
  });

  final String id;
  final String provider;
  final String providerItemId;
  final String status;
  final int attempts;
  final int maxAttempts;
  final DateTime? nextRunAt;
  final String? itemId;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isFailed => status == 'failed';
  bool get isQueued => status == 'queued';
  bool get isRunning => status == 'running';
  bool get isDone => status == 'done';

  String get displayTitle => '$provider $providerItemId';

  factory AdminProviderIngestJob.fromJson(Map<String, dynamic> json) {
    return AdminProviderIngestJob(
      id: json['id']?.toString() ?? '',
      provider: json['provider'] as String? ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'queued',
      attempts: json['attempts'] as int? ?? 0,
      maxAttempts: json['max_attempts'] as int? ?? 1,
      nextRunAt: _parseDateTime(json['next_run_at'] as String?),
      itemId: json['item_id']?.toString(),
      lastError: json['last_error'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: _parseDateTime(json['updated_at'] as String?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class AdminProviderIngestJobRunResult {
  const AdminProviderIngestJobRunResult({
    required this.processed,
    required this.jobs,
    required this.recovered,
  });

  final int processed;
  final List<AdminProviderIngestJob> jobs;
  final int recovered;

  factory AdminProviderIngestJobRunResult.fromJson(Map<String, dynamic> json) {
    return AdminProviderIngestJobRunResult(
      processed: json['processed'] as int? ?? 0,
      recovered: json['recovered'] as int? ?? 0,
      jobs: [
        for (final row in (json['jobs'] as List<dynamic>? ?? []))
          AdminProviderIngestJob.fromJson(row as Map<String, dynamic>),
      ],
    );
  }
}

class AdminProviderIngestJobSummary {
  const AdminProviderIngestJobSummary({
    required this.queued,
    required this.running,
    required this.failed,
    required this.done,
    required this.dueQueued,
    required this.staleRunning,
    this.oldestQueuedAt,
    this.nextRunAt,
    this.latestFailureAt,
  });

  final int queued;
  final int running;
  final int failed;
  final int done;
  final int dueQueued;
  final int staleRunning;
  final DateTime? oldestQueuedAt;
  final DateTime? nextRunAt;
  final DateTime? latestFailureAt;

  int get total => queued + running + failed + done;

  factory AdminProviderIngestJobSummary.fromJson(Map<String, dynamic> json) {
    return AdminProviderIngestJobSummary(
      queued: json['queued'] as int? ?? 0,
      running: json['running'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      done: json['done'] as int? ?? 0,
      dueQueued: json['due_queued'] as int? ?? 0,
      staleRunning: json['stale_running'] as int? ?? 0,
      oldestQueuedAt: _parseDateTime(json['oldest_queued_at'] as String?),
      nextRunAt: _parseDateTime(json['next_run_at'] as String?),
      latestFailureAt: _parseDateTime(json['latest_failure_at'] as String?),
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
    final providerItemId = detailsJson['provider_item_id'];
    if (providerItemId != null) {
      return 'provider item $providerItemId';
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
