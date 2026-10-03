import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';

/// Canonical metadata for one concrete Board Game edition.
@immutable
final class BoardGameMetadata implements JsonEncodable {
  const BoardGameMetadata({
    required this.title,
    this.sortKey,
    this.originalTitle,
    this.localizedTitle,
    this.titleExtension,
    this.subtitle,
    this.searchAliases = const [],
    this.synopsis,
    this.description,
    this.plotSummary,
    this.plotDescription,
    this.ageRating,
    this.audienceRating,
    this.barcode,
    this.catalogNumber,
    this.itemNumber,
    this.contributors = const [],
    this.country,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.designers = const [],
    this.artists = const [],
    this.editionTitle,
    this.expansionFor,
    this.expansions = const [],
    this.externalLinks = const [],
    this.families = const [],
    this.categories = const [],
    this.genres = const [],
    this.identifiers = const [],
    this.language,
    this.languages = const [],
    this.maxPlayers,
    this.maxPlaytimeMinutes,
    this.mechanics = const [],
    this.minimumAge,
    this.minPlayers,
    this.minPlaytimeMinutes,
    this.originalLanguage,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.platforms = const [],
    this.playingTimeMinutes,
    this.publisher,
    this.publishers = const [],
    this.rankings = const [],
    this.releaseDate,
    this.releaseDateParts,
    this.releaseStatus,
    this.seriesTitle,
    this.seriesTags = const [],
    this.themes = const [],
    this.variantName,
    this.yearPublished,
    this.recommendedPlayers,
    this.bestPlayers,
    this.complexityWeight,
    this.bggRating,
    this.bggRatingCount,
    this.bggRank,
    this.characters = const [],
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.boardgame;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? sortKey;
  final String? originalTitle;
  final String? localizedTitle;
  final String? titleExtension;
  final String? subtitle;
  final List<String> searchAliases;
  final String? synopsis;
  final String? description;
  final String? plotSummary;
  final String? plotDescription;
  final String? ageRating;
  final String? audienceRating;
  final String? barcode;
  final String? catalogNumber;
  final String? itemNumber;
  final List<BoardGamePersonCredit> contributors;
  final String? country;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String> designers;
  final List<String> artists;
  final String? editionTitle;
  final String? expansionFor;
  final List<String> expansions;
  final List<BoardGameLink> externalLinks;
  final List<String> families;
  final List<String> categories;
  final List<String> genres;
  final List<BoardGameIdentifier> identifiers;
  final String? language;
  final List<String> languages;
  final int? maxPlayers;
  final int? maxPlaytimeMinutes;
  final List<String> mechanics;
  final int? minimumAge;
  final int? minPlayers;
  final int? minPlaytimeMinutes;
  final String? originalLanguage;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<String> platforms;
  final int? playingTimeMinutes;
  final String? publisher;
  final List<String> publishers;
  final List<String> rankings;
  final PartialDate? releaseDate;
  final PartialDate? releaseDateParts;
  final String? releaseStatus;
  final String? seriesTitle;
  final List<String> seriesTags;
  final List<String> themes;
  final String? variantName;
  final int? yearPublished;
  final String? recommendedPlayers;
  final String? bestPlayers;
  final double? complexityWeight;
  final double? bggRating;
  final int? bggRatingCount;
  final int? bggRank;
  final List<BoardGameCharacter> characters;

  /// Credit values used by catalog presentation, derived from typed fields.
  List<BoardGamePersonCredit> get credits => [
        ...contributors,
        ...designers
            .map((name) => BoardGamePersonCredit(name: name, role: 'Designer')),
        ...artists
            .map((name) => BoardGamePersonCredit(name: name, role: 'Artist')),
      ];

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        if (sortKey != null) 'sort_key': sortKey,
        if (originalTitle != null) 'original_title': originalTitle,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (subtitle != null) 'subtitle': subtitle,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (synopsis != null) 'synopsis': synopsis,
        if (description != null) 'description': description,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (itemNumber != null) 'item_number': itemNumber,
        if (contributors.isNotEmpty)
          'contributors': contributors.map((value) => value.toJson()).toList(),
        if (country != null) 'country': country,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (designers.isNotEmpty) 'designers': designers,
        if (artists.isNotEmpty) 'artists': artists,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (expansionFor != null) 'expansion_for': expansionFor,
        if (expansions.isNotEmpty) 'expansions': expansions,
        if (externalLinks.isNotEmpty)
          'external_links':
              externalLinks.map((value) => value.toJson()).toList(),
        if (families.isNotEmpty) 'families': families,
        if (categories.isNotEmpty) 'categories': categories,
        if (genres.isNotEmpty) 'genres': genres,
        if (identifiers.isNotEmpty)
          'identifiers': identifiers.map((value) => value.toJson()).toList(),
        if (language != null) 'language': language,
        if (languages.isNotEmpty) 'languages': languages,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (maxPlaytimeMinutes != null)
          'max_playtime_minutes': maxPlaytimeMinutes,
        if (mechanics.isNotEmpty) 'mechanics': mechanics,
        if (minimumAge != null) 'min_age': minimumAge,
        if (minPlayers != null) 'min_players': minPlayers,
        if (minPlaytimeMinutes != null)
          'min_playtime_minutes': minPlaytimeMinutes,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (platforms.isNotEmpty) 'platforms': platforms,
        if (playingTimeMinutes != null)
          'playing_time_minutes': playingTimeMinutes,
        if (publisher != null) 'publisher': publisher,
        if (publishers.isNotEmpty) 'publishers': publishers,
        if (rankings.isNotEmpty) 'rankings': rankings,
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
        if (themes.isNotEmpty) 'themes': themes,
        if (variantName != null) 'variant_name': variantName,
        if (yearPublished != null) 'year_published': yearPublished,
        if (recommendedPlayers != null)
          'recommended_players': recommendedPlayers,
        if (bestPlayers != null) 'best_players': bestPlayers,
        if (complexityWeight != null) 'complexity_weight': complexityWeight,
        if (bggRating != null) 'bgg_rating': bggRating,
        if (bggRatingCount != null) 'bgg_rating_count': bggRatingCount,
        if (bggRank != null) 'bgg_rank': bggRank,
        if (characters.isNotEmpty)
          'characters': characters.map((value) => value.toJson()).toList(),
      };

  factory BoardGameMetadata.fromJson(Map<String, dynamic> json) {
    return BoardGameMetadata(
      title: _string(json['title']) ?? '',
      sortKey: _string(json['sort_key']),
      originalTitle: _string(json['original_title']),
      localizedTitle: _string(json['localized_title']),
      titleExtension: _string(json['title_extension']),
      subtitle: _string(json['subtitle']),
      searchAliases: _stringList(json['search_aliases']),
      synopsis: _string(json['synopsis']),
      description: _string(json['description']),
      plotSummary: _string(json['plot_summary']),
      plotDescription: _string(json['plot_description']),
      ageRating: _string(json['age_rating']),
      audienceRating: _string(json['audience_rating']),
      barcode: _string(json['barcode']),
      catalogNumber: _string(json['catalog_number']),
      itemNumber: _string(json['item_number']),
      contributors: _objectsOrStrings(
          json['contributors'], BoardGamePersonCredit.fromJson),
      country: _string(json['country']),
      coverImageUrl: _string(json['cover_image_url']),
      thumbnailImageUrl: _string(json['thumbnail_image_url']),
      designers: _stringList(json['designers']),
      artists: _stringList(json['artists']),
      editionTitle: _string(json['edition_title']),
      expansionFor: _string(json['expansion_for']),
      expansions: _stringList(json['expansions']),
      externalLinks: _objects(json['external_links'], BoardGameLink.fromJson),
      families: _stringList(json['families']),
      categories: _stringList(json['categories']),
      genres: _stringList(json['genres']),
      identifiers:
          _objectsOrStrings(json['identifiers'], BoardGameIdentifier.fromJson),
      language: _string(json['language']),
      languages: _stringList(json['languages']),
      maxPlayers: _integer(json['max_players']),
      maxPlaytimeMinutes: _integer(json['max_playtime_minutes']),
      mechanics: _stringList(json['mechanics']),
      minimumAge: _integer(json['min_age']),
      minPlayers: _integer(json['min_players']),
      minPlaytimeMinutes: _integer(json['min_playtime_minutes']),
      originalLanguage: _string(json['original_language']),
      physicalFormat: _string(json['physical_format']),
      physicalFormatLabel: _string(json['physical_format_label']),
      platforms: _stringList(json['platforms']),
      playingTimeMinutes: _integer(json['playing_time_minutes']),
      publisher: _string(json['publisher']),
      publishers: _stringList(json['publishers']),
      rankings: _stringList(json['rankings']),
      releaseDate: PartialDate.tryParse(json['release_date']),
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      releaseStatus: _string(json['release_status']),
      seriesTitle: _string(json['series_title']),
      seriesTags: _stringList(json['series_tags']),
      themes: _stringList(json['themes']),
      variantName: _string(json['variant_name']),
      yearPublished: _integer(json['year_published']),
      recommendedPlayers: _string(json['recommended_players']),
      bestPlayers: _string(json['best_players']),
      complexityWeight: _decimal(json['complexity_weight']),
      bggRating: _decimal(json['bgg_rating']),
      bggRatingCount: _integer(json['bgg_rating_count']),
      bggRank: _integer(json['bgg_rank']),
      characters:
          _objectsOrStrings(json['characters'], BoardGameCharacter.fromJson),
    );
  }
}

@immutable
final class BoardGameIdentifier implements JsonEncodable {
  const BoardGameIdentifier({
    required this.identifierType,
    required this.value,
    this.id,
    this.normalizedValue,
    this.isPrimary = false,
  });

