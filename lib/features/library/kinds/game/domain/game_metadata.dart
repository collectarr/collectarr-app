import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

@immutable
class GameCatalogMetadata implements JsonEncodable {
  const GameCatalogMetadata({
    required this.title,
    this.platform,
    this.platforms = const [],
    this.toySubtype,
    this.toyType,
    this.releaseRegion,
    this.edition,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.developers = const [],
    this.publishers = const [],
    this.franchise,
    this.series,
    this.genres = const [],
    this.ageRating,
    this.languages = const [],
    this.country = 'US',
    this.synopsis,
    this.releaseDate,
    this.barcode,
    this.priceChartingId,
    this.valuations,
    this.creators = const [],
    this.links = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.game;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? platform;
  final List<String> platforms;
  final String? toySubtype;
  final String? toyType;
  final String? releaseRegion;
  final String? edition;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<String> developers;
  final List<String> publishers;
  final String? franchise;
  final String? series;
  final List<String> genres;
  final String? ageRating;
  final List<String> languages;
  final String country;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? barcode;
  final String? priceChartingId;
  final GameValuationSet? valuations;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLinkDto> links;
  final Map<String, dynamic> rawPayload;

  @override
  Map<String, dynamic> toJson() {
    final aliases = _rawList('search_aliases');
    final identifiers = _rawList('identifiers');
    final companyRoles = _rawList('company_roles');
    final seriesTags = _rawList('series_tags');
    final externalLinks = [
      ...links
          .where((link) => link.isExternalLink)
          .map((link) => link.toJson()),
    ];
    final trailers = [
      ...links.where((link) => link.isTrailerLink).map((link) => link.toJson()),
    ];
    return {
      'title': title,
      if (sortKey case final value?) 'sort_key': value,
      if (_rawText('localized_title') case final value?)
        'localized_title': value,
      if (_rawText('original_title') case final value?) 'original_title': value,
      if (_rawText('title_extension') case final value?)
        'title_extension': value,
      if (_rawText('subtitle') case final value?) 'subtitle': value,
      if (aliases.isNotEmpty) 'search_aliases': aliases,
      if (synopsis != null) 'synopsis': synopsis,
      if (_rawText('description') case final value?) 'description': value,
      if (_rawText('plot_summary') case final value?) 'plot_summary': value,
      if (_rawText('plot_description') case final value?)
        'plot_description': value,
      if (ageRating != null) 'age_rating': ageRating,
      if (_rawText('audience_rating') case final value?)
        'audience_rating': value,
      if (barcode != null) 'barcode': barcode,
      if (_rawText('catalog_number') case final value?) 'catalog_number': value,
      if (companyRoles.isNotEmpty) 'company_roles': companyRoles,
      if (_rawMaps('contributors') case final values when values.isNotEmpty)
        'contributors': values,
      if (country.isNotEmpty) 'country': country,
      if (_rawText('cover_image_url') case final value?)
        'cover_image_url': value,
      if (creators.isNotEmpty) 'creators': creators,
      if (developers.isNotEmpty) 'developers': developers,
      if (edition != null) 'edition_title': edition,
      if (externalLinks.isNotEmpty) 'external_links': externalLinks,
      if (genres.isNotEmpty) 'genres': genres,
      if (identifiers.isNotEmpty) 'identifiers': identifiers,
      if (_rawText('item_number') case final value?) 'item_number': value,
      if (languages.firstOrNull case final value?) 'language': value,
      if (physicalFormat case final value?) 'physical_format': value,
      if (platforms.isNotEmpty) 'platforms': platforms,
      if (publishers.firstOrNull case final value?) 'publisher': value,
      if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
      if (releaseRegion != null) 'release_region': releaseRegion,
      if (_rawText('release_status') case final value?) 'release_status': value,
      if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
      if (series != null) 'series_title': series,
      if (trailers.isNotEmpty) 'trailer_urls': trailers,
      if (_rawText('thumbnail_image_url') case final value?)
        'thumbnail_image_url': value,
      if (_rawText('variant_name') case final value?) 'variant_name': value,
    };
  }

  String? _rawText(String key) {
    final value = rawPayload[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get sortKey => _rawText('sort_key');

  List<String> _rawList(String key) =>
      (rawPayload[key] as List?)?.map((value) => value.toString()).toList() ??
      const [];

  List<Map<String, dynamic>> _rawMaps(String key) => [
        for (final entry in rawPayload[key] as List? ?? const [])
          if (entry is Map) Map<String, dynamic>.from(entry),
      ];

  GameCatalogMetadata copyWith({
    String? title,
    String? platform,
    List<String>? platforms,
    String? toySubtype,
    String? toyType,
    String? releaseRegion,
    String? edition,
    String? physicalFormat,
    String? physicalFormatLabel,
    List<String>? developers,
    List<String>? publishers,
    String? franchise,
    String? series,
    List<String>? genres,
    String? ageRating,
    List<String>? languages,
    String? country,
    String? synopsis,
    DateTime? releaseDate,
    String? barcode,
    String? priceChartingId,
    GameValuationSet? valuations,
    List<Map<String, dynamic>>? creators,
    List<TrailerLinkDto>? links,
  }) {
    return GameCatalogMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      platform: platform ?? this.platform,
      platforms: platforms ?? this.platforms,
      toySubtype: toySubtype ?? this.toySubtype,
      toyType: toyType ?? this.toyType,
      releaseRegion: releaseRegion ?? this.releaseRegion,
      edition: edition ?? this.edition,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      developers: developers ?? this.developers,
      publishers: publishers ?? this.publishers,
      franchise: franchise ?? this.franchise,
      series: series ?? this.series,
      genres: genres ?? this.genres,
      ageRating: ageRating ?? this.ageRating,
      languages: languages ?? this.languages,
      country: country ?? this.country,
      synopsis: synopsis ?? this.synopsis,
      releaseDate: releaseDate ?? this.releaseDate,
      barcode: barcode ?? this.barcode,
      priceChartingId: priceChartingId ?? this.priceChartingId,
      valuations: valuations ?? this.valuations,
      creators: creators ?? this.creators,
      links: links ?? this.links,
    );
  }

  factory GameCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
    final gameMap = (json['game'] is Map)
        ? Map<String, dynamic>.from(json['game'] as Map)
        : json;
    final rawPlatforms = (json['platforms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (gameMap['platforms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (json['platform'] != null
            ? <String>[json['platform'].toString()]
            : const <String>[]);

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<Object?, Object?>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    final rawLinks = <TrailerLinkDto>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) =>
                  TrailerLinkDto.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLinkDto>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) =>
                  TrailerLinkDto.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLinkDto>[]),
    ];

    return GameCatalogMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      platform: json['platform'] as String? ?? rawPlatforms.firstOrNull,
      platforms: rawPlatforms,
      toySubtype: (gameMap['toy_subtype'] ?? json['toy_subtype']) as String?,
      toyType: (gameMap['toy_type'] ?? json['toy_type']) as String?,
      releaseRegion: json['release_region'] as String?,
      edition: json['edition_title'] as String?,
      physicalFormat:
          (json['physical_format'] ?? gameMap['physical_format']) as String?,
      physicalFormatLabel: (json['physical_format_label'] ??
          gameMap['physical_format_label']) as String?,
      developers: (json['developers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['publisher'] != null
              ? <String>[json['publisher'].toString()]
              : const []),
      franchise: json['franchise'] as String?,
      series: json['series'] is Map
          ? (json['series'] as Map)['series_title'] as String?
          : (json['series'] as String? ?? json['series_title'] as String?),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ageRating: json['age_rating'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: (json['country'] as String?) ?? 'US',
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      barcode: json['barcode'] as String?,
      priceChartingId: json['price_charting_id'] as String?,
      valuations: json['valuations'] != null
          ? GameValuationSet.fromJson(
              json['valuations'] as Map<String, dynamic>)
          : null,
      creators: rawCreators,
      links: rawLinks,
    );
  }
}
