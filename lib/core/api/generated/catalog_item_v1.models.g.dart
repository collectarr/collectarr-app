// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tool/core_contracts/catalog-item-v1.json
// Contract SHA-256: 488e91853da0f08418a386ba7243f0d3210ddc9e1358a389d5e26ba124ec3504
part of 'collectarr_api.models.dart';

abstract interface class CatalogItemKindDetailsV1Dto {
  String get kind;
  String get title;
  Map<String, dynamic> toJson();
}

abstract interface class CatalogItemWriteKindDetailsV1Dto {
  String get kind;
  String get title;
  Map<String, dynamic> toJson();
}

String _catalogString(Object? value, String field,
    {int? minLength, int? maxLength}) {
  if (value is String &&
      (minLength == null || value.length >= minLength) &&
      (maxLength == null || value.length <= maxLength)) {
    return value;
  }
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

String? _catalogNullableString(Object? value, String field,
    {int? minLength, int? maxLength}) {
  if (value == null) return null;
  return _catalogString(
    value,
    field,
    minLength: minLength,
    maxLength: maxLength,
  );
}

int _catalogInt(Object? value, String field, {num? minimum, num? maximum}) {
  if (value is int &&
      (minimum == null || value >= minimum) &&
      (maximum == null || value <= maximum)) {
    return value;
  }
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

int? _catalogNullableInt(Object? value, String field,
    {num? minimum, num? maximum}) {
  if (value == null) return null;
  return _catalogInt(
    value,
    field,
    minimum: minimum,
    maximum: maximum,
  );
}

double _catalogDouble(Object? value, String field,
    {num? minimum, num? maximum}) {
  if (value is num &&
      value.isFinite &&
      (minimum == null || value >= minimum) &&
      (maximum == null || value <= maximum)) {
    return value.toDouble();
  }
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

double? _catalogNullableDouble(Object? value, String field,
    {num? minimum, num? maximum}) {
  if (value == null) return null;
  return _catalogDouble(
    value,
    field,
    minimum: minimum,
    maximum: maximum,
  );
}

bool _catalogBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

bool? _catalogNullableBool(Object? value, String field) {
  if (value == null) return null;
  return _catalogBool(value, field);
}

String _catalogConstString(
  Object? value,
  String field,
  String expected,
) {
  if (value == expected) return expected;
  throw FormatException('Catalog Item field $field must equal $expected.');
}

String _catalogEnumString(
  Object? value,
  String field,
  Set<String> allowed,
) {
  if (value is String && allowed.contains(value)) return value;
  throw FormatException(
      'Catalog Item field $field has unsupported value: $value.');
}

DateTime _catalogDateTime(Object? value, String field) {
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

Map<String, dynamic> _catalogMap(Object? value, String field) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Catalog Item field $field must be an object.');
}

void _catalogCheckKeys(
  Map<String, dynamic> json,
  String model,
  Set<String> allowed,
) {
  final unknown = json.keys.where((key) => !allowed.contains(key));
  if (unknown.isNotEmpty) {
    throw FormatException(
        'Unsupported $model field(s): ${unknown.join(', ')}.');
  }
}

void _catalogCheckPartialDateKeys(Map<String, dynamic> json) {
  _catalogCheckKeys(json, 'PartialDateValue', const {'year', 'month', 'day'});
}

PartialDate? _catalogPartialDate(Object? value, String field) {
  if (value == null) return null;
  final json = _catalogMap(value, field);
  _catalogCheckPartialDateKeys(json);
  final year = _catalogNullableInt(json['year'], '$field.year');
  final month = _catalogNullableInt(json['month'], '$field.month');
  final day = _catalogNullableInt(json['day'], '$field.day');
  if (year != null && (year < 1 || year > 9999) ||
      month != null && (month < 1 || month > 12) ||
      day != null && (day < 1 || day > 31)) {
    throw FormatException('Invalid Catalog Item partial date: $field');
  }
  return PartialDate(year: year, month: month, day: day);
}

List<String> _catalogStrings(Object? value, String field) {
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException(
        'Catalog Item field $field must be a list of strings.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<int> _catalogInts(Object? value, String field) {
  if (value is! List || value.any((entry) => entry is! int)) {
    throw FormatException(
        'Catalog Item field $field must be a list of integers.');
  }
  return List<int>.unmodifiable(value.cast<int>());
}

List<T> _catalogObjects<T>(
  Object? value,
  String field,
  T Function(Map<String, dynamic>) decode,
) {
  if (value is! List || value.any((entry) => entry is! Map)) {
    throw FormatException(
        'Catalog Item field $field must be a list of objects.');
  }
  return List<T>.unmodifiable([
    for (final row in value) decode(Map<String, dynamic>.from(row as Map)),
  ]);
}

@immutable
final class CatalogComponentV1Dto {
  const CatalogComponentV1Dto({
    required this.name,
    required this.position,
    required this.quantity,
  });

  final String name;
  final int position;
  final int quantity;

  factory CatalogComponentV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(
        json, 'CatalogComponentV1Dto', const {"name", "position", "quantity"});
    return CatalogComponentV1Dto(
      name: _catalogString(json['name'], 'name', minLength: 1, maxLength: 255),
      position: (json.containsKey('position')
          ? _catalogInt(json['position'], 'position', minimum: 0.0)
          : 0),
      quantity: (json.containsKey('quantity')
          ? _catalogInt(json['quantity'], 'quantity', minimum: 1.0)
          : 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'quantity': quantity,
      };
}

@immutable
final class CatalogCreditV1Dto {
  const CatalogCreditV1Dto({
    required this.characterName,
    required this.name,
    required this.role,
    required this.sortName,
  });

  final String? characterName;
  final String name;
  final String role;
  final String? sortName;

  factory CatalogCreditV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogCreditV1Dto',
        const {"character_name", "name", "role", "sort_name"});
    return CatalogCreditV1Dto(
      characterName: json['character_name'] == null
          ? null
          : _catalogNullableString(json['character_name'], 'character_name',
              maxLength: 255),
      name: _catalogString(json['name'], 'name', minLength: 1, maxLength: 500),
      role: _catalogString(json['role'], 'role', minLength: 1, maxLength: 100),
      sortName: json['sort_name'] == null
          ? null
          : _catalogNullableString(json['sort_name'], 'sort_name',
              maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'character_name': characterName,
        'name': name,
        'role': role,
        'sort_name': sortName,
      };
}

@immutable
final class CatalogEpisodeV1Dto {
  const CatalogEpisodeV1Dto({
    required this.airDate,
    required this.description,
    required this.episodeNumber,
    required this.runtimeMinutes,
    required this.title,
  });

  final PartialDate? airDate;
  final String? description;
  final String? episodeNumber;
  final int? runtimeMinutes;
  final String title;

  factory CatalogEpisodeV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogEpisodeV1Dto', const {
      "air_date",
      "description",
      "episode_number",
      "runtime_minutes",
      "title"
    });
    return CatalogEpisodeV1Dto(
      airDate: json['air_date'] == null
          ? null
          : _catalogPartialDate(json['air_date'], 'air_date'),
      description: json['description'] == null
          ? null
          : _catalogNullableString(json['description'], 'description',
              maxLength: 10000),
      episodeNumber: json['episode_number'] == null
          ? null
          : _catalogNullableString(json['episode_number'], 'episode_number',
              maxLength: 32),
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : _catalogNullableInt(json['runtime_minutes'], 'runtime_minutes',
              minimum: 0.0),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'air_date': airDate?.toJson(),
        'description': description,
        'episode_number': episodeNumber,
        'runtime_minutes': runtimeMinutes,
        'title': title,
      };
}

@immutable
final class CatalogIdentifierV1Dto {
  const CatalogIdentifierV1Dto({
    required this.identifierType,
    required this.isPrimary,
    required this.value,
  });

  final String identifierType;
  final bool isPrimary;
  final String value;

  factory CatalogIdentifierV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogIdentifierV1Dto',
        const {"identifier_type", "is_primary", "value"});
    return CatalogIdentifierV1Dto(
      identifierType: _catalogString(json['identifier_type'], 'identifier_type',
          minLength: 1, maxLength: 64),
      isPrimary: (json.containsKey('is_primary')
          ? _catalogBool(json['is_primary'], 'is_primary')
          : false),
      value:
          _catalogString(json['value'], 'value', minLength: 1, maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'identifier_type': identifierType,
        'is_primary': isPrimary,
        'value': value,
      };
}

@immutable
final class CatalogImageV1Dto {
  const CatalogImageV1Dto({
    required this.imageKey,
    required this.imageType,
    required this.position,
    required this.url,
  });

  final String? imageKey;
  final String imageType;
  final int position;
  final String? url;

  factory CatalogImageV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogImageV1Dto',
        const {"image_key", "image_type", "position", "url"});
    return CatalogImageV1Dto(
      imageKey: json['image_key'] == null
          ? null
          : _catalogNullableString(json['image_key'], 'image_key',
              maxLength: 512),
      imageType: _catalogString(json['image_type'], 'image_type',
          minLength: 1, maxLength: 64),
      position: (json.containsKey('position')
          ? _catalogInt(json['position'], 'position', minimum: 0.0)
          : 0),
      url: json['url'] == null
          ? null
          : _catalogNullableString(json['url'], 'url',
              minLength: 1, maxLength: 2083),
    );
  }

  Map<String, dynamic> toJson() => {
        'image_key': imageKey,
        'image_type': imageType,
        'position': position,
        'url': url,
      };
}

@immutable
final class CatalogMediaTrackV1Dto {
  const CatalogMediaTrackV1Dto({
    required this.aspectRatio,
    required this.audioTracks,
    required this.mediaNumber,
    required this.mediaType,
    required this.subtitles,
    required this.title,
  });

  final String? aspectRatio;
  final List<String> audioTracks;
  final int mediaNumber;
  final String? mediaType;
  final List<String> subtitles;
  final String? title;

  factory CatalogMediaTrackV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogMediaTrackV1Dto', const {
      "aspect_ratio",
      "audio_tracks",
      "media_number",
      "media_type",
      "subtitles",
      "title"
    });
    return CatalogMediaTrackV1Dto(
      aspectRatio: json['aspect_ratio'] == null
          ? null
          : _catalogNullableString(json['aspect_ratio'], 'aspect_ratio',
              maxLength: 64),
      audioTracks: _catalogStrings(
          (json.containsKey('audio_tracks') ? json['audio_tracks'] : const []),
          'audio_tracks'),
      mediaNumber: (json.containsKey('media_number')
          ? _catalogInt(json['media_number'], 'media_number', minimum: 1.0)
          : 1),
      mediaType: json['media_type'] == null
          ? null
          : _catalogNullableString(json['media_type'], 'media_type',
              maxLength: 100),
      subtitles: _catalogStrings(
          (json.containsKey('subtitles') ? json['subtitles'] : const []),
          'subtitles'),
      title: json['title'] == null
          ? null
          : _catalogNullableString(json['title'], 'title', maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'aspect_ratio': aspectRatio,
        'audio_tracks': audioTracks,
        'media_number': mediaNumber,
        'media_type': mediaType,
        'subtitles': subtitles,
        'title': title,
      };
}

@immutable
final class CatalogRelatedItemV1Dto {
  const CatalogRelatedItemV1Dto({
    required this.itemId,
    required this.relation,
    required this.title,
  });

  final String? itemId;
  final String relation;
  final String? title;

