class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.seasonNumber,
    this.episodeNumber,
    this.runtimeMinutes,
    this.trackCount,
    this.tracks,
    this.catalogNumber,
    this.creators,
    this.characters,
    this.storyArcs,
    this.platforms,
    this.genres,
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.country,
    this.releaseStatus,
    this.language,
    this.ageRating,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData; // base64-encoded processed image bytes
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? runtimeMinutes;
  final int? trackCount;
  final List<Map<String, dynamic>>? tracks;
  final String? catalogNumber;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? platforms;
  final List<String>? genres;
  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? country;
  final String? releaseStatus;
  final String? language;
  final String? ageRating;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;

  Map<String, dynamic> toSyncPayload() {
    return {
      'snapshot_version': 1,
      'kind': kind,
      'title': title,
      'item_number': itemNumber,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      'edition_title': editionTitle,
      'physical_format': physicalFormat,
      'physical_format_label': physicalFormatLabel,
      'publisher': publisher,
      'release_date': releaseDate?.toUtc().toIso8601String(),
      'release_year': releaseYear,
      'barcode': barcode,
      'variant': variant,
      'series_id': seriesId,
      'series_title': seriesTitle,
      'volume_name': volumeName,
      'volume_number': volumeNumber,
      'volume_start_year': volumeStartYear,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'runtime_minutes': runtimeMinutes,
      'catalog_number': catalogNumber,
      'platforms': platforms,
      'release_status': releaseStatus,
    };
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      releaseYear: json['release_year'] as int?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
      volumeStartYear: json['volume_start_year'] as int?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      runtimeMinutes: json['runtime_minutes'] as int?,
      trackCount: json['track_count'] as int?,
      tracks: (json['tracks'] as List?)
          ?.cast<Map<String, dynamic>>()
          .toList(growable: false),
      catalogNumber: json['catalog_number'] as String?,
      creators: (json['creators'] as List?)
          ?.cast<Map<String, dynamic>>()
          .toList(growable: false),
      characters: (json['characters'] as List?)?.cast<String>().toList(growable: false),
      storyArcs: (json['story_arcs'] as List?)?.cast<String>().toList(growable: false),
      platforms: (json['platforms'] as List?)?.cast<String>().toList(growable: false),
      genres: (json['genres'] as List?)?.cast<String>().toList(growable: false),
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      country: json['country'] as String?,
      releaseStatus: json['release_status'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
      imprint: json['imprint'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
