import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

@immutable
class TvPersonCredit {
  const TvPersonCredit({
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

  factory TvPersonCredit.fromJson(Map<String, dynamic> json) {
    return TvPersonCredit(
      name: (json['name'] as String?) ?? '',
      role: json['role'] as String?,
      character: json['character'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

@immutable
class TvEpisodeMetadata {
  const TvEpisodeMetadata({
    required this.number,
    required this.title,
    this.synopsis,
    this.airDate,
    this.runtimeMinutes,
    this.stillUrl,
  });

  final int number;
  final String title;
  final String? synopsis;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillUrl;

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        if (synopsis != null) 'synopsis': synopsis,
        if (airDate != null) 'air_date': airDate!.toIso8601String(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (stillUrl != null) 'still_url': stillUrl,
      };

  factory TvEpisodeMetadata.fromJson(Map<String, dynamic> json) {
    return TvEpisodeMetadata(
      number: json['number'] as int? ?? json['episode_number'] as int? ?? 1,
      title: (json['title'] as String?) ?? '',
      synopsis: (json['synopsis'] ?? json['overview']) as String?,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
      runtimeMinutes: json['runtime_minutes'] as int?,
      stillUrl: json['still_url'] as String?,
    );
  }
}

@immutable
class TvSeasonMetadata {
  const TvSeasonMetadata({
    required this.seasonNumber,
    this.title,
    this.airDate,
    this.episodeCount,
    this.episodes = const [],
  });

  final int seasonNumber;
  final String? title;
  final DateTime? airDate;
  final int? episodeCount;
  final List<TvEpisodeMetadata> episodes;

  Map<String, dynamic> toJson() => {
        'season_number': seasonNumber,
        if (title != null) 'title': title,
        if (airDate != null) 'air_date': airDate!.toIso8601String(),
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodes.isNotEmpty)
          'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  factory TvSeasonMetadata.fromJson(Map<String, dynamic> json) {
    return TvSeasonMetadata(
      seasonNumber: json['season_number'] as int? ?? 1,
      title: json['title'] as String?,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
      episodeCount: json['episode_count'] as int?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map(
                  (e) => TvEpisodeMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

@immutable
class TvPhysicalReleaseMetadata {
  const TvPhysicalReleaseMetadata({
    required this.id,
    required this.title,
    this.seasonOrSeriesBoxSet,
    this.region,
    this.discCount,
    this.packaging,
    this.hdrFormats = const [],
    this.audioTracks = const [],
    this.subtitles = const [],
    this.releaseDate,
    this.barcode,
  });

  final String id;
  final String title;
  final String? seasonOrSeriesBoxSet;
  final String? region;
  final int? discCount;
  final String? packaging;
  final List<String> hdrFormats;
  final List<String> audioTracks;
  final List<String> subtitles;
  final DateTime? releaseDate;
  final String? barcode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (seasonOrSeriesBoxSet != null)
          'season_or_series_box_set': seasonOrSeriesBoxSet,
        if (region != null) 'region': region,
        if (discCount != null) 'disc_count': discCount,
        if (packaging != null) 'packaging': packaging,
        if (hdrFormats.isNotEmpty) 'hdr_formats': hdrFormats,
        if (audioTracks.isNotEmpty) 'audio_tracks': audioTracks,
        if (subtitles.isNotEmpty) 'subtitles': subtitles,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (barcode != null) 'barcode': barcode,
      };

  factory TvPhysicalReleaseMetadata.fromJson(Map<String, dynamic> json) {
    return TvPhysicalReleaseMetadata(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      seasonOrSeriesBoxSet: json['season_or_series_box_set'] as String?,
      region: json['region'] as String?,
      discCount: json['disc_count'] as int?,
      packaging: json['packaging'] as String?,
      hdrFormats: (json['hdr_formats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      audioTracks: (json['audio_tracks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      barcode: json['barcode'] as String?,
    );
  }
}

typedef TvMetadata = TvSeriesMetadata;

@immutable
class TvSeriesMetadata implements LibraryKindMetadataRuntime {
  const TvSeriesMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.network,
    this.streamingService,
    this.productionCompanies = const [],
    this.country = 'US',
    this.originalLanguage = 'en',
    this.genres = const [],
    this.contentRating,
    this.seasonCount,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.cast = const [],
    this.crew = const [],
    this.seasons = const [],
    this.releases = const [],
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.tv;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final String? status;
  final String? network;
  final String? streamingService;
  final List<String> productionCompanies;
  final String country;
  final String originalLanguage;
  final List<String> genres;
  final String? contentRating;
  final int? seasonCount;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;
  final List<TvPersonCredit> cast;
  final List<TvPersonCredit> crew;
  final List<TvSeasonMetadata> seasons;
  final List<TvPhysicalReleaseMetadata> releases;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (firstAirDate != null)
          'first_air_date': firstAirDate!.toIso8601String(),
        if (lastAirDate != null)
          'last_air_date': lastAirDate!.toIso8601String(),
        if (status != null) 'status': status,
        if (network != null) 'network': network,
        if (streamingService != null) 'streaming_service': streamingService,
        if (productionCompanies.isNotEmpty)
          'production_companies': productionCompanies,
        'country': country,
        'original_language': originalLanguage,
        if (genres.isNotEmpty) 'genres': genres,
        if (contentRating != null) 'content_rating': contentRating,
        if (seasonCount != null) 'season_count': seasonCount,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodeRuntimeMinutes != null)
          'episode_runtime_minutes': episodeRuntimeMinutes,
        if (cast.isNotEmpty) 'cast': cast.map((e) => e.toJson()).toList(),
        if (crew.isNotEmpty) 'crew': crew.map((e) => e.toJson()).toList(),
        if (seasons.isNotEmpty)
          'seasons': seasons.map((e) => e.toJson()).toList(),
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
      };

  factory TvSeriesMetadata.fromJson(Map<String, dynamic> json) {
    return TvSeriesMetadata(
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      synopsis: (json['synopsis'] ?? json['overview']) as String?,
      firstAirDate: json['first_air_date'] != null
          ? DateTime.tryParse(json['first_air_date'] as String)
          : null,
      lastAirDate: json['last_air_date'] != null
          ? DateTime.tryParse(json['last_air_date'] as String)
          : null,
      status: json['status'] as String?,
      network: json['network'] as String?,
      streamingService: json['streaming_service'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: (json['country'] as String?) ?? 'US',
      originalLanguage: (json['original_language'] as String?) ?? 'en',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      contentRating: (json['content_rating'] ?? json['age_rating']) as String?,
      seasonCount: json['season_count'] as int?,
      episodeCount: json['episode_count'] as int?,
      episodeRuntimeMinutes: json['episode_runtime_minutes'] as int?,
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) => TvPersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => TvPersonCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => TvSeasonMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      releases: (json['releases'] as List<dynamic>?)
              ?.map((e) =>
                  TvPhysicalReleaseMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