  factory CatalogRelatedItemV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogRelatedItemV1Dto',
        const {"item_id", "relation", "title"});
    return CatalogRelatedItemV1Dto(
      itemId: json['item_id'] == null
          ? null
          : _catalogNullableString(json['item_id'], 'item_id'),
      relation: _catalogString(json['relation'], 'relation',
          minLength: 1, maxLength: 64),
      title: json['title'] == null
          ? null
          : _catalogNullableString(json['title'], 'title', maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'relation': relation,
        'title': title,
      };
}

@immutable
final class CatalogSeasonV1Dto {
  const CatalogSeasonV1Dto({
    required this.episodes,
    required this.seasonNumber,
    required this.title,
  });

  final List<CatalogEpisodeV1Dto> episodes;
  final int seasonNumber;
  final String? title;

  factory CatalogSeasonV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogSeasonV1Dto',
        const {"episodes", "season_number", "title"});
    return CatalogSeasonV1Dto(
      episodes: _catalogObjects<CatalogEpisodeV1Dto>(
          (json.containsKey('episodes') ? json['episodes'] : const []),
          'episodes',
          CatalogEpisodeV1Dto.fromJson),
      seasonNumber:
          _catalogInt(json['season_number'], 'season_number', minimum: 0.0),
      title: json['title'] == null
          ? null
          : _catalogNullableString(json['title'], 'title', maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'episodes': episodes.map((value) => value.toJson()).toList(),
        'season_number': seasonNumber,
        'title': title,
      };
}

@immutable
final class CatalogSeriesMembershipV1Dto {
  const CatalogSeriesMembershipV1Dto({
    required this.position,
    required this.seriesId,
    required this.seriesTitle,
  });

  final String? position;
  final String? seriesId;
  final String seriesTitle;

  factory CatalogSeriesMembershipV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogSeriesMembershipV1Dto',
        const {"position", "series_id", "series_title"});
    return CatalogSeriesMembershipV1Dto(
      position: json['position'] == null
          ? null
          : _catalogNullableString(json['position'], 'position', maxLength: 64),
      seriesId: json['series_id'] == null
          ? null
          : _catalogNullableString(json['series_id'], 'series_id'),
      seriesTitle: _catalogString(json['series_title'], 'series_title',
          minLength: 1, maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'series_id': seriesId,
        'series_title': seriesTitle,
      };
}

@immutable
final class MusicAlbumTrackV1Dto {
  const MusicAlbumTrackV1Dto({
    required this.albumId,
    required this.artist,
    required this.discNumber,
    required this.durationMs,
    required this.position,
    required this.title,
  });

  final String albumId;
  final String? artist;
  final int discNumber;
  final int? durationMs;
  final int position;
  final String title;

  factory MusicAlbumTrackV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicAlbumTrackV1Dto', const {
      "album_id",
      "artist",
      "disc_number",
      "duration_ms",
      "position",
      "title"
    });
    return MusicAlbumTrackV1Dto(
      albumId: _catalogString(json['album_id'], 'album_id'),
      artist: json['artist'] == null
          ? null
          : _catalogNullableString(json['artist'], 'artist', maxLength: 500),
      discNumber: _catalogInt(json['disc_number'], 'disc_number', minimum: 1.0),
      durationMs: json['duration_ms'] == null
          ? null
          : _catalogNullableInt(json['duration_ms'], 'duration_ms',
              minimum: 0.0),
      position: _catalogInt(json['position'], 'position', minimum: 1.0),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'album_id': albumId,
        'artist': artist,
        'disc_number': discNumber,
        'duration_ms': durationMs,
        'position': position,
        'title': title,
      };
}

@immutable
final class AnimeCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const AnimeCatalogDetailsV1Dto({
    required this.credits,
    required this.editionTitle,
    required this.episodes,
    required this.format,
    required this.genres,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.region,
    required this.releaseDate,
    required this.sortTitle,
    required this.studios,
    required this.subtitle,
    required this.title,
  });

  final List<CatalogCreditV1Dto> credits;
  final String? editionTitle;
  final List<CatalogEpisodeV1Dto> episodes;
  final String? format;
  final List<String> genres;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final String? region;
  final PartialDate? releaseDate;
  final String? sortTitle;
  final List<String> studios;
  final String? subtitle;
  @override
  final String title;

  factory AnimeCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'AnimeCatalogDetailsV1Dto', const {
      "credits",
      "edition_title",
      "episodes",
      "format",
      "genres",
      "identifiers",
      "images",
      "kind",
      "region",
      "release_date",
      "sort_title",
      "studios",
      "subtitle",
      "title"
    });
    return AnimeCatalogDetailsV1Dto(
      credits: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          CatalogCreditV1Dto.fromJson),
      editionTitle: json['edition_title'] == null
          ? null
          : _catalogNullableString(json['edition_title'], 'edition_title',
              maxLength: 500),
      episodes: _catalogObjects<CatalogEpisodeV1Dto>(
          (json.containsKey('episodes') ? json['episodes'] : const []),
          'episodes',
          CatalogEpisodeV1Dto.fromJson),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "anime"),
      region: json['region'] == null
          ? null
          : _catalogNullableString(json['region'], 'region', maxLength: 64),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      studios: _catalogStrings(
          (json.containsKey('studios') ? json['studios'] : const []),
          'studios'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'credits': credits.map((value) => value.toJson()).toList(),
        'edition_title': editionTitle,
        'episodes': episodes.map((value) => value.toJson()).toList(),
        'format': format,
        'genres': genres,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'region': region,
        'release_date': releaseDate?.toJson(),
        'sort_title': sortTitle,
        'studios': studios,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class BoardGameCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const BoardGameCatalogDetailsV1Dto({
    required this.bestPlayers,
    required this.categories,
    required this.components,
    required this.designers,
    required this.edition,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.maxPlayers,
    required this.mechanics,
    required this.minPlayers,
    required this.playTimeMinutes,
    required this.publishers,
    required this.recommendedPlayers,
    required this.relatedItems,
    required this.releaseDate,
    required this.sortTitle,
    required this.subtitle,
    required this.title,
  });

  final List<int> bestPlayers;
  final List<String> categories;
  final List<CatalogComponentV1Dto> components;
  final List<String> designers;
  final String? edition;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final int? maxPlayers;
  final List<String> mechanics;
  final int? minPlayers;
  final int? playTimeMinutes;
  final List<String> publishers;
  final List<int> recommendedPlayers;
  final List<CatalogRelatedItemV1Dto> relatedItems;
  final PartialDate? releaseDate;
  final String? sortTitle;
  final String? subtitle;
  @override
  final String title;

  factory BoardGameCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'BoardGameCatalogDetailsV1Dto', const {
      "best_players",
      "categories",
      "components",
      "designers",
      "edition",
      "identifiers",
      "images",
      "kind",
      "max_players",
      "mechanics",
      "min_players",
      "play_time_minutes",
      "publishers",
      "recommended_players",
      "related_items",
      "release_date",
      "sort_title",
      "subtitle",
      "title"
    });
    return BoardGameCatalogDetailsV1Dto(
      bestPlayers: _catalogInts(
          (json.containsKey('best_players') ? json['best_players'] : const []),
          'best_players'),
      categories: _catalogStrings(
          (json.containsKey('categories') ? json['categories'] : const []),
          'categories'),
      components: _catalogObjects<CatalogComponentV1Dto>(
          (json.containsKey('components') ? json['components'] : const []),
          'components',
          CatalogComponentV1Dto.fromJson),
      designers: _catalogStrings(
          (json.containsKey('designers') ? json['designers'] : const []),
          'designers'),
      edition: json['edition'] == null
          ? null
          : _catalogNullableString(json['edition'], 'edition', maxLength: 255),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "boardgame"),
      maxPlayers: json['max_players'] == null
          ? null
          : _catalogNullableInt(json['max_players'], 'max_players',
              minimum: 1.0),
      mechanics: _catalogStrings(
          (json.containsKey('mechanics') ? json['mechanics'] : const []),
          'mechanics'),
      minPlayers: json['min_players'] == null
          ? null
          : _catalogNullableInt(json['min_players'], 'min_players',
              minimum: 1.0),
      playTimeMinutes: json['play_time_minutes'] == null
          ? null
          : _catalogNullableInt(json['play_time_minutes'], 'play_time_minutes',
              minimum: 0.0),
      publishers: _catalogStrings(
          (json.containsKey('publishers') ? json['publishers'] : const []),
          'publishers'),
      recommendedPlayers: _catalogInts(
          (json.containsKey('recommended_players')
              ? json['recommended_players']
              : const []),
          'recommended_players'),
      relatedItems: _catalogObjects<CatalogRelatedItemV1Dto>(
          (json.containsKey('related_items')
              ? json['related_items']
              : const []),
          'related_items',
          CatalogRelatedItemV1Dto.fromJson),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'best_players': bestPlayers,
        'categories': categories,
        'components': components.map((value) => value.toJson()).toList(),
        'designers': designers,
        'edition': edition,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'max_players': maxPlayers,
        'mechanics': mechanics,
        'min_players': minPlayers,
        'play_time_minutes': playTimeMinutes,
        'publishers': publishers,
        'recommended_players': recommendedPlayers,
        'related_items': relatedItems.map((value) => value.toJson()).toList(),
        'release_date': releaseDate?.toJson(),
        'sort_title': sortTitle,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class BookCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const BookCatalogDetailsV1Dto({
    required this.contributors,
    required this.edition,
    required this.format,
    required this.genres,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.originalTitle,
    required this.publicationDate,
    required this.publisher,
    required this.releaseDate,
    required this.seriesMembership,
    required this.sortTitle,
    required this.subjects,
    required this.subtitle,
    required this.title,
  });

  final List<CatalogCreditV1Dto> contributors;
  final String? edition;
  final String? format;
  final List<String> genres;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final String? originalTitle;
  final PartialDate? publicationDate;
  final String? publisher;
  final PartialDate? releaseDate;
  final CatalogSeriesMembershipV1Dto? seriesMembership;
  final String? sortTitle;
  final List<String> subjects;
  final String? subtitle;
  @override
  final String title;

  factory BookCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'BookCatalogDetailsV1Dto', const {
      "contributors",
      "edition",
      "format",
      "genres",
      "identifiers",
      "images",
      "kind",
      "original_title",
      "publication_date",
      "publisher",
      "release_date",
      "series_membership",
      "sort_title",
      "subjects",
      "subtitle",
      "title"
    });
    return BookCatalogDetailsV1Dto(
      contributors: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('contributors') ? json['contributors'] : const []),
          'contributors',
          CatalogCreditV1Dto.fromJson),
      edition: json['edition'] == null
          ? null
          : _catalogNullableString(json['edition'], 'edition', maxLength: 255),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "book"),
      originalTitle: json['original_title'] == null
          ? null
          : _catalogNullableString(json['original_title'], 'original_title',
              maxLength: 500),
      publicationDate: json['publication_date'] == null
          ? null
          : _catalogPartialDate(json['publication_date'], 'publication_date'),
      publisher: json['publisher'] == null
          ? null
          : _catalogNullableString(json['publisher'], 'publisher',
              maxLength: 255),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      seriesMembership: json['series_membership'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              _catalogMap(json['series_membership'], 'series_membership')),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      subjects: _catalogStrings(
          (json.containsKey('subjects') ? json['subjects'] : const []),
          'subjects'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'contributors': contributors.map((value) => value.toJson()).toList(),
        'edition': edition,
        'format': format,
        'genres': genres,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'original_title': originalTitle,
        'publication_date': publicationDate?.toJson(),
        'publisher': publisher,
        'release_date': releaseDate?.toJson(),
        'series_membership': seriesMembership?.toJson(),
        'sort_title': sortTitle,
        'subjects': subjects,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class ComicCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const ComicCatalogDetailsV1Dto({
    required this.characters,
    required this.creators,
    required this.identifiers,
    required this.images,
    required this.issueNumber,
    required this.keyIssue,
    required this.kind,
    required this.plot,
    required this.publisher,
    required this.releaseDate,
    required this.series,
    required this.sortTitle,
    required this.storyArcs,
    required this.subtitle,
    required this.title,
    required this.variant,
  });

  final List<String> characters;
  final List<CatalogCreditV1Dto> creators;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  final String? issueNumber;
  final bool keyIssue;
  @override
  final String kind;
  final String? plot;
  final String? publisher;
  final PartialDate? releaseDate;
  final CatalogSeriesMembershipV1Dto? series;
  final String? sortTitle;
  final List<String> storyArcs;
  final String? subtitle;
  @override
  final String title;
  final String? variant;

  factory ComicCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'ComicCatalogDetailsV1Dto', const {
      "characters",
      "creators",
      "identifiers",
      "images",
      "issue_number",
      "key_issue",
      "kind",
      "plot",
      "publisher",
      "release_date",
      "series",
      "sort_title",
      "story_arcs",
      "subtitle",
      "title",
      "variant"
    });
    return ComicCatalogDetailsV1Dto(
      characters: _catalogStrings(
          (json.containsKey('characters') ? json['characters'] : const []),
          'characters'),
      creators: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('creators') ? json['creators'] : const []),
          'creators',
          CatalogCreditV1Dto.fromJson),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      issueNumber: json['issue_number'] == null
          ? null
          : _catalogNullableString(json['issue_number'], 'issue_number',
              maxLength: 64),
      keyIssue: (json.containsKey('key_issue')
          ? _catalogBool(json['key_issue'], 'key_issue')
          : false),
      kind: _catalogConstString(json['kind'], 'kind', "comic"),
      plot: json['plot'] == null
          ? null
          : _catalogNullableString(json['plot'], 'plot', maxLength: 10000),
      publisher: json['publisher'] == null
          ? null
          : _catalogNullableString(json['publisher'], 'publisher',
              maxLength: 255),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      series: json['series'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              _catalogMap(json['series'], 'series')),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      storyArcs: _catalogStrings(
          (json.containsKey('story_arcs') ? json['story_arcs'] : const []),
          'story_arcs'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
      variant: json['variant'] == null
          ? null
          : _catalogNullableString(json['variant'], 'variant', maxLength: 255),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'characters': characters,
        'creators': creators.map((value) => value.toJson()).toList(),
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'issue_number': issueNumber,
        'key_issue': keyIssue,
        'kind': kind,
        'plot': plot,
        'publisher': publisher,
        'release_date': releaseDate?.toJson(),
        'series': series?.toJson(),
        'sort_title': sortTitle,
        'story_arcs': storyArcs,
        'subtitle': subtitle,
        'title': title,
        'variant': variant,
      };
}

