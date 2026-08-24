import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
    this.language,
    this.releaseDate,
    this.directors = const [],
    this.writers = const [],
    this.producers = const [],
    this.cast = const [],
    this.crew = const [],
    this.trailerUrls = const [],
    this.editionTitle,
    this.barcode,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.variant,
    this.itemNumber,
    this.series,
    this.seriesTitle,
    this.video,
    this.audioTracks,
    this.subtitles,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.layers,
    this.creators = const [],
    this.links = const [],
    this.releases = const [],
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
  final String? language;
  final DateTime? releaseDate;
  final List<MoviePersonCredit> directors;
  final List<MoviePersonCredit> writers;
  final List<MoviePersonCredit> producers;
  final List<MoviePersonCredit> cast;
  final List<MoviePersonCredit> crew;
  final List<String> trailerUrls;
  final String? editionTitle;
  final String? barcode;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? variant;
  final String? itemNumber;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final VideoCatalogDetailsDto? video;
  final String? audioTracks;
  final String? subtitles;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? layers;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLink> links;
  final List<MovieReleaseMetadata> releases;

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
        if (language != null) 'language': language,
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
        if (editionTitle != null) 'edition_title': editionTitle,
        if (barcode != null) 'barcode': barcode,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (variant != null) 'variant': variant,
        if (itemNumber != null) 'item_number': itemNumber,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (series != null && series!.hasData) ...{
          'series': series!.toJson(),
          ...series!.toJson(),
        },
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (color != null) 'color': color,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (layers != null) 'layers': layers,
        if (video != null && video!.hasData) ...{
          'video': video!.toJson(),
          ...video!.toJson(),
        },
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
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
      };

  factory MovieCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
    ];

    final rawReleases = (json['releases'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) =>
                MovieReleaseMetadata.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <MovieReleaseMetadata>[];

    final rawTrailerUrls = (json['trailer_urls'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    final seriesRaw = json['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : CatalogSeriesDetailsDto.fromJson(json);
    final resolvedSeriesTitle =
        (json['series_title'] ?? series.seriesTitle) as String?;

    final videoRaw = json['video'];
    final video = videoRaw is Map
        ? VideoCatalogDetailsDto.fromJson(Map<String, dynamic>.from(videoRaw))
        : VideoCatalogDetailsDto.fromJson(json);

    final resolvedAudioTracks =
        (json['audio_tracks'] ?? video.audioTracks) as String?;
    final resolvedSubtitles = (json['subtitles'] ?? video.subtitles) as String?;
    final resolvedColor = (json['color'] ?? video.color) as String?;
    final resolvedNrDiscs =
        (json['nr_discs'] as num?)?.toInt() ?? video.nrDiscs;
    final resolvedScreenRatio =
        (json['screen_ratio'] ?? video.screenRatio) as String?;
    final resolvedLayers = (json['layers'] ?? video.layers) as String?;

    return MovieCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      runtimeMinutes:
          json['runtime_minutes'] as int? ?? video.runtimeMinutes,
      audienceRating: json['audience_rating'] as String?,
      ageRating: json['age_rating'] as String?,
      studio: json['studio'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: json['country'] as String?,
      originalLanguage: json['original_language'] as String?,
      language: json['language'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      directors: (json['directors'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      writers: (json['writers'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      cast: (json['cast'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      trailerUrls: rawTrailerUrls,
      editionTitle: json['edition_title'] as String?,
      barcode: json['barcode'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: (json['publisher'] ?? json['studio']) as String?,
      variant: json['variant'] as String?,
      itemNumber: (json['item_number'] ?? json['issue_number']) as String?,
      series: series.hasData ? series : null,
      seriesTitle: resolvedSeriesTitle,
      video: video,
      audioTracks: resolvedAudioTracks,
      subtitles: resolvedSubtitles,
      color: resolvedColor,
      nrDiscs: resolvedNrDiscs,
      screenRatio: resolvedScreenRatio,
      layers: resolvedLayers,
      creators: rawCreators,
      links: rawLinks,
      releases: rawReleases,
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
