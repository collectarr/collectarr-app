import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

@immutable
class MoviePersonCredit {
  const MoviePersonCredit({
    required this.name,
    this.id,
    this.personId,
    this.artistId,
    this.role,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.sortName,
    this.instrument,
    this.character,
    this.imageUrl,
  });

  final String? id;
  final String? personId;
  final String? artistId;
  final String name;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? sortName;
  final String? instrument;
  final String? character;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personId != null) 'person_id': personId,
        if (artistId != null) 'artist_id': artistId,
        'name': name,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (creditedName != null) 'credited_name': creditedName,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
        if (character != null) 'character': character,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  factory MoviePersonCredit.fromJson(Map<String, dynamic> json) {
    _checkKeys(
        json,
        const {
          'id',
          'person_id',
          'artist_id',
          'name',
          'role',
          'role_id',
          'sequence',
          'credited_name',
          'join_phrase',
          'sort_name',
          'instrument',
          'character',
          'image_url',
        },
        'Movie person credit');
    return MoviePersonCredit(
      id: json['id'] as String?,
      personId: json['person_id'] as String?,
      artistId: json['artist_id'] as String?,
      name: (json['name'] as String?) ?? '',
      role: json['role'] as String?,
      roleId: json['role_id'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      creditedName: json['credited_name'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      sortName: json['sort_name'] as String?,
      instrument: json['instrument'] as String?,
      character: json['character'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

@immutable
class MovieCharacter {
  const MovieCharacter({
    this.id,
    this.characterId,
    required this.name,
    this.aliases = const [],
    this.role,
    this.description,
    this.imageUrl,
  });

  final String? id;
  final String? characterId;
  final String name;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        'name': name,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  Object toJsonValue() => id == null &&
          characterId == null &&
          aliases.isEmpty &&
          role == null &&
          description == null &&
          imageUrl == null
      ? name
      : toJson();

  factory MovieCharacter.fromJson(Map<String, dynamic> json) {
    _checkKeys(
        json,
        const {
          'id',
          'character_id',
          'name',
          'aliases',
          'role',
          'description',
          'image_url',
        },
        'Movie character');
    return MovieCharacter(
      id: json['id'] as String?,
      characterId: json['character_id'] as String?,
      name: (json['name'] as String?) ?? '',
      aliases: _strictStringList(json['aliases'], 'Movie character aliases'),
      role: json['role'] as String?,
      description: json['description'] as String?,
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
    _checkKeys(
        json,
        const {
          'id',
          'media_number',
          'media_type',
          'title',
          'aspect_ratio',
          'screen_ratio',
          'color',
          'num_discs',
          'nr_layers',
          'layers',
          'audio_tracks',
          'subtitles',
        },
        'Movie media');
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
    this.editionTitle,
    this.subtitle,
    this.barcode,
    this.catalogNumber,
    this.physicalFormat,
    this.publisher,
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
    this.characters = const <MovieCharacter>[],
    this.characterDetails = const <MovieCharacter>[],
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
  final String? editionTitle;
  final String? subtitle;
  final String? barcode;
  final String? catalogNumber;
  final String? physicalFormat;
  final String? publisher;
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
  final List<MovieCharacter> characters;
  final List<MovieCharacter> characterDetails;
  final List<MoviePersonCredit> creators;
  final List<MoviePersonCredit> contributors;
  final List<TrailerLinkDto> links;

  int? get releaseYear => releaseDateParts?.year ?? releaseDate?.year;
  List<MoviePersonCredit> get allPeople => [
        ...creators,
        ...contributors,
      ];
  List<MoviePersonCredit> get directors => _peopleWithRole('director');
  List<MoviePersonCredit> get writers => _peopleWithRole('writer');
  List<MoviePersonCredit> get producers => _peopleWithRole('producer');
  List<MoviePersonCredit> get cast => allPeople
      .where((credit) => _isCastRole(credit.role))
      .toList(growable: false);
  List<MoviePersonCredit> get crew => allPeople
      .where((credit) => !_isCastRole(credit.role))
      .toList(growable: false);

  List<MoviePersonCredit> _peopleWithRole(String expected) => allPeople
      .where((credit) => credit.role?.toLowerCase().contains(expected) == true)
      .toList(growable: false);

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
      if (releaseDateParts != null)
        'release_date_parts': releaseDateParts!.toJson(),
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (subtitle != null) 'subtitle': subtitle,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (description != null) 'description': description,
      if (plotSummary != null) 'plot_summary': plotSummary,
      if (plotDescription != null) 'plot_description': plotDescription,
      if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
      if (characters.isNotEmpty)
        'characters': characters.map((value) => value.toJsonValue()).toList(),
      if (characterDetails.isNotEmpty)
        'character_details': characterDetails.map((e) => e.toJson()).toList(),
      if (contributors.isNotEmpty)
        'contributors': contributors.map((e) => e.toJson()).toList(),
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
      if (editionTitle != null) 'edition_title': editionTitle,
      if (barcode != null) 'barcode': barcode,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (publisher != null) 'publisher': publisher,
      if (variant != null) 'variant_name': variant,
      if (itemNumber != null) 'item_number': itemNumber,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (audioTracks != null) 'audio_tracks': audioTracks,
      if (subtitles != null) 'subtitles': subtitles,
      if (color != null) 'color': color,
      if (nrDiscs != null) 'nr_discs': nrDiscs,
      if (screenRatio != null) 'screen_ratio': screenRatio,
      if (layers != null) 'layers': layers,
      if (creators.isNotEmpty)
        'creators': creators.map((e) => e.toJson()).toList(),
      if (links.isNotEmpty) ...{
        if (links.any((l) => l.isTrailerLink))
          'trailer_urls':
              links.where((l) => l.isTrailerLink).map(_movieLinkJson).toList(),
        if (links.any((l) => l.isExternalLink))
          'external_links':
              links.where((l) => l.isExternalLink).map(_movieLinkJson).toList(),
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
    List<MoviePersonCredit>? creators,
    List<MoviePersonCredit>? contributors,
    String? editionTitle,
    String? subtitle,
    String? barcode,
    String? catalogNumber,
    String? physicalFormat,
    String? publisher,
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
    List<MovieCharacter>? characters,
    List<MovieCharacter>? characterDetails,
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
      creators: creators ?? this.creators,
      contributors: contributors ?? this.contributors,
      editionTitle: editionTitle ?? this.editionTitle,
      subtitle: subtitle ?? this.subtitle,
      barcode: barcode ?? this.barcode,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      publisher: publisher ?? this.publisher,
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
      links: links ?? this.links,
    );
  }

  factory MovieCatalogMetadata.fromJson(Map<String, dynamic> json) {
    _checkKeys(
        json,
        const {
          'title',
          'display_title',
          'localized_title',
          'title_extension',
          'search_aliases',
          'original_title',
          'sort_key',
          'synopsis',
          'cover_image_url',
          'thumbnail_image_url',
          'genres',
          'runtime_minutes',
          'audience_rating',
          'age_rating',
          'studio',
          'production_companies',
          'country',
          'original_language',
          'language',
          'release_date',
          'release_date_parts',
          'release_status',
          'creators',
          'contributors',
          'edition_title',
          'subtitle',
          'barcode',
          'catalog_number',
          'physical_format',
          'publisher',
          'variant_name',
          'item_number',
          'series_title',
          'audio_tracks',
          'subtitles',
          'color',
          'nr_discs',
          'screen_ratio',
          'layers',
          'media',
          'series_tags',
          'description',
          'plot_summary',
          'plot_description',
          'characters',
          'character_details',
          'trailer_urls',
          'external_links',
        },
        'Movie metadata');

    final media = _movieMediaList(json['media']);

    return MovieCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      searchAliases: _stringList(json['search_aliases'], 'search_aliases'),
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_key'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      releaseStatus: json['release_status'] as String?,
      subtitle: json['subtitle'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      description: json['description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      plotDescription: json['plot_description'] as String?,
      seriesTags: _stringList(json['series_tags'], 'series_tags'),
      characters: _movieCharacterList(json['characters'], allowStrings: true),
      characterDetails:
          _movieCharacterList(json['character_details'], allowStrings: false),
      creators: _moviePeopleList(json['creators']),
      contributors: _moviePeopleList(json['contributors']),
      genres: _stringList(json['genres'], 'genres'),
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      audienceRating: json['audience_rating'] as String?,
      ageRating: json['age_rating'] as String?,
      studio: json['studio'] as String?,
      productionCompanies:
          _stringList(json['production_companies'], 'production_companies'),
      country: json['country'] as String?,
      originalLanguage: json['original_language'] as String?,
      language: json['language'] as String?,
      releaseDate: PartialDate.tryParse(json['release_date'])?.asDateTime,
      editionTitle: json['edition_title'] as String?,
      barcode: json['barcode'] as String?,
      physicalFormat: json['physical_format'] as String?,
      publisher: json['publisher'] as String?,
      variant: json['variant_name'] as String?,
      itemNumber: json['item_number'] as String?,
      seriesTitle: json['series_title'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      color: json['color'] as String?,
      nrDiscs: (json['nr_discs'] as num?)?.toInt(),
      screenRatio: json['screen_ratio'] as String?,
      layers: json['layers'] as String?,
      links: _movieLinkList(json),
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

List<String> _stringList(Object? value, String fieldName) {
  if (value == null) return const [];
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('Movie $fieldName must be a list of strings.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<String> _strictStringList(Object? value, String fieldName) =>
    _stringList(value, fieldName);

List<MoviePersonCredit> _moviePeopleList(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Movie people must be a list.');
  }
  return [
    for (final entry in value)
      if (entry is String)
        MoviePersonCredit(name: entry)
      else if (entry is Map)
        MoviePersonCredit.fromJson(Map<String, dynamic>.from(entry))
      else
        throw const FormatException('Movie person must be a string or object.'),
  ];
}

List<MovieCharacter> _movieCharacterList(
  Object? value, {
  required bool allowStrings,
}) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Movie characters must be a list.');
  }
  return [
    for (final entry in value)
      if (entry is String && allowStrings)
        MovieCharacter(name: entry)
      else if (entry is Map)
        MovieCharacter.fromJson(Map<String, dynamic>.from(entry))
      else
        throw const FormatException('Movie character must be an object.'),
  ];
}

List<TrailerLinkDto> _movieLinkList(Map<String, dynamic> json) {
  final links = <TrailerLinkDto>[];
  for (final field in const ['trailer_urls', 'external_links']) {
    final value = json[field];
    if (value == null) continue;
    if (value is! List) {
      throw FormatException('Movie $field must be a list.');
    }
    for (final entry in value) {
      if (entry is! Map) {
        throw FormatException('Movie $field entries must be objects.');
      }
      links.add(TrailerLinkDto.fromJson(Map<String, dynamic>.from(entry)));
    }
  }
  return links;
}

Map<String, Object?> _movieLinkJson(TrailerLinkDto link) => {
      if (link.title != null) 'title': link.title,
      'url': link.url,
      if (link.description != null) 'description': link.description,
      'kind': link.kind,
    };

void _checkKeys(
  Map<String, dynamic> value,
  Set<String> allowed,
  String description,
) {
  final unknown = value.keys.where((key) => !allowed.contains(key)).toList()
    ..sort();
  if (unknown.isNotEmpty) {
    throw FormatException(
      '$description contains unsupported fields: ${unknown.join(', ')}.',
    );
  }
}

bool _isCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return true;
  return const {
    'actor',
    'voice',
    'voice actor',
    'guest star',
    'cameo',
    'narrator',
  }.any(normalized.contains);
}