@immutable
final class GameCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const GameCatalogDetailsV1Dto({
    required this.edition,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.platform,
    required this.publisher,
    required this.region,
    required this.relatedItems,
    required this.releaseDate,
    required this.sortTitle,
    required this.subtitle,
    required this.title,
  });

  final String? edition;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final String? platform;
  final String? publisher;
  final String? region;
  final List<CatalogRelatedItemV1Dto> relatedItems;
  final PartialDate? releaseDate;
  final String? sortTitle;
  final String? subtitle;
  @override
  final String title;

  factory GameCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'GameCatalogDetailsV1Dto', const {
      "edition",
      "identifiers",
      "images",
      "kind",
      "platform",
      "publisher",
      "region",
      "related_items",
      "release_date",
      "sort_title",
      "subtitle",
      "title"
    });
    return GameCatalogDetailsV1Dto(
      edition: json['edition'] == null
          ? null
          : _catalogNullableString(json['edition'], 'edition', maxLength: 255),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "game"),
      platform: json['platform'] == null
          ? null
          : _catalogNullableString(json['platform'], 'platform',
              maxLength: 100),
      publisher: json['publisher'] == null
          ? null
          : _catalogNullableString(json['publisher'], 'publisher',
              maxLength: 255),
      region: json['region'] == null
          ? null
          : _catalogNullableString(json['region'], 'region', maxLength: 64),
      relatedItems: _catalogObjects<CatalogRelatedItemV1Dto>(
          (json.containsKey('related_items')
              ? json['related_items']
              : const []),
          'related_items',
          CatalogRelatedItemV1Dto.fromJson),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'edition': edition,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'platform': platform,
        'publisher': publisher,
        'region': region,
        'related_items': relatedItems.map((value) => value.toJson()).toList(),
        'release_date': releaseDate?.toJson(),
        'sort_title': sortTitle,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class MangaCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const MangaCatalogDetailsV1Dto({
    required this.chapters,
    required this.contributors,
    required this.editionFormat,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.publisher,
    required this.releaseDate,
    required this.seriesMembership,
    required this.sortTitle,
    required this.subtitle,
    required this.title,
    required this.volumeNumber,
  });

  final List<String> chapters;
  final List<CatalogCreditV1Dto> contributors;
  final String? editionFormat;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final String? publisher;
  final PartialDate? releaseDate;
  final CatalogSeriesMembershipV1Dto? seriesMembership;
  final String? sortTitle;
  final String? subtitle;
  @override
  final String title;
  final String? volumeNumber;

  factory MangaCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MangaCatalogDetailsV1Dto', const {
      "chapters",
      "contributors",
      "edition_format",
      "identifiers",
      "images",
      "kind",
      "publisher",
      "release_date",
      "series_membership",
      "sort_title",
      "subtitle",
      "title",
      "volume_number"
    });
    return MangaCatalogDetailsV1Dto(
      chapters: _catalogStrings(
          (json.containsKey('chapters') ? json['chapters'] : const []),
          'chapters'),
      contributors: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('contributors') ? json['contributors'] : const []),
          'contributors',
          CatalogCreditV1Dto.fromJson),
      editionFormat: json['edition_format'] == null
          ? null
          : _catalogNullableString(json['edition_format'], 'edition_format',
              maxLength: 100),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "manga"),
      publisher: json['publisher'] == null
          ? null
          : _catalogNullableString(json['publisher'], 'publisher',
              maxLength: 255),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      seriesMembership: json['series_membership'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              _catalogMap(json['series_membership'], 'series_membership')),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
      volumeNumber: json['volume_number'] == null
          ? null
          : _catalogNullableString(json['volume_number'], 'volume_number',
              maxLength: 64),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'chapters': chapters,
        'contributors': contributors.map((value) => value.toJson()).toList(),
        'edition_format': editionFormat,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'publisher': publisher,
        'release_date': releaseDate?.toJson(),
        'series_membership': seriesMembership?.toJson(),
        'sort_title': sortTitle,
        'subtitle': subtitle,
        'title': title,
        'volume_number': volumeNumber,
      };
}

@immutable
final class MovieCatalogWriteDetailsV1Dto
    implements CatalogItemWriteKindDetailsV1Dto {
  const MovieCatalogWriteDetailsV1Dto({
    required this.audienceRating,
    required this.boxSet,
    required this.credits,
    required this.format,
    required this.genres,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.mediaTracks,
    required this.plot,
    required this.region,
    required this.releaseDate,
    required this.releaseYear,
    required this.runtimeMinutes,
    required this.sortTitle,
    required this.studios,
    required this.subtitle,
    required this.title,
  });

  final double? audienceRating;
  final String? boxSet;
  final List<CatalogCreditV1Dto> credits;
  final String? format;
  final List<String> genres;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final List<CatalogMediaTrackV1Dto> mediaTracks;
  final String? plot;
  final String? region;
  final PartialDate? releaseDate;
  final int? releaseYear;
  final int? runtimeMinutes;
  final String? sortTitle;
  final List<String> studios;
  final String? subtitle;
  @override
  final String title;

  factory MovieCatalogWriteDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MovieCatalogWriteDetailsV1Dto', const {
      "audience_rating",
      "box_set",
      "credits",
      "format",
      "genres",
      "identifiers",
      "images",
      "kind",
      "media_tracks",
      "plot",
      "region",
      "release_date",
      "release_year",
      "runtime_minutes",
      "sort_title",
      "studios",
      "subtitle",
      "title"
    });
    return MovieCatalogWriteDetailsV1Dto(
      audienceRating: json['audience_rating'] == null
          ? null
          : _catalogNullableDouble(json['audience_rating'], 'audience_rating',
              minimum: 0.0),
      boxSet: json['box_set'] == null
          ? null
          : _catalogNullableString(json['box_set'], 'box_set', maxLength: 255),
      credits: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          CatalogCreditV1Dto.fromJson),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "movie"),
      mediaTracks: _catalogObjects<CatalogMediaTrackV1Dto>(
          (json.containsKey('media_tracks') ? json['media_tracks'] : const []),
          'media_tracks',
          CatalogMediaTrackV1Dto.fromJson),
      plot: json['plot'] == null
          ? null
          : _catalogNullableString(json['plot'], 'plot', maxLength: 10000),
      region: json['region'] == null
          ? null
          : _catalogNullableString(json['region'], 'region', maxLength: 64),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      releaseYear: json['release_year'] == null
          ? null
          : _catalogNullableInt(json['release_year'], 'release_year',
              minimum: 0.0, maximum: 9999.0),
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : _catalogNullableInt(json['runtime_minutes'], 'runtime_minutes',
              minimum: 0.0),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      studios: _catalogStrings(
          (json.containsKey('studios') ? json['studios'] : const []),
          'studios'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'audience_rating': audienceRating,
        'box_set': boxSet,
        'credits': credits.map((value) => value.toJson()).toList(),
        'format': format,
        'genres': genres,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'media_tracks': mediaTracks.map((value) => value.toJson()).toList(),
        'plot': plot,
        'region': region,
        'release_date': releaseDate?.toJson(),
        'release_year': releaseYear,
        'runtime_minutes': runtimeMinutes,
        'sort_title': sortTitle,
        'studios': studios,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class MovieCatalogDetailsV1Dto implements CatalogItemKindDetailsV1Dto {
  const MovieCatalogDetailsV1Dto({
    required this.audienceRating,
    required this.boxSet,
    required this.credits,
    required this.format,
    required this.genres,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.mediaTracks,
    required this.plot,
    required this.region,
    required this.releaseDate,
    required this.releaseYear,
    required this.runtimeMinutes,
    required this.sortTitle,
    required this.studios,
    required this.subtitle,
    required this.title,
  });

  final String? audienceRating;
  final String? boxSet;
  final List<CatalogCreditV1Dto> credits;
  final String? format;
  final List<String> genres;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final List<CatalogMediaTrackV1Dto> mediaTracks;
  final String? plot;
  final String? region;
  final PartialDate? releaseDate;
  final int? releaseYear;
  final int? runtimeMinutes;
  final String? sortTitle;
  final List<String> studios;
  final String? subtitle;
  @override
  final String title;

  factory MovieCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MovieCatalogDetailsV1Dto', const {
      "audience_rating",
      "box_set",
      "credits",
      "format",
      "genres",
      "identifiers",
      "images",
      "kind",
      "media_tracks",
      "plot",
      "region",
      "release_date",
      "release_year",
      "runtime_minutes",
      "sort_title",
      "studios",
      "subtitle",
      "title"
    });
    return MovieCatalogDetailsV1Dto(
      audienceRating: json['audience_rating'] == null
          ? null
          : _catalogNullableString(json['audience_rating'], 'audience_rating'),
      boxSet: json['box_set'] == null
          ? null
          : _catalogNullableString(json['box_set'], 'box_set', maxLength: 255),
      credits: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          CatalogCreditV1Dto.fromJson),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "movie"),
      mediaTracks: _catalogObjects<CatalogMediaTrackV1Dto>(
          (json.containsKey('media_tracks') ? json['media_tracks'] : const []),
          'media_tracks',
          CatalogMediaTrackV1Dto.fromJson),
      plot: json['plot'] == null
          ? null
          : _catalogNullableString(json['plot'], 'plot', maxLength: 10000),
      region: json['region'] == null
          ? null
          : _catalogNullableString(json['region'], 'region', maxLength: 64),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      releaseYear: json['release_year'] == null
          ? null
          : _catalogNullableInt(json['release_year'], 'release_year',
              minimum: 0.0, maximum: 9999.0),
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : _catalogNullableInt(json['runtime_minutes'], 'runtime_minutes',
              minimum: 0.0),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      studios: _catalogStrings(
          (json.containsKey('studios') ? json['studios'] : const []),
          'studios'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'audience_rating': audienceRating,
        'box_set': boxSet,
        'credits': credits.map((value) => value.toJson()).toList(),
        'format': format,
        'genres': genres,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'media_tracks': mediaTracks.map((value) => value.toJson()).toList(),
        'plot': plot,
        'region': region,
        'release_date': releaseDate?.toJson(),
        'release_year': releaseYear,
        'runtime_minutes': runtimeMinutes,
        'sort_title': sortTitle,
        'studios': studios,
        'subtitle': subtitle,
        'title': title,
      };
}

