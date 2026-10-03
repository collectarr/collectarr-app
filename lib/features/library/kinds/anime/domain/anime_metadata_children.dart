import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AnimePersonMetadata {
  const AnimePersonMetadata({
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
    this.stringValue = false,
  });

  final String name;
  final String? id;
  final String? personId;
  final String? artistId;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? imageUrl;
  final String? sortName;
  final String? instrument;
  final bool stringValue;

  factory AnimePersonMetadata.fromJsonValue(Object value) {
    if (value is String) {
      return AnimePersonMetadata(name: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Anime person must be a string or object.');
    }
    return AnimePersonMetadata(
      name: value['name'] as String? ?? '',
      id: value['id'] as String?,
      personId: value['person_id'] as String?,
      artistId: value['artist_id'] as String?,
      role: value['role'] as String?,
      roleId: value['role_id'] as String?,
      sequence: (value['sequence'] as num?)?.toInt(),
      creditedName: value['credited_name'] as String?,
      joinPhrase: value['join_phrase'] as String?,
      imageUrl: value['image_url'] as String?,
      sortName: value['sort_name'] as String?,
      instrument: value['instrument'] as String?,
    );
  }

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
        };
}

@immutable
final class AnimeCharacterMetadata {
  const AnimeCharacterMetadata({
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

  factory AnimeCharacterMetadata.fromJsonValue(Object value) {
    if (value is String) {
      return AnimeCharacterMetadata(name: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException(
        'Anime character must be a string or object.',
      );
    }
    return AnimeCharacterMetadata.fromJson(value);
  }

  factory AnimeCharacterMetadata.fromJson(Map<String, dynamic> value) {
    return AnimeCharacterMetadata(
      name: value['name'] as String? ?? '',
      id: value['id'] as String?,
      characterId: value['character_id'] as String?,
      aliases: _stringValues(value['aliases']),
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
final class AnimeIdentifierMetadata {
  const AnimeIdentifierMetadata({
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

  factory AnimeIdentifierMetadata.fromJsonValue(Object value) {
    if (value is String) {
      return AnimeIdentifierMetadata(value: value, stringValue: true);
    }
    if (value is! Map<String, dynamic>) {
      throw const FormatException(
        'Anime identifier must be a string or object.',
      );
    }
    return AnimeIdentifierMetadata(
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
final class AnimeEpisodeMetadata {
  const AnimeEpisodeMetadata({
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

  factory AnimeEpisodeMetadata.fromJson(Map<String, dynamic> json) {
    final position = (json['position'] as num?)?.toInt();
    if (position == null || position < 0) {
      throw const FormatException('Anime episode requires a position.');
    }
    return AnimeEpisodeMetadata(
      position: position,
      id: json['id'] as String?,
      seasonNumber: (json['season_number'] as num?)?.toInt(),
      episodeNumber: (json['episode_number'] as num?)?.toInt(),
      episodeTitle: json['episode_title'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      overview: json['overview'] as String?,
      airDate: PartialDate.tryParse(json['air_date']),
      originalAirDate: PartialDate.tryParse(json['original_air_date']),
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
      pageCount: (json['page_count'] as num?)?.toInt(),
    );
  }

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
}

@immutable
final class AnimeSeasonMetadata {
  const AnimeSeasonMetadata({
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
  final List<AnimeEpisodeMetadata> episodes;

  factory AnimeSeasonMetadata.fromJson(Map<String, dynamic> json) {
    final seasonNumber = (json['season_number'] as num?)?.toInt();
    if (seasonNumber == null || seasonNumber < 0) {
      throw const FormatException('Anime season requires a number.');
    }
    return AnimeSeasonMetadata(
      seasonNumber: seasonNumber,
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      airDate: PartialDate.tryParse(json['air_date']),
      releaseDate: PartialDate.tryParse(json['release_date']),
      episodeCount: (json['episode_count'] as num?)?.toInt(),
      episodes: decodeAnimeObjectList(json['episodes'], 'season episodes')
          .map(AnimeEpisodeMetadata.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'season_number': seasonNumber,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toJson(),
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodes.isNotEmpty)
          'episodes': episodes.map((episode) => episode.toJson()).toList(),
      };
}

List<String> _stringValues(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Anime character aliases must be a list.');
  }
  return value.map((entry) {
    if (entry is! String) {
      throw const FormatException('Anime character aliases must be strings.');
    }
    return entry;
  }).toList(growable: false);
}

List<Map<String, dynamic>> decodeAnimeObjectList(Object? value, String label) {
  if (value == null) return const [];
  if (value is! List) throw FormatException('$label must be a list.');
  return value.map((entry) {
    if (entry is! Map<String, dynamic>) {
      throw FormatException('$label entries must be objects.');
    }
    return entry;
  }).toList(growable: false);
}

List<T> decodeAnimeTypedValues<T>(
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
