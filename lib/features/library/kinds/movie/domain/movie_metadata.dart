import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

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

@immutable
class MovieMediaMetadata {
  const MovieMediaMetadata({
    this.id,
    required this.mediaNumber,
    this.mediaType,
    this.title,
    this.aspectRatio,
    this.screenRatio,
    this.color,
    this.numDiscs,
    this.nrLayers,
    this.layers,
    this.audioTracks,
    this.subtitles,
  });

  final String? id;
  final int mediaNumber;
  final String? mediaType;
  final String? title;
  final String? aspectRatio;
  final String? screenRatio;
  final String? color;
  final int? numDiscs;
  final int? nrLayers;
  final String? layers;
  final String? audioTracks;
  final String? subtitles;

  factory MovieMediaMetadata.fromJson(Map<String, dynamic> json) {
    final mediaNumber = (json['media_number'] as num?)?.toInt();
    if (mediaNumber == null || mediaNumber < 1) {
      throw const FormatException(
        'Movie media requires a positive media_number.',
      );
    }
    return MovieMediaMetadata(
      id: json['id'] as String?,
      mediaNumber: mediaNumber,
      mediaType: json['media_type'] as String?,
      title: json['title'] as String?,
      aspectRatio: json['aspect_ratio'] as String?,
      screenRatio: json['screen_ratio'] as String?,
      color: json['color'] as String?,
      numDiscs: (json['num_discs'] as num?)?.toInt(),
      nrLayers: (json['nr_layers'] as num?)?.toInt(),
      layers: json['layers'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'media_number': mediaNumber,
        if (mediaType != null) 'media_type': mediaType,
        if (title != null) 'title': title,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (color != null) 'color': color,
        if (numDiscs != null) 'num_discs': numDiscs,
        if (nrLayers != null) 'nr_layers': nrLayers,
        if (layers != null) 'layers': layers,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
      };
}

@immutable
class MovieCatalogMetadata implements JsonEncodable {
  const MovieCatalogMetadata({
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.titleExtension,
    this.searchAliases = const [],
    this.originalTitle,
    this.sortTitle,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
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
    this.releaseDateParts,
    this.releaseStatus,
    this.directors = const [],
    this.writers = const [],
    this.producers = const [],
    this.cast = const [],
    this.crew = const [],
    this.editionTitle,
    this.subtitle,
    this.barcode,
    this.catalogNumber,
    this.physicalFormat,
    this.publisher,
    this.region,
    this.packaging,
    this.distributor,
    this.hdr,
    this.variant,
    this.itemNumber,
    this.seriesTitle,
    this.audioTracks,
    this.subtitles,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.layers,
    this.media = const [],
    this.seriesTags = const [],
    this.description,
    this.plotSummary,
    this.plotDescription,
    this.characters = const [],
    this.characterDetails = const [],
    this.creators = const [],
    this.contributors = const [],
    this.links = const [],
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.movie;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? titleExtension;
  final List<String> searchAliases;
  final String? originalTitle;
  final String? sortTitle;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
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
  final PartialDate? releaseDateParts;
  final String? releaseStatus;
  final List<MoviePersonCredit> directors;
  final List<MoviePersonCredit> writers;
  final List<MoviePersonCredit> producers;
  final List<MoviePersonCredit> cast;
  final List<MoviePersonCredit> crew;
  final String? editionTitle;
  final String? subtitle;
  final String? barcode;
  final String? catalogNumber;
  final String? physicalFormat;
  final String? publisher;
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? hdr;
  final String? variant;
  final String? itemNumber;
  final String? seriesTitle;
  final String? audioTracks;
  final String? subtitles;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? layers;
  final List<MovieMediaMetadata> media;
  final List<String> seriesTags;
  final String? description;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>> characters;
  final List<Map<String, dynamic>> characterDetails;
  final List<Map<String, dynamic>> creators;
  final List<Map<String, dynamic>> contributors;
  final List<TrailerLinkDto> links;

  int? get releaseYear => releaseDateParts?.year ?? releaseDate?.year;

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (displayTitle != null) 'display_title': displayTitle,
      if (localizedTitle != null) 'localized_title': localizedTitle,
      if (titleExtension != null) 'title_extension': titleExtension,
      if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
      if (originalTitle != null) 'original_title': originalTitle,
      if (sortTitle != null) 'sort_key': sortTitle,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      if (releaseDateParts != null)
        'release_date_parts': releaseDateParts!.toJson(),
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (subtitle != null) 'subtitle': subtitle,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (description != null) 'description': description,
      if (plotSummary != null) 'plot_summary': plotSummary,
      if (plotDescription != null) 'plot_description': plotDescription,
      if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
      if (characters.isNotEmpty) 'characters': characters,
      if (characterDetails.isNotEmpty) 'character_details': characterDetails,
      if (contributors.isNotEmpty) 'contributors': contributors,
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
      if (media.isNotEmpty) 'media': media.map((e) => e.toJson()).toList(),
      if (directors.isNotEmpty)
        'directors': directors.map((e) => e.toJson()).toList(),
      if (writers.isNotEmpty)
        'writers': writers.map((e) => e.toJson()).toList(),
      if (producers.isNotEmpty)
        'producers': producers.map((e) => e.toJson()).toList(),
      if (cast.isNotEmpty) 'cast': cast.map((e) => e.toJson()).toList(),
      if (crew.isNotEmpty) 'crew': crew.map((e) => e.toJson()).toList(),
      if (editionTitle != null) 'edition_title': editionTitle,
      if (barcode != null) 'barcode': barcode,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (publisher != null) 'publisher': publisher,
      if (region != null) 'region': region,
      if (packaging != null) 'packaging': packaging,
      if (distributor != null) 'distributor': distributor,
      if (hdr != null) 'hdr': hdr,
      if (variant != null) 'variant_name': variant,
      if (itemNumber != null) 'item_number': itemNumber,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (audioTracks != null) 'audio_tracks': audioTracks,
      if (subtitles != null) 'subtitles': subtitles,
      if (color != null) 'color': color,
      if (nrDiscs != null) 'nr_discs': nrDiscs,
      if (screenRatio != null) 'screen_ratio': screenRatio,
      if (layers != null) 'layers': layers,
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
  }

  MovieCatalogMetadata copyWith({
    String? title,
    String? displayTitle,
    String? localizedTitle,
    String? titleExtension,
    List<String>? searchAliases,
    String? originalTitle,
    String? sortTitle,
    String? synopsis,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? coverImageData,
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
    PartialDate? releaseDateParts,
    String? releaseStatus,
    List<MoviePersonCredit>? directors,
    List<MoviePersonCredit>? writers,
    List<MoviePersonCredit>? producers,
    List<MoviePersonCredit>? cast,
    List<MoviePersonCredit>? crew,
    String? editionTitle,
    String? subtitle,
    String? barcode,
    String? catalogNumber,
    String? physicalFormat,
    String? publisher,
    String? region,
    String? packaging,
    String? distributor,
    String? hdr,
    String? variant,
    String? itemNumber,
    String? seriesTitle,
    String? audioTracks,
    String? subtitles,
    String? color,
    int? nrDiscs,
    String? screenRatio,
    String? layers,
    List<MovieMediaMetadata>? media,
    List<String>? seriesTags,
    String? description,
    String? plotSummary,
    String? plotDescription,
    List<Map<String, dynamic>>? characters,
    List<Map<String, dynamic>>? characterDetails,
    List<Map<String, dynamic>>? contributors,
    List<Map<String, dynamic>>? creators,
    List<TrailerLinkDto>? links,
  }) {
    return MovieCatalogMetadata(
      title: title ?? this.title,
      displayTitle: displayTitle ?? this.displayTitle,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      searchAliases: searchAliases ?? this.searchAliases,
      originalTitle: originalTitle ?? this.originalTitle,
      sortTitle: sortTitle ?? this.sortTitle,
      synopsis: synopsis ?? this.synopsis,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      coverImageData: coverImageData ?? this.coverImageData,
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
      releaseDateParts: releaseDateParts ?? this.releaseDateParts,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      directors: directors ?? this.directors,
      writers: writers ?? this.writers,
      producers: producers ?? this.producers,
      cast: cast ?? this.cast,
      crew: crew ?? this.crew,
      editionTitle: editionTitle ?? this.editionTitle,
      subtitle: subtitle ?? this.subtitle,
      barcode: barcode ?? this.barcode,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      publisher: publisher ?? this.publisher,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      hdr: hdr ?? this.hdr,
      variant: variant ?? this.variant,
      itemNumber: itemNumber ?? this.itemNumber,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitles: subtitles ?? this.subtitles,
      color: color ?? this.color,
      nrDiscs: nrDiscs ?? this.nrDiscs,
      screenRatio: screenRatio ?? this.screenRatio,
      layers: layers ?? this.layers,
      media: media ?? this.media,
      seriesTags: seriesTags ?? this.seriesTags,
      description: description ?? this.description,
      plotSummary: plotSummary ?? this.plotSummary,
      plotDescription: plotDescription ?? this.plotDescription,
      characters: characters ?? this.characters,
      characterDetails: characterDetails ?? this.characterDetails,
      contributors: contributors ?? this.contributors,
      creators: creators ?? this.creators,
      links: links ?? this.links,
    );
  }

  factory MovieCatalogMetadata.fromJson(Map<String, dynamic> json) {
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

    final media = _movieMediaList(json['media']);

    return MovieCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      searchAliases: _stringList(json['search_aliases']),
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_key'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      releaseStatus: json['release_status'] as String?,
      subtitle: json['subtitle'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      description: json['description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      plotDescription: json['plot_description'] as String?,
      seriesTags: _stringList(json['series_tags']),
      characters: _mapList(json['characters']),
      characterDetails: _mapList(json['character_details']),
      contributors: _mapList(json['contributors']),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
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
      releaseDate: PartialDate.tryParse(json['release_date'])?.asDateTime,
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
      editionTitle: json['edition_title'] as String?,
      barcode: json['barcode'] as String?,
      physicalFormat: json['physical_format'] as String?,
      publisher: json['publisher'] as String?,
      region: json['region'] as String?,
      packaging: json['packaging'] as String?,
      distributor: json['distributor'] as String?,
      hdr: json['hdr'] as String?,
      variant: json['variant_name'] as String?,
      itemNumber: json['item_number'] as String?,
      seriesTitle: json['series_title'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      color: json['color'] as String?,
      nrDiscs: (json['nr_discs'] as num?)?.toInt(),
      screenRatio: json['screen_ratio'] as String?,
      layers: json['layers'] as String?,
      creators: rawCreators,
      links: rawLinks,
      media: media,
    );
  }
}

List<MovieMediaMetadata> _movieMediaList(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Movie media contents must be a list.');
  }
  return [
    for (final entry in value)
      if (entry is Map)
        MovieMediaMetadata.fromJson(Map<String, dynamic>.from(entry))
      else
        throw const FormatException('Movie media entry must be an object.'),
  ];
}

List<String> _stringList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is String) entry
      ]
    : const [];

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const [];
