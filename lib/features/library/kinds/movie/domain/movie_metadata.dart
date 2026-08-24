import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

@immutable
class MoviePersonCredit {
  const MoviePersonCredit({
    required this.name,
    this.role,
    this.character,
    this.imageUrl,
  });

  final String name;
  final String? role;
  final String? character;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (role != null) 'role': role,
        if (character != null) 'character': character,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  factory MoviePersonCredit.fromJson(Map<String, dynamic> json) {
    return MoviePersonCredit(
      name: (json['name'] as String?) ?? '',
      role: json['role'] as String?,
      character: json['character'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

typedef MovieMetadata = MovieCatalogMetadata;

@immutable
class MovieCatalogMetadata implements LibraryKindMetadataRuntime {
  const MovieCatalogMetadata({
    required this.title,
    this.originalTitle,
    this.sortTitle,
    this.synopsis,
    this.genres = const [],
    this.runtimeMinutes,
    this.audienceRating,
    this.ageRating,
    this.studio,
    this.productionCompanies = const [],
    this.country,
    this.originalLanguage,
    this.releaseDate,
    this.directors = const [],
    this.writers = const [],
    this.producers = const [],
    this.cast = const [],
    this.crew = const [],
    this.trailerUrls = const [],
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.movie;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? originalTitle;
  final String? sortTitle;
  final String? synopsis;
  final List<String> genres;
  final int? runtimeMinutes;
  final String? audienceRating;
  final String? ageRating;
  final String? studio;
  final List<String> productionCompanies;
  final String? country;
  final String? originalLanguage;
  final DateTime? releaseDate;
  final List<MoviePersonCredit> directors;
  final List<MoviePersonCredit> writers;
  final List<MoviePersonCredit> producers;
  final List<MoviePersonCredit> cast;
  final List<MoviePersonCredit> crew;
  final List<String> trailerUrls;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (genres.isNotEmpty) 'genres': genres,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (ageRating != null) 'age_rating': ageRating,
        if (studio != null) 'studio': studio,
        if (productionCompanies.isNotEmpty)
          'production_companies': productionCompanies,
        if (country != null) 'country': country,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (directors.isNotEmpty)
          'directors': directors.map((e) => e.toJson()).toList(),
        if (writers.isNotEmpty)
          'writers': writers.map((e) => e.toJson()).toList(),
        if (producers.isNotEmpty)
          'producers': producers.map((e) => e.toJson()).toList(),
        if (cast.isNotEmpty) 'cast': cast.map((e) => e.toJson()).toList(),
        if (crew.isNotEmpty) 'crew': crew.map((e) => e.toJson()).toList(),
        if (trailerUrls.isNotEmpty) 'trailer_urls': trailerUrls,
      };

  factory MovieCatalogMetadata.fromJson(Map<String, dynamic> json) {
    return MovieCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: json['synopsis'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      runtimeMinutes: json['runtime_minutes'] as int?,
      audienceRating: json['audience_rating'] as String?,
      ageRating: json['age_rating'] as String?,
      studio: json['studio'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: json['country'] as String?,
      originalLanguage: json['original_language'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      directors: (json['directors'] as List<dynamic>?)
              ?.map(
                  (e) => MoviePersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      writers: (json['writers'] as List<dynamic>?)
              ?.map(
                  (e) => MoviePersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.map(
                  (e) => MoviePersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cast: (json['cast'] as List<dynamic>?)
              ?.map(
                  (e) => MoviePersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map(
                  (e) => MoviePersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trailerUrls: (json['trailer_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

@immutable
class MovieReleaseMetadata {
  const MovieReleaseMetadata({
    required this.id,
    required this.title,
    this.physicalFormat,
    this.region,
    this.distributor,
    this.packaging,
    this.discCount,
    this.edition,
    this.subtitles = const [],
    this.audioTracks = const [],
    this.hdrFormats = const [],
    this.screenRatio,
    this.colorFormat,
    this.layers,
    this.extras,
    this.releaseDate,
    this.boxSetName,
    this.barcode,
  });

  final String id;
  final String title;
  final String? physicalFormat;
  final String? region;
  final String? distributor;
  final String? packaging;
  final int? discCount;
  final String? edition;
  final List<String> subtitles;
  final List<String> audioTracks;
  final List<String> hdrFormats;
  final String? screenRatio;
  final String? colorFormat;
  final String? layers;
  final String? extras;
  final DateTime? releaseDate;
  final String? boxSetName;
  final String? barcode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (region != null) 'region': region,
        if (distributor != null) 'distributor': distributor,
        if (packaging != null) 'packaging': packaging,
        if (discCount != null) 'disc_count': discCount,
        if (edition != null) 'edition': edition,
        if (subtitles.isNotEmpty) 'subtitles': subtitles,
        if (audioTracks.isNotEmpty) 'audio_tracks': audioTracks,
        if (hdrFormats.isNotEmpty) 'hdr_formats': hdrFormats,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (colorFormat != null) 'color_format': colorFormat,
        if (layers != null) 'layers': layers,
        if (extras != null) 'extras': extras,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (boxSetName != null) 'box_set_name': boxSetName,
        if (barcode != null) 'barcode': barcode,
      };

  factory MovieReleaseMetadata.fromJson(Map<String, dynamic> json) {
    return MovieReleaseMetadata(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      physicalFormat: json['physical_format'] as String?,
      region: json['region'] as String?,
      distributor: json['distributor'] as String?,
      packaging: json['packaging'] as String?,
      discCount: json['disc_count'] as int?,
      edition: json['edition'] as String?,
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      audioTracks: (json['audio_tracks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hdrFormats: (json['hdr_formats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      screenRatio: json['screen_ratio'] as String?,
      colorFormat: json['color_format'] as String?,
      layers: json['layers'] as String?,
      extras: json['extras'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      boxSetName: json['box_set_name'] as String?,
      barcode: json['barcode'] as String?,
    );
  }
}
