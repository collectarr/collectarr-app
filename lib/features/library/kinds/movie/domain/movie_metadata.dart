import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
    this.region,
    this.packaging,
    this.distributor,
    this.hdr,
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
    this.editions = const [],
    this.rawPayload = const <String, dynamic>{},
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
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? hdr;
  final String? variant;
  final String? itemNumber;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final Map<String, dynamic>? video;
  final String? audioTracks;
  final String? subtitles;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? layers;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLink> links;
  final List<MovieReleaseMetadata> releases;
  final List<CatalogEditionDto> editions;
  final Map<String, dynamic> rawPayload;

  /// Optional provider valuation preserved at the provider boundary.
  ///
  /// Movie providers do not share a common valuation contract, so the value
  /// remains an optional typed-domain projection of the normalized payload.
  int? get providerValueCents =>
      _movieIntValue(rawPayload['estimated_value_cents']) ??
      _movieIntValue(rawPayload['market_value_cents']) ??
      _movieIntValue(rawPayload['value_cents']);

  Map<String, dynamic> toJson() => {
        ...rawPayload,
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
        if (region != null) 'region': region,
        if (packaging != null) 'packaging': packaging,
        if (distributor != null) 'distributor': distributor,
        if (hdr != null) 'hdr': hdr,
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
        if (video != null && video!.isNotEmpty) ...{
          'video': video!,
          ...video!,
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
        if (editions.isNotEmpty)
          'editions': editions.map((e) => e.toJson()).toList(),
      };

  MovieCatalogMetadata copyWith({
    String? title,
    String? originalTitle,
    String? sortTitle,
    String? synopsis,
    List<String>? genres,
    int? runtimeMinutes,
    String? audienceRating,
    String? ageRating,
    String? studio,
    List<String>? productionCompanies,
    String? country,
    String? originalLanguage,
    String? language,
    DateTime? releaseDate,
    List<MoviePersonCredit>? directors,
    List<MoviePersonCredit>? writers,
    List<MoviePersonCredit>? producers,
    List<MoviePersonCredit>? cast,
    List<MoviePersonCredit>? crew,
    List<String>? trailerUrls,
    String? editionTitle,
    String? barcode,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? region,
    String? packaging,
    String? distributor,
    String? hdr,
    String? variant,
    String? itemNumber,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
    String? audioTracks,
    String? subtitles,
    String? color,
    int? nrDiscs,
    String? screenRatio,
    String? layers,
    Map<String, dynamic>? video,
    List<Map<String, dynamic>>? creators,
    List<TrailerLink>? links,
    List<MovieReleaseMetadata>? releases,
    List<CatalogEditionDto>? editions,
  }) {
    return MovieCatalogMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      originalTitle: originalTitle ?? this.originalTitle,
      sortTitle: sortTitle ?? this.sortTitle,
      synopsis: synopsis ?? this.synopsis,
      genres: genres ?? this.genres,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      audienceRating: audienceRating ?? this.audienceRating,
      ageRating: ageRating ?? this.ageRating,
      studio: studio ?? this.studio,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      country: country ?? this.country,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      language: language ?? this.language,
      releaseDate: releaseDate ?? this.releaseDate,
      directors: directors ?? this.directors,
      writers: writers ?? this.writers,
      producers: producers ?? this.producers,
      cast: cast ?? this.cast,
      crew: crew ?? this.crew,
      trailerUrls: trailerUrls ?? this.trailerUrls,
      editionTitle: editionTitle ?? this.editionTitle,
      barcode: barcode ?? this.barcode,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      hdr: hdr ?? this.hdr,
      variant: variant ?? this.variant,
      itemNumber: itemNumber ?? this.itemNumber,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitles: subtitles ?? this.subtitles,
      color: color ?? this.color,
      nrDiscs: nrDiscs ?? this.nrDiscs,
      screenRatio: screenRatio ?? this.screenRatio,
      layers: layers ?? this.layers,
      video: video ?? this.video,
      creators: creators ?? this.creators,
      links: links ?? this.links,
      releases: releases ?? this.releases,
      editions: editions ?? this.editions,
    );
  }

  factory MovieCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
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

    final rawReleases = (json['releases'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
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

    final videoRaw = (json['video'] is Map) ? (json['video'] as Map) : json;
    final video = json['video'] is Map
        ? Map<String, dynamic>.from(json['video'] as Map)
        : null;

    final resolvedAudioTracks = (json['audio_tracks'] ??
        videoRaw['audio_tracks'] ??
        videoRaw['audioTracks']) as String?;
    final resolvedSubtitles =
        (json['subtitles'] ?? videoRaw['subtitles']) as String?;
    final resolvedColor = (json['color'] ?? videoRaw['color']) as String?;
    final resolvedNrDiscs = (json['nr_discs'] as num?)?.toInt() ??
        (videoRaw['nr_discs'] as num?)?.toInt();
    final resolvedScreenRatio = (json['screen_ratio'] ??
        videoRaw['screen_ratio'] ??
        videoRaw['screenRatio']) as String?;
    final resolvedLayers = (json['layers'] ?? videoRaw['layers']) as String?;

    final rawEditions = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(
                (e) => CatalogEditionDto.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <CatalogEditionDto>[];

    return MovieCatalogMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ??
          (videoRaw['runtime_minutes'] as num?)?.toInt(),
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
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      writers: (json['writers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      cast: (json['cast'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  MoviePersonCredit.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
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
      region: (json['region'] ?? videoRaw['region']) as String?,
      packaging: (json['packaging'] ?? videoRaw['packaging']) as String?,
      distributor: (json['distributor'] ?? videoRaw['distributor']) as String?,
      hdr: (json['hdr'] ?? videoRaw['hdr']) as String?,
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
      editions: rawEditions,
    );
  }
}

int? _movieIntValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
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