  final String? id;
  final String identifierType;
  final String value;
  final String? normalizedValue;
  final bool isPrimary;

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'identifier_type': identifierType,
        'value': value,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
      };

  factory BoardGameIdentifier.fromJson(Object? value) {
    if (value is String) {
      return BoardGameIdentifier(identifierType: 'other', value: value);
    }
    final json = _map(value);
    return BoardGameIdentifier(
      id: _string(json['id']),
      identifierType: _string(json['identifier_type']) ?? 'other',
      value: _string(json['value']) ?? '',
      normalizedValue: _string(json['normalized_value']),
      isPrimary: json['is_primary'] == true,
    );
  }
}

@immutable
final class BoardGamePersonCredit implements JsonEncodable {
  const BoardGamePersonCredit({
    required this.name,
    this.id,
    this.personId,
    this.artistId,
    this.role,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.imageUrl,
    this.sortName,
    this.instrument,
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
  final String? imageUrl;
  final String? sortName;
  final String? instrument;

  @override
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
        if (imageUrl != null) 'image_url': imageUrl,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
      };

  factory BoardGamePersonCredit.fromJson(Object? value) {
    if (value is String) return BoardGamePersonCredit(name: value);
    final json = _map(value);
    return BoardGamePersonCredit(
      id: _string(json['id']),
      personId: _string(json['person_id']),
      artistId: _string(json['artist_id']),
      name: _string(json['name']) ?? '',
      role: _string(json['role']),
      roleId: _string(json['role_id']),
      sequence: _integer(json['sequence']),
      creditedName: _string(json['credited_name']),
      joinPhrase: _string(json['join_phrase']),
      imageUrl: _string(json['image_url']),
      sortName: _string(json['sort_name']),
      instrument: _string(json['instrument']),
    );
  }
}

@immutable
final class BoardGameCharacter implements JsonEncodable {
  const BoardGameCharacter({
    required this.name,
    this.id,
    this.characterId,
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

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        'name': name,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  factory BoardGameCharacter.fromJson(Object? value) {
    if (value is String) return BoardGameCharacter(name: value);
    final json = _map(value);
    return BoardGameCharacter(
      id: _string(json['id']),
      characterId: _string(json['character_id']),
      name: _string(json['name']) ?? '',
      aliases: _stringList(json['aliases']),
      role: _string(json['role']),
      description: _string(json['description']),
      imageUrl: _string(json['image_url']),
    );
  }
}

@immutable
final class BoardGameLink implements JsonEncodable {
  const BoardGameLink({
    required this.url,
    this.id,
    this.label,
    this.title,
    this.site,
    this.name,
    this.kind,
    this.description,
    this.position,
    this.linkType,
  });

  final String? id;
  final String? label;
  final String? title;
  final String url;
  final String? site;
  final String? name;
  final String? kind;
  final String? description;
  final int? position;
  final String? linkType;

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (label != null) 'label': label,
        if (title != null) 'title': title,
        'url': url,
        if (site != null) 'site': site,
        if (name != null) 'name': name,
        if (kind != null) 'kind': kind,
        if (description != null) 'description': description,
        if (position != null) 'position': position,
        if (linkType != null) 'link_type': linkType,
      };

  factory BoardGameLink.fromJson(Object? value) {
    final json = _map(value);
    return BoardGameLink(
      id: _string(json['id']),
      label: _string(json['label']),
      title: _string(json['title']),
      url: _string(json['url']) ?? '',
      site: _string(json['site']),
      name: _string(json['name']),
      kind: _string(json['kind']),
      description: _string(json['description']),
      position: _integer(json['position']),
      linkType: _string(json['link_type']),
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

String? _string(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

int? _integer(Object? value) => value is num ? value.toInt() : null;

double? _decimal(Object? value) => value is num ? value.toDouble() : null;

List<String> _stringList(Object? value) => value is Iterable
    ? [
        for (final item in value)
          if (_string(item) case final text?) text
      ]
    : const [];

List<T> _objects<T>(Object? value, T Function(Object?) decode) =>
    value is Iterable
        ? [
            for (final item in value)
              if (item is Map) decode(item)
          ]
        : const [];

List<T> _objectsOrStrings<T>(Object? value, T Function(Object?) decode) =>
    value is Iterable
        ? [
            for (final item in value)
              if (item is String || item is Map) decode(item)
          ]
        : const [];
