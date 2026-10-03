import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

import 'anime_metadata_children.dart';

enum AnimeFormat {
  tv('TV'),
  movie('Movie'),
  ova('OVA'),
  ona('ONA'),
  special('Special');

  const AnimeFormat(this.label);
  final String label;

  static AnimeFormat fromString(String? value) {
    if (value == null) return AnimeFormat.tv;
    final normalized = value.trim().toLowerCase();
    return AnimeFormat.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => AnimeFormat.tv,
    );
  }
}

enum AnimeSeason {
  winter('Winter'),
  spring('Spring'),
  summer('Summer'),
  fall('Fall');

  const AnimeSeason(this.label);
  final String label;

  static AnimeSeason fromString(String? value) {
    if (value == null) return AnimeSeason.winter;
    final normalized = value.trim().toLowerCase();
    return AnimeSeason.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => AnimeSeason.winter,
    );
  }
}

enum AnimeAiringStatus {
  airing('Currently Airing'),
  finished('Finished Airing'),
  notYetAired('Not Yet Aired'),
  cancelled('Cancelled');

  const AnimeAiringStatus(this.label);
  final String label;

  static AnimeAiringStatus fromString(String? value) {
    if (value == null) return AnimeAiringStatus.finished;
    final normalized = value.trim().toLowerCase();
    return AnimeAiringStatus.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => AnimeAiringStatus.finished,
    );
  }
}

enum AnimeSource {
  manga('Manga'),
  lightNovel('Light Novel'),
  original('Original'),
  visualNovel('Visual Novel'),
  game('Game'),
  novel('Novel'),
  other('Other');

  const AnimeSource(this.label);
  final String label;

  static AnimeSource fromString(String? value) {
    if (value == null) return AnimeSource.manga;
    final normalized = value.trim().toLowerCase();
    return AnimeSource.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => AnimeSource.other,
    );
  }
}

@immutable
class AnimeMediaMetadata implements JsonEncodable {
  const AnimeMediaMetadata({
    required this.position,
    this.id,
    this.mediaNumber,
    this.mediaType,
    this.title,
    this.episodeCount,
    this.runtimeMinutes,
    this.regionCode,
    this.encoding,
    this.aspectRatio,
    this.audioTracks,
    this.subtitles,
    this.resolution,
    this.hdrFormat,
  });

  final int position;
  final String? id;
  final int? mediaNumber;
  final String? mediaType;
  final String? title;
  final int? episodeCount;
  final int? runtimeMinutes;
  final String? regionCode;
  final String? encoding;
  final String? aspectRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? resolution;
  final String? hdrFormat;

