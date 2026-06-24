part of 'admin_metadata.dart';

// Duplicate, metadata item, edition, variant, provider link models

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
    this.confidenceFactors = const <String>[],
    this.mergeWarnings = const <String>[],
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
  final List<String> confidenceFactors;
  final List<String> mergeWarnings;

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
      confidenceFactors: [
        for (final value
            in (json['confidence_factors'] as List<dynamic>? ?? []))
          value.toString(),
      ],
      mergeWarnings: [
        for (final value in (json['merge_warnings'] as List<dynamic>? ?? []))
          value.toString(),
      ],
    );
  }
}

class AdminMetadataItem {
  const AdminMetadataItem({
    required this.id,
    required this.kind,
    required this.title,
    this.originalTitle,
    this.localizedTitle,
    this.sortKey,
    this.searchAliases = const [],
    this.itemNumber,
    this.synopsis,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.publisher,
    this.barcode,
    this.series,
    this.publishing,
    this.coverDate,
    this.storeDate,
    this.video,
    this.music,
    this.genres = const [],
    this.platforms = const [],
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.titleExtension,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.trailerUrls = const [],
    this.externalLinks = const [],
    this.providerLinks = const [],
    this.editions = const [],
  });

  final String id;
  final String kind;
  final String title;
  final String? originalTitle;
  final String? localizedTitle;
  final String? sortKey;
  final List<String> searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final String? titleExtension;
  final String? publisher;
  final String? barcode;
  final CatalogSeriesDetails? series;
  final CatalogPublishingDetails? publishing;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final VideoCatalogDetails? video;
  final MusicCatalogDetails? music;
  final List<String> genres;
  final List<String> platforms;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<Map<String, dynamic>> creators;
  final List<Map<String, dynamic>> characters;
  final List<Map<String, dynamic>> storyArcs;
  final List<TrailerLink> trailerUrls;
  final List<TrailerLink> externalLinks;
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
      color: json['color'] as String?,
      nrDiscs: json['nr_discs'] as int?,
      screenRatio: json['screen_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      layers: json['layers'] as String?,
    );
    final music = MusicCatalogDetails(
      trackCount: json['track_count'] as int?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogTrack.fromJson)
              .toList(growable: false) ??
          const <CatalogTrack>[],
      catalogNumber: json['catalog_number'] as String?,
      releaseStatus: json['release_status'] as String?,
    );
    return AdminMetadataItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      sortKey: json['sort_key'] as String?,
      searchAliases: (json['search_aliases'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      crossover: json['crossover'] as String?,
      plotSummary: json['plot_summary'] as String?,
      plotDescription: json['plot_description'] as String?,
      titleExtension: json['title_extension'] as String?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      series: series.hasData ? series : null,
      publishing: publishing.hasData ? publishing : null,
      coverDate: _parseDate(json['cover_date'] as String?),
      storeDate: _parseDate(json['store_date'] as String?),
      video: video.hasData ? video : null,
      music: music.hasData ? music : null,
      genres: (json['genres'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      platforms: (json['platforms'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      country: json['country'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
      creators: (json['creators'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      characters: (json['characters'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      storyArcs: (json['story_arcs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      trailerUrls: ((json['trailer_urls'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TrailerLink.fromJson)
          .toList(growable: false)),
      externalLinks: ((json['external_links'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TrailerLink.fromJson)
          .toList(growable: false)),
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
  });

  final String id;
  final String title;
  final String? publisher;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<AdminVariant> variants;

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
