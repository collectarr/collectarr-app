part of 'admin_metadata.dart';

// Provider, ingest, and preview models

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

class AdminMetadataProposalSummary {
  const AdminMetadataProposalSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  final int pending;
  final int approved;
  final int rejected;
  final int total;

  factory AdminMetadataProposalSummary.fromJson(Map<String, dynamic> json) {
    return AdminMetadataProposalSummary(
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class AdminMetadataProposal {
  const AdminMetadataProposal({
    required this.id,
    required this.provider,
    required this.query,
    required this.status,
    this.providerItemId,
    this.title,
    this.summary,
    this.imageUrl,
    this.metadataPayload,
  });

  final String id;
  final String provider;
  final String query;
  final String status;
  final String? providerItemId;
  final String? title;
  final String? summary;
  final String? imageUrl;
  final Map<String, dynamic>? metadataPayload;

  String get displayTitle {
    final title = this.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return query;
  }

  bool get isPending => status == 'pending';

  factory AdminMetadataProposal.fromJson(Map<String, dynamic> json) {
    final payload = json['metadata_payload'];
    return AdminMetadataProposal(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      providerItemId: json['provider_item_id']?.toString(),
      query: json['query']?.toString() ?? '',
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
      metadataPayload:
          payload is Map<String, dynamic> ? payload : const <String, dynamic>{},
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class AdminReleaseMediaMappingRule {
  const AdminReleaseMediaMappingRule({
    required this.id,
    required this.releaseType,
    required this.targetKind,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.provider,
    this.notes,
  });

  final String id;
  final String? provider;
  final String releaseType;
  final String targetKind;
  final int priority;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AdminReleaseMediaMappingRule.fromJson(Map<String, dynamic> json) {
    return AdminReleaseMediaMappingRule(
      id: json['id']?.toString() ?? '',
      provider: json['provider'] as String?,
      releaseType: json['release_type']?.toString() ?? '',
      targetKind: json['target_kind']?.toString() ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 100,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: _adminDateTimeFromJson(json['created_at']),
      updatedAt: _adminDateTimeFromJson(json['updated_at']),
    );
  }
}

class AdminReleaseMediaMappingRuleUpsert {
  const AdminReleaseMediaMappingRuleUpsert({
    required this.releaseType,
    required this.targetKind,
    required this.priority,
    required this.isActive,
    this.provider,
    this.notes,
  });

  final String? provider;
  final String releaseType;
  final String targetKind;
  final int priority;
  final bool isActive;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'release_type': releaseType.trim(),
      'target_kind': targetKind,
      'priority': priority,
      'is_active': isActive,
      'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    };
  }
}

class AdminProviderPrefillResolved {
  const AdminProviderPrefillResolved({
    required this.source,
    this.provider,
    this.kind,
    this.query,
    this.providerItemId,
    this.releaseType,
    this.matchedRule,
    this.notes = const <String>[],
  });

  final String source;
  final String? provider;
  final String? kind;
  final String? query;
  final String? providerItemId;
  final String? releaseType;
  final AdminReleaseMediaMappingRule? matchedRule;
  final List<String> notes;

  factory AdminProviderPrefillResolved.fromJson(Map<String, dynamic> json) {
    final ruleJson = json['matched_rule'];
    return AdminProviderPrefillResolved(
      source: json['source']?.toString() ?? 'manual',
      provider: json['provider'] as String?,
      kind: json['kind'] as String?,
      query: json['query'] as String?,
      providerItemId: json['provider_item_id'] as String?,
      releaseType: json['release_type'] as String?,
      matchedRule: ruleJson is Map<String, dynamic>
          ? AdminReleaseMediaMappingRule.fromJson(ruleJson)
          : null,
      notes: (json['notes'] as List<dynamic>? ?? const <dynamic>[])
          .map((entry) => entry.toString())
          .toList(growable: false),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool isActive;
  final bool isAdmin;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get label {
    final value = displayName?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return email;
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isAdmin: json['is_admin'] as bool? ?? false,
      role: json['role']?.toString() ?? 'viewer',
      createdAt: _adminDateTimeFromJson(json['created_at']),
      updatedAt: _adminDateTimeFromJson(json['updated_at']),
    );
  }
}

class AdminImageCacheStats {
  const AdminImageCacheStats({
    required this.totalEntries,
    required this.totalSizeBytes,
    required this.maxSizeBytes,
    required this.usagePercent,
    required this.mirroringEnabled,
    this.providers = const <String, int>{},
  });

  final int totalEntries;
  final int totalSizeBytes;
  final int maxSizeBytes;
  final double usagePercent;
  final bool mirroringEnabled;
  final Map<String, int> providers;

  factory AdminImageCacheStats.fromJson(Map<String, dynamic> json) {
    final providerMap = json['providers'];
    return AdminImageCacheStats(
      totalEntries: (json['total_entries'] as num?)?.toInt() ?? 0,
      totalSizeBytes: (json['total_size_bytes'] as num?)?.toInt() ?? 0,
      maxSizeBytes: (json['max_size_bytes'] as num?)?.toInt() ?? 0,
      usagePercent: (json['usage_percent'] as num?)?.toDouble() ?? 0,
      mirroringEnabled: json['mirroring_enabled'] as bool? ?? false,
      providers: providerMap is Map<String, dynamic>
          ? providerMap.map(
              (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
            )
          : const <String, int>{},
    );
  }
}

class AdminImageCachePurgeResult {
  const AdminImageCachePurgeResult({
    required this.deletedEntries,
    required this.freedBytes,
  });

  final int deletedEntries;
  final int freedBytes;

  factory AdminImageCachePurgeResult.fromJson(Map<String, dynamic> json) {
    return AdminImageCachePurgeResult(
      deletedEntries: (json['deleted_entries'] as num?)?.toInt() ?? 0,
      freedBytes: (json['freed_bytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProviderPreviewCredit {
  const ProviderPreviewCredit({required this.name, this.role, this.imageUrl});
  final String name;
  final String? role;
  final String? imageUrl;

  factory ProviderPreviewCredit.fromJson(Map<String, dynamic> json) {
    return ProviderPreviewCredit(
      name: json['name'] as String,
      role: json['role'] as String?,
      imageUrl: json['image_url'] as String?,
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
    this.publisher,
    this.editionTitle,
    this.editionFormat,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.releaseDate,
    this.barcode,
    this.isbn,
    this.variantName,
    this.coverImageUrl,
    this.series,
    this.publishing,
    this.video,
    this.music,
    this.game,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.genres = const [],
  });

  final String provider;
  final String providerItemId;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? publisher;
  final String? editionTitle;
  final String? editionFormat;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final DateTime? releaseDate;
  final String? barcode;
  final String? isbn;
  final String? variantName;
  final String? coverImageUrl;
  final CatalogSeriesDetails? series;
  final CatalogPublishingDetails? publishing;
  final VideoCatalogDetails? video;
  final MusicCatalogDetails? music;
  final GameCatalogDetails? game;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<ProviderPreviewCredit> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;

  int? get trackCount => music?.trackCount;
  List<CatalogTrack> get tracks => music?.tracks ?? const <CatalogTrack>[];

  factory AdminProviderPreview.fromJson(Map<String, dynamic> json) {
    final tracks = (json['tracks'] as List<dynamic>?)
            ?.map((e) => CatalogTrack.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const <CatalogTrack>[];
    final series = CatalogSeriesDetails(
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
      volumeStartYear: json['volume_start_year'] as int?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
    final publishing = CatalogPublishingDetails(
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      imprint: json['imprint'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
    );
    final video = VideoCatalogDetails(
      runtimeMinutes: json['runtime_minutes'] as int?,
    );
    final music = MusicCatalogDetails(
      trackCount: json['track_count'] as int?,
      tracks: tracks,
      catalogNumber: json['catalog_number'] as String?,
      releaseStatus: json['release_status'] as String?,
    );
    final game = GameCatalogDetails(
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
    );
    return AdminProviderPreview(
      provider: json['provider'] as String,
      providerItemId: json['provider_item_id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      publisher: json['publisher'] as String?,
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
      series: series.hasData ? series : null,
      publishing: publishing.hasData ? publishing : null,
      video: video.hasData ? video : null,
      music: music.hasData ? music : null,
      game: game.hasData ? game : null,
      country: json['country'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
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
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(growable: false) ??
          const [],
    );
  }
}

class AdminBatchHydrateResultItem {
  const AdminBatchHydrateResultItem({
    required this.providerItemId,
    required this.success,
    this.preview,
    this.error,
  });

  final String providerItemId;
  final bool success;
  final AdminProviderPreview? preview;
  final String? error;

  factory AdminBatchHydrateResultItem.fromJson(Map<String, dynamic> json) {
    final previewData = json['preview'] as Map<String, dynamic>?;
    return AdminBatchHydrateResultItem(
      providerItemId: json['provider_item_id'] as String,
      success: json['success'] as bool,
      preview: previewData != null
          ? AdminProviderPreview.fromJson(previewData)
          : null,
      error: json['error'] as String?,
    );
  }
}

class AdminBatchHydrateResult {
  const AdminBatchHydrateResult({
    required this.results,
    required this.total,
    required this.succeeded,
    required this.failed,
  });

  final List<AdminBatchHydrateResultItem> results;
  final int total;
  final int succeeded;
  final int failed;

  factory AdminBatchHydrateResult.fromJson(Map<String, dynamic> json) {
    return AdminBatchHydrateResult(
      results: (json['results'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AdminBatchHydrateResultItem.fromJson)
              .toList(growable: false) ??
          const <AdminBatchHydrateResultItem>[],
      total: json['total'] as int? ?? 0,
      succeeded: json['succeeded'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
    );
  }
}
