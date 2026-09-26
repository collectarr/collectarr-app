// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tool/core_contracts/catalog-item-v1.json
// Contract SHA-256: 3b03dee60e7ff72afd634ecc95bbaac13146840b612bd1e22792dd340a8de449
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

String _catalogString(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

int _catalogInt(Object? value, String field) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

double _catalogDouble(Object? value, String field) {
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

DateTime _catalogDateTime(Object? value, String field) {
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid Catalog Item field: $field');
}

List<String> _catalogStrings(Object? value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

List<T> _catalogObjects<T>(
  Object? value,
  T Function(Map<String, dynamic>) decode,
) {
  if (value is! List) return <T>[];
  return [
    for (final row in value)
      if (row is Map) decode(Map<String, dynamic>.from(row))
  ];
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
    return CatalogComponentV1Dto(
      name: _catalogString(json['name'], 'name'),
      position: ((json['position'] as num?)?.toInt() ?? 0),
      quantity: ((json['quantity'] as num?)?.toInt() ?? 1),
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
    return CatalogCreditV1Dto(
      characterName: json['character_name'] == null
          ? null
          : json['character_name'] as String?,
      name: _catalogString(json['name'], 'name'),
      role: _catalogString(json['role'], 'role'),
      sortName: json['sort_name'] == null ? null : json['sort_name'] as String?,
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
    required this.seasonNumber,
    required this.title,
  });

  final PartialDate? airDate;
  final String? description;
  final String? episodeNumber;
  final int? runtimeMinutes;
  final int? seasonNumber;
  final String title;

  factory CatalogEpisodeV1Dto.fromJson(Map<String, dynamic> json) {
    return CatalogEpisodeV1Dto(
      airDate: json['air_date'] == null
          ? null
          : PartialDate.tryParse(json['air_date']),
      description:
          json['description'] == null ? null : json['description'] as String?,
      episodeNumber: json['episode_number'] == null
          ? null
          : json['episode_number'] as String?,
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : (json['runtime_minutes'] as num?)?.toInt(),
      seasonNumber: json['season_number'] == null
          ? null
          : (json['season_number'] as num?)?.toInt(),
      title: _catalogString(json['title'], 'title'),
    );
  }

  Map<String, dynamic> toJson() => {
        'air_date': airDate?.toJson(),
        'description': description,
        'episode_number': episodeNumber,
        'runtime_minutes': runtimeMinutes,
        'season_number': seasonNumber,
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
    return CatalogIdentifierV1Dto(
      identifierType:
          _catalogString(json['identifier_type'], 'identifier_type'),
      isPrimary: (json['is_primary'] as bool? ?? false),
      value: _catalogString(json['value'], 'value'),
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
    return CatalogImageV1Dto(
      imageKey: json['image_key'] == null ? null : json['image_key'] as String?,
      imageType: _catalogString(json['image_type'], 'image_type'),
      position: ((json['position'] as num?)?.toInt() ?? 0),
      url: json['url'] == null ? null : json['url'] as String?,
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
    return CatalogMediaTrackV1Dto(
      aspectRatio:
          json['aspect_ratio'] == null ? null : json['aspect_ratio'] as String?,
      audioTracks: _catalogStrings(json['audio_tracks']),
      mediaNumber: ((json['media_number'] as num?)?.toInt() ?? 1),
      mediaType:
          json['media_type'] == null ? null : json['media_type'] as String?,
      subtitles: _catalogStrings(json['subtitles']),
      title: json['title'] == null ? null : json['title'] as String?,
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
    return CatalogRelatedItemV1Dto(
      itemId: json['item_id'] == null ? null : json['item_id'] as String?,
      relation: _catalogString(json['relation'], 'relation'),
      title: json['title'] == null ? null : json['title'] as String?,
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
    return CatalogSeasonV1Dto(
      episodes: _catalogObjects<CatalogEpisodeV1Dto>(
          json['episodes'], CatalogEpisodeV1Dto.fromJson),
      seasonNumber: _catalogInt(json['season_number'], 'season_number'),
      title: json['title'] == null ? null : json['title'] as String?,
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
    return CatalogSeriesMembershipV1Dto(
      position: json['position'] == null ? null : json['position'] as String?,
      seriesId: json['series_id'] == null ? null : json['series_id'] as String?,
      seriesTitle: _catalogString(json['series_title'], 'series_title'),
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
    return MusicAlbumTrackV1Dto(
      albumId: _catalogString(json['album_id'], 'album_id'),
      artist: json['artist'] == null ? null : json['artist'] as String?,
      discNumber: _catalogInt(json['disc_number'], 'disc_number'),
      durationMs: json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num?)?.toInt(),
      position: _catalogInt(json['position'], 'position'),
      title: _catalogString(json['title'], 'title'),
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
    return AnimeCatalogDetailsV1Dto(
      credits: _catalogObjects<CatalogCreditV1Dto>(
          json['credits'], CatalogCreditV1Dto.fromJson),
      editionTitle: json['edition_title'] == null
          ? null
          : json['edition_title'] as String?,
      episodes: _catalogObjects<CatalogEpisodeV1Dto>(
          json['episodes'], CatalogEpisodeV1Dto.fromJson),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      region: json['region'] == null ? null : json['region'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      studios: _catalogStrings(json['studios']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
    required this.categories,
    required this.components,
    required this.designers,
    required this.edition,
    required this.identifiers,
    required this.images,
    required this.kind,
    required this.mechanics,
    required this.playTimeMinutes,
    required this.playerCounts,
    required this.publishers,
    required this.relatedItems,
    required this.releaseDate,
    required this.sortTitle,
    required this.subtitle,
    required this.title,
  });

  final List<String> categories;
  final List<CatalogComponentV1Dto> components;
  final List<String> designers;
  final String? edition;
  final List<CatalogIdentifierV1Dto> identifiers;
  final List<CatalogImageV1Dto> images;
  @override
  final String kind;
  final List<String> mechanics;
  final int? playTimeMinutes;
  final List<String> playerCounts;
  final List<String> publishers;
  final List<CatalogRelatedItemV1Dto> relatedItems;
  final PartialDate? releaseDate;
  final String? sortTitle;
  final String? subtitle;
  @override
  final String title;

  factory BoardGameCatalogDetailsV1Dto.fromJson(Map<String, dynamic> json) {
    return BoardGameCatalogDetailsV1Dto(
      categories: _catalogStrings(json['categories']),
      components: _catalogObjects<CatalogComponentV1Dto>(
          json['components'], CatalogComponentV1Dto.fromJson),
      designers: _catalogStrings(json['designers']),
      edition: json['edition'] == null ? null : json['edition'] as String?,
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      mechanics: _catalogStrings(json['mechanics']),
      playTimeMinutes: json['play_time_minutes'] == null
          ? null
          : (json['play_time_minutes'] as num?)?.toInt(),
      playerCounts: _catalogStrings(json['player_counts']),
      publishers: _catalogStrings(json['publishers']),
      relatedItems: _catalogObjects<CatalogRelatedItemV1Dto>(
          json['related_items'], CatalogRelatedItemV1Dto.fromJson),
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'categories': categories,
        'components': components.map((value) => value.toJson()).toList(),
        'designers': designers,
        'edition': edition,
        'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'images': images.map((value) => value.toJson()).toList(),
        'kind': kind,
        'mechanics': mechanics,
        'play_time_minutes': playTimeMinutes,
        'player_counts': playerCounts,
        'publishers': publishers,
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
    return BookCatalogDetailsV1Dto(
      contributors: _catalogObjects<CatalogCreditV1Dto>(
          json['contributors'], CatalogCreditV1Dto.fromJson),
      edition: json['edition'] == null ? null : json['edition'] as String?,
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      originalTitle: json['original_title'] == null
          ? null
          : json['original_title'] as String?,
      publicationDate: json['publication_date'] == null
          ? null
          : PartialDate.tryParse(json['publication_date']),
      publisher:
          json['publisher'] == null ? null : json['publisher'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      seriesMembership: json['series_membership'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              Map<String, dynamic>.from(json['series_membership'] as Map)),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      subjects: _catalogStrings(json['subjects']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
    return ComicCatalogDetailsV1Dto(
      characters: _catalogStrings(json['characters']),
      creators: _catalogObjects<CatalogCreditV1Dto>(
          json['creators'], CatalogCreditV1Dto.fromJson),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      issueNumber:
          json['issue_number'] == null ? null : json['issue_number'] as String?,
      keyIssue: (json['key_issue'] as bool? ?? false),
      kind: _catalogString(json['kind'], 'kind'),
      plot: json['plot'] == null ? null : json['plot'] as String?,
      publisher:
          json['publisher'] == null ? null : json['publisher'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      series: json['series'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              Map<String, dynamic>.from(json['series'] as Map)),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      storyArcs: _catalogStrings(json['story_arcs']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
      variant: json['variant'] == null ? null : json['variant'] as String?,
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
    return GameCatalogDetailsV1Dto(
      edition: json['edition'] == null ? null : json['edition'] as String?,
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      platform: json['platform'] == null ? null : json['platform'] as String?,
      publisher:
          json['publisher'] == null ? null : json['publisher'] as String?,
      region: json['region'] == null ? null : json['region'] as String?,
      relatedItems: _catalogObjects<CatalogRelatedItemV1Dto>(
          json['related_items'], CatalogRelatedItemV1Dto.fromJson),
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
    return MangaCatalogDetailsV1Dto(
      chapters: _catalogStrings(json['chapters']),
      contributors: _catalogObjects<CatalogCreditV1Dto>(
          json['contributors'], CatalogCreditV1Dto.fromJson),
      editionFormat: json['edition_format'] == null
          ? null
          : json['edition_format'] as String?,
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      publisher:
          json['publisher'] == null ? null : json['publisher'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      seriesMembership: json['series_membership'] == null
          ? null
          : CatalogSeriesMembershipV1Dto.fromJson(
              Map<String, dynamic>.from(json['series_membership'] as Map)),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
      volumeNumber: json['volume_number'] == null
          ? null
          : json['volume_number'] as String?,
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
    return MovieCatalogWriteDetailsV1Dto(
      audienceRating: json['audience_rating'] == null
          ? null
          : (json['audience_rating'] == null
              ? null
              : _catalogDouble(json['audience_rating'], 'audience_rating')),
      boxSet: json['box_set'] == null ? null : json['box_set'] as String?,
      credits: _catalogObjects<CatalogCreditV1Dto>(
          json['credits'], CatalogCreditV1Dto.fromJson),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      mediaTracks: _catalogObjects<CatalogMediaTrackV1Dto>(
          json['media_tracks'], CatalogMediaTrackV1Dto.fromJson),
      plot: json['plot'] == null ? null : json['plot'] as String?,
      region: json['region'] == null ? null : json['region'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      releaseYear: json['release_year'] == null
          ? null
          : (json['release_year'] as num?)?.toInt(),
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : (json['runtime_minutes'] as num?)?.toInt(),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      studios: _catalogStrings(json['studios']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
    return MovieCatalogDetailsV1Dto(
      audienceRating: json['audience_rating'] == null
          ? null
          : json['audience_rating'] as String?,
      boxSet: json['box_set'] == null ? null : json['box_set'] as String?,
      credits: _catalogObjects<CatalogCreditV1Dto>(
          json['credits'], CatalogCreditV1Dto.fromJson),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      mediaTracks: _catalogObjects<CatalogMediaTrackV1Dto>(
          json['media_tracks'], CatalogMediaTrackV1Dto.fromJson),
      plot: json['plot'] == null ? null : json['plot'] as String?,
      region: json['region'] == null ? null : json['region'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      releaseYear: json['release_year'] == null
          ? null
          : (json['release_year'] as num?)?.toInt(),
      runtimeMinutes: json['runtime_minutes'] == null
          ? null
          : (json['runtime_minutes'] as num?)?.toInt(),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      studios: _catalogStrings(json['studios']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
    return MusicAlbumArtistV1Dto(
      name: _catalogString(json['name'], 'name'),
      sortName: json['sort_name'] == null ? null : json['sort_name'] as String?,
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
    return MusicAlbumCreditV1Dto(
      creditedName: _catalogString(json['credited_name'], 'credited_name'),
      instrument:
          json['instrument'] == null ? null : json['instrument'] as String?,
      joinPhrase:
          json['join_phrase'] == null ? null : json['join_phrase'] as String?,
      role: _catalogString(json['role'], 'role'),
      sequence: _catalogInt(json['sequence'], 'sequence'),
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
    return MusicAlbumDiscTitleV1Dto(
      discNumber: _catalogInt(json['disc_number'], 'disc_number'),
      title: _catalogString(json['title'], 'title'),
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
    return MusicAlbumLabelV1Dto(
      catalogNumber: json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?,
      name: _catalogString(json['name'], 'name'),
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
    return MusicAlbumLinkV1Dto(
      description:
          json['description'] == null ? null : json['description'] as String?,
      position: _catalogInt(json['position'], 'position'),
      title: json['title'] == null ? null : json['title'] as String?,
      url: _catalogString(json['url'], 'url'),
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
    return MusicAlbumTrackInputV1Dto(
      artist: json['artist'] == null ? null : json['artist'] as String?,
      discNumber: _catalogInt(json['disc_number'], 'disc_number'),
      durationMs: json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num?)?.toInt(),
      position: _catalogInt(json['position'], 'position'),
      title: _catalogString(json['title'], 'title'),
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
    return MusicCatalogDetailsV1Dto(
      artists: _catalogObjects<MusicAlbumArtistV1Dto>(
          json['artists'], MusicAlbumArtistV1Dto.fromJson),
      backCoverImageUrl: json['back_cover_image_url'] == null
          ? null
          : json['back_cover_image_url'] as String?,
      barcode: json['barcode'] == null ? null : json['barcode'] as String?,
      boxSet: json['box_set'] == null ? null : json['box_set'] as String?,
      catalogNumber: json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?,
      country: json['country'] == null ? null : json['country'] as String?,
      coverImageUrl: json['cover_image_url'] == null
          ? null
          : json['cover_image_url'] as String?,
      credits: _catalogObjects<MusicAlbumCreditV1Dto>(
          json['credits'], MusicAlbumCreditV1Dto.fromJson),
      discTitles: _catalogObjects<MusicAlbumDiscTitleV1Dto>(
          json['disc_titles'], MusicAlbumDiscTitleV1Dto.fromJson),
      extras: _catalogStrings(json['extras']),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      isLive: json['is_live'] == null ? null : json['is_live'] as bool?,
      kind: _catalogString(json['kind'], 'kind'),
      labels: _catalogObjects<MusicAlbumLabelV1Dto>(
          json['labels'], MusicAlbumLabelV1Dto.fromJson),
      links: _catalogObjects<MusicAlbumLinkV1Dto>(
          json['links'], MusicAlbumLinkV1Dto.fromJson),
      matrixNumberSideA: json['matrix_number_side_a'] == null
          ? null
          : json['matrix_number_side_a'] as String?,
      matrixNumberSideB: json['matrix_number_side_b'] == null
          ? null
          : json['matrix_number_side_b'] as String?,
      originalReleaseDate: json['original_release_date'] == null
          ? null
          : PartialDate.tryParse(json['original_release_date']),
      packaging:
          json['packaging'] == null ? null : json['packaging'] as String?,
      recordingDate: json['recording_date'] == null
          ? null
          : PartialDate.tryParse(json['recording_date']),
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      rpm: json['rpm'] == null ? null : (json['rpm'] as num?)?.toInt(),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      soundTypes: _catalogStrings(json['sound_types']),
      sparsCode:
          json['spars_code'] == null ? null : json['spars_code'] as String?,
      studio: _catalogStrings(json['studio']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
      tracks: _catalogObjects<MusicAlbumTrackV1Dto>(
          json['tracks'], MusicAlbumTrackV1Dto.fromJson),
      vinylColor:
          json['vinyl_color'] == null ? null : json['vinyl_color'] as String?,
      vinylWeight:
          json['vinyl_weight'] == null ? null : json['vinyl_weight'] as String?,
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
    return MusicCatalogWriteDetailsV1Dto(
      artists: _catalogObjects<MusicAlbumArtistV1Dto>(
          json['artists'], MusicAlbumArtistV1Dto.fromJson),
      backCoverImageUrl: json['back_cover_image_url'] == null
          ? null
          : json['back_cover_image_url'] as String?,
      barcode: json['barcode'] == null ? null : json['barcode'] as String?,
      boxSet: json['box_set'] == null ? null : json['box_set'] as String?,
      catalogNumber: json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?,
      country: json['country'] == null ? null : json['country'] as String?,
      coverImageUrl: json['cover_image_url'] == null
          ? null
          : json['cover_image_url'] as String?,
      credits: _catalogObjects<MusicAlbumCreditV1Dto>(
          json['credits'], MusicAlbumCreditV1Dto.fromJson),
      discTitles: _catalogObjects<MusicAlbumDiscTitleV1Dto>(
          json['disc_titles'], MusicAlbumDiscTitleV1Dto.fromJson),
      extras: _catalogStrings(json['extras']),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      isLive: json['is_live'] == null ? null : json['is_live'] as bool?,
      kind: _catalogString(json['kind'], 'kind'),
      labels: _catalogObjects<MusicAlbumLabelV1Dto>(
          json['labels'], MusicAlbumLabelV1Dto.fromJson),
      links: _catalogObjects<MusicAlbumLinkV1Dto>(
          json['links'], MusicAlbumLinkV1Dto.fromJson),
      matrixNumberSideA: json['matrix_number_side_a'] == null
          ? null
          : json['matrix_number_side_a'] as String?,
      matrixNumberSideB: json['matrix_number_side_b'] == null
          ? null
          : json['matrix_number_side_b'] as String?,
      originalReleaseDate: json['original_release_date'] == null
          ? null
          : PartialDate.tryParse(json['original_release_date']),
      packaging:
          json['packaging'] == null ? null : json['packaging'] as String?,
      recordingDate: json['recording_date'] == null
          ? null
          : PartialDate.tryParse(json['recording_date']),
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      rpm: json['rpm'] == null ? null : (json['rpm'] as num?)?.toInt(),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      soundTypes: _catalogStrings(json['sound_types']),
      sparsCode:
          json['spars_code'] == null ? null : json['spars_code'] as String?,
      studio: _catalogStrings(json['studio']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
      tracks: _catalogObjects<MusicAlbumTrackInputV1Dto>(
          json['tracks'], MusicAlbumTrackInputV1Dto.fromJson),
      vinylColor:
          json['vinyl_color'] == null ? null : json['vinyl_color'] as String?,
      vinylWeight: json['vinyl_weight'] == null
          ? null
          : (json['vinyl_weight'] == null
              ? null
              : _catalogDouble(json['vinyl_weight'], 'vinyl_weight')),
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
    required this.episodes,
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
  final List<CatalogEpisodeV1Dto> episodes;
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
    return TVCatalogDetailsV1Dto(
      credits: _catalogObjects<CatalogCreditV1Dto>(
          json['credits'], CatalogCreditV1Dto.fromJson),
      editionTitle: json['edition_title'] == null
          ? null
          : json['edition_title'] as String?,
      episodes: _catalogObjects<CatalogEpisodeV1Dto>(
          json['episodes'], CatalogEpisodeV1Dto.fromJson),
      format: json['format'] == null ? null : json['format'] as String?,
      genres: _catalogStrings(json['genres']),
      identifiers: _catalogObjects<CatalogIdentifierV1Dto>(
          json['identifiers'], CatalogIdentifierV1Dto.fromJson),
      images: _catalogObjects<CatalogImageV1Dto>(
          json['images'], CatalogImageV1Dto.fromJson),
      kind: _catalogString(json['kind'], 'kind'),
      region: json['region'] == null ? null : json['region'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date']),
      seasons: _catalogObjects<CatalogSeasonV1Dto>(
          json['seasons'], CatalogSeasonV1Dto.fromJson),
      sortTitle:
          json['sort_title'] == null ? null : json['sort_title'] as String?,
      studios: _catalogStrings(json['studios']),
      subtitle: json['subtitle'] == null ? null : json['subtitle'] as String?,
      title: _catalogString(json['title'], 'title'),
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
  factory CatalogItemV1Dto.fromJson(Map<String, dynamic> json) =>
      CatalogItemV1Dto(
        id: _catalogString(json['id'], 'id'),
        details: catalogItemDetailsFromJson(
          Map<String, dynamic>.from(json['details'] as Map),
        ),
        createdAt: _catalogDateTime(json['created_at'], 'created_at'),
        updatedAt: _catalogDateTime(json['updated_at'], 'updated_at'),
      );
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
  });
  final String id;
  final String kind;
  final String title;
  final String? sortTitle;
  final PartialDate? releaseDate;
  final String? coverImageUrl;
  CatalogItemRef get reference =>
      CatalogItemRef(kind: catalogMediaKindFromApiValue(kind), id: id);
  factory CatalogItemSummaryV1Dto.fromJson(
    Map<String, dynamic> json,
  ) =>
      CatalogItemSummaryV1Dto(
        id: _catalogString(json['id'], 'id'),
        kind: _catalogString(json['kind'], 'kind'),
        title: _catalogString(json['title'], 'title'),
        sortTitle: json['sort_title'] as String?,
        releaseDate: PartialDate.tryParse(json['release_date']),
        coverImageUrl: json['cover_image_url'] as String?,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'sort_title': sortTitle,
        'release_date': releaseDate?.toJson(),
        'cover_image_url': coverImageUrl,
      };
}
