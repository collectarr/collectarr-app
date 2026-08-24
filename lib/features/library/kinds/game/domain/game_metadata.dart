import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

typedef GameMetadata = GameCatalogMetadata;

@immutable
class GameCatalogMetadata implements LibraryKindMetadataRuntime {
  const GameCatalogMetadata({
    required this.title,
    this.platform,
    this.releaseRegion,
    this.edition,
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
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.game;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? platform;
  final String? releaseRegion;
  final String? edition;
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

  Map<String, dynamic> toJson() => {
        'title': title,
        if (platform != null) 'platform': platform,
        if (releaseRegion != null) 'release_region': releaseRegion,
        if (edition != null) 'edition': edition,
        if (developers.isNotEmpty) 'developers': developers,
        if (publishers.isNotEmpty) 'publishers': publishers,
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
      };

  factory GameCatalogMetadata.fromJson(Map<String, dynamic> json) {
    return GameCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      platform: json['platform'] as String?,
      releaseRegion: json['release_region'] as String?,
      edition: json['edition'] as String?,
      developers: (json['developers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      franchise: json['franchise'] as String?,
      series: json['series'] as String?,
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
    );
  }
}
