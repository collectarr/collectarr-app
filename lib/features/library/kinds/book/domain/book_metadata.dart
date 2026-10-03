import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

@immutable
class BookCatalogMetadata implements JsonEncodable {
  const BookCatalogMetadata({
    required this.title,
    this.subtitle,
    this.sortTitle,
    this.synopsis,
    this.authors = const [],
    this.genres = const [],
    this.subjects = const [],
    this.editors = const [],
    this.translators = const [],
    this.illustrators = const [],
    this.photographers = const [],
    this.coverArtists = const [],
    this.forewordAuthors = const [],
    this.ghostwriters = const [],
    this.originalTitle,
    this.originalSubtitle,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublisher,
    this.originalPublicationDate,
    this.country,
    this.language,
    this.creators = const [],
    this.publishing,
    this.links = const [],
    this.publisher,
    this.barcode,
    this.variant,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.itemNumber,
    this.series,
    this.seriesTitle,
    this.rawPayload = const <String, dynamic>{},
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.book;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? subtitle;
  final String? sortTitle;
  final String? synopsis;
  final List<String> authors;
  final List<String> genres;
  final List<String> subjects;
  final List<String> editors;
  final List<String> translators;
  final List<String> illustrators;
  final List<String> photographers;
  final List<String> coverArtists;
  final List<String> forewordAuthors;
  final List<String> ghostwriters;
  final String? originalTitle;
  final String? originalSubtitle;
  final String? originalCountry;
  final String? originalLanguage;
  final String? originalPublisher;
  final DateTime? originalPublicationDate;
  final String? country;
  final String? language;
  final List<Map<String, dynamic>> creators;
  final CatalogPublishingDetailsDto? publishing;
  final List<TrailerLinkDto> links;
  final String? publisher;
  final String? barcode;
  final String? variant;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? itemNumber;
  final CatalogSeriesDetailsDto? series;
  final String? seriesTitle;
  final Map<String, dynamic> rawPayload;

  @override
  Map<String, dynamic> toJson() {
    final base = Map<String, dynamic>.from(rawPayload);
    if (links.isNotEmpty) {
      base.remove('trailer_urls');
      base.remove('external_links');
    }
    return {
      ...base,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (synopsis != null) 'synopsis': synopsis,
      if (authors.isNotEmpty) 'authors': authors,
      if (genres.isNotEmpty) 'genres': genres,
      if (subjects.isNotEmpty) 'subjects': subjects,
      if (editors.isNotEmpty) 'editors': editors,
      if (translators.isNotEmpty) 'translators': translators,
      if (illustrators.isNotEmpty) 'illustrators': illustrators,
      if (photographers.isNotEmpty) 'photographers': photographers,
      if (coverArtists.isNotEmpty) 'cover_artists': coverArtists,
      if (forewordAuthors.isNotEmpty) 'foreword_authors': forewordAuthors,
      if (ghostwriters.isNotEmpty) 'ghostwriters': ghostwriters,
      if (originalTitle != null) 'original_title': originalTitle,
      if (originalSubtitle != null) 'original_subtitle': originalSubtitle,
      if (originalCountry != null) 'original_country': originalCountry,
      if (originalLanguage != null) 'original_language': originalLanguage,
      if (originalPublisher != null) 'original_publisher': originalPublisher,
      if (originalPublicationDate != null)
        'original_publication_date': originalPublicationDate!.toIso8601String(),
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      if (publisher != null) 'publisher': publisher,
      if (barcode != null) 'barcode': barcode,
      if (variant != null) 'variant_name': variant,
      if (editionTitle != null) 'edition_title': editionTitle,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      if (itemNumber != null) 'item_number': itemNumber,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (series != null && series!.hasData) ...{
        'series': series!.toJson(),
        ...series!.toJson(),
      },
      if (creators.isNotEmpty) 'creators': creators,
      if (publishing != null && publishing!.hasData) ...{
        'publishing': publishing!.toJson(),
        ...publishing!.toJson(),
      },
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
  }

  BookCatalogMetadata copyWith({
    String? title,
    String? subtitle,
    String? sortTitle,
    String? synopsis,
    List<String>? authors,
    List<String>? genres,
    List<String>? subjects,
    List<String>? editors,
    List<String>? translators,
    List<String>? illustrators,
    List<String>? photographers,
    List<String>? coverArtists,
    List<String>? forewordAuthors,
    List<String>? ghostwriters,
    String? originalTitle,
    String? originalSubtitle,
    String? originalCountry,
    String? originalLanguage,
    String? originalPublisher,
    DateTime? originalPublicationDate,
    String? country,
    String? language,
    List<Map<String, dynamic>>? creators,
    CatalogPublishingDetailsDto? publishing,
    List<TrailerLinkDto>? links,
    String? publisher,
    String? barcode,
    String? variant,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? itemNumber,
    CatalogSeriesDetailsDto? series,
    String? seriesTitle,
  }) {
    return BookCatalogMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      subtitle: subtitle ?? this.subtitle,
      sortTitle: sortTitle ?? this.sortTitle,
      synopsis: synopsis ?? this.synopsis,
      authors: authors ?? this.authors,
      genres: genres ?? this.genres,
      subjects: subjects ?? this.subjects,
      editors: editors ?? this.editors,
      translators: translators ?? this.translators,
      illustrators: illustrators ?? this.illustrators,
      photographers: photographers ?? this.photographers,
      coverArtists: coverArtists ?? this.coverArtists,
      forewordAuthors: forewordAuthors ?? this.forewordAuthors,
      ghostwriters: ghostwriters ?? this.ghostwriters,
      originalTitle: originalTitle ?? this.originalTitle,
      originalSubtitle: originalSubtitle ?? this.originalSubtitle,
      originalCountry: originalCountry ?? this.originalCountry,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      originalPublisher: originalPublisher ?? this.originalPublisher,
      originalPublicationDate:
          originalPublicationDate ?? this.originalPublicationDate,
      country: country ?? this.country,
      language: language ?? this.language,
      creators: creators ?? this.creators,
      publishing: publishing ?? this.publishing,
      links: links ?? this.links,
      publisher: publisher ?? this.publisher,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      itemNumber: itemNumber ?? this.itemNumber,
      series: series ?? this.series,
      seriesTitle: seriesTitle ?? this.seriesTitle,
    );
  }

  factory BookCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
    final pubRaw = json['publishing'];
    final pubMap = (pubRaw is Map) ? Map<String, dynamic>.from(pubRaw) : null;
    final publishing = pubMap != null
        ? CatalogPublishingDetailsDto.fromJson(pubMap)
        : CatalogPublishingDetailsDto.fromJson(json);

    final seriesRaw = json['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : null;
    final resolvedSeriesTitle =
        (json['series_title'] ?? series?.seriesTitle) as String?;

    final rawLinks = <TrailerLinkDto>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TrailerLinkDto.fromJson) ??
          const <TrailerLinkDto>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TrailerLinkDto.fromJson) ??
          const <TrailerLinkDto>[]),
    ];

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    return BookCatalogMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translators: (json['translators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      illustrators: (json['illustrators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photographers: (json['photographers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      forewordAuthors: (json['foreword_authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ghostwriters: (json['ghostwriters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      originalTitle: json['original_title'] as String?,
      originalSubtitle: json['original_subtitle'] as String?,
      originalCountry: json['original_country'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublisher: json['original_publisher'] as String?,
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      country: (json['country'] ?? json['original_country']) as String?,
      language: (json['language'] ?? json['original_language']) as String?,
      creators: rawCreators,
      publishing: publishing,
      links: rawLinks,
      publisher: (json['publisher'] ??
          publishing.originalPublisher ??
          json['original_publisher']) as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant_name'] as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      itemNumber: (json['item_number'] ?? json['issue_number']) as String?,
      series: series ??
          (resolvedSeriesTitle != null
              ? CatalogSeriesDetailsDto(seriesTitle: resolvedSeriesTitle)
              : null),
      seriesTitle: resolvedSeriesTitle,
    );
  }
}
