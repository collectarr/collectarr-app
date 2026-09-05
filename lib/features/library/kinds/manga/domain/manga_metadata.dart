import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';

enum MangaDemographic {
  shonen('Shonen'),
  shojo('Shojo'),
  seinen('Seinen'),
  josei('Josei'),
  kodomo('Kodomo'),
  other('Other');

  const MangaDemographic(this.label);
  final String label;

  static MangaDemographic fromString(String? value) {
    if (value == null) return MangaDemographic.other;
    final normalized = value.trim().toLowerCase();
    return MangaDemographic.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaDemographic.other,
    );
  }
}

enum MangaPublicationStatus {
  ongoing('Ongoing'),
  completed('Completed'),
  hiatus('On Hiatus'),
  cancelled('Cancelled'),
  upcoming('Upcoming');

  const MangaPublicationStatus(this.label);
  final String label;

  static MangaPublicationStatus fromString(String? value) {
    if (value == null) return MangaPublicationStatus.ongoing;
    final normalized = value.trim().toLowerCase();
    return MangaPublicationStatus.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaPublicationStatus.ongoing,
    );
  }
}

enum MangaEditionFormat {
  tankobon('Tankobon'),
  bunkoban('Bunkoban'),
  kanzenban('Kanzenban'),
  omnibus('Omnibus'),
  hardcover('Hardcover'),
  digital('Digital'),
  other('Other');

  const MangaEditionFormat(this.label);
  final String label;

  static MangaEditionFormat fromString(String? value) {
    if (value == null) return MangaEditionFormat.tankobon;
    final normalized = value.trim().toLowerCase();
    return MangaEditionFormat.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaEditionFormat.tankobon,
    );
  }
}

enum MangaReadingDirection {
  rightToLeft('Right to Left'),
  leftToRight('Left to Right');

  const MangaReadingDirection(this.label);
  final String label;

  static MangaReadingDirection fromString(String? value) {
    if (value == null) return MangaReadingDirection.rightToLeft;
    final normalized = value.trim().toLowerCase();
    return MangaReadingDirection.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaReadingDirection.rightToLeft,
    );
  }
}

