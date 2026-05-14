class AdminProviderStatus {
  const AdminProviderStatus({
    required this.name,
    required this.displayName,
    required this.kind,
    required this.status,
    required this.isConfigured,
    required this.supportsSearch,
    required this.supportsIngest,
    required this.requiresUserKey,
    required this.nonCommercialOnly,
    required this.allowsRedistribution,
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
  final String status;
  final bool isConfigured;
  final bool supportsSearch;
  final bool supportsIngest;
  final bool requiresUserKey;
  final bool nonCommercialOnly;
  final bool allowsRedistribution;
  final bool requiresAttribution;
  final String? licenseName;
  final String? termsUrl;
  final String? attributionUrl;
  final String? rateLimit;
  final String? cachePolicy;
  final String message;

  factory AdminProviderStatus.fromJson(Map<String, dynamic> json) {
    return AdminProviderStatus(
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      kind: json['kind'] as String? ?? 'comic',
      status: json['status'] as String? ?? 'unknown',
      isConfigured: json['is_configured'] as bool? ?? false,
      supportsSearch: json['supports_search'] as bool? ?? true,
      supportsIngest: json['supports_ingest'] as bool? ?? true,
      requiresUserKey: json['requires_user_key'] as bool? ?? false,
      nonCommercialOnly: json['non_commercial_only'] as bool? ?? false,
      allowsRedistribution: json['allows_redistribution'] as bool? ?? false,
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
  });

  final String kind;
  final String title;
  final String? itemNumber;
  final int count;
  final List<String> itemIds;

  String get displayTitle {
    if (itemNumber == null || itemNumber!.isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  factory AdminDuplicateCandidate.fromJson(Map<String, dynamic> json) {
    return AdminDuplicateCandidate(
      kind: json['kind'] as String? ?? 'comic',
      title: json['title'] as String? ?? '',
      itemNumber: json['item_number'] as String?,
      count: json['count'] as int? ?? 0,
      itemIds: [
        for (final id in (json['item_ids'] as List<dynamic>? ?? []))
          id.toString(),
      ],
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

  String? get displayCoverUrl =>
      primaryVariant?.thumbnailImageUrl ?? primaryVariant?.coverImageUrl;

  factory AdminMetadataItem.fromJson(Map<String, dynamic> json) {
    return AdminMetadataItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? 'comic',
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
    this.variants = const [],
    this.releases = const [],
  });

  final String id;
  final String title;
  final String? publisher;
  final DateTime? releaseDate;
  final List<AdminVariant> variants;
  final List<AdminRelease> releases;

  factory AdminEdition.fromJson(Map<String, dynamic> json) {
    return AdminEdition(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
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
