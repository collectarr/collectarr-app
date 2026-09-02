import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

typedef BoardGameCatalogMetadata = BoardGameMetadata;

@immutable
class BoardGameMetadata implements LibraryKindMetadataRuntime {
  const BoardGameMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.recommendedPlayers,
    this.bestPlayers,
    this.minPlaytimeMinutes,
    this.maxPlaytimeMinutes,
    this.minimumAge,
    this.complexityWeight,
    this.designers = const [],
    this.artists = const [],
    this.publishers = const [],
    this.mechanics = const [],
    this.categories = const [],
    this.families = const [],
    this.themes = const [],
    this.expansions = const [],
    this.expansionFor,
    this.languages = const [],
    this.bggRating,
    this.bggRatingCount,
    this.bggRank,
    this.series,
    this.seriesTitle,
    this.itemNumber,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.barcode,
    this.variant,
    this.creators = const [],
    this.links = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.boardgame;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final String? recommendedPlayers;
  final String? bestPlayers;
  final int? minPlaytimeMinutes;
  final int? maxPlaytimeMinutes;
  final int? minimumAge;
  final double? complexityWeight;
  final List<String> designers;
  final List<String> artists;
  final List<String> publishers;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> themes;
  final List<String> expansions;
  final String? expansionFor;
  final List<String> languages;
  final double? bggRating;
  final int? bggRatingCount;
  final int? bggRank;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final String? itemNumber;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? barcode;
  final String? variant;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLink> links;
    final Map<String, dynamic> rawPayload;

  Map<String, dynamic> toJson() => {
      ...rawPayload,
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (yearPublished != null) 'year_published': yearPublished,
        if (minPlayers != null) 'min_players': minPlayers,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (recommendedPlayers != null)
          'recommended_players': recommendedPlayers,
        if (bestPlayers != null) 'best_players': bestPlayers,
        if (minPlaytimeMinutes != null)
          'min_playtime_minutes': minPlaytimeMinutes,
        if (maxPlaytimeMinutes != null)
          'max_playtime_minutes': maxPlaytimeMinutes,
        if (minimumAge != null) 'minimum_age': minimumAge,
        if (complexityWeight != null) 'complexity_weight': complexityWeight,
        if (designers.isNotEmpty) 'designers': designers,
        if (artists.isNotEmpty) 'artists': artists,
        if (publishers.isNotEmpty) 'publishers': publishers,
        if (mechanics.isNotEmpty) 'mechanics': mechanics,
        if (categories.isNotEmpty) 'categories': categories,
        if (families.isNotEmpty) 'families': families,
        if (themes.isNotEmpty) 'themes': themes,
        if (expansions.isNotEmpty) 'expansions': expansions,
        if (expansionFor != null) 'expansion_for': expansionFor,
        if (languages.isNotEmpty) 'languages': languages,
        if (bggRating != null) 'bgg_rating': bggRating,
        if (bggRatingCount != null) 'bgg_rating_count': bggRatingCount,
        if (bggRank != null) 'bgg_rank': bggRank,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (series != null && series!.hasData) ...{
          'series': series!.toJson(),
          ...series!.toJson(),
        },
        if (itemNumber != null) 'item_number': itemNumber,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant': variant,
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

  BoardGameCatalogMetadata copyWith({
    String? title,
    String? originalTitle,
    String? synopsis,
    int? yearPublished,
    int? minPlayers,
    int? maxPlayers,
    String? recommendedPlayers,
    String? bestPlayers,
    int? minPlaytimeMinutes,
    int? maxPlaytimeMinutes,
    int? minimumAge,
    double? complexityWeight,
    List<String>? designers,
    List<String>? artists,
    List<String>? publishers,
    List<String>? mechanics,
    List<String>? categories,
    List<String>? families,
    List<String>? themes,
    List<String>? expansions,
    String? expansionFor,
    List<String>? languages,
    double? bggRating,
    int? bggRatingCount,
    int? bggRank,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
    String? itemNumber,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? barcode,
    String? variant,
    List<Map<String, dynamic>>? creators,
    List<TrailerLink>? links,
  }) {
    return BoardGameCatalogMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      originalTitle: originalTitle ?? this.originalTitle,
      synopsis: synopsis ?? this.synopsis,
      yearPublished: yearPublished ?? this.yearPublished,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      recommendedPlayers: recommendedPlayers ?? this.recommendedPlayers,
      bestPlayers: bestPlayers ?? this.bestPlayers,
      minPlaytimeMinutes: minPlaytimeMinutes ?? this.minPlaytimeMinutes,
      maxPlaytimeMinutes: maxPlaytimeMinutes ?? this.maxPlaytimeMinutes,
      minimumAge: minimumAge ?? this.minimumAge,
      complexityWeight: complexityWeight ?? this.complexityWeight,
      designers: designers ?? this.designers,
      artists: artists ?? this.artists,
      publishers: publishers ?? this.publishers,
      mechanics: mechanics ?? this.mechanics,
      categories: categories ?? this.categories,
      families: families ?? this.families,
      themes: themes ?? this.themes,
      expansions: expansions ?? this.expansions,
      expansionFor: expansionFor ?? this.expansionFor,
      languages: languages ?? this.languages,
      bggRating: bggRating ?? this.bggRating,
      bggRatingCount: bggRatingCount ?? this.bggRatingCount,
      bggRank: bggRank ?? this.bggRank,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      itemNumber: itemNumber ?? this.itemNumber,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      creators: creators ?? this.creators,
      links: links ?? this.links,
    );
  }

  factory BoardGameMetadata.fromJson(Map<String, dynamic> json) {
    final seriesRaw = json['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : null;
    final resolvedSeriesTitle =
        (json['series_title'] ?? series?.seriesTitle) as String?;

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
    ];

    return BoardGameMetadata(
      rawPayload: Map<String, dynamic>.from(json),
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      yearPublished:
          json['year_published'] as int? ?? json['release_year'] as int?,
      minPlayers: json['min_players'] as int?,
      maxPlayers: json['max_players'] as int?,
      recommendedPlayers: json['recommended_players'] as String?,
      bestPlayers: json['best_players'] as String?,
      minPlaytimeMinutes: json['min_playtime_minutes'] as int?,
      maxPlaytimeMinutes: json['max_playtime_minutes'] as int?,
      minimumAge: json['minimum_age'] as int? ?? json['min_age'] as int?,
      complexityWeight: (json['complexity_weight'] as num?)?.toDouble() ??
          (json['weight'] as num?)?.toDouble(),
      designers: (json['designers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mechanics: (json['mechanics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      families: (json['families'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expansions: (json['expansions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expansionFor: json['expansion_for'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      bggRating: (json['bgg_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble(),
      bggRatingCount: json['bgg_rating_count'] as int? ??
          json['rating_count'] as int? ??
          json['users_rated'] as int?,
      bggRank: json['bgg_rank'] as int? ?? json['rank'] as int?,
      series: series ??
          (resolvedSeriesTitle != null
              ? CatalogSeriesDetailsDto(seriesTitle: resolvedSeriesTitle)
              : null),
      seriesTitle: resolvedSeriesTitle,
      itemNumber: (json['item_number'] ?? json['issue_number']) as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: (json['publisher'] ??
          ((json['publishers'] as List?)?.isNotEmpty == true
              ? (json['publishers'] as List).first.toString()
              : null)) as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      creators: rawCreators,
      links: rawLinks,
    );
  }
}