@immutable
final class MusicAlbumArtistV1Dto {
  const MusicAlbumArtistV1Dto({
    required this.name,
    required this.sortName,
  });

  final String name;
  final String? sortName;

  factory MusicAlbumArtistV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(
        json, 'MusicAlbumArtistV1Dto', const {"name", "sort_name"});
    return MusicAlbumArtistV1Dto(
      name: _catalogString(json['name'], 'name', minLength: 1, maxLength: 500),
      sortName: json['sort_name'] == null
          ? null
          : _catalogNullableString(json['sort_name'], 'sort_name',
              maxLength: 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sort_name': sortName,
      };
}

@immutable
final class MusicAlbumCreditV1Dto {
  const MusicAlbumCreditV1Dto({
    required this.creditedName,
    required this.instrument,
    required this.joinPhrase,
    required this.role,
    required this.sequence,
  });

  final String creditedName;
  final String? instrument;
  final String? joinPhrase;
  final String role;
  final int sequence;

  factory MusicAlbumCreditV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicAlbumCreditV1Dto', const {
      "credited_name",
      "instrument",
      "join_phrase",
      "role",
      "sequence"
    });
    return MusicAlbumCreditV1Dto(
      creditedName: _catalogString(json['credited_name'], 'credited_name',
          minLength: 1, maxLength: 500),
      instrument: json['instrument'] == null
          ? null
          : _catalogNullableString(json['instrument'], 'instrument',
              maxLength: 100),
      joinPhrase: json['join_phrase'] == null
          ? null
          : _catalogNullableString(json['join_phrase'], 'join_phrase',
              maxLength: 100),
      role: _catalogString(json['role'], 'role', minLength: 1, maxLength: 64),
      sequence: _catalogInt(json['sequence'], 'sequence', minimum: 0.0),
    );
  }

  Map<String, dynamic> toJson() => {
        'credited_name': creditedName,
        'instrument': instrument,
        'join_phrase': joinPhrase,
        'role': role,
        'sequence': sequence,
      };
}

@immutable
final class MusicAlbumDiscTitleV1Dto {
  const MusicAlbumDiscTitleV1Dto({
    required this.discNumber,
    required this.title,
  });

  final int discNumber;
  final String title;

  factory MusicAlbumDiscTitleV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(
        json, 'MusicAlbumDiscTitleV1Dto', const {"disc_number", "title"});
    return MusicAlbumDiscTitleV1Dto(
      discNumber: _catalogInt(json['disc_number'], 'disc_number', minimum: 1.0),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'disc_number': discNumber,
        'title': title,
      };
}

@immutable
final class MusicAlbumLabelV1Dto {
  const MusicAlbumLabelV1Dto({
    required this.catalogNumber,
    required this.name,
  });

  final String? catalogNumber;
  final String name;

  factory MusicAlbumLabelV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(
        json, 'MusicAlbumLabelV1Dto', const {"catalog_number", "name"});
    return MusicAlbumLabelV1Dto(
      catalogNumber: json['catalog_number'] == null
          ? null
          : _catalogNullableString(json['catalog_number'], 'catalog_number',
              maxLength: 100),
      name: _catalogString(json['name'], 'name', minLength: 1, maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'catalog_number': catalogNumber,
        'name': name,
      };
}

@immutable
final class MusicAlbumLinkV1Dto {
  const MusicAlbumLinkV1Dto({
    required this.description,
    required this.position,
    required this.title,
    required this.url,
  });

  final String? description;
  final int position;
  final String? title;
  final String url;

  factory MusicAlbumLinkV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicAlbumLinkV1Dto',
        const {"description", "position", "title", "url"});
    return MusicAlbumLinkV1Dto(
      description: json['description'] == null
          ? null
          : _catalogNullableString(json['description'], 'description',
              maxLength: 2000),
      position: _catalogInt(json['position'], 'position', minimum: 0.0),
      title: json['title'] == null
          ? null
          : _catalogNullableString(json['title'], 'title', maxLength: 255),
      url: _catalogString(json['url'], 'url', minLength: 1, maxLength: 2083),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'position': position,
        'title': title,
        'url': url,
      };
}

@immutable
final class MusicAlbumTrackInputV1Dto {
  const MusicAlbumTrackInputV1Dto({
    required this.artist,
    required this.discNumber,
    required this.durationMs,
    required this.position,
    required this.title,
  });

  final String? artist;
  final int discNumber;
  final int? durationMs;
  final int position;
  final String title;

  factory MusicAlbumTrackInputV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicAlbumTrackInputV1Dto',
        const {"artist", "disc_number", "duration_ms", "position", "title"});
    return MusicAlbumTrackInputV1Dto(
      artist: json['artist'] == null
          ? null
          : _catalogNullableString(json['artist'], 'artist', maxLength: 500),
      discNumber: _catalogInt(json['disc_number'], 'disc_number', minimum: 1.0),
      durationMs: json['duration_ms'] == null
          ? null
          : _catalogNullableInt(json['duration_ms'], 'duration_ms',
              minimum: 0.0),
      position: _catalogInt(json['position'], 'position', minimum: 1.0),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 255),
    );
  }

  Map<String, dynamic> toJson() => {
        'artist': artist,
        'disc_number': discNumber,
        'duration_ms': durationMs,
        'position': position,
        'title': title,
      };
}

@immutable
final class MusicCatalogDetailsV1Dto implements CatalogItemKindDetailsV1Dto {
  const MusicCatalogDetailsV1Dto({
    required this.artists,
    required this.backCoverImageUrl,
    required this.barcode,
    required this.boxSet,
    required this.catalogNumber,
    required this.country,
    required this.coverImageUrl,
    required this.credits,
    required this.discTitles,
    required this.extras,
    required this.format,
    required this.genres,
    required this.isLive,
    required this.kind,
    required this.labels,
    required this.links,
    required this.matrixNumberSideA,
    required this.matrixNumberSideB,
    required this.originalReleaseDate,
    required this.packaging,
    required this.recordingDate,
    required this.releaseDate,
    required this.rpm,
    required this.sortTitle,
    required this.soundTypes,
    required this.sparsCode,
    required this.studio,
    required this.subtitle,
    required this.title,
    required this.tracks,
    required this.vinylColor,
    required this.vinylWeight,
  });

  final List<MusicAlbumArtistV1Dto> artists;
  final String? backCoverImageUrl;
  final String? barcode;
  final String? boxSet;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrl;
  final List<MusicAlbumCreditV1Dto> credits;
  final List<MusicAlbumDiscTitleV1Dto> discTitles;
  final List<String> extras;
  final String? format;
  final List<String> genres;
  final bool? isLive;
  @override
  final String kind;
  final List<MusicAlbumLabelV1Dto> labels;
  final List<MusicAlbumLinkV1Dto> links;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final PartialDate? originalReleaseDate;
  final String? packaging;
  final PartialDate? recordingDate;
  final PartialDate? releaseDate;
  final int? rpm;
  final String? sortTitle;
  final List<String> soundTypes;
  final String? sparsCode;
  final List<String> studio;
  final String? subtitle;
  @override
  final String title;
  final List<MusicAlbumTrackV1Dto> tracks;
  final String? vinylColor;
  final String? vinylWeight;

