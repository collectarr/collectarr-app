class AdminProviderStatus {
  const AdminProviderStatus({
    required this.name,
    required this.displayName,
    required this.kind,
    this.supportedKinds = const [],
    required this.status,
    required this.isConfigured,
    required this.supportsSearch,
    required this.supportsIngest,
    required this.requiresUserKey,
    required this.nonCommercialOnly,
    required this.allowsRedistribution,
    required this.allowsImageMirroring,
    required this.requiresAttribution,
    this.licenseName,
    this.termsUrl,
    this.attributionUrl,
    this.rateLimit,
    this.cachePolicy,
    required this.message,
  });

  final String name;
  final String displayName;
  final String kind;
  final List<String> supportedKinds;
  final String status;
  final bool isConfigured;
  final bool supportsSearch;
  final bool supportsIngest;
  final bool requiresUserKey;
  final bool nonCommercialOnly;
  final bool allowsRedistribution;
  final bool allowsImageMirroring;
  final bool requiresAttribution;
  final String? licenseName;
  final String? termsUrl;
  final String? attributionUrl;
  final String? rateLimit;
  final String? cachePolicy;
  final String message;

  List<String> get effectiveKinds =>
      supportedKinds.isEmpty && kind.isNotEmpty ? [kind] : supportedKinds;

  factory AdminProviderStatus.fromJson(Map<String, dynamic> json) {
    return AdminProviderStatus(
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      kind: json['kind'] as String? ?? '',
      supportedKinds: [
        for (final kind in (json['supported_kinds'] as List<dynamic>? ?? []))
          kind.toString(),
      ],
      status: json['status'] as String? ?? 'unknown',
      isConfigured: json['is_configured'] as bool? ?? false,
      supportsSearch: json['supports_search'] as bool? ?? true,
      supportsIngest: json['supports_ingest'] as bool? ?? true,
      requiresUserKey: json['requires_user_key'] as bool? ?? false,
      nonCommercialOnly: json['non_commercial_only'] as bool? ?? false,
      allowsRedistribution: json['allows_redistribution'] as bool? ?? false,
      allowsImageMirroring: json['allows_image_mirroring'] as bool? ?? false,
      requiresAttribution: json['requires_attribution'] as bool? ?? false,
      licenseName: json['license_name'] as String?,
      termsUrl: json['terms_url'] as String?,
      attributionUrl: json['attribution_url'] as String?,
      rateLimit: json['rate_limit'] as String?,
      cachePolicy: json['cache_policy'] as String?,
      message: json['message'] as String? ?? '',
    );
  }
}

class AdminProviderIngestResult {
  const AdminProviderIngestResult({
    required this.itemId,
    required this.created,
    required this.item,
  });

  final String itemId;
  final bool created;
  final AdminMetadataItem item;

  String get title => item.title;
  String get kind => item.kind;
  String? get itemNumber => item.itemNumber;
  String get displayTitle => item.displayTitle;

  factory AdminProviderIngestResult.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    final itemJson =
        item is Map<String, dynamic> ? item : const <String, dynamic>{};
    final itemId = json['item_id']?.toString() ?? itemJson['id']?.toString();
    if (itemId == null || itemId.isEmpty) {
      throw const FormatException(
          'Provider ingest response did not include item_id');
    }
    return AdminProviderIngestResult(
      itemId: itemId,
      created: json['created'] as bool? ?? false,
      item: AdminMetadataItem.fromJson({
        'id': itemId,
        ...itemJson,
      }),
    );
  }
}

class ProviderPreviewCredit {
  const ProviderPreviewCredit({required this.name, this.role});
  final String name;
  final String? role;

  factory ProviderPreviewCredit.fromJson(Map<String, dynamic> json) {
    return ProviderPreviewCredit(
      name: json['name'] as String,
      role: json['role'] as String?,
    );
  }
}

class ProviderPreviewTrack {
  const ProviderPreviewTrack({
    this.position,
    required this.title,
    this.durationSeconds,
    this.artist,
    this.discNumber,
  });
  final int? position;
  final String title;
  final int? durationSeconds;
  final String? artist;
  final int? discNumber;

  factory ProviderPreviewTrack.fromJson(Map<String, dynamic> json) {
    return ProviderPreviewTrack(
      position: json['position'] as int?,
      title: json['title'] as String,
      durationSeconds: json['duration_seconds'] as int?,
      artist: json['artist'] as String?,
      discNumber: json['disc_number'] as int?,
    );
  }
}

class AdminProviderPreview {
  const AdminProviderPreview({
    required this.provider,
    required this.providerItemId,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.publisher,
    this.imprint,
    this.editionTitle,
    this.editionFormat,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.releaseDate,
    this.barcode,
    this.isbn,
    this.variantName,
    this.coverImageUrl,
    this.coverPriceCents,
    this.currency,
    this.country,
    this.language,
    this.ageRating,
    this.subtitle,
    this.seriesGroup,
    this.pageCount,
    this.runtimeMinutes,
    this.trackCount,
    this.catalogNumber,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.platforms = const [],
    this.genres = const [],
    this.releaseStatus,
    this.tracks = const [],
  });

