import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:flutter/foundation.dart';

class TrailerLinkDto {
  const TrailerLinkDto({
    required this.url,
    this.title,
    this.description,
    this.source,
    this.isAutomatic = true,
    this.kind = 'trailer',
  });

  final String url;
  final String? title;
  final String? description;
  final String? source;
  final bool isAutomatic;
  final String kind;

  bool get isExternalLink => kind == 'external' || kind == 'link';
  bool get isTrailerLink => !isExternalLink;

  factory TrailerLinkDto.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['type'])?.toString().toLowerCase();
    final source = json['source'] as String?;
    final inferredKind = rawKind ??
        ((source?.toLowerCase().contains('external') ?? false)
            ? 'external'
            : 'trailer');
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return TrailerLinkDto(
      url: (json['url'] ?? '').toString(),
      title: title ?? description,
      description: description ?? title,
      source: source,
      isAutomatic: json['is_automatic'] as bool? ?? true,
      kind: inferredKind,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
      'is_automatic': isAutomatic,
      'kind': kind,
    };
  }
}

@immutable
final class CatalogCommonDto {
  const CatalogCommonDto({
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.searchAliases,
    this.sortKey,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.releaseDate,
    this.releaseYear,
    this.trailerUrls = const <TrailerLinkDto>[],
    this.editions = const <CatalogEditionDto>[],
  });

  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final List<String>? searchAliases;
  final String? sortKey;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final DateTime? releaseDate;
  final int? releaseYear;
  final List<TrailerLinkDto> trailerUrls;
  final List<CatalogEditionDto> editions;

  String get resolvedDisplayTitle =>
      displayTitle ?? localizedTitle ?? originalTitle ?? title;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory CatalogCommonDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    }

    final rawAliases = json['search_aliases'] ?? json['aliases'];
    final aliases = (rawAliases as List<dynamic>?)
        ?.whereType<String>()
        .toList(growable: false);

    final rawTrailerUrls = (json['trailer_urls'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TrailerLinkDto.fromJson)
            .toList(growable: false) ??
        (json['trailers'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TrailerLinkDto.fromJson)
            .toList(growable: false);

    final rawExternalLinks = (json['external_links'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map((link) => TrailerLinkDto.fromJson({
              ...link,
              if (link['kind'] == null && link['type'] == null)
                'kind': 'external',
            }))
        .toList(growable: false);

    final allTrailers = [
      if (rawTrailerUrls != null) ...rawTrailerUrls,
      if (rawExternalLinks != null) ...rawExternalLinks,
    ];

    final rawEditions = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(CatalogEditionDto.fromJson)
            .toList(growable: false) ??
        const <CatalogEditionDto>[];

    return CatalogCommonDto(
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      searchAliases: aliases,
      sortKey: json['sort_key'] as String?,
      synopsis: (json['synopsis'] ?? json['overview'] ?? json['description'])
          as String?,
      coverImageUrl: (json['cover_image_url'] ??
          json['cover_url'] ??
          json['poster_url']) as String?,
      thumbnailImageUrl: (json['thumbnail_image_url'] ??
          json['thumbnail_url'] ??
          json['cover_thumbnail_url']) as String?,
      coverImageData: json['cover_image_data'] as String?,
      releaseDate: parseDate(
          json['release_date'] as String? ?? json['first_air_date'] as String?),
      releaseYear: json['release_year'] as int?,
      trailerUrls: allTrailers,
      editions: rawEditions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (displayTitle != null) 'display_title': displayTitle,
      if (localizedTitle != null) 'localized_title': localizedTitle,
      if (originalTitle != null) 'original_title': originalTitle,
      if (titleExtension != null) 'title_extension': titleExtension,
      if (searchAliases != null) 'search_aliases': searchAliases,
      if (sortKey != null) 'sort_key': sortKey,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      if (releaseDate != null)
        'release_date': releaseDate!.toUtc().toIso8601String(),
      if (releaseYear != null) 'release_year': releaseYear,
      if (trailerUrls.isNotEmpty)
        'trailer_urls': trailerUrls.map((t) => t.toJson()).toList(),
      if (editions.isNotEmpty)
        'editions': editions.map((e) => e.toJson()).toList(),
    };
  }
}
