class ComicDetail {
  const ComicDetail({
    required this.id,
    required this.kind,
    required this.title,
    required this.editions,
    this.itemNumber,
    this.sortKey,
    this.synopsis,
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? sortKey;
  final String? synopsis;
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
    this.releaseDate,
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? isbn;
  final String? upc;
  final String? language;
  final DateTime? releaseDate;
  final List<ComicVariant> variants;

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
      releaseDate: _parseDate(json['release_date'] as String?),
      variants: [
        for (final variant in (json['variants'] as List<dynamic>? ?? []))
          ComicVariant.fromJson(variant as Map<String, dynamic>),
      ],
    );
  }

  static DateTime? _parseDate(String? value) {
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
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String id;
  final String name;
  final String? sku;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final bool isPrimary;

  factory ComicVariant.fromJson(Map<String, dynamic> json) {
    return ComicVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}
