import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> toJson() => {
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
      };

  factory BoardGameMetadata.fromJson(Map<String, dynamic> json) {
    return BoardGameMetadata(
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
    );
  }
}
