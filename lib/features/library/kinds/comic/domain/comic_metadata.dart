import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/contracts/comic_contracts.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

enum ComicKeyEventType {
  firstAppearance,
  cameoAppearance,
  death,
  origin,
  firstIssue,
  iconicCover,
  other,
}

@immutable
class ComicKeyEvent {
  const ComicKeyEvent({
    required this.type,
    required this.characterOrSubject,
    this.description,
  });

  final ComicKeyEventType type;
  final String characterOrSubject;
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'character_or_subject': characterOrSubject,
        if (description != null) 'description': description,
      };

  factory ComicKeyEvent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type = ComicKeyEventType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ComicKeyEventType.other,
    );
    return ComicKeyEvent(
      type: type,
      characterOrSubject: (json['character_or_subject'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }
}

@immutable
class ComicCreatorCredit {
  const ComicCreatorCredit({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
      };

  factory ComicCreatorCredit.fromJson(Map<String, dynamic> json) {
    return ComicCreatorCredit(
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
    );
  }
}

typedef ComicMetadata = ComicCatalogMetadata;

@immutable
class ComicCatalogMetadata implements LibraryKindMetadataRuntime {
  const ComicCatalogMetadata({
    required this.title,
    this.seriesTitle,
    this.issueNumber,
    this.publisher,
    this.imprint,
    this.releaseDate,
    this.coverDate,
    this.pageCount,
    this.country = 'US',
    this.language = 'en',
    this.ageRating,
    this.crossover,
    this.genres = const [],
    this.synopsis,
    this.writers = const [],
    this.artists = const [],
    this.inkers = const [],
    this.colorists = const [],
    this.letterers = const [],
    this.editors = const [],
    this.coverArtists = const [],
    this.characters = const [],
    this.characterDetails = const [],
    this.creators = const [],
    this.storyArcs = const [],
    this.keyEvents = const [],
    this.isKeyComic = false,
    this.keyReason,
    this.variant,
    this.variantDescription,
    this.barcode,
    this.series,
    this.publishing,
    this.editionTitle,
    this.titleExtension,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.links = const [],
    this.releases = const [],
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.comic;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? seriesTitle;
  final String? issueNumber;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final int? pageCount;
  final String country;
  final String language;
  final String? ageRating;
  final String? crossover;
  final List<String> genres;
  final String? synopsis;
  final List<String> writers;
  final List<String> artists;
  final List<String> inkers;
  final List<String> colorists;
  final List<String> letterers;
  final List<String> editors;
  final List<String> coverArtists;
  final List<String> characters;
  final List<Map<String, dynamic>> characterDetails;
  final List<Map<String, dynamic>> creators;
  final List<String> storyArcs;
  final List<ComicKeyEvent> keyEvents;
  final bool isKeyComic;
  final String? keyReason;
  final String? variant;
  final String? variantDescription;
  final String? barcode;
  final CatalogSeriesDetailsDto? series;
  final CatalogPublishingDetailsDto? publishing;
  final String? editionTitle;
  final String? titleExtension;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<ComicLink> links;
  final List<ComicRelease> releases;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (issueNumber != null) ...{
          'issue_number': issueNumber,
          'item_number': issueNumber,
        },
        if (publisher != null) 'publisher': publisher,
        if (imprint != null) 'imprint': imprint,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (coverDate != null) 'cover_date': coverDate!.toIso8601String(),
        if (pageCount != null) 'page_count': pageCount,
        'country': country,
        'language': language,
        if (ageRating != null) 'age_rating': ageRating,
        if (crossover != null) 'crossover': crossover,
        if (genres.isNotEmpty) 'genres': genres,
        if (synopsis != null) 'synopsis': synopsis,
        if (writers.isNotEmpty) 'writers': writers,
        if (artists.isNotEmpty) 'artists': artists,
        if (inkers.isNotEmpty) 'inkers': inkers,
        if (colorists.isNotEmpty) 'colorists': colorists,
        if (letterers.isNotEmpty) 'letterers': letterers,
        if (editors.isNotEmpty) 'editors': editors,
        if (coverArtists.isNotEmpty) 'cover_artists': coverArtists,
        if (characters.isNotEmpty) 'characters': characters,
        if (characterDetails.isNotEmpty) 'character_details': characterDetails,
        if (creators.isNotEmpty) 'creators': creators,
        if (storyArcs.isNotEmpty) 'story_arcs': storyArcs,
        if (keyEvents.isNotEmpty)
          'key_events': keyEvents.map((e) => e.toJson()).toList(),
        if (isKeyComic) 'is_key_comic': true,
        if (keyReason != null) 'key_reason': keyReason,
        if (variant != null) 'variant': variant,
        if (variantDescription != null)
          'variant_description': variantDescription,
        if (barcode != null) 'barcode': barcode,
        if (series != null && series!.hasData) ...{
          'series': series!.toJson(),
          ...series!.toJson(),
        },
        if (publishing != null && publishing!.hasData) ...{
          'publishing': publishing!.toJson(),
          ...publishing!.toJson(),
        },
        if (editionTitle != null) 'edition_title': editionTitle,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
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
          'editions': releases.map((e) => e.toEditionDto().toJson()).toList(),
      };

  factory ComicCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawLinks = <ComicLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
    ];

    final seriesMap = json['series'] as Map<String, dynamic>?;
    final series = seriesMap != null
        ? CatalogSeriesDetailsDto.fromJson(seriesMap)
        : CatalogSeriesDetailsDto.fromJson(json);

    final pubMap = json['publishing'] as Map<String, dynamic>?;
    final publishing = pubMap != null
        ? CatalogPublishingDetailsDto.fromJson(pubMap)
        : CatalogPublishingDetailsDto.fromJson(json);

    final rawReleases = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) =>
                ComicRelease.fromEditionDto(CatalogEditionDto.fromJson(e)))
            .toList(growable: false) ??
        const <ComicRelease>[];

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: true) ??
        <Map<String, dynamic>>[];

    final rawCharDetails = (json['character_details'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    return ComicCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      seriesTitle: (json['series_title'] ?? series.seriesTitle) as String?,
      issueNumber: (json['issue_number'] ?? json['item_number']) as String?,
      publisher: (json['publisher'] ?? publishing.originalPublisher) as String?,
      imprint: (json['imprint'] ?? publishing.imprint) as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      coverDate: json['cover_date'] != null
          ? DateTime.tryParse(json['cover_date'] as String)
          : null,
      pageCount: (json['page_count'] ?? publishing.pageCount) as int?,
      country: (json['country'] as String?) ?? 'US',
      language: (json['language'] as String?) ?? 'en',
      ageRating: json['age_rating'] as String?,
      crossover: json['crossover'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      writers: (json['writers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      inkers: (json['inkers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      colorists: (json['colorists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      letterers: (json['letterers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      characterDetails: rawCharDetails,
      creators: rawCreators,
      storyArcs: (json['story_arcs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keyEvents: (json['key_events'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicKeyEvent.fromJson)
              .toList() ??
          const [],
      isKeyComic: json['is_key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      variant: json['variant'] as String?,
      variantDescription: json['variant_description'] as String?,
      barcode: json['barcode'] as String?,
      series: series.hasData ? series : null,
      publishing: publishing.hasData ? publishing : null,
      editionTitle: json['edition_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      links: rawLinks,
      releases: rawReleases,
    );
  }
}
