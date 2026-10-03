import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

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
      number: _asInt(json['number']) ?? _asInt(json['episode_number']) ?? 1,
      title: (json['title'] as String?) ?? '',
      synopsis: (json['synopsis'] ?? json['overview']) as String?,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
      runtimeMinutes: _asInt(json['runtime_minutes']),
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
      seasonNumber: _asInt(json['season_number']) ?? 1,
      title: json['title'] as String?,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
      episodeCount: _asInt(json['episode_count']),
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
      discCount: _asInt(json['disc_count']),
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

@immutable
class TvSeriesMetadata implements JsonEncodable {
  const TvSeriesMetadata({
    required this.title,
    this.displayTitle,
    this.originalTitle,
    this.localizedTitle,
    this.titleExtension,
    this.editionTitle,
    this.sortKey,
    this.searchAliases = const [],
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.synopsis,
    this.firstAirDate,
    this.lastAirDate,
    this.releaseDateParts,
    this.releaseYear,
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
    this.series,
    this.seriesTitle,
    this.seasonNumber,
    this.episodeNumber,
    this.itemNumber,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.region,
    this.packaging,
    this.distributor,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.barcode,
    this.variant,
    this.creators = const [],
    this.links = const [],
    this.editions = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.tv;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? displayTitle;
  final String? originalTitle;
  final String? localizedTitle;
  final String? titleExtension;
  final String? editionTitle;
  final String? sortKey;
  final List<String> searchAliases;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final String? synopsis;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final PartialDate? releaseDateParts;
  final int? releaseYear;
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
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? itemNumber;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? barcode;
  final String? variant;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLinkDto> links;
  final List<CatalogEditionDto> editions;
  final Map<String, dynamic> rawPayload;

  DateTime? get releaseDate => releaseDateParts?.asDateTime;

  @override
  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'title': title,
        if (displayTitle != null) 'display_title': displayTitle,
        if (originalTitle != null) 'original_title': originalTitle,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (sortKey != null) 'sort_key': sortKey,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (coverImageData != null) 'cover_image_data': coverImageData,
        if (synopsis != null) 'synopsis': synopsis,
        if (firstAirDate != null)
          'first_air_date': firstAirDate!.toIso8601String(),
        if (lastAirDate != null)
          'last_air_date': lastAirDate!.toIso8601String(),
        if (releaseDateParts != null) ...{
          'release_date': releaseDateParts!.isoString,
          'release_date_parts': releaseDateParts!.toJson(),
        },
        if (releaseYear != null) 'release_year': releaseYear,
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
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (itemNumber != null) 'item_number': itemNumber,
        if (series != null) 'series': series!.toJson(),
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (region != null) 'region': region,
        if (packaging != null) 'packaging': packaging,
        if (distributor != null) 'distributor': distributor,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant_name': variant,
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
        if (editions.isNotEmpty)
          'editions': editions.map((e) => e.toJson()).toList(),
      };

  TvSeriesMetadata copyWith({
    String? title,
    String? displayTitle,
    String? originalTitle,
    String? localizedTitle,
    String? titleExtension,
    String? editionTitle,
    String? sortKey,
    List<String>? searchAliases,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? coverImageData,
    String? synopsis,
    DateTime? firstAirDate,
    DateTime? lastAirDate,
    PartialDate? releaseDateParts,
    int? releaseYear,
    String? status,
    String? network,
    String? streamingService,
    List<String>? productionCompanies,
    String? country,
    String? originalLanguage,
    List<String>? genres,
    String? contentRating,
    int? seasonCount,
    int? episodeCount,
    int? episodeRuntimeMinutes,
    List<TvPersonCredit>? cast,
    List<TvPersonCredit>? crew,
    List<TvSeasonMetadata>? seasons,
    List<TvPhysicalReleaseMetadata>? releases,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
    int? seasonNumber,
    int? episodeNumber,
    String? itemNumber,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? region,
    String? packaging,
    String? distributor,
    String? screenRatio,
    String? audioTracks,
    String? subtitles,
    String? barcode,
    String? variant,
    List<Map<String, dynamic>>? creators,
    List<TrailerLinkDto>? links,
    List<CatalogEditionDto>? editions,
  }) {
    return TvSeriesMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      displayTitle: displayTitle ?? this.displayTitle,
      originalTitle: originalTitle ?? this.originalTitle,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      editionTitle: editionTitle ?? this.editionTitle,
      sortKey: sortKey ?? this.sortKey,
      searchAliases: searchAliases ?? this.searchAliases,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      coverImageData: coverImageData ?? this.coverImageData,
      synopsis: synopsis ?? this.synopsis,
      firstAirDate: firstAirDate ?? this.firstAirDate,
      lastAirDate: lastAirDate ?? this.lastAirDate,
      releaseDateParts: releaseDateParts ?? this.releaseDateParts,
      releaseYear: releaseYear ?? this.releaseYear,
      status: status ?? this.status,
      network: network ?? this.network,
      streamingService: streamingService ?? this.streamingService,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      country: country ?? this.country,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      genres: genres ?? this.genres,
      contentRating: contentRating ?? this.contentRating,
      seasonCount: seasonCount ?? this.seasonCount,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      cast: cast ?? this.cast,
      crew: crew ?? this.crew,
      seasons: seasons ?? this.seasons,
      releases: releases ?? this.releases,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      itemNumber: itemNumber ?? this.itemNumber,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      screenRatio: screenRatio ?? this.screenRatio,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitles: subtitles ?? this.subtitles,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      creators: creators ?? this.creators,
      links: links ?? this.links,
      editions: editions ?? this.editions,
    );
  }