  factory MusicCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicCatalogDetailsV1Dto', const {
      "artists",
      "back_cover_image_url",
      "barcode",
      "box_set",
      "catalog_number",
      "country",
      "cover_image_url",
      "credits",
      "disc_titles",
      "extras",
      "format",
      "genres",
      "is_live",
      "kind",
      "labels",
      "links",
      "matrix_number_side_a",
      "matrix_number_side_b",
      "original_release_date",
      "packaging",
      "recording_date",
      "release_date",
      "rpm",
      "sort_title",
      "sound_types",
      "spars_code",
      "studio",
      "subtitle",
      "title",
      "tracks",
      "vinyl_color",
      "vinyl_weight"
    });
    return MusicCatalogDetailsV1Dto(
      artists: _catalogObjects<MusicAlbumArtistV1Dto>(
          (json.containsKey('artists') ? json['artists'] : const []),
          'artists',
          MusicAlbumArtistV1Dto.fromJson),
      backCoverImageUrl: json['back_cover_image_url'] == null
          ? null
          : _catalogNullableString(
              json['back_cover_image_url'], 'back_cover_image_url',
              minLength: 1, maxLength: 2083),
      barcode: json['barcode'] == null
          ? null
          : _catalogNullableString(json['barcode'], 'barcode', maxLength: 100),
      boxSet: json['box_set'] == null
          ? null
          : _catalogNullableString(json['box_set'], 'box_set', maxLength: 255),
      catalogNumber: json['catalog_number'] == null
          ? null
          : _catalogNullableString(json['catalog_number'], 'catalog_number',
              maxLength: 100),
      country: json['country'] == null
          ? null
          : _catalogNullableString(json['country'], 'country', maxLength: 64),
      coverImageUrl: json['cover_image_url'] == null
          ? null
          : _catalogNullableString(json['cover_image_url'], 'cover_image_url',
              minLength: 1, maxLength: 2083),
      credits: _catalogObjects<MusicAlbumCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          MusicAlbumCreditV1Dto.fromJson),
      discTitles: _catalogObjects<MusicAlbumDiscTitleV1Dto>(
          (json.containsKey('disc_titles') ? json['disc_titles'] : const []),
          'disc_titles',
          MusicAlbumDiscTitleV1Dto.fromJson),
      extras: _catalogStrings(
          (json.containsKey('extras') ? json['extras'] : const []), 'extras'),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      isLive: json['is_live'] == null
          ? null
          : _catalogNullableBool(json['is_live'], 'is_live'),
      kind: _catalogConstString(json['kind'], 'kind', "music"),
      labels: _catalogObjects<MusicAlbumLabelV1Dto>(
          (json.containsKey('labels') ? json['labels'] : const []),
          'labels',
          MusicAlbumLabelV1Dto.fromJson),
      links: _catalogObjects<MusicAlbumLinkV1Dto>(
          (json.containsKey('links') ? json['links'] : const []),
          'links',
          MusicAlbumLinkV1Dto.fromJson),
      matrixNumberSideA: json['matrix_number_side_a'] == null
          ? null
          : _catalogNullableString(
              json['matrix_number_side_a'], 'matrix_number_side_a',
              maxLength: 255),
      matrixNumberSideB: json['matrix_number_side_b'] == null
          ? null
          : _catalogNullableString(
              json['matrix_number_side_b'], 'matrix_number_side_b',
              maxLength: 255),
      originalReleaseDate: json['original_release_date'] == null
          ? null
          : _catalogPartialDate(
              json['original_release_date'], 'original_release_date'),
      packaging: json['packaging'] == null
          ? null
          : _catalogNullableString(json['packaging'], 'packaging',
              maxLength: 100),
      recordingDate: json['recording_date'] == null
          ? null
          : _catalogPartialDate(json['recording_date'], 'recording_date'),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      rpm: json['rpm'] == null
          ? null
          : _catalogNullableInt(json['rpm'], 'rpm', minimum: 0.0),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 255),
      soundTypes: _catalogStrings(
          (json.containsKey('sound_types') ? json['sound_types'] : const []),
          'sound_types'),
      sparsCode: json['spars_code'] == null
          ? null
          : _catalogNullableString(json['spars_code'], 'spars_code',
              maxLength: 50),
      studio: _catalogStrings(
          (json.containsKey('studio') ? json['studio'] : const []), 'studio'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 500),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 255),
      tracks: _catalogObjects<MusicAlbumTrackV1Dto>(
          (json.containsKey('tracks') ? json['tracks'] : const []),
          'tracks',
          MusicAlbumTrackV1Dto.fromJson),
      vinylColor: json['vinyl_color'] == null
          ? null
          : _catalogNullableString(json['vinyl_color'], 'vinyl_color',
              maxLength: 100),
      vinylWeight: json['vinyl_weight'] == null
          ? null
          : _catalogNullableString(json['vinyl_weight'], 'vinyl_weight'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'artists': artists.map((value) => value.toJson()).toList(),
        'back_cover_image_url': backCoverImageUrl,
        'barcode': barcode,
        'box_set': boxSet,
        'catalog_number': catalogNumber,
        'country': country,
        'cover_image_url': coverImageUrl,
        'credits': credits.map((value) => value.toJson()).toList(),
        'disc_titles': discTitles.map((value) => value.toJson()).toList(),
        'extras': extras,
        'format': format,
        'genres': genres,
        'is_live': isLive,
        'kind': kind,
        'labels': labels.map((value) => value.toJson()).toList(),
        'links': links.map((value) => value.toJson()).toList(),
        'matrix_number_side_a': matrixNumberSideA,
        'matrix_number_side_b': matrixNumberSideB,
        'original_release_date': originalReleaseDate?.toJson(),
        'packaging': packaging,
        'recording_date': recordingDate?.toJson(),
        'release_date': releaseDate?.toJson(),
        'rpm': rpm,
        'sort_title': sortTitle,
        'sound_types': soundTypes,
        'spars_code': sparsCode,
        'studio': studio,
        'subtitle': subtitle,
        'title': title,
        'tracks': tracks.map((value) => value.toJson()).toList(),
        'vinyl_color': vinylColor,
        'vinyl_weight': vinylWeight,
      };
}

@immutable
final class MusicCatalogWriteDetailsV1Dto
    implements CatalogItemWriteKindDetailsV1Dto {
  const MusicCatalogWriteDetailsV1Dto({
    required this.artists,
    required this.backCoverImageUrl,
    required this.barcode,
    required this.boxSet,
    required this.catalogNumber,
    required this.country,
    required this.coverImageUrl,
    required this.credits,
    required this.discTitles,
    required this.extras,
    required this.format,
    required this.genres,
    required this.isLive,
    required this.kind,
    required this.labels,
    required this.links,
    required this.matrixNumberSideA,
    required this.matrixNumberSideB,
    required this.originalReleaseDate,
    required this.packaging,
    required this.recordingDate,
    required this.releaseDate,
    required this.rpm,
    required this.sortTitle,
    required this.soundTypes,
    required this.sparsCode,
    required this.studio,
    required this.subtitle,
    required this.title,
    required this.tracks,
    required this.vinylColor,
    required this.vinylWeight,
  });

  final List<MusicAlbumArtistV1Dto> artists;
  final String? backCoverImageUrl;
  final String? barcode;
  final String? boxSet;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrl;
  final List<MusicAlbumCreditV1Dto> credits;
  final List<MusicAlbumDiscTitleV1Dto> discTitles;
  final List<String> extras;
  final String? format;
  final List<String> genres;
  final bool? isLive;
  @override
  final String kind;
  final List<MusicAlbumLabelV1Dto> labels;
  final List<MusicAlbumLinkV1Dto> links;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final PartialDate? originalReleaseDate;
  final String? packaging;
  final PartialDate? recordingDate;
  final PartialDate? releaseDate;
  final int? rpm;
  final String? sortTitle;
  final List<String> soundTypes;
  final String? sparsCode;
  final List<String> studio;
  final String? subtitle;
  @override
  final String title;
  final List<MusicAlbumTrackInputV1Dto> tracks;
  final String? vinylColor;
  final double? vinylWeight;

  factory MusicCatalogWriteDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'MusicCatalogWriteDetailsV1Dto', const {
      "artists",
      "back_cover_image_url",
      "barcode",
      "box_set",
      "catalog_number",
      "country",
      "cover_image_url",
      "credits",
      "disc_titles",
      "extras",
      "format",
      "genres",
      "is_live",
      "kind",
      "labels",
      "links",
      "matrix_number_side_a",
      "matrix_number_side_b",
      "original_release_date",
      "packaging",
      "recording_date",
      "release_date",
      "rpm",
      "sort_title",
      "sound_types",
      "spars_code",
      "studio",
      "subtitle",
      "title",
      "tracks",
      "vinyl_color",
      "vinyl_weight"
    });
    return MusicCatalogWriteDetailsV1Dto(
      artists: _catalogObjects<MusicAlbumArtistV1Dto>(
          (json.containsKey('artists') ? json['artists'] : const []),
          'artists',
          MusicAlbumArtistV1Dto.fromJson),
      backCoverImageUrl: json['back_cover_image_url'] == null
          ? null
          : _catalogNullableString(
              json['back_cover_image_url'], 'back_cover_image_url',
              minLength: 1, maxLength: 2083),
      barcode: json['barcode'] == null
          ? null
          : _catalogNullableString(json['barcode'], 'barcode', maxLength: 100),
      boxSet: json['box_set'] == null
          ? null
          : _catalogNullableString(json['box_set'], 'box_set', maxLength: 255),
      catalogNumber: json['catalog_number'] == null
          ? null
          : _catalogNullableString(json['catalog_number'], 'catalog_number',
              maxLength: 100),
      country: json['country'] == null
          ? null
          : _catalogNullableString(json['country'], 'country', maxLength: 64),
      coverImageUrl: json['cover_image_url'] == null
          ? null
          : _catalogNullableString(json['cover_image_url'], 'cover_image_url',
              minLength: 1, maxLength: 2083),
      credits: _catalogObjects<MusicAlbumCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          MusicAlbumCreditV1Dto.fromJson),
      discTitles: _catalogObjects<MusicAlbumDiscTitleV1Dto>(
          (json.containsKey('disc_titles') ? json['disc_titles'] : const []),
          'disc_titles',
          MusicAlbumDiscTitleV1Dto.fromJson),
      extras: _catalogStrings(
          (json.containsKey('extras') ? json['extras'] : const []), 'extras'),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      isLive: json['is_live'] == null
          ? null
          : _catalogNullableBool(json['is_live'], 'is_live'),
      kind: _catalogConstString(json['kind'], 'kind', "music"),
      labels: _catalogObjects<MusicAlbumLabelV1Dto>(
          (json.containsKey('labels') ? json['labels'] : const []),
          'labels',
          MusicAlbumLabelV1Dto.fromJson),
      links: _catalogObjects<MusicAlbumLinkV1Dto>(
          (json.containsKey('links') ? json['links'] : const []),
          'links',
          MusicAlbumLinkV1Dto.fromJson),
      matrixNumberSideA: json['matrix_number_side_a'] == null
          ? null
          : _catalogNullableString(
              json['matrix_number_side_a'], 'matrix_number_side_a',
              maxLength: 255),
      matrixNumberSideB: json['matrix_number_side_b'] == null
          ? null
          : _catalogNullableString(
              json['matrix_number_side_b'], 'matrix_number_side_b',
              maxLength: 255),
      originalReleaseDate: json['original_release_date'] == null
          ? null
          : _catalogPartialDate(
              json['original_release_date'], 'original_release_date'),
      packaging: json['packaging'] == null
          ? null
          : _catalogNullableString(json['packaging'], 'packaging',
              maxLength: 100),
      recordingDate: json['recording_date'] == null
          ? null
          : _catalogPartialDate(json['recording_date'], 'recording_date'),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      rpm: json['rpm'] == null
          ? null
          : _catalogNullableInt(json['rpm'], 'rpm', minimum: 0.0),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 255),
      soundTypes: _catalogStrings(
          (json.containsKey('sound_types') ? json['sound_types'] : const []),
          'sound_types'),
      sparsCode: json['spars_code'] == null
          ? null
          : _catalogNullableString(json['spars_code'], 'spars_code',
              maxLength: 50),
      studio: _catalogStrings(
          (json.containsKey('studio') ? json['studio'] : const []), 'studio'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 500),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 255),
      tracks: _catalogObjects<MusicAlbumTrackInputV1Dto>(
          (json.containsKey('tracks') ? json['tracks'] : const []),
          'tracks',
          MusicAlbumTrackInputV1Dto.fromJson),
      vinylColor: json['vinyl_color'] == null
          ? null
          : _catalogNullableString(json['vinyl_color'], 'vinyl_color',
              maxLength: 100),
      vinylWeight: json['vinyl_weight'] == null
          ? null
          : _catalogNullableDouble(json['vinyl_weight'], 'vinyl_weight',
              minimum: 0.0),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'artists': artists.map((value) => value.toJson()).toList(),
        'back_cover_image_url': backCoverImageUrl,
        'barcode': barcode,
        'box_set': boxSet,
        'catalog_number': catalogNumber,
        'country': country,
        'cover_image_url': coverImageUrl,
        'credits': credits.map((value) => value.toJson()).toList(),
        'disc_titles': discTitles.map((value) => value.toJson()).toList(),
        'extras': extras,
        'format': format,
        'genres': genres,
        'is_live': isLive,
        'kind': kind,
        'labels': labels.map((value) => value.toJson()).toList(),
        'links': links.map((value) => value.toJson()).toList(),
        'matrix_number_side_a': matrixNumberSideA,
        'matrix_number_side_b': matrixNumberSideB,
        'original_release_date': originalReleaseDate?.toJson(),
        'packaging': packaging,
        'recording_date': recordingDate?.toJson(),
        'release_date': releaseDate?.toJson(),
        'rpm': rpm,
        'sort_title': sortTitle,
        'sound_types': soundTypes,
        'spars_code': sparsCode,
        'studio': studio,
        'subtitle': subtitle,
        'title': title,
        'tracks': tracks.map((value) => value.toJson()).toList(),
        'vinyl_color': vinylColor,
        'vinyl_weight': vinylWeight,
      };
}

