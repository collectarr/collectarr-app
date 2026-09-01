import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

typedef GameMetadata = GameCatalogMetadata;

@immutable
class GameCatalogMetadata implements LibraryKindMetadataRuntime {
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
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.game;

  @override
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
  final List<TrailerLink> links;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (platform != null) 'platform': platform,
        if (platforms.isNotEmpty) 'platforms': platforms,
        if (toySubtype != null) 'toy_subtype': toySubtype,
        if (toyType != null) 'toy_type': toyType,
        if (releaseRegion != null) 'release_region': releaseRegion,
        if (edition != null) 'edition': edition,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (developers.isNotEmpty) 'developers': developers,
        if (publishers.isNotEmpty) ...{
          'publishers': publishers,
          'publisher': publishers.first,
        },
        if (franchise != null) 'franchise': franchise,
        if (series != null) 'series': series,
        if (genres.isNotEmpty) 'genres': genres,
        if (ageRating != null) 'age_rating': ageRating,
        if (languages.isNotEmpty) 'languages': languages,
        'country': country,
        if (synopsis != null) 'synopsis': synopsis,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (barcode != null) 'barcode': barcode,
        if (priceChartingId != null) 'price_charting_id': priceChartingId,
        if (valuations != null) 'valuations': valuations!.toJson(),
        if (creators.isNotEmpty) 'creators': creators,
        if (links.isNotEmpty) ...{
          if (links.any((l) => l.isTrailerLink))
            'trailer_urls': links
                .where((l) => l.isTrailerLink)
                .map((e) => e.toJson())
                .toList(),
          if (links.any((l) => l.isExternalLink))
            'external_links': links
                .where((l) => l.isExternalLink)
                .map((e) => e.toJson())
                .toList(),
        },
      };

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
    List<TrailerLink>? links,
  }) {
    return GameCatalogMetadata(
      title: title ?? this.title,
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

    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
    ];

    return GameCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      platform: json['platform'] as String? ?? rawPlatforms.firstOrNull,
      platforms: rawPlatforms,
      toySubtype: (gameMap['toy_subtype'] ?? json['toy_subtype']) as String?,
      toyType: (gameMap['toy_type'] ?? json['toy_type']) as String?,
      releaseRegion: json['release_region'] as String?,
      edition: json['edition'] as String?,
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