  factory AnimeMediaMetadata.fromJson(Map<String, dynamic> json) {
    final position = (json['position'] as num?)?.toInt();
    if (position == null || position < 1) {
      throw const FormatException('Anime media requires a positive position.');
    }
    return AnimeMediaMetadata(
      position: position,
      id: json['id'] as String?,
      mediaNumber: (json['media_number'] as num?)?.toInt(),
      mediaType: json['media_type'] as String?,
      title: json['title'] as String?,
      episodeCount: (json['episode_count'] as num?)?.toInt(),
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      regionCode: json['region_code'] as String?,
      encoding: json['encoding'] as String?,
      aspectRatio: json['aspect_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      resolution: json['resolution'] as String?,
      hdrFormat: json['hdr_format'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'position': position,
        if (id != null) 'id': id,
        if (mediaNumber != null) 'media_number': mediaNumber,
        if (mediaType != null) 'media_type': mediaType,
        if (title != null) 'title': title,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (regionCode != null) 'region_code': regionCode,
        if (encoding != null) 'encoding': encoding,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (resolution != null) 'resolution': resolution,
        if (hdrFormat != null) 'hdr_format': hdrFormat,
      };
}

@immutable
class AnimeMetadata implements JsonEncodable {
  const AnimeMetadata({
    this.title = '',
    this.displayTitle,
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.sortKey,
    this.synopsis,
    this.ageRating,
    this.audienceRating,
    this.audioTracks,
    this.catalogNumber,
    this.color,
    this.layers,
    this.plotDescription,
    this.plotSummary,
    this.searchAliases = const [],
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.alternateTitles = const [],
    this.format = AnimeFormat.tv,
    this.season,
    this.seasonYear,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.airingStatus = AnimeAiringStatus.finished,
    this.startDate,
    this.endDate,
    this.releaseDateParts,
    this.releaseYear,
    this.studios = const [],
    this.producers = const [],
    this.licensors = const [],
    this.sourceMaterial = AnimeSource.manga,
    this.genres = const [],
    this.themes = const [],
    this.country = 'JP',
    this.language = 'ja',
    this.seriesTitle,
    this.itemNumber,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.barcode,
    this.variant,
    this.nrDiscs,
    this.releaseStatus,
    this.runtimeMinutes,
    this.screenRatio,
    this.subtitle,
    this.subtitles,
    this.seriesTags,
    this.media = const [],
    this.description,
    this.contributors = const [],
    this.characters = const [],
    this.characterDetails = const [],
    this.identifiers = const [],
    this.seasons = const [],
    this.episodes = const [],
    this.creators = const [],
    this.links = const [],
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.anime;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? displayTitle;
  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final String? sortKey;
  final String? synopsis;
  final String? description;
  final String? ageRating;
  final String? audienceRating;
  final String? audioTracks;
  final String? catalogNumber;
  final String? color;
  final String? layers;
  final String? plotDescription;
  final String? plotSummary;
  final List<String> searchAliases;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final List<String> alternateTitles;
  final AnimeFormat format;
  final AnimeSeason? season;
  final int? seasonYear;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;
  final AnimeAiringStatus airingStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final PartialDate? releaseDateParts;
  final int? releaseYear;
  final List<String> studios;
  final List<String> producers;
  final List<String> licensors;
  final AnimeSource sourceMaterial;
  final List<String> genres;
  final List<String> themes;
  final String country;
  final String language;
  final String? seriesTitle;
  final String? itemNumber;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? barcode;
  final String? variant;
  final int? nrDiscs;
  final String? releaseStatus;
  final int? runtimeMinutes;
  final String? screenRatio;
  final String? subtitle;
  final String? subtitles;
  final List<String>? seriesTags;
  final List<AnimeMediaMetadata> media;
  final List<AnimePersonMetadata> creators;
  final List<AnimePersonMetadata> contributors;
  final List<AnimeCharacterMetadata> characters;
  final List<AnimeCharacterMetadata> characterDetails;
  final List<AnimeIdentifierMetadata> identifiers;
  final List<AnimeSeasonMetadata> seasons;
  final List<AnimeEpisodeMetadata> episodes;
  final List<TrailerLinkDto> links;

  DateTime? get releaseDate => releaseDateParts?.asDateTime;

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        if (displayTitle != null) 'display_title': displayTitle,
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (originalTitle != null) 'original_title': originalTitle,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (sortKey != null) 'sort_key': sortKey,
        if (synopsis != null) 'synopsis': synopsis,
        if (description != null) 'description': description,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (color != null) 'color': color,
        if (layers != null) 'layers': layers,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (coverImageData != null) 'cover_image_data': coverImageData,
        if (alternateTitles.isNotEmpty) 'alternate_titles': alternateTitles,
        'format': format.name,
        if (season != null) 'season': season!.name,
        if (seasonYear != null) 'season_year': seasonYear,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodeRuntimeMinutes != null)
          'episode_runtime_minutes': episodeRuntimeMinutes,
        'airing_status': airingStatus.name,
        if (startDate != null) 'start_date': startDate!.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        if (releaseDateParts != null) ...{
          'release_date': releaseDateParts!.isoString,
          'release_date_parts': releaseDateParts!.toJson(),
        },
        if (releaseYear != null) 'release_year': releaseYear,
        if (studios.isNotEmpty) 'studios': studios,
        if (producers.isNotEmpty) 'producers': producers,
        if (licensors.isNotEmpty) 'licensors': licensors,
        'source_material': sourceMaterial.name,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        'country': country,
        'language': language,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (itemNumber != null) 'item_number': itemNumber,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant_name': variant,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (subtitle != null) 'subtitle': subtitle,
        if (subtitles != null) 'subtitles': subtitles,
        if (seriesTags != null) 'series_tags': seriesTags,
        if (media.isNotEmpty) 'media': media.map((e) => e.toJson()).toList(),
        if (contributors.isNotEmpty)
          'contributors': contributors.map((e) => e.toJsonValue()).toList(),
        if (characters.isNotEmpty)
          'characters': characters.map((e) => e.toJsonValue()).toList(),
        if (characterDetails.isNotEmpty)
          'character_details':
              characterDetails.map((e) => e.toJsonValue()).toList(),
        if (identifiers.isNotEmpty)
          'identifiers': identifiers.map((e) => e.toJsonValue()).toList(),
        if (seasons.isNotEmpty)
          'seasons': seasons.map((e) => e.toJson()).toList(),
        if (episodes.isNotEmpty)
          'episodes': episodes.map((e) => e.toJson()).toList(),
        if (creators.isNotEmpty)
          'creators': creators.map((e) => e.toJsonValue()).toList(),
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

  AnimeMetadata copyWith({
    String? title,
    String? displayTitle,
    String? nativeTitle,
    String? romajiTitle,
    String? englishTitle,
    String? localizedTitle,
    String? originalTitle,
    String? titleExtension,
    String? sortKey,
    String? synopsis,
    String? description,
    String? ageRating,
    String? audienceRating,
    String? audioTracks,
    String? catalogNumber,
    String? color,
    String? layers,
    String? plotDescription,
    String? plotSummary,
    List<String>? searchAliases,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? coverImageData,
    List<String>? alternateTitles,
    AnimeFormat? format,
    AnimeSeason? season,
    int? seasonYear,
    int? episodeCount,
    int? episodeRuntimeMinutes,
    AnimeAiringStatus? airingStatus,
    DateTime? startDate,
    DateTime? endDate,
    PartialDate? releaseDateParts,
    int? releaseYear,
    List<String>? studios,
    List<String>? producers,
    List<String>? licensors,
    AnimeSource? sourceMaterial,
    List<String>? genres,
    List<String>? themes,
    String? country,
    String? language,
    String? seriesTitle,
    String? itemNumber,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? barcode,
    String? variant,
    int? nrDiscs,
    String? releaseStatus,
    int? runtimeMinutes,
    String? screenRatio,
    String? subtitle,
    String? subtitles,
    List<String>? seriesTags,
    List<AnimeMediaMetadata>? media,
    List<AnimePersonMetadata>? creators,
    List<AnimePersonMetadata>? contributors,
    List<AnimeCharacterMetadata>? characters,
    List<AnimeCharacterMetadata>? characterDetails,
    List<AnimeIdentifierMetadata>? identifiers,
    List<AnimeSeasonMetadata>? seasons,
    List<AnimeEpisodeMetadata>? episodes,
    List<TrailerLinkDto>? links,
  }) {
    return AnimeMetadata(
      title: title ?? this.title,
      displayTitle: displayTitle ?? this.displayTitle,
      nativeTitle: nativeTitle ?? this.nativeTitle,
      romajiTitle: romajiTitle ?? this.romajiTitle,
      englishTitle: englishTitle ?? this.englishTitle,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      originalTitle: originalTitle ?? this.originalTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      sortKey: sortKey ?? this.sortKey,
      synopsis: synopsis ?? this.synopsis,
      description: description ?? this.description,
      ageRating: ageRating ?? this.ageRating,
      audienceRating: audienceRating ?? this.audienceRating,
      audioTracks: audioTracks ?? this.audioTracks,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      color: color ?? this.color,
      layers: layers ?? this.layers,
      plotDescription: plotDescription ?? this.plotDescription,
      plotSummary: plotSummary ?? this.plotSummary,
      searchAliases: searchAliases ?? this.searchAliases,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      coverImageData: coverImageData ?? this.coverImageData,
      alternateTitles: alternateTitles ?? this.alternateTitles,
      format: format ?? this.format,
      season: season ?? this.season,
      seasonYear: seasonYear ?? this.seasonYear,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      airingStatus: airingStatus ?? this.airingStatus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      releaseDateParts: releaseDateParts ?? this.releaseDateParts,
      releaseYear: releaseYear ?? this.releaseYear,
      studios: studios ?? this.studios,
      producers: producers ?? this.producers,
      licensors: licensors ?? this.licensors,
      sourceMaterial: sourceMaterial ?? this.sourceMaterial,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      country: country ?? this.country,
      language: language ?? this.language,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      itemNumber: itemNumber ?? this.itemNumber,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      nrDiscs: nrDiscs ?? this.nrDiscs,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      screenRatio: screenRatio ?? this.screenRatio,
      subtitle: subtitle ?? this.subtitle,
      subtitles: subtitles ?? this.subtitles,
      seriesTags: seriesTags ?? this.seriesTags,
      media: media ?? this.media,
      creators: creators ?? this.creators,
      contributors: contributors ?? this.contributors,
      characters: characters ?? this.characters,
      characterDetails: characterDetails ?? this.characterDetails,
      identifiers: identifiers ?? this.identifiers,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      links: links ?? this.links,
    );
  }

  factory AnimeMetadata.fromJson(Map<String, dynamic> json) {
    final rawMedia = (json['media'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(AnimeMediaMetadata.fromJson)
            .toList() ??
        const <AnimeMediaMetadata>[];

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

    return AnimeMetadata(
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      sortKey: json['sort_key'] as String?,
      synopsis: json['synopsis'] as String?,
      description: json['description'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      color: json['color'] as String?,
      layers: json['layers'] as String?,
      plotDescription: json['plot_description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      searchAliases: (json['search_aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      format: AnimeFormat.fromString(json['format'] as String?),
      season: json['season'] != null
          ? AnimeSeason.fromString(json['season'] as String)
          : null,
      seasonYear: json['season_year'] as int?,
      episodeCount: json['episode_count'] as int?,
      episodeRuntimeMinutes: json['episode_runtime_minutes'] as int?,
      airingStatus:
          AnimeAiringStatus.fromString(json['airing_status'] as String?),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      releaseDateParts: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      ),
      releaseYear: (json['release_year'] as num?)?.toInt(),
      studios: (json['studios'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      licensors: (json['licensors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sourceMaterial:
          AnimeSource.fromString(json['source_material'] as String?),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: (json['country'] as String?) ?? 'JP',
      language: (json['language'] as String?) ?? 'ja',
      seriesTitle: json['series_title'] as String?,
      itemNumber: json['item_number'] as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant_name'] as String?,
      nrDiscs: (json['nr_discs'] as num?)?.toInt(),
      releaseStatus: json['release_status'] as String?,
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      screenRatio: json['screen_ratio'] as String?,
      subtitle: json['subtitle'] as String?,
      subtitles: json['subtitles'] as String?,
      seriesTags: (json['series_tags'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      media: rawMedia,
      contributors: decodeAnimeTypedValues(
        json['contributors'],
        'Anime contributors',
        AnimePersonMetadata.fromJsonValue,
      ),
      characters: decodeAnimeTypedValues(
        json['characters'],
        'Anime characters',
        AnimeCharacterMetadata.fromJsonValue,
      ),
      characterDetails: decodeAnimeObjectList(
        json['character_details'],
        'Anime character details',
      ).map(AnimeCharacterMetadata.fromJson).toList(growable: false),
      identifiers: decodeAnimeTypedValues(
        json['identifiers'],
        'Anime identifiers',
        AnimeIdentifierMetadata.fromJsonValue,
      ),
      seasons: decodeAnimeObjectList(json['seasons'], 'Anime seasons')
          .map(AnimeSeasonMetadata.fromJson)
          .toList(growable: false),
      episodes: decodeAnimeObjectList(json['episodes'], 'Anime episodes')
          .map(AnimeEpisodeMetadata.fromJson)
          .toList(growable: false),
      creators: decodeAnimeTypedValues(
        json['creators'],
        'Anime creators',
        AnimePersonMetadata.fromJsonValue,
      ),
      links: rawLinks,
    );
  }
}