@immutable
final class TVCatalogDetailsV1Dto
    implements CatalogItemKindDetailsV1Dto, CatalogItemWriteKindDetailsV1Dto {
  const TVCatalogDetailsV1Dto({
    required this.credits,
    required this.editionTitle,
    required this.format,
    required this.genres,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.region,
    required this.releaseDate,
    required this.seasons,
    required this.sortTitle,
    required this.studios,
    required this.subtitle,
    required this.title,
  });

  final List<CatalogCreditV1Dto> credits;
  final String? editionTitle;
  final String? format;
  final List<String> genres;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final String? region;
  final PartialDate? releaseDate;
  final List<CatalogSeasonV1Dto> seasons;
  final String? sortTitle;
  final List<String> studios;
  final String? subtitle;
  @override
  final String title;

  factory TVCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'TVCatalogDetailsV1Dto', const {
      "credits",
      "edition_title",
      "format",
      "genres",
      "identifiers",
      "images",
      "kind",
      "region",
      "release_date",
      "seasons",
      "sort_title",
      "studios",
      "subtitle",
      "title"
    });
    return TVCatalogDetailsV1Dto(
      credits: _catalogObjects<CatalogCreditV1Dto>(
          (json.containsKey('credits') ? json['credits'] : const []),
          'credits',
          CatalogCreditV1Dto.fromJson),
      editionTitle: json['edition_title'] == null
          ? null
          : _catalogNullableString(json['edition_title'], 'edition_title',
              maxLength: 500),
      format: json['format'] == null
          ? null
          : _catalogNullableString(json['format'], 'format', maxLength: 100),
      genres: _catalogStrings(
          (json.containsKey('genres') ? json['genres'] : const []), 'genres'),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          (json.containsKey('identifiers') ? json['identifiers'] : const []),
          'identifiers',
          CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          (json.containsKey('images') ? json['images'] : const []),
          'images',
          CatalogImageV1Dto.fromJson),
      kind: _catalogConstString(json['kind'], 'kind', "tv"),
      region: json['region'] == null
          ? null
          : _catalogNullableString(json['region'], 'region', maxLength: 64),
      releaseDate: json['release_date'] == null
          ? null
          : _catalogPartialDate(json['release_date'], 'release_date'),
      seasons: _catalogObjects<CatalogSeasonV1Dto>(
          (json.containsKey('seasons') ? json['seasons'] : const []),
          'seasons',
          CatalogSeasonV1Dto.fromJson),
      sortTitle: json['sort_title'] == null
          ? null
          : _catalogNullableString(json['sort_title'], 'sort_title',
              maxLength: 500),
      studios: _catalogStrings(
          (json.containsKey('studios') ? json['studios'] : const []),
          'studios'),
      subtitle: json['subtitle'] == null
          ? null
          : _catalogNullableString(json['subtitle'], 'subtitle',
              maxLength: 1000),
      title:
          _catalogString(json['title'], 'title', minLength: 1, maxLength: 500),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'credits': credits.map((value) => value.toJson()).toList(),
        'edition_title': editionTitle,
        'format': format,
        'genres': genres,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'region': region,
        'release_date': releaseDate?.toJson(),
        'seasons': seasons.map((value) => value.toJson()).toList(),
        'sort_title': sortTitle,
        'studios': studios,
        'subtitle': subtitle,
        'title': title,
      };
}

CatalogItemKindDetailsV1Dto catalogItemDetailsFromJson(
  Map<String, dynamic> json,
) {
  final kind = json['kind'];
  return switch (kind) {
    'anime' => AnimeCatalogDetailsV1Dto.fromJson(json),
    'boardgame' => BoardGameCatalogDetailsV1Dto.fromJson(json),
    'book' => BookCatalogDetailsV1Dto.fromJson(json),
    'comic' => ComicCatalogDetailsV1Dto.fromJson(json),
    'game' => GameCatalogDetailsV1Dto.fromJson(json),
    'manga' => MangaCatalogDetailsV1Dto.fromJson(json),
    'movie' => MovieCatalogDetailsV1Dto.fromJson(json),
    'music' => MusicCatalogDetailsV1Dto.fromJson(json),
    'tv' => TVCatalogDetailsV1Dto.fromJson(json),
    _ => throw FormatException('Unsupported Catalog Item kind: $kind'),
  };
}

CatalogItemWriteKindDetailsV1Dto catalogItemWriteDetailsFromJson(
  Map<String, dynamic> json,
) {
  final kind = json['kind'];
  return switch (kind) {
    'anime' => AnimeCatalogDetailsV1Dto.fromJson(json),
    'boardgame' => BoardGameCatalogDetailsV1Dto.fromJson(json),
    'book' => BookCatalogDetailsV1Dto.fromJson(json),
    'comic' => ComicCatalogDetailsV1Dto.fromJson(json),
    'game' => GameCatalogDetailsV1Dto.fromJson(json),
    'manga' => MangaCatalogDetailsV1Dto.fromJson(json),
    'movie' => MovieCatalogWriteDetailsV1Dto.fromJson(json),
    'music' => MusicCatalogWriteDetailsV1Dto.fromJson(json),
    'tv' => TVCatalogDetailsV1Dto.fromJson(json),
    _ => throw FormatException('Unsupported Catalog Item kind: $kind'),
  };
}