@immutable
class MangaMetadata {
  const MangaMetadata({
    this.title = '',
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.authors = const [],
    this.artists = const [],
    this.demographic = MangaDemographic.other,
    this.serializationPlatform,
    this.publicationStatus = MangaPublicationStatus.ongoing,
    this.originalPublisher,
    this.localizedPublisher,
    this.volumeNumber,
    this.totalVolumes,
    this.chapterCount,
    this.originalPublicationDate,
    this.localizedReleaseDate,
    this.isbn,
    this.editionFormat = MangaEditionFormat.tankobon,
    this.language = 'ja',
    this.country = 'JP',
    this.genres = const [],
    this.themes = const [],
    this.translator,
    this.readingDirection = MangaReadingDirection.rightToLeft,
    this.relations = const [],
    this.series,
    this.seriesTitle,
    this.itemNumber,
    this.editionTitle,
    this.pageCount,
    this.imprint,
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

  CatalogMediaKind get mediaKind => CatalogMediaKind.manga;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final List<String> alternateTitles;
  final List<String> authors;
  final List<String> artists;
  final MangaDemographic demographic;
  final String? serializationPlatform;
  final MangaPublicationStatus publicationStatus;
  final String? originalPublisher;
  final String? localizedPublisher;
  final int? volumeNumber;
  final int? totalVolumes;
  final int? chapterCount;
  final DateTime? originalPublicationDate;
  final DateTime? localizedReleaseDate;
  final String? isbn;
  final MangaEditionFormat editionFormat;
  final String language;
  final String country;
  final List<String> genres;
  final List<String> themes;
  final String? translator;
  final MangaReadingDirection readingDirection;
  final List<String> relations;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final String? itemNumber;
  final String? editionTitle;
  final int? pageCount;
  final String? imprint;
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
        if (authors.isNotEmpty) 'authors': authors,
        if (artists.isNotEmpty) 'artists': artists,
        'demographic': demographic.name,
        if (serializationPlatform != null)
          'serialization_platform': serializationPlatform,
        'publication_status': publicationStatus.name,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (localizedPublisher != null)
          'localized_publisher': localizedPublisher,
        if (volumeNumber != null) 'volume_number': volumeNumber,
        if (totalVolumes != null) 'total_volumes': totalVolumes,
        if (chapterCount != null) 'chapter_count': chapterCount,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (localizedReleaseDate != null)
          'localized_release_date': localizedReleaseDate!.toIso8601String(),
        if (isbn != null) 'isbn': isbn,
        'edition_format': editionFormat.name,
        'language': language,
        'country': country,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        if (translator != null) 'translator': translator,
        'reading_direction': readingDirection.name,
        if (relations.isNotEmpty) 'relations': relations,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (series != null && series!.hasData) ...{
          'series': series!.toJson(),
        },
        if (itemNumber != null) 'item_number': itemNumber,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (pageCount != null) 'page_count': pageCount,
        if (imprint != null) 'imprint': imprint,
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

  MangaMetadata copyWith({
    String? title,
    String? nativeTitle,
    String? romajiTitle,
    String? englishTitle,
    List<String>? alternateTitles,
    List<String>? authors,
    List<String>? artists,
    MangaDemographic? demographic,
    String? serializationPlatform,
    MangaPublicationStatus? publicationStatus,
    String? originalPublisher,
    String? localizedPublisher,
    int? volumeNumber,
    int? totalVolumes,
    int? chapterCount,
    DateTime? originalPublicationDate,
    DateTime? localizedReleaseDate,
    String? isbn,
    MangaEditionFormat? editionFormat,
    String? language,
    String? country,
    List<String>? genres,
    List<String>? themes,
    String? translator,
    MangaReadingDirection? readingDirection,
    List<String>? relations,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
    String? itemNumber,
    String? editionTitle,
    int? pageCount,
    String? imprint,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? barcode,
    String? variant,
    List<CatalogEditionDto>? editions,
    List<Map<String, dynamic>>? creators,
    List<TrailerLink>? links,
  }) {
    return MangaMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      nativeTitle: nativeTitle ?? this.nativeTitle,
      romajiTitle: romajiTitle ?? this.romajiTitle,
      englishTitle: englishTitle ?? this.englishTitle,
      alternateTitles: alternateTitles ?? this.alternateTitles,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      demographic: demographic ?? this.demographic,
      serializationPlatform:
          serializationPlatform ?? this.serializationPlatform,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      originalPublisher: originalPublisher ?? this.originalPublisher,
      localizedPublisher: localizedPublisher ?? this.localizedPublisher,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      totalVolumes: totalVolumes ?? this.totalVolumes,
      chapterCount: chapterCount ?? this.chapterCount,
      originalPublicationDate:
          originalPublicationDate ?? this.originalPublicationDate,
      localizedReleaseDate: localizedReleaseDate ?? this.localizedReleaseDate,
      isbn: isbn ?? this.isbn,
      editionFormat: editionFormat ?? this.editionFormat,
      language: language ?? this.language,
      country: country ?? this.country,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      translator: translator ?? this.translator,
      readingDirection: readingDirection ?? this.readingDirection,
      relations: relations ?? this.relations,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      itemNumber: itemNumber ?? this.itemNumber,
      editionTitle: editionTitle ?? this.editionTitle,
      pageCount: pageCount ?? this.pageCount,
      imprint: imprint ?? this.imprint,
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

  factory MangaMetadata.fromJson(Map<String, dynamic> json) {
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
            ?.whereType<Map<Object?, Object?>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
    ];

    return MangaMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      demographic: MangaDemographic.fromString(json['demographic'] as String?),
      serializationPlatform: json['serialization_platform'] as String?,
      publicationStatus: MangaPublicationStatus.fromString(
          json['publication_status'] as String?),
      originalPublisher: json['original_publisher'] as String?,
      localizedPublisher: json['localized_publisher'] as String?,
      volumeNumber: (json['volume_number'] as num?)?.toInt(),
      totalVolumes: (json['total_volumes'] as num?)?.toInt(),
      chapterCount: (json['chapter_count'] as num?)?.toInt(),
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      localizedReleaseDate: json['localized_release_date'] != null
          ? DateTime.tryParse(json['localized_release_date'] as String)
          : null,
      isbn: json['isbn'] as String?,
      editionFormat:
          MangaEditionFormat.fromString(json['edition_format'] as String?),
      language: (json['language'] as String?) ?? 'ja',
      country: (json['country'] as String?) ?? 'JP',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translator: json['translator'] as String?,
      readingDirection: MangaReadingDirection.fromString(
          json['reading_direction'] as String?),
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      series: series,
      seriesTitle: resolvedSeriesTitle,
      itemNumber:
          (json['item_number'] ?? json['volume_number']?.toString()) as String?,
      editionTitle: json['edition_title'] as String?,
      pageCount: (json['page_count'] as num?)?.toInt(),
      imprint: json['imprint'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      editions: rawEditions,
      creators: rawCreators,
      links: rawLinks,
    );
  }
}
