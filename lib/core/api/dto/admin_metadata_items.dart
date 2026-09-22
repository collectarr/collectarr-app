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
    this.canonicalFieldValues = const <String, dynamic>{},
    this.itemNumber,
    this.providerLinks = const [],
    this.editions = const [],
  });

  final String id;
  final String kind;
  final String title;

  /// Uninterpreted canonical field values from the Admin transport response.
  /// Kind contributors interpret these values; the API DTO keeps the payload
  /// opaque so it does not become a second field registry.
  final Map<String, dynamic> canonicalFieldValues;
  final String? itemNumber;
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
      canonicalFieldValues: {
        if (json['normalized'] is Map)
          ...(json['normalized'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        for (final entry in json.entries)
          if (entry.key != 'normalized' && entry.value != null)
            entry.key: entry.value,
      },
      itemNumber: json['item_number'] as String?,
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
    this.releaseDateParts,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.variants = const [],
  });

  final String id;
  final String title;
  final String? publisher;
  final DateTime? releaseDate;
  final PartialDate? releaseDateParts;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<AdminVariant> variants;

  String? get formatLabel => physicalFormatLabel ?? physicalFormat;

  factory AdminEdition.fromJson(Map<String, dynamic> json) {
    return AdminEdition(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      releaseDateParts: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      ),
      releaseDate: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      )?.asDateTime,
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
  });

  final String id;
  final String name;
  final bool isPrimary;
  final String? variantType;
  final String? barcode;

  String? get identifierCode => barcode;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? physicalFormat;
  final String? physicalFormatLabel;

  String? get formatLabel => physicalFormatLabel ?? physicalFormat;

  String get coverStatus {
    if (coverImageUrl == null && thumbnailImageUrl == null) {
      return 'missing';
    }
    return 'external_url';
  }

  String? get coverStorage => null;
  String? get coverPolicy => null;
  String? get coverSourceUrl => null;

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

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

String _shortModelId(String id) => id.length <= 8 ? id : id.substring(0, 8);