@immutable
final class CatalogItemV1Dto {
  const CatalogItemV1Dto({
    required this.id,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final CatalogItemKindDetailsV1Dto details;
  final DateTime createdAt;
  final DateTime updatedAt;
  String get kind => details.kind;
  String get title => details.title;
  CatalogItemRef get reference =>
      CatalogItemRef(kind: catalogMediaKindFromApiValue(kind), id: id);
  factory CatalogItemV1Dto.fromJson(Map<String, dynamic> json) {
    _catalogCheckKeys(json, 'CatalogItemV1Dto',
        const {'id', 'details', 'created_at', 'updated_at'});
    return CatalogItemV1Dto(
      id: _catalogString(json['id'], 'id'),
      details:
          catalogItemDetailsFromJson(_catalogMap(json['details'], 'details')),
      createdAt: _catalogDateTime(json['created_at'], 'created_at'),
      updatedAt: _catalogDateTime(json['updated_at'], 'updated_at'),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'details': details.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

@immutable
final class CatalogItemWriteV1Dto {
  const CatalogItemWriteV1Dto({required this.details});
  final CatalogItemWriteKindDetailsV1Dto details;
  Map<String, dynamic> toJson() => {'details': details.toJson()};
}

@immutable
final class CatalogItemSummaryV1Dto {
  const CatalogItemSummaryV1Dto({
    required this.id,
    required this.kind,
    required this.title,
    this.sortTitle,
    this.releaseDate,
    this.coverImageUrl,
    this.artist,
    this.format,
    this.country,
    this.label,
    this.barcode,
  });
  final String id;
  final String kind;
  final String title;
  final String? sortTitle;
  final PartialDate? releaseDate;
  final String? coverImageUrl;
  final String? artist;
  final String? format;
  final String? country;
  final String? label;
  final String? barcode;
  CatalogItemRef get reference =>
      CatalogItemRef(kind: catalogMediaKindFromApiValue(kind), id: id);
  factory CatalogItemSummaryV1Dto.fromJson(
    Map<String, dynamic> json,
  ) {
    _catalogCheckKeys(json, 'CatalogItemSummaryV1', const {
      "artist",
      "barcode",
      "country",
      "cover_image_url",
      "format",
      "id",
      "kind",
      "label",
      "release_date",
      "sort_title",
      "title"
    });
    return CatalogItemSummaryV1Dto(
      id: _catalogString(json['id'], 'id'),
      kind: _catalogEnumString(json['kind'], 'kind', const {
        "anime",
        "boardgame",
        "book",
        "comic",
        "game",
        "manga",
        "movie",
        "music",
        "tv"
      }),
      title: _catalogString(json['title'], 'title'),
      sortTitle: _catalogNullableString(json['sort_title'], 'sort_title'),
      releaseDate: _catalogPartialDate(json['release_date'], 'release_date'),
      coverImageUrl:
          _catalogNullableString(json['cover_image_url'], 'cover_image_url'),
      artist: _catalogNullableString(json['artist'], 'artist'),
      format: _catalogNullableString(json['format'], 'format'),
      country: _catalogNullableString(json['country'], 'country'),
      label: _catalogNullableString(json['label'], 'label'),
      barcode: _catalogNullableString(json['barcode'], 'barcode'),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'sort_title': sortTitle,
        'release_date': releaseDate?.toJson(),
        'cover_image_url': coverImageUrl,
        'artist': artist,
        'format': format,
        'country': country,
        'label': label,
        'barcode': barcode,
      };
}

const String catalogItemV1ContractSchemaJson =
    "{\"\$defs\":{\"AnimeCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"edition_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition Title\"},\"episodes\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogEpisodeV1\"},\"title\":\"Episodes\",\"type\":\"array\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"anime\",\"title\":\"Kind\",\"type\":\"string\"},\"region\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Region\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"studios\":{\"items\":{\"type\":\"string\"},\"title\":\"Studios\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"AnimeCatalogDetailsV1\",\"type\":\"object\"},\"BoardGameCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"best_players\":{\"items\":{\"type\":\"integer\"},\"maxItems\":32,\"title\":\"Best Players\",\"type\":\"array\"},\"categories\":{\"items\":{\"type\":\"string\"},\"title\":\"Categories\",\"type\":\"array\"},\"components\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogComponentV1\"},\"title\":\"Components\",\"type\":\"array\"},\"designers\":{\"items\":{\"type\":\"string\"},\"title\":\"Designers\",\"type\":\"array\"},\"edition\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"boardgame\",\"title\":\"Kind\",\"type\":\"string\"},\"max_players\":{\"anyOf\":[{\"minimum\":1.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Max Players\"},\"mechanics\":{\"items\":{\"type\":\"string\"},\"title\":\"Mechanics\",\"type\":\"array\"},\"min_players\":{\"anyOf\":[{\"minimum\":1.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Min Players\"},\"play_time_minutes\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Play Time Minutes\"},\"publishers\":{\"items\":{\"type\":\"string\"},\"title\":\"Publishers\",\"type\":\"array\"},\"recommended_players\":{\"items\":{\"type\":\"integer\"},\"maxItems\":32,\"title\":\"Recommended Players\",\"type\":\"array\"},\"related_items\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogRelatedItemV1\"},\"title\":\"Related Items\",\"type\":\"array\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"BoardGameCatalogDetailsV1\",\"type\":\"object\"},\"BookCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"contributors\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Contributors\",\"type\":\"array\"},\"edition\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"book\",\"title\":\"Kind\",\"type\":\"string\"},\"original_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Original Title\"},\"publication_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"publisher\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Publisher\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"series_membership\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/CatalogSeriesMembershipV1\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"subjects\":{\"items\":{\"type\":\"string\"},\"title\":\"Subjects\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"BookCatalogDetailsV1\",\"type\":\"object\"},\"CatalogComponentV1\":{\"additionalProperties\":false,\"properties\":{\"name\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Name\",\"type\":\"string\"},\"position\":{\"default\":0,\"minimum\":0.0,\"title\":\"Position\",\"type\":\"integer\"},\"quantity\":{\"default\":1,\"minimum\":1.0,\"title\":\"Quantity\",\"type\":\"integer\"}},\"required\":[\"name\"],\"title\":\"CatalogComponentV1\",\"type\":\"object\"},\"CatalogCreditV1\":{\"additionalProperties\":false,\"properties\":{\"character_name\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Character Name\"},\"name\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Name\",\"type\":\"string\"},\"role\":{\"maxLength\":100,\"minLength\":1,\"title\":\"Role\",\"type\":\"string\"},\"sort_name\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Name\"}},\"required\":[\"name\",\"role\"],\"title\":\"CatalogCreditV1\",\"type\":\"object\"},\"CatalogEpisodeV1\":{\"additionalProperties\":false,\"properties\":{\"air_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"description\":{\"anyOf\":[{\"maxLength\":10000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Description\"},\"episode_number\":{\"anyOf\":[{\"maxLength\":32,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Episode Number\"},\"runtime_minutes\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Runtime Minutes\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\"],\"title\":\"CatalogEpisodeV1\",\"type\":\"object\"},\"CatalogIdentifierV1\":{\"additionalProperties\":false,\"properties\":{\"identifier_type\":{\"maxLength\":64,\"minLength\":1,\"title\":\"Identifier Type\",\"type\":\"string\"},\"is_primary\":{\"default\":false,\"title\":\"Is Primary\",\"type\":\"boolean\"},\"value\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Value\",\"type\":\"string\"}},\"required\":[\"identifier_type\",\"value\"],\"title\":\"CatalogIdentifierV1\",\"type\":\"object\"},\"CatalogImageV1\":{\"additionalProperties\":false,\"properties\":{\"image_key\":{\"anyOf\":[{\"maxLength\":512,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Image Key\"},\"image_type\":{\"maxLength\":64,\"minLength\":1,\"title\":\"Image Type\",\"type\":\"string\"},\"position\":{\"default\":0,\"minimum\":0.0,\"title\":\"Position\",\"type\":\"integer\"},\"url\":{\"anyOf\":[{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Url\"}},\"required\":[\"image_type\"],\"title\":\"CatalogImageV1\",\"type\":\"object\"},\"CatalogItemDetailsV1\":{\"discriminator\":{\"mapping\":{\"anime\":\"#/components/schemas/AnimeCatalogDetailsV1\",\"boardgame\":\"#/components/schemas/BoardGameCatalogDetailsV1\",\"book\":\"#/components/schemas/BookCatalogDetailsV1\",\"comic\":\"#/components/schemas/ComicCatalogDetailsV1\",\"game\":\"#/components/schemas/GameCatalogDetailsV1\",\"manga\":\"#/components/schemas/MangaCatalogDetailsV1\",\"movie\":\"#/components/schemas/MovieCatalogDetailsV1-Output\",\"music\":\"#/components/schemas/MusicCatalogDetailsV1\",\"tv\":\"#/components/schemas/TVCatalogDetailsV1\"},\"propertyName\":\"kind\"},\"oneOf\":[{\"\$ref\":\"#/\$defs/AnimeCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/BoardGameCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/BookCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/ComicCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/GameCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/MangaCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/MovieCatalogDetailsV1-Output\"},{\"\$ref\":\"#/\$defs/MusicCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/TVCatalogDetailsV1\"}]},\"CatalogItemSummaryV1\":{\"additionalProperties\":false,\"properties\":{\"artist\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Artist\"},\"barcode\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Barcode\"},\"country\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Country\"},\"cover_image_url\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Cover Image Url\"},\"format\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"id\":{\"format\":\"uuid\",\"title\":\"Id\",\"type\":\"string\"},\"kind\":{\"enum\":[\"anime\",\"boardgame\",\"book\",\"comic\",\"game\",\"manga\",\"movie\",\"music\",\"tv\"],\"title\":\"Kind\",\"type\":\"string\"},\"label\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Label\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"title\":{\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"id\",\"kind\",\"title\"],\"title\":\"CatalogItemSummaryV1\",\"type\":\"object\"},\"CatalogItemV1\":{\"additionalProperties\":false,\"properties\":{\"created_at\":{\"format\":\"date-time\",\"title\":\"Created At\",\"type\":\"string\"},\"details\":{\"\$ref\":\"#/\$defs/CatalogItemDetailsV1\"},\"id\":{\"format\":\"uuid\",\"title\":\"Id\",\"type\":\"string\"},\"updated_at\":{\"format\":\"date-time\",\"title\":\"Updated At\",\"type\":\"string\"}},\"required\":[\"id\",\"details\",\"created_at\",\"updated_at\"],\"title\":\"CatalogItemV1\",\"type\":\"object\"},\"CatalogItemWriteDetailsV1\":{\"discriminator\":{\"mapping\":{\"anime\":\"#/components/schemas/AnimeCatalogDetailsV1\",\"boardgame\":\"#/components/schemas/BoardGameCatalogDetailsV1\",\"book\":\"#/components/schemas/BookCatalogDetailsV1\",\"comic\":\"#/components/schemas/ComicCatalogDetailsV1\",\"game\":\"#/components/schemas/GameCatalogDetailsV1\",\"manga\":\"#/components/schemas/MangaCatalogDetailsV1\",\"movie\":\"#/components/schemas/MovieCatalogDetailsV1-Input\",\"music\":\"#/components/schemas/MusicCatalogWriteDetailsV1\",\"tv\":\"#/components/schemas/TVCatalogDetailsV1\"},\"propertyName\":\"kind\"},\"oneOf\":[{\"\$ref\":\"#/\$defs/AnimeCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/BoardGameCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/BookCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/ComicCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/GameCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/MangaCatalogDetailsV1\"},{\"\$ref\":\"#/\$defs/MovieCatalogDetailsV1-Input\"},{\"\$ref\":\"#/\$defs/MusicCatalogWriteDetailsV1\"},{\"\$ref\":\"#/\$defs/TVCatalogDetailsV1\"}]},\"CatalogItemWriteV1\":{\"additionalProperties\":false,\"properties\":{\"details\":{\"\$ref\":\"#/\$defs/CatalogItemWriteDetailsV1\"}},\"required\":[\"details\"],\"title\":\"CatalogItemWriteV1\",\"type\":\"object\"},\"CatalogMediaTrackV1\":{\"additionalProperties\":false,\"properties\":{\"aspect_ratio\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Aspect Ratio\"},\"audio_tracks\":{\"items\":{\"type\":\"string\"},\"title\":\"Audio Tracks\",\"type\":\"array\"},\"media_number\":{\"default\":1,\"minimum\":1.0,\"title\":\"Media Number\",\"type\":\"integer\"},\"media_type\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Media Type\"},\"subtitles\":{\"items\":{\"type\":\"string\"},\"title\":\"Subtitles\",\"type\":\"array\"},\"title\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Title\"}},\"title\":\"CatalogMediaTrackV1\",\"type\":\"object\"},\"CatalogRelatedItemV1\":{\"additionalProperties\":false,\"properties\":{\"item_id\":{\"anyOf\":[{\"format\":\"uuid\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Item Id\"},\"relation\":{\"maxLength\":64,\"minLength\":1,\"title\":\"Relation\",\"type\":\"string\"},\"title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Title\"}},\"required\":[\"relation\"],\"title\":\"CatalogRelatedItemV1\",\"type\":\"object\"},\"CatalogSeasonV1\":{\"additionalProperties\":false,\"properties\":{\"episodes\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogEpisodeV1\"},\"title\":\"Episodes\",\"type\":\"array\"},\"season_number\":{\"minimum\":0.0,\"title\":\"Season Number\",\"type\":\"integer\"},\"title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Title\"}},\"required\":[\"season_number\"],\"title\":\"CatalogSeasonV1\",\"type\":\"object\"},\"CatalogSeriesMembershipV1\":{\"additionalProperties\":false,\"properties\":{\"position\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Position\"},\"series_id\":{\"anyOf\":[{\"format\":\"uuid\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Series Id\"},\"series_title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Series Title\",\"type\":\"string\"}},\"required\":[\"series_title\"],\"title\":\"CatalogSeriesMembershipV1\",\"type\":\"object\"},\"ComicCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"characters\":{\"items\":{\"type\":\"string\"},\"title\":\"Characters\",\"type\":\"array\"},\"creators\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Creators\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"issue_number\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Issue Number\"},\"key_issue\":{\"default\":false,\"title\":\"Key Issue\",\"type\":\"boolean\"},\"kind\":{\"const\":\"comic\",\"title\":\"Kind\",\"type\":\"string\"},\"plot\":{\"anyOf\":[{\"maxLength\":10000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Plot\"},\"publisher\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Publisher\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"series\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/CatalogSeriesMembershipV1\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"story_arcs\":{\"items\":{\"type\":\"string\"},\"title\":\"Story Arcs\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"},\"variant\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Variant\"}},\"required\":[\"title\",\"kind\"],\"title\":\"ComicCatalogDetailsV1\",\"type\":\"object\"},\"GameCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"edition\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"game\",\"title\":\"Kind\",\"type\":\"string\"},\"platform\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Platform\"},\"publisher\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Publisher\"},\"region\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Region\"},\"related_items\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogRelatedItemV1\"},\"title\":\"Related Items\",\"type\":\"array\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"GameCatalogDetailsV1\",\"type\":\"object\"},\"MangaCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"chapters\":{\"items\":{\"type\":\"string\"},\"title\":\"Chapters\",\"type\":\"array\"},\"contributors\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Contributors\",\"type\":\"array\"},\"edition_format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition Format\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"manga\",\"title\":\"Kind\",\"type\":\"string\"},\"publisher\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Publisher\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"series_membership\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/CatalogSeriesMembershipV1\"},{\"type\":\"null\"}]},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"},\"volume_number\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Volume Number\"}},\"required\":[\"title\",\"kind\"],\"title\":\"MangaCatalogDetailsV1\",\"type\":\"object\"},\"MovieCatalogDetailsV1-Input\":{\"additionalProperties\":false,\"properties\":{\"audience_rating\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"number\"},{\"pattern\":\"^(?!^[-+.]*\$)[+-]?0*(?:\\\\d{0,3}|(?=[\\\\d.]{1,6}0*\$)\\\\d{0,3}\\\\.\\\\d{0,2}0*\$)\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Audience Rating\"},\"box_set\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Box Set\"},\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"movie\",\"title\":\"Kind\",\"type\":\"string\"},\"media_tracks\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogMediaTrackV1\"},\"title\":\"Media Tracks\",\"type\":\"array\"},\"plot\":{\"anyOf\":[{\"maxLength\":10000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Plot\"},\"region\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Region\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"release_year\":{\"anyOf\":[{\"maximum\":9999.0,\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Release Year\"},\"runtime_minutes\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Runtime Minutes\"},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"studios\":{\"items\":{\"type\":\"string\"},\"title\":\"Studios\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"MovieCatalogDetailsV1\",\"type\":\"object\"},\"MovieCatalogDetailsV1-Output\":{\"additionalProperties\":false,\"properties\":{\"audience_rating\":{\"anyOf\":[{\"pattern\":\"^(?!^[-+.]*\$)[+-]?0*(?:\\\\d{0,3}|(?=[\\\\d.]{1,6}0*\$)\\\\d{0,3}\\\\.\\\\d{0,2}0*\$)\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Audience Rating\"},\"box_set\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Box Set\"},\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"movie\",\"title\":\"Kind\",\"type\":\"string\"},\"media_tracks\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogMediaTrackV1\"},\"title\":\"Media Tracks\",\"type\":\"array\"},\"plot\":{\"anyOf\":[{\"maxLength\":10000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Plot\"},\"region\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Region\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"release_year\":{\"anyOf\":[{\"maximum\":9999.0,\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Release Year\"},\"runtime_minutes\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Runtime Minutes\"},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"studios\":{\"items\":{\"type\":\"string\"},\"title\":\"Studios\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"MovieCatalogDetailsV1\",\"type\":\"object\"},\"MusicAlbumArtistV1\":{\"additionalProperties\":false,\"properties\":{\"name\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Name\",\"type\":\"string\"},\"sort_name\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Name\"}},\"required\":[\"name\"],\"title\":\"MusicAlbumArtistV1\",\"type\":\"object\"},\"MusicAlbumCreditV1\":{\"additionalProperties\":false,\"properties\":{\"credited_name\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Credited Name\",\"type\":\"string\"},\"instrument\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Instrument\"},\"join_phrase\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Join Phrase\"},\"role\":{\"maxLength\":64,\"minLength\":1,\"title\":\"Role\",\"type\":\"string\"},\"sequence\":{\"minimum\":0.0,\"title\":\"Sequence\",\"type\":\"integer\"}},\"required\":[\"role\",\"sequence\",\"credited_name\"],\"title\":\"MusicAlbumCreditV1\",\"type\":\"object\"},\"MusicAlbumDiscTitleV1\":{\"additionalProperties\":false,\"properties\":{\"disc_number\":{\"minimum\":1.0,\"title\":\"Disc Number\",\"type\":\"integer\"},\"title\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"disc_number\",\"title\"],\"title\":\"MusicAlbumDiscTitleV1\",\"type\":\"object\"},\"MusicAlbumLabelV1\":{\"additionalProperties\":false,\"properties\":{\"catalog_number\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Catalog Number\"},\"name\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Name\",\"type\":\"string\"}},\"required\":[\"name\"],\"title\":\"MusicAlbumLabelV1\",\"type\":\"object\"},\"MusicAlbumLinkV1\":{\"additionalProperties\":false,\"properties\":{\"description\":{\"anyOf\":[{\"maxLength\":2000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Description\"},\"position\":{\"minimum\":0.0,\"title\":\"Position\",\"type\":\"integer\"},\"title\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Title\"},\"url\":{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"title\":\"Url\",\"type\":\"string\"}},\"required\":[\"position\",\"url\"],\"title\":\"MusicAlbumLinkV1\",\"type\":\"object\"},\"MusicAlbumTrackInputV1\":{\"additionalProperties\":false,\"properties\":{\"artist\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Artist\"},\"disc_number\":{\"minimum\":1.0,\"title\":\"Disc Number\",\"type\":\"integer\"},\"duration_ms\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Duration Ms\"},\"position\":{\"minimum\":1.0,\"title\":\"Position\",\"type\":\"integer\"},\"title\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"disc_number\",\"position\",\"title\"],\"title\":\"MusicAlbumTrackInputV1\",\"type\":\"object\"},\"MusicAlbumTrackV1\":{\"additionalProperties\":false,\"properties\":{\"album_id\":{\"format\":\"uuid\",\"title\":\"Album Id\",\"type\":\"string\"},\"artist\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Artist\"},\"disc_number\":{\"minimum\":1.0,\"title\":\"Disc Number\",\"type\":\"integer\"},\"duration_ms\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Duration Ms\"},\"position\":{\"minimum\":1.0,\"title\":\"Position\",\"type\":\"integer\"},\"title\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"album_id\",\"disc_number\",\"position\",\"title\"],\"title\":\"MusicAlbumTrackV1\",\"type\":\"object\"},\"MusicCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"artists\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumArtistV1\"},\"title\":\"Artists\",\"type\":\"array\"},\"back_cover_image_url\":{\"anyOf\":[{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Back Cover Image Url\"},\"barcode\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Barcode\"},\"box_set\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Box Set\"},\"catalog_number\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Catalog Number\"},\"country\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Country\"},\"cover_image_url\":{\"anyOf\":[{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Cover Image Url\"},\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"disc_titles\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumDiscTitleV1\"},\"title\":\"Disc Titles\",\"type\":\"array\"},\"extras\":{\"items\":{\"type\":\"string\"},\"title\":\"Extras\",\"type\":\"array\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"is_live\":{\"anyOf\":[{\"type\":\"boolean\"},{\"type\":\"null\"}],\"title\":\"Is Live\"},\"kind\":{\"const\":\"music\",\"title\":\"Kind\",\"type\":\"string\"},\"labels\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumLabelV1\"},\"title\":\"Labels\",\"type\":\"array\"},\"links\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumLinkV1\"},\"title\":\"Links\",\"type\":\"array\"},\"matrix_number_side_a\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Matrix Number Side A\"},\"matrix_number_side_b\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Matrix Number Side B\"},\"original_release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"packaging\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Packaging\"},\"recording_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"rpm\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Rpm\"},\"sort_title\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"sound_types\":{\"items\":{\"type\":\"string\"},\"title\":\"Sound Types\",\"type\":\"array\"},\"spars_code\":{\"anyOf\":[{\"maxLength\":50,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Spars Code\"},\"studio\":{\"items\":{\"type\":\"string\"},\"title\":\"Studio\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"},\"tracks\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumTrackV1\"},\"title\":\"Tracks\",\"type\":\"array\"},\"vinyl_color\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Vinyl Color\"},\"vinyl_weight\":{\"anyOf\":[{\"pattern\":\"^(?!^[-+.]*\$)[+-]?0*(?:\\\\d{0,6}|(?=[\\\\d.]{1,9}0*\$)\\\\d{0,6}\\\\.\\\\d{0,2}0*\$)\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Vinyl Weight\"}},\"required\":[\"title\",\"kind\"],\"title\":\"MusicCatalogDetailsV1\",\"type\":\"object\"},\"MusicCatalogWriteDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"artists\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumArtistV1\"},\"title\":\"Artists\",\"type\":\"array\"},\"back_cover_image_url\":{\"anyOf\":[{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Back Cover Image Url\"},\"barcode\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Barcode\"},\"box_set\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Box Set\"},\"catalog_number\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Catalog Number\"},\"country\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Country\"},\"cover_image_url\":{\"anyOf\":[{\"format\":\"uri\",\"maxLength\":2083,\"minLength\":1,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Cover Image Url\"},\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"disc_titles\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumDiscTitleV1\"},\"title\":\"Disc Titles\",\"type\":\"array\"},\"extras\":{\"items\":{\"type\":\"string\"},\"title\":\"Extras\",\"type\":\"array\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"is_live\":{\"anyOf\":[{\"type\":\"boolean\"},{\"type\":\"null\"}],\"title\":\"Is Live\"},\"kind\":{\"const\":\"music\",\"title\":\"Kind\",\"type\":\"string\"},\"labels\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumLabelV1\"},\"title\":\"Labels\",\"type\":\"array\"},\"links\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumLinkV1\"},\"title\":\"Links\",\"type\":\"array\"},\"matrix_number_side_a\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Matrix Number Side A\"},\"matrix_number_side_b\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Matrix Number Side B\"},\"original_release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"packaging\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Packaging\"},\"recording_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"rpm\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Rpm\"},\"sort_title\":{\"anyOf\":[{\"maxLength\":255,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"sound_types\":{\"items\":{\"type\":\"string\"},\"title\":\"Sound Types\",\"type\":\"array\"},\"spars_code\":{\"anyOf\":[{\"maxLength\":50,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Spars Code\"},\"studio\":{\"items\":{\"type\":\"string\"},\"title\":\"Studio\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":255,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"},\"tracks\":{\"items\":{\"\$ref\":\"#/\$defs/MusicAlbumTrackInputV1\"},\"title\":\"Tracks\",\"type\":\"array\"},\"vinyl_color\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Vinyl Color\"},\"vinyl_weight\":{\"anyOf\":[{\"minimum\":0.0,\"type\":\"number\"},{\"pattern\":\"^(?!^[-+.]*\$)[+-]?0*(?:\\\\d{0,6}|(?=[\\\\d.]{1,9}0*\$)\\\\d{0,6}\\\\.\\\\d{0,2}0*\$)\",\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Vinyl Weight\"}},\"required\":[\"title\",\"kind\"],\"title\":\"MusicCatalogWriteDetailsV1\",\"type\":\"object\"},\"PartialDateValue\":{\"additionalProperties\":false,\"description\":\"A catalog date with independently optional components.\",\"properties\":{\"day\":{\"anyOf\":[{\"maximum\":31.0,\"minimum\":1.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Day\"},\"month\":{\"anyOf\":[{\"maximum\":12.0,\"minimum\":1.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Month\"},\"year\":{\"anyOf\":[{\"maximum\":9999.0,\"minimum\":1.0,\"type\":\"integer\"},{\"type\":\"null\"}],\"title\":\"Year\"}},\"title\":\"PartialDateValue\",\"type\":\"object\"},\"TVCatalogDetailsV1\":{\"additionalProperties\":false,\"properties\":{\"credits\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogCreditV1\"},\"title\":\"Credits\",\"type\":\"array\"},\"edition_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Edition Title\"},\"format\":{\"anyOf\":[{\"maxLength\":100,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Format\"},\"genres\":{\"items\":{\"type\":\"string\"},\"title\":\"Genres\",\"type\":\"array\"},\"identifiers\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogIdentifierV1\"},\"title\":\"Identifiers\",\"type\":\"array\"},\"images\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogImageV1\"},\"title\":\"Images\",\"type\":\"array\"},\"kind\":{\"const\":\"tv\",\"title\":\"Kind\",\"type\":\"string\"},\"region\":{\"anyOf\":[{\"maxLength\":64,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Region\"},\"release_date\":{\"anyOf\":[{\"\$ref\":\"#/\$defs/PartialDateValue\"},{\"type\":\"null\"}]},\"seasons\":{\"items\":{\"\$ref\":\"#/\$defs/CatalogSeasonV1\"},\"title\":\"Seasons\",\"type\":\"array\"},\"sort_title\":{\"anyOf\":[{\"maxLength\":500,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Sort Title\"},\"studios\":{\"items\":{\"type\":\"string\"},\"title\":\"Studios\",\"type\":\"array\"},\"subtitle\":{\"anyOf\":[{\"maxLength\":1000,\"type\":\"string\"},{\"type\":\"null\"}],\"title\":\"Subtitle\"},\"title\":{\"maxLength\":500,\"minLength\":1,\"title\":\"Title\",\"type\":\"string\"}},\"required\":[\"title\",\"kind\"],\"title\":\"TVCatalogDetailsV1\",\"type\":\"object\"}}}";
