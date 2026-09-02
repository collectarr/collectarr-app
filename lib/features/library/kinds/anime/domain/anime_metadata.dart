import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

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

enum AnimeRelationType {
  prequel('Prequel'),
  sequel('Sequel'),
  adaptation('Adaptation'),
  spinOff('Spin-off'),
  sideStory('Side-story'),
  other('Other');

  const AnimeRelationType(this.label);
  final String label;

  static AnimeRelationType fromString(String? value) {
    if (value == null) return AnimeRelationType.other;
    final normalized = value.trim().toLowerCase().replaceAll('-', '');
    return AnimeRelationType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.label.toLowerCase().replaceAll('-', '') == normalized,
      orElse: () => AnimeRelationType.other,
    );
  }
}

@immutable
class AnimeRelation {
  const AnimeRelation({
    required this.relationType,
    required this.targetTitle,
    this.targetId,
  });

  final AnimeRelationType relationType;
  final String targetTitle;
  final String? targetId;

  Map<String, dynamic> toJson() => {
        'relation_type': relationType.name,
        'target_title': targetTitle,
        if (targetId != null) 'target_id': targetId,
      };

  factory AnimeRelation.fromJson(Map<String, dynamic> json) {
    return AnimeRelation(
      relationType: AnimeRelationType.fromString(
          json['relation_type'] as String? ?? json['type'] as String?),
      targetTitle:
          (json['target_title'] as String? ?? json['title'] as String?) ?? '',
      targetId: json['target_id'] as String? ?? json['id'] as String?,
    );
  }
}

@immutable
class AnimeMetadata implements LibraryKindMetadataRuntime {
  const AnimeMetadata({
    this.title = '',
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.format = AnimeFormat.tv,
    this.season,
    this.seasonYear,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.airingStatus = AnimeAiringStatus.finished,
    this.startDate,
    this.endDate,
    this.studios = const [],
    this.producers = const [],
    this.licensors = const [],
    this.sourceMaterial = AnimeSource.manga,
    this.genres = const [],
    this.themes = const [],
    this.country = 'JP',
    this.language = 'ja',
    this.relations = const [],
    this.series,
    this.seriesTitle,
    this.itemNumber,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.barcode,
    this.variant,
    this.editions = const [],
    this.creators = const [],
    this.links = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.anime;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final List<String> alternateTitles;
  final AnimeFormat format;
  final AnimeSeason? season;
  final int? seasonYear;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;
  final AnimeAiringStatus airingStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> studios;
  final List<String> producers;
  final List<String> licensors;
  final AnimeSource sourceMaterial;
  final List<String> genres;
  final List<String> themes;
  final String country;
  final String language;
  final List<AnimeRelation> relations;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final String? itemNumber;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? barcode;
  final String? variant;
  final List<CatalogEditionDto> editions;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLink> links;
    final Map<String, dynamic> rawPayload;

  Map<String, dynamic> toJson() => {
      ...rawPayload,
        'title': title,
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
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
        if (studios.isNotEmpty) 'studios': studios,
        if (producers.isNotEmpty) 'producers': producers,
        if (licensors.isNotEmpty) 'licensors': licensors,
        'source_material': sourceMaterial.name,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        'country': country,
        'language': language,
        if (relations.isNotEmpty)
          'relations': relations.map((e) => e.toJson()).toList(),
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (series != null && series!.hasData) ...{
          'series': series!.toJson(),
        },
        if (itemNumber != null) 'item_number': itemNumber,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant': variant,
        if (editions.isNotEmpty)
          'editions': editions.map((e) => e.toJson()).toList(),
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

  AnimeMetadata copyWith({
    String? title,
    String? nativeTitle,
    String? romajiTitle,
    String? englishTitle,
    List<String>? alternateTitles,
    AnimeFormat? format,
    AnimeSeason? season,
    int? seasonYear,
    int? episodeCount,
    int? episodeRuntimeMinutes,
    AnimeAiringStatus? airingStatus,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? studios,
    List<String>? producers,
    List<String>? licensors,
    AnimeSource? sourceMaterial,
    List<String>? genres,
    List<String>? themes,
    String? country,
    String? language,
    List<AnimeRelation>? relations,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
    String? itemNumber,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? barcode,
    String? variant,
    List<CatalogEditionDto>? editions,
    List<Map<String, dynamic>>? creators,
    List<TrailerLink>? links,
  }) {
    return AnimeMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      nativeTitle: nativeTitle ?? this.nativeTitle,
      romajiTitle: romajiTitle ?? this.romajiTitle,
      englishTitle: englishTitle ?? this.englishTitle,
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
      studios: studios ?? this.studios,
      producers: producers ?? this.producers,
      licensors: licensors ?? this.licensors,
      sourceMaterial: sourceMaterial ?? this.sourceMaterial,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      country: country ?? this.country,
      language: language ?? this.language,
      relations: relations ?? this.relations,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      itemNumber: itemNumber ?? this.itemNumber,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      editions: editions ?? this.editions,
      creators: creators ?? this.creators,
      links: links ?? this.links,
    );
  }

  factory AnimeMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
    final seriesRaw = json['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : null;
    final resolvedSeriesTitle =
        (json['series_title'] ?? series?.seriesTitle) as String?;

    final rawEditions = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(
                (e) => CatalogEditionDto.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <CatalogEditionDto>[];

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

    return AnimeMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
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
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => AnimeRelation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      series: series ??
          (resolvedSeriesTitle != null
              ? CatalogSeriesDetailsDto(seriesTitle: resolvedSeriesTitle)
              : null),
      seriesTitle: resolvedSeriesTitle,
      itemNumber: (json['item_number'] ?? json['issue_number']) as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: (json['publisher'] ??
          ((json['studios'] as List?)?.isNotEmpty == true
              ? (json['studios'] as List).first.toString()
              : null)) as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      editions: rawEditions,
      creators: rawCreators,
      links: rawLinks,
    );
  }
}