  factory TvSeriesMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
    final videoRaw = json['video'] is Map
        ? Map<String, dynamic>.from(json['video'] as Map)
        : const <String, dynamic>{};
    final seriesRaw = json['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : null;

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    final rawLinks = <TrailerLinkDto>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  TrailerLinkDto.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLinkDto>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  TrailerLinkDto.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLinkDto>[]),
    ];

    final resolvedSeasonNumber =
        (json['season_number'] as num?)?.toInt() ?? series?.seasonNumber;
    final resolvedEpisodeNumber =
        (json['episode_number'] as num?)?.toInt() ?? series?.episodeNumber;
    final resolvedSeriesTitle =
        (json['series_title'] ?? series?.seriesTitle) as String?;

    return TvSeriesMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      originalTitle: json['original_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      editionTitle: json['edition_title'] as String?,
      sortKey: json['sort_key'] as String?,
      searchAliases: (json['search_aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      synopsis: (json['synopsis'] ?? json['overview']) as String?,
      firstAirDate: json['first_air_date'] != null
          ? DateTime.tryParse(json['first_air_date'] as String)
          : null,
      lastAirDate: json['last_air_date'] != null
          ? DateTime.tryParse(json['last_air_date'] as String)
          : null,
      releaseDateParts: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      ),
      releaseYear: (json['release_year'] as num?)?.toInt(),
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
      seasonCount: _asInt(json['season_count']),
      episodeCount: _asInt(json['episode_count']),
      episodeRuntimeMinutes: _asInt(json['episode_runtime_minutes']),
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
      series: series ??
          (resolvedSeriesTitle != null || resolvedSeasonNumber != null
              ? CatalogSeriesDetailsDto(
                  seriesTitle: resolvedSeriesTitle,
                  seasonNumber: resolvedSeasonNumber,
                  episodeNumber: resolvedEpisodeNumber,
                )
              : null),
      seriesTitle: resolvedSeriesTitle,
      seasonNumber: resolvedSeasonNumber,
      episodeNumber: resolvedEpisodeNumber,
      itemNumber: (json['item_number'] ?? json['issue_number']) as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher:
          (json['publisher'] ?? json['network'] ?? json['studio']) as String?,
      region: (json['region'] ?? videoRaw['region']) as String?,
      packaging: (json['packaging'] ?? videoRaw['packaging']) as String?,
      distributor: (json['distributor'] ?? videoRaw['distributor']) as String?,
      screenRatio:
          (json['screen_ratio'] ?? videoRaw['screen_ratio']) as String?,
      audioTracks:
          (json['audio_tracks'] ?? videoRaw['audio_tracks']) as String?,
      subtitles: (json['subtitles'] ?? videoRaw['subtitles']) as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant_name'] as String?,
      creators: rawCreators,
      links: rawLinks,
      editions: (json['editions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) =>
                  CatalogEditionDto.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const <CatalogEditionDto>[],
    );
  }
}