  final String provider;
  final String providerItemId;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? volumeStartYear;
  final String? publisher;
  final String? imprint;
  final String? editionTitle;
  final String? editionFormat;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final DateTime? releaseDate;
  final String? barcode;
  final String? isbn;
  final String? variantName;
  final String? coverImageUrl;
  final int? coverPriceCents;
  final String? currency;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? subtitle;
  final String? seriesGroup;
  final int? pageCount;
  final int? runtimeMinutes;
  final int? trackCount;
  final String? catalogNumber;
  final List<ProviderPreviewCredit> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> platforms;
  final List<String> genres;
  final String? releaseStatus;
  final List<ProviderPreviewTrack> tracks;

  factory AdminProviderPreview.fromJson(Map<String, dynamic> json) {
    return AdminProviderPreview(
      provider: json['provider'] as String,
      providerItemId: json['provider_item_id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
      volumeStartYear: json['volume_start_year'] as int?,
      publisher: json['publisher'] as String?,
      imprint: json['imprint'] as String?,
      editionTitle: json['edition_title'] as String?,
      editionFormat: json['edition_format'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      barcode: json['barcode'] as String?,
      isbn: json['isbn'] as String?,
      variantName: json['variant_name'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
      pageCount: json['page_count'] as int?,
      runtimeMinutes: json['runtime_minutes'] as int?,
      trackCount: json['track_count'] as int?,
        catalogNumber: json['catalog_number'] as String?,
      creators: (json['creators'] as List<dynamic>?)
              ?.map((e) =>
                  ProviderPreviewCredit.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
      storyArcs: (json['story_arcs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
        platforms: (json['platforms'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(growable: false) ??
          const [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
        releaseStatus: json['release_status'] as String?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) =>
                  ProviderPreviewTrack.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
    );
  }
}

class AdminCatalogSummary {
  const AdminCatalogSummary({
    required this.items,
    required this.series,
    required this.volumes,
    required this.editions,
    required this.variants,
    required this.releases,
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
  final int series;
  final int volumes;
  final int editions;
  final int variants;
  final int releases;
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
    return AdminCatalogSummary(
      items: json['items'] as int? ?? 0,
      series: json['series'] as int? ?? 0,
      volumes: json['volumes'] as int? ?? 0,
      editions: json['editions'] as int? ?? 0,
      variants: json['variants'] as int? ?? 0,
      releases: json['releases'] as int? ?? 0,
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

class AdminDuplicateActionResult {
  const AdminDuplicateActionResult({
    required this.ok,
    required this.affectedItems,
    this.item,
  });

  final bool ok;
  final int affectedItems;
  final AdminMetadataItem? item;

  factory AdminDuplicateActionResult.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    return AdminDuplicateActionResult(
      ok: json['ok'] as bool? ?? false,
      affectedItems: json['affected_items'] as int? ?? 0,
      item: item is Map<String, dynamic>
          ? AdminMetadataItem.fromJson(item)
          : null,
    );
  }
}

class AdminDuplicateCandidate {
  const AdminDuplicateCandidate({
    required this.kind,
    required this.title,
    required this.count,
    required this.itemIds,
    this.itemNumber,
    this.reason = 'same title and item number',
    this.hasProviderConflicts = false,
    this.hasCoverConflicts = false,
    this.duplicateScore = 0,
    this.recommendedTargetItemId,
  });

  final String kind;
  final String title;
  final String? itemNumber;
  final int count;
  final List<String> itemIds;
  final String reason;
  final bool hasProviderConflicts;
  final bool hasCoverConflicts;
  final int duplicateScore;
  final String? recommendedTargetItemId;

  String? get preferredTargetItemId {
    final recommended = recommendedTargetItemId;
    if (recommended != null && itemIds.contains(recommended)) {
      return recommended;
    }
    return itemIds.isEmpty ? null : itemIds.first;
  }

  String get displayTitle {
    if (itemNumber == null || itemNumber!.isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  factory AdminDuplicateCandidate.fromJson(Map<String, dynamic> json) {
    return AdminDuplicateCandidate(
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      itemNumber: json['item_number'] as String?,
      count: json['count'] as int? ?? 0,
      itemIds: [
        for (final id in (json['item_ids'] as List<dynamic>? ?? []))
          id.toString(),
      ],
      reason: json['reason'] as String? ?? 'same title and item number',
      hasProviderConflicts: json['has_provider_conflicts'] as bool? ?? false,
      hasCoverConflicts: json['has_cover_conflicts'] as bool? ?? false,
      duplicateScore: json['duplicate_score'] as int? ?? 0,
      recommendedTargetItemId: json['recommended_target_item_id'] as String?,
    );
  }
}

class AdminMetadataItem {
  const AdminMetadataItem({
    required this.id,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.seriesTitle,
    this.volumeName,
    this.volumeStartYear,
    this.publisher,
    this.barcode,
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.coverDate,
    this.storeDate,
    this.providerLinks = const [],
    this.editions = const [],
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeStartYear;
  final String? publisher;
  final String? barcode;
  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final List<AdminProviderLink> providerLinks;
  final List<AdminEdition> editions;

  String get displayTitle {
    if (itemNumber == null || itemNumber!.isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  AdminVariant? get primaryVariant {
    for (final edition in editions) {
      for (final variant in edition.variants) {
        if (variant.isPrimary) {
          return variant;
        }
      }
      if (edition.variants.isNotEmpty) {
        return edition.variants.first;
      }
    }
    return null;
  }

  AdminEdition? get primaryEdition => editions.isEmpty ? null : editions.first;

  String? get displayCoverUrl =>
      primaryVariant?.thumbnailImageUrl ?? primaryVariant?.coverImageUrl;

  factory AdminMetadataItem.fromJson(Map<String, dynamic> json) {
    return AdminMetadataItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeStartYear: json['volume_start_year'] as int?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverDate: _parseDate(json['cover_date'] as String?),
      storeDate: _parseDate(json['store_date'] as String?),
      providerLinks: [
        for (final link in (json['provider_links'] as List<dynamic>? ?? []))
          AdminProviderLink.fromJson(link as Map<String, dynamic>),
      ],
      editions: [
        for (final edition in (json['editions'] as List<dynamic>? ?? []))
          AdminEdition.fromJson(edition as Map<String, dynamic>),
      ],
    );
  }
}

class AdminEdition {
  const AdminEdition({
    required this.id,
    required this.title,
    this.publisher,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.variants = const [],
    this.releases = const [],
  });

  final String id;
  final String title;
  final String? publisher;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<AdminVariant> variants;
  final List<AdminRelease> releases;

  factory AdminEdition.fromJson(Map<String, dynamic> json) {
    return AdminEdition(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      variants: [
        for (final variant in (json['variants'] as List<dynamic>? ?? []))
          AdminVariant.fromJson(variant as Map<String, dynamic>),
      ],
      releases: [
        for (final release in (json['releases'] as List<dynamic>? ?? []))
          AdminRelease.fromJson(release as Map<String, dynamic>),
      ],
    );
  }
}

class AdminVariant {
  const AdminVariant({
    required this.id,
    required this.name,
    required this.isPrimary,
    this.variantType,
    this.barcode,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadataJson = const {},
  });

  final String id;
  final String name;
  final bool isPrimary;
  final String? variantType;
  final String? barcode;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic> metadataJson;

  Map<String, dynamic> get normalizedMetadata {
    final normalized = metadataJson['normalized'];
    return normalized is Map
        ? normalized.cast<String, dynamic>()
        : const <String, dynamic>{};
  }

  String get coverStatus {
    final status = normalizedMetadata['cover_status'];
    if (status != null && status.toString().trim().isNotEmpty) {
      return status.toString();
    }
    return coverImageUrl == null && thumbnailImageUrl == null
        ? 'missing'
        : 'external_url';
  }

  String? get coverStorage => normalizedMetadata['cover_storage']?.toString();
  String? get coverPolicy => normalizedMetadata['cover_policy']?.toString();
  String? get coverSourceUrl =>
      normalizedMetadata['cover_source_url']?.toString();

  factory AdminVariant.fromJson(Map<String, dynamic> json) {
    return AdminVariant(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      variantType: json['variant_type'] as String?,
      barcode: json['barcode'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadataJson: (json['metadata_json'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }
}

class AdminRelease {
  const AdminRelease({
    required this.id,
    required this.region,
    this.releaseDate,
    this.publisher,
  });

  final String id;
  final String region;
  final DateTime? releaseDate;
  final String? publisher;

  factory AdminRelease.fromJson(Map<String, dynamic> json) {
    return AdminRelease(
      id: json['id']?.toString() ?? '',
      region: json['region'] as String? ?? '',
      releaseDate: _parseDate(json['release_date'] as String?),
      publisher: json['publisher'] as String?,
    );
  }
}

class AdminProviderLink {
  const AdminProviderLink({
    required this.provider,
    required this.entityType,
    required this.providerItemId,
    this.siteUrl,
    this.apiUrl,
  });

  final String provider;
  final String entityType;
  final String providerItemId;
  final String? siteUrl;
  final String? apiUrl;

  factory AdminProviderLink.fromJson(Map<String, dynamic> json) {
    return AdminProviderLink(
      provider: json['provider'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      siteUrl: json['site_url'] as String?,
      apiUrl: json['api_url'] as String?,
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parts = value.split('-');
  if (parts.length == 3) {
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year != null && month != null && day != null) {
      return DateTime.utc(year, month, day);
    }
  }
  return DateTime.tryParse(value)?.toUtc();
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

String _shortModelId(String id) => id.length <= 8 ? id : id.substring(0, 8);
