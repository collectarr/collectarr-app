class ComicDetail {
  const ComicDetail({
    required this.id,
    required this.kind,
    required this.title,
    required this.editions,
    this.itemNumber,
    this.sortKey,
    this.synopsis,
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.publisher,
    this.barcode,
    this.coverDate,
    this.storeDate,
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.providerLinks = const [],
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? sortKey;
  final String? synopsis;
  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? volumeStartYear;
  final String? publisher;
  final String? barcode;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final List<ComicCredit> creators;
  final List<ComicCredit> characters;
  final List<ComicCredit> storyArcs;
  final List<ComicProviderLink> providerLinks;
  final List<ComicEdition> editions;

  ComicEdition? get primaryEdition => editions.isEmpty ? null : editions.first;

  ComicVariant? get primaryVariant {
    for (final edition in editions) {
      final primary = edition.primaryVariant;
      if (primary != null) {
        return primary;
      }
    }
    return null;
  }

  String? get displayCoverUrl =>
      primaryVariant?.thumbnailImageUrl ?? primaryVariant?.coverImageUrl;

  factory ComicDetail.fromJson(Map<String, dynamic> json) {
    return ComicDetail(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      sortKey: json['sort_key'] as String?,
      synopsis: json['synopsis'] as String?,
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
      volumeStartYear: json['volume_start_year'] as int?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      coverDate: ComicEdition.parseDate(json['cover_date'] as String?),
      storeDate: ComicEdition.parseDate(json['store_date'] as String?),
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      creators: [
        for (final credit in (json['creators'] as List<dynamic>? ?? []))
          ComicCredit.fromJson(credit as Map<String, dynamic>),
      ],
      characters: [
        for (final credit in (json['characters'] as List<dynamic>? ?? []))
          ComicCredit.fromJson(credit as Map<String, dynamic>),
      ],
      storyArcs: [
        for (final credit in (json['story_arcs'] as List<dynamic>? ?? []))
          ComicCredit.fromJson(credit as Map<String, dynamic>),
      ],
      providerLinks: [
        for (final link in (json['provider_links'] as List<dynamic>? ?? []))
          ComicProviderLink.fromJson(link as Map<String, dynamic>),
      ],
      editions: [
        for (final edition in (json['editions'] as List<dynamic>? ?? []))
          ComicEdition.fromJson(edition as Map<String, dynamic>),
      ],
    );
  }
}

class ComicEdition {
  const ComicEdition({
    required this.id,
    required this.title,
    required this.variants,
    this.format,
    this.publisher,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadataJson,
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadataJson;
  final List<ComicVariant> variants;

  Map<String, dynamic>? get sourceMetadata {
    final source = metadataJson?['source'];
    return source is Map<String, dynamic> ? source : null;
  }

  ComicVariant? get primaryVariant {
    for (final variant in variants) {
      if (variant.isPrimary) {
        return variant;
      }
    }
    return variants.isEmpty ? null : variants.first;
  }

  factory ComicEdition.fromJson(Map<String, dynamic> json) {
    return ComicEdition(
      id: json['id'] as String,
      title: json['title'] as String,
      format: json['format'] as String?,
      publisher: json['publisher'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      language: json['language'] as String?,
      region: json['region'] as String?,
      releaseDate: parseDate(json['release_date'] as String?),
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadataJson: json['metadata_json'] as Map<String, dynamic>?,
      variants: [
        for (final variant in (json['variants'] as List<dynamic>? ?? []))
          ComicVariant.fromJson(variant as Map<String, dynamic>),
      ],
    );
  }

  static DateTime? parseDate(String? value) {
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
}

class ComicVariant {
  const ComicVariant({
    required this.id,
    required this.name,
    required this.isPrimary,
    this.sku,
    this.barcode,
    this.isbn,
    this.variantType,
    this.region,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.description,
    this.physicalFormat,
    this.physicalFormatLabel,
  });

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? variantType;
  final String? region;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? description;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;

  factory ComicVariant.fromJson(Map<String, dynamic> json) {
    return ComicVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isbn: json['isbn'] as String?,
      variantType: json['variant_type'] as String?,
      region: json['region'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      description: json['description'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class ComicCredit {
  const ComicCredit({
    required this.name,
    this.role,
    this.apiDetailUrl,
    this.siteDetailUrl,
    this.aliases = const [],
    this.description,
    this.imageUrl,
    this.firstAppearanceItemId,
    this.ordinal,
    this.publisher,
  });

  final String name;
  final String? role;
  final String? apiDetailUrl;
  final String? siteDetailUrl;
  final List<String> aliases;
  final String? description;
  final String? imageUrl;
  final String? firstAppearanceItemId;
  final int? ordinal;
  final String? publisher;

  factory ComicCredit.fromJson(Map<String, dynamic> json) {
    return ComicCredit(
      name: json['name'] as String,
      role: json['role'] as String?,
      apiDetailUrl: json['api_detail_url'] as String?,
      siteDetailUrl: json['site_detail_url'] as String?,
      aliases: [
        for (final alias in (json['aliases'] as List<dynamic>? ?? const []))
          alias.toString(),
      ],
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      firstAppearanceItemId: json['first_appearance_item_id'] as String?,
      ordinal: json['ordinal'] as int?,
      publisher: json['publisher'] as String?,
    );
  }
}

class ComicProviderLink {
  const ComicProviderLink({
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

  factory ComicProviderLink.fromJson(Map<String, dynamic> json) {
    return ComicProviderLink(
      provider: json['provider'] as String,
      entityType: json['entity_type'] as String,
      providerItemId: json['provider_item_id'] as String,
      siteUrl: json['site_url'] as String?,
      apiUrl: json['api_url'] as String?,
    );
  }
}
