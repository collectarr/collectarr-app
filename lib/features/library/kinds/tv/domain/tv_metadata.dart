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
    this.id,
    this.personId,
    this.artistId,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.sortName,
    this.instrument,
    this.stringValue = false,
  });

  final String name;
  final String? role;
  final String? character;
  final String? imageUrl;
  final String? id;
  final String? personId;
  final String? artistId;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? sortName;
  final String? instrument;
  final bool stringValue;

  Object toJsonValue() => stringValue
      ? name
      : <String, dynamic>{
          if (id != null) 'id': id,
          if (personId != null) 'person_id': personId,
          if (artistId != null) 'artist_id': artistId,
          'name': name,
          if (role != null) 'role': role,
          if (roleId != null) 'role_id': roleId,
          if (sequence != null) 'sequence': sequence,
          if (creditedName != null) 'credited_name': creditedName,
          if (joinPhrase != null) 'join_phrase': joinPhrase,
          if (imageUrl != null) 'image_url': imageUrl,
          if (sortName != null) 'sort_name': sortName,
          if (instrument != null) 'instrument': instrument,
          if (character != null) 'character': character,
        };

  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(toJsonValue() as Map);

  TvPersonCredit withEditedIdentity({
    required String name,
    required String? role,
  }) =>
      TvPersonCredit(
        name: name,
        role: role,
        character: character,
        imageUrl: imageUrl,
        id: id,
        personId: personId,
        artistId: artistId,
        roleId: roleId,
        sequence: sequence,
        creditedName: creditedName,
        joinPhrase: joinPhrase,
        sortName: sortName,
        instrument: instrument,
        stringValue: false,
      );

  factory TvPersonCredit.fromJsonValue(Object value) {
    if (value is String) {
      return TvPersonCredit(name: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException('TV person must be a string or object.');
    }
    return TvPersonCredit.fromJson(value);
  }

  factory TvPersonCredit.fromJson(Map<String, dynamic> json) {
    return TvPersonCredit(
      name: (json['name'] as String?) ?? '',
      role: json['role'] as String?,
      character: json['character'] as String?,
      imageUrl: json['image_url'] as String?,
      id: json['id'] as String?,
      personId: json['person_id'] as String?,
      artistId: json['artist_id'] as String?,
      roleId: json['role_id'] as String?,
      sequence: _asInt(json['sequence']),
      creditedName: json['credited_name'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      sortName: json['sort_name'] as String?,
      instrument: json['instrument'] as String?,
    );
  }
}

@immutable
class TvCharacterMetadata {
  const TvCharacterMetadata({
    required this.name,
    this.id,
    this.characterId,
    this.aliases = const [],
    this.role,
    this.description,
    this.imageUrl,
    this.stringValue = false,
  });

  final String name;
  final String? id;
  final String? characterId;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? imageUrl;
  final bool stringValue;

  factory TvCharacterMetadata.fromJsonValue(Object value) {
    if (value is String) {
      return TvCharacterMetadata(name: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException('TV character must be a string or object.');
    }
    return TvCharacterMetadata.fromJson(value);
  }

  factory TvCharacterMetadata.fromJson(Map<String, dynamic> value) {
    return TvCharacterMetadata(
      name: value['name'] as String? ?? '',
      id: value['id'] as String?,
      characterId: value['character_id'] as String?,
      aliases: _stringValues(value['aliases'], 'TV character aliases'),
      role: value['role'] as String?,
      description: value['description'] as String?,
      imageUrl: value['image_url'] as String?,
    );
  }

  Object toJsonValue() => stringValue
      ? name
      : <String, dynamic>{
          if (id != null) 'id': id,
          if (characterId != null) 'character_id': characterId,
          'name': name,
          if (aliases.isNotEmpty) 'aliases': aliases,
          if (role != null) 'role': role,
          if (description != null) 'description': description,
          if (imageUrl != null) 'image_url': imageUrl,
        };
}

@immutable
class TvIdentifierMetadata {
  const TvIdentifierMetadata({
    required this.value,
    this.id,
    this.identifierType,
    this.normalizedValue,
    this.isPrimary,
    this.stringValue = false,
  });

  final String value;
  final String? id;
  final String? identifierType;
  final String? normalizedValue;
  final bool? isPrimary;
  final bool stringValue;

  factory TvIdentifierMetadata.fromJsonValue(Object value) {
    if (value is String) {
      return TvIdentifierMetadata(value: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException('TV identifier must be a string or object.');
    }
    return TvIdentifierMetadata(
      value: value['value'] as String? ?? '',
      id: value['id'] as String?,
      identifierType: value['identifier_type'] as String?,
      normalizedValue: value['normalized_value'] as String?,
      isPrimary: value['is_primary'] as bool?,
    );
  }

  Object toJsonValue() => stringValue
      ? value
      : <String, dynamic>{
          if (id != null) 'id': id,
          if (identifierType != null) 'identifier_type': identifierType,
          'value': value,
          if (normalizedValue != null) 'normalized_value': normalizedValue,
          if (isPrimary != null) 'is_primary': isPrimary,
        };
}

@immutable
class TvEpisodeMetadata {
  const TvEpisodeMetadata({
    required this.position,
    this.id,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.title,
    this.description,
    this.overview,
    this.airDate,
    this.originalAirDate,
    this.runtimeMinutes,
    this.pageCount,
  });

  final int position;
  final String? id;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final String? title;
  final String? description;
  final String? overview;
  final PartialDate? airDate;
  final PartialDate? originalAirDate;
  final int? runtimeMinutes;
  final int? pageCount;

  int get number => episodeNumber ?? position;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (episodeTitle != null) 'episode_title': episodeTitle,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (overview != null) 'overview': overview,
        if (airDate != null) 'air_date': airDate!.toJson(),
        if (originalAirDate != null)
          'original_air_date': originalAirDate!.toJson(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (pageCount != null) 'page_count': pageCount,
        'position': position,
      };

  factory TvEpisodeMetadata.fromJson(Map<String, dynamic> json) {
    final position = _asInt(json['position']);
    if (position == null || position < 0) {
      throw const FormatException('TV episode requires a position.');
    }
    return TvEpisodeMetadata(
      position: position,
      id: json['id'] as String?,
      seasonNumber: _asInt(json['season_number']),
      episodeNumber: _asInt(json['episode_number']),
      episodeTitle: json['episode_title'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      overview: json['overview'] as String?,
      airDate: PartialDate.tryParse(json['air_date']),
      originalAirDate: PartialDate.tryParse(json['original_air_date']),
      runtimeMinutes: _asInt(json['runtime_minutes']),
      pageCount: _asInt(json['page_count']),
    );
  }
}

@immutable
class TvSeasonMetadata {
  const TvSeasonMetadata({
    required this.seasonNumber,
    this.id,
    this.title,
    this.description,
    this.airDate,
    this.releaseDate,
    this.episodeCount,
    this.episodes = const [],
  });

  final int seasonNumber;
  final String? id;
  final String? title;
  final String? description;
  final PartialDate? airDate;
  final PartialDate? releaseDate;
  final int? episodeCount;
  final List<TvEpisodeMetadata> episodes;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'season_number': seasonNumber,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toJson(),
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodes.isNotEmpty)
          'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  factory TvSeasonMetadata.fromJson(Map<String, dynamic> json) {
    final seasonNumber = _asInt(json['season_number']);
    if (seasonNumber == null || seasonNumber < 0) {
      throw const FormatException('TV season requires a number.');
    }
    return TvSeasonMetadata(
      seasonNumber: seasonNumber,
      title: json['title'] as String?,
      id: json['id'] as String?,
      description: json['description'] as String?,
      airDate: PartialDate.tryParse(json['air_date']),
      releaseDate: PartialDate.tryParse(json['release_date']),
      episodeCount: _asInt(json['episode_count']),
      episodes: _tvObjectList(json['episodes'], 'TV season episodes')
          .map(TvEpisodeMetadata.fromJson)
          .toList(growable: false),
    );
  }
}

@immutable
class TvMediaMetadata implements JsonEncodable {
  const TvMediaMetadata({
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
    this.color,
    this.layers,
    this.frameRate,
    this.bitDepth,
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
  final String? color;
  final String? layers;
  final String? frameRate;
  final int? bitDepth;

  factory TvMediaMetadata.fromJson(Map<String, dynamic> json) {
    final position = _asInt(json['position']);
    if (position == null || position < 0) {
      throw const FormatException('TV media requires a non-negative position.');
    }
    return TvMediaMetadata(
      position: position,
      id: json['id'] as String?,
      mediaNumber: _asInt(json['media_number']),
      mediaType: json['media_type'] as String?,
      title: json['title'] as String?,
      episodeCount: _asInt(json['episode_count']),
      runtimeMinutes: _asInt(json['runtime_minutes']),
      regionCode: json['region_code'] as String?,
      encoding: json['encoding'] as String?,
      aspectRatio: json['aspect_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      resolution: json['resolution'] as String?,
      hdrFormat: json['hdr_format'] as String?,
      color: json['color'] as String?,
      layers: json['layers'] as String?,
      frameRate: json['frame_rate'] as String?,
      bitDepth: _asInt(json['bit_depth']),
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
        if (color != null) 'color': color,
        if (layers != null) 'layers': layers,
        if (frameRate != null) 'frame_rate': frameRate,
        if (bitDepth != null) 'bit_depth': bitDepth,
      };
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
    this.description,
    this.catalogNumber,
    this.color,
    this.layers,
    this.nrDiscs,
    this.plotDescription,
    this.plotSummary,
    this.releaseStatus,
    this.subtitle,
    this.seriesTags,
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
    this.seasons = const [],
    this.media = const [],
    this.episodes = const [],
    this.contributors = const [],
    this.characters = const [],
    this.characterDetails = const [],
    this.identifiers = const [],
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
  final String? description;
  final String? catalogNumber;
  final String? color;
  final String? layers;
  final int? nrDiscs;
  final String? plotDescription;
  final String? plotSummary;
  final String? releaseStatus;
  final String? subtitle;
  final List<String>? seriesTags;
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
  final List<TvSeasonMetadata> seasons;
  final List<TvMediaMetadata> media;
  final List<TvEpisodeMetadata> episodes;
  final List<TvPersonCredit> contributors;
  final List<TvCharacterMetadata> characters;
  final List<TvCharacterMetadata> characterDetails;
  final List<TvIdentifierMetadata> identifiers;
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
  final List<TvPersonCredit> creators;
  final List<TrailerLinkDto> links;

  List<TvPersonCredit> get cast =>
      creators.where((credit) => _isTvCastRole(credit.role)).toList();

  List<TvPersonCredit> get crew =>
      creators.where((credit) => !_isTvCastRole(credit.role)).toList();

  DateTime? get releaseDate => releaseDateParts?.asDateTime;

  @override
  Map<String, dynamic> toJson() => {
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
        if (description != null) 'description': description,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (color != null) 'color': color,
        if (layers != null) 'layers': layers,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (subtitle != null) 'subtitle': subtitle,
        if (seriesTags != null) 'series_tags': seriesTags,
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
        if (contentRating != null) 'age_rating': contentRating,
        if (seasonCount != null) 'season_count': seasonCount,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodeRuntimeMinutes != null)
          'episode_runtime_minutes': episodeRuntimeMinutes,
        if (seasons.isNotEmpty)
          'seasons': seasons.map((e) => e.toJson()).toList(),
        if (media.isNotEmpty) 'media': media.map((e) => e.toJson()).toList(),
        if (episodes.isNotEmpty)
          'episodes': episodes.map((e) => e.toJson()).toList(),
        if (contributors.isNotEmpty)
          'contributors': contributors.map((e) => e.toJsonValue()).toList(),
        if (characters.isNotEmpty)
          'characters': characters.map((e) => e.toJsonValue()).toList(),
        if (characterDetails.isNotEmpty)
          'character_details':
              characterDetails.map((e) => e.toJsonValue()).toList(),
        if (identifiers.isNotEmpty)
          'identifiers': identifiers.map((e) => e.toJsonValue()).toList(),
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (itemNumber != null) 'item_number': itemNumber,
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
    String? description,
    String? catalogNumber,
    String? color,
    String? layers,
    int? nrDiscs,
    String? plotDescription,
    String? plotSummary,
    String? releaseStatus,
    String? subtitle,
    List<String>? seriesTags,
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
    List<TvMediaMetadata>? media,
    List<TvEpisodeMetadata>? episodes,
    List<TvPersonCredit>? contributors,
    List<TvCharacterMetadata>? characters,
    List<TvCharacterMetadata>? characterDetails,
    List<TvIdentifierMetadata>? identifiers,
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
    List<TvPersonCredit>? creators,
    List<TrailerLinkDto>? links,
  }) {
    final updatedCreators = creators ??
        (cast == null && crew == null
            ? this.creators
            : [...cast ?? this.cast, ...crew ?? this.crew]);
    return TvSeriesMetadata(
      title: title ?? this.title,
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
      description: description ?? this.description,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      color: color ?? this.color,
      layers: layers ?? this.layers,
      nrDiscs: nrDiscs ?? this.nrDiscs,
      plotDescription: plotDescription ?? this.plotDescription,
      plotSummary: plotSummary ?? this.plotSummary,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      subtitle: subtitle ?? this.subtitle,
      seriesTags: seriesTags ?? this.seriesTags,
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
      seasons: seasons ?? this.seasons,
      media: media ?? this.media,
      episodes: episodes ?? this.episodes,
      contributors: contributors ?? this.contributors,
      characters: characters ?? this.characters,
      characterDetails: characterDetails ?? this.characterDetails,
      identifiers: identifiers ?? this.identifiers,
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
      creators: updatedCreators,
      links: links ?? this.links,
    );
  }

  factory TvSeriesMetadata.fromJson(Map<String, dynamic> json) {
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

    final resolvedSeasonNumber = (json['season_number'] as num?)?.toInt();
    final resolvedEpisodeNumber = (json['episode_number'] as num?)?.toInt();
    final resolvedSeriesTitle = json['series_title'] as String?;

    return TvSeriesMetadata(
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
      synopsis: json['synopsis'] as String?,
      description: json['description'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      color: json['color'] as String?,
      layers: json['layers'] as String?,
      nrDiscs: _asInt(json['nr_discs']),
      plotDescription: json['plot_description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      releaseStatus: json['release_status'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesTags: (json['series_tags'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
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
      contentRating: json['age_rating'] as String?,
      seasonCount: _asInt(json['season_count']),
      episodeCount: _asInt(json['episode_count']),
      episodeRuntimeMinutes: _asInt(json['episode_runtime_minutes']),
      seasons: _tvObjectList(json['seasons'], 'TV seasons')
          .map(TvSeasonMetadata.fromJson)
          .toList(growable: false),
      media: _tvObjectList(json['media'], 'TV media')
          .map(TvMediaMetadata.fromJson)
          .toList(growable: false),
      episodes: _tvObjectList(json['episodes'], 'TV episodes')
          .map(TvEpisodeMetadata.fromJson)
          .toList(growable: false),
      contributors: _tvTypedValues(
        json['contributors'],
        'TV contributors',
        TvPersonCredit.fromJsonValue,
      ),
      characters: _tvTypedValues(
        json['characters'],
        'TV characters',
        TvCharacterMetadata.fromJsonValue,
      ),
      characterDetails: _tvObjectList(
        json['character_details'],
        'TV character details',
      ).map(TvCharacterMetadata.fromJson).toList(growable: false),
      identifiers: _tvTypedValues(
        json['identifiers'],
        'TV identifiers',
        TvIdentifierMetadata.fromJsonValue,
      ),
      seriesTitle: resolvedSeriesTitle,
      seasonNumber: resolvedSeasonNumber,
      episodeNumber: resolvedEpisodeNumber,
      itemNumber: json['item_number'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      region: json['region'] as String?,
      packaging: json['packaging'] as String?,
      distributor: json['distributor'] as String?,
      screenRatio: json['screen_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant_name'] as String?,
      creators: _tvTypedValues(
        json['creators'],
        'TV creators',
        TvPersonCredit.fromJsonValue,
      ),
      links: rawLinks,
    );
  }
}

List<String> _stringValues(Object? value, String label) {
  if (value == null) return const [];
  if (value is! List) throw FormatException('$label must be a list.');
  return value.map((entry) {
    if (entry is! String) throw FormatException('$label must contain strings.');
    return entry;
  }).toList(growable: false);
}

List<Map<String, dynamic>> _tvObjectList(Object? value, String label) {
  if (value == null) return const [];
  if (value is! List) throw FormatException('$label must be a list.');
  return value.map((entry) {
    if (entry is! Map) throw FormatException('$label entries must be objects.');
    return Map<String, dynamic>.from(entry);
  }).toList(growable: false);
}

List<T> _tvTypedValues<T>(
  Object? value,
  String label,
  T Function(Object) decode,
) {
  if (value == null) return const [];
  if (value is! List) throw FormatException('$label must be a list.');
  return value.map<T>((entry) {
    if (entry == null) throw FormatException('$label values cannot be null.');
    return decode(entry as Object);
  }).toList(growable: false);
}

bool _isTvCastRole(String? role) {
  final normalized = role?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return true;
  return const [
    'actor',
    'voice',
    'guest star',
    'cameo',
    'narrator',
    'cast',
  ].any(normalized.contains);
}
