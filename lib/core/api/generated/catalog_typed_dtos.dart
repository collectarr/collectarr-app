import 'collectarr_api.enums.dart';

abstract class CatalogTypedDto {
  CatalogTypedDto(this.raw);

  final Map<String, dynamic> raw;

  String get id;
  String get title;
  String? get kind;
  DateTime? get releaseDate;
  String? get coverImageUrl;
  String? get thumbnailImageUrl;
  String? get barcode;

}

class BookWorkDto extends CatalogTypedDto {
  BookWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.searchAliases,
    required this.genres,
    required this.series,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.book.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<String> searchAliases;
  final List<String> genres;
  final List<String> series;

  factory BookWorkDto.fromJson(Map<String, dynamic> json) {
    return BookWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      searchAliases: _stringList(json['search_aliases']),
      genres: _stringList(json['genres']),
      series: _stringList(json['series']),
    );
  }
}

class BookEditionDto extends CatalogTypedDto {
  BookEditionDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.format,
    required this.publisher,
    required this.isbn,
    required this.upc,
    required this.language,
    required this.region,
    required this.releaseDate,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.book.apiValue;
  @override
  final DateTime? releaseDate;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final String? format;
  final String? publisher;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;

  factory BookEditionDto.fromJson(Map<String, dynamic> json) {
    return BookEditionDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Edition',
      format: json['format']?.toString(),
      publisher: json['publisher']?.toString(),
      isbn: json['isbn']?.toString(),
      upc: json['upc']?.toString(),
      language: json['language']?.toString(),
      region: json['region']?.toString(),
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']),
    );
  }
}

class GameWorkDto extends CatalogTypedDto {
  GameWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.platforms,
    required this.identifiers,
    required this.companyRoles,
    required this.ageRatings,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.game.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> companyRoles;
  final List<String> ageRatings;

  factory GameWorkDto.fromJson(Map<String, dynamic> json) {
    return GameWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      platforms: _stringList(json['platforms']),
      identifiers: _stringList(json['identifiers']),
      companyRoles: _stringList(json['company_roles']),
      ageRatings: _stringList(json['age_ratings']),
    );
  }
}

class GameReleaseDto extends CatalogTypedDto {
  GameReleaseDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.regionCode,
    required this.format,
    required this.publisher,
    required this.catalogNumber,
    required this.releaseStatus,
    required this.language,
    required this.barcode,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.game.apiValue;
  @override
  final DateTime? releaseDate;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode;
  final String? platform;
  final String? regionCode;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? language;

  factory GameReleaseDto.fromJson(Map<String, dynamic> json) {
    return GameReleaseDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['release_title']?.toString() ??
          json['title']?.toString() ??
          'Release',
      platform: json['platform']?.toString(),
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']),
      regionCode: json['region_code']?.toString() ?? json['region']?.toString(),
      format: json['format']?.toString(),
      publisher: json['publisher']?.toString(),
      catalogNumber: json['catalog_number']?.toString(),
      releaseStatus: json['release_status']?.toString(),
      language: json['language']?.toString(),
      barcode: json['barcode']?.toString(),
    );
  }
}

class BoardGameWorkDto extends CatalogTypedDto {
  BoardGameWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.platforms,
    required this.identifiers,
    required this.contributors,
    required this.mechanics,
    required this.categories,
    required this.families,
    required this.expansions,
    required this.rankings,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.boardgame.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> expansions;
  final List<String> rankings;

  factory BoardGameWorkDto.fromJson(Map<String, dynamic> json) {
    return BoardGameWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      platforms: _stringList(json['platforms']),
      identifiers: _stringList(json['identifiers']),
      contributors: _stringList(json['contributors']),
      mechanics: _stringList(json['mechanics']),
      categories: _stringList(json['categories']),
      families: _stringList(json['families']),
      expansions: _stringList(json['expansions']),
      rankings: _stringList(json['rankings']),
    );
  }
}

class BoardGameEditionDto extends CatalogTypedDto {
  BoardGameEditionDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.editionTitle,
    required this.format,
    required this.publisher,
    required this.catalogNumber,
    required this.barcode,
    required this.releaseStatus,
    required this.releaseDate,
    required this.language,
    required this.country,
    required this.ageRating,
    required this.audienceRating,
    required this.minPlayers,
    required this.maxPlayers,
    required this.playingTimeMinutes,
    required this.minAge,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.boardgame.apiValue;
  @override
  final DateTime? releaseDate;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode;
  final String? editionTitle;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? language;
  final String? country;
  final String? ageRating;
  final String? audienceRating;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final int? minAge;

  factory BoardGameEditionDto.fromJson(Map<String, dynamic> json) {
    return BoardGameEditionDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ??
          json['edition_title']?.toString() ??
          'Edition',
      editionTitle: json['edition_title']?.toString(),
      format: json['format']?.toString(),
      publisher: json['publisher']?.toString(),
      catalogNumber: json['catalog_number']?.toString(),
      barcode: json['barcode']?.toString(),
      releaseStatus: json['release_status']?.toString(),
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']),
      language: json['language']?.toString(),
      country: json['country']?.toString(),
      ageRating: json['age_rating']?.toString(),
      audienceRating: json['audience_rating']?.toString(),
      minPlayers: _intValue(json['min_players']),
      maxPlayers: _intValue(json['max_players']),
      playingTimeMinutes: _intValue(json['playing_time_minutes']),
      minAge: _intValue(json['min_age']),
    );
  }
}

class MusicReleaseDto extends CatalogTypedDto {
  MusicReleaseDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.subtitle,
    required this.releaseType,
    required this.releaseStatus,
    required this.releaseDate,
    required this.recordingDate,
    required this.trackCount,
    required this.publisher,
    required this.studio,
    required this.catalogNumber,
    required this.barcode,
    required this.countryCode,
    required this.language,
    required this.coverImageUrl,
    required this.coverImageKey,
    required this.extras,
    required this.media,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.music.apiValue;
  @override
  final DateTime? releaseDate;
  @override
  final String? coverImageUrl;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode;
  final String? subtitle;
  final String? releaseType;
  final String? releaseStatus;
  final DateTime? recordingDate;
  final int? trackCount;
  final String? publisher;
  final String? studio;
  final String? catalogNumber;
  final String? countryCode;
  final String? language;
  final String? coverImageKey;
  final String? extras;
  final List<MusicMediaDto> media;

  factory MusicReleaseDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Release',
      subtitle: json['subtitle']?.toString(),
      releaseType: json['release_type']?.toString(),
      releaseStatus: json['release_status']?.toString(),
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']),
      recordingDate: _parseDate(json['recording_date'] ?? json['recordingDate']),
      trackCount: _intValue(json['track_count'] ?? json['trackCount']),
      publisher: json['publisher']?.toString(),
      studio: json['studio']?.toString(),
      catalogNumber: json['catalog_number']?.toString(),
      barcode: json['barcode']?.toString(),
      countryCode: json['country_code']?.toString(),
      language: json['language']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      coverImageKey: json['cover_image_key']?.toString(),
      extras: json['extras']?.toString(),
      media: _musicMediaList(json['media']),
    );
  }
}

class MusicMediaDto extends CatalogTypedDto {
  MusicMediaDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.mediaNumber,
    required this.mediaType,
    required this.trackCount,
    required this.packaging,
    required this.soundType,
    required this.vinylColor,
    required this.vinylWeight,
    required this.rpm,
    required this.spars,
    required this.tracks,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.music.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final int? mediaNumber;
  final String? mediaType;
  final int? trackCount;
  final String? packaging;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final int? rpm;
  final String? spars;
  final List<MusicTrackDto> tracks;

  factory MusicMediaDto.fromJson(Map<String, dynamic> json) {
    return MusicMediaDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Media',
      mediaNumber: _intValue(json['media_number'] ?? json['mediaNumber']),
      mediaType: json['media_type']?.toString(),
      trackCount: _intValue(json['track_count'] ?? json['trackCount']),
      packaging: json['packaging']?.toString(),
      soundType: json['sound_type']?.toString(),
      vinylColor: json['vinyl_color']?.toString(),
      vinylWeight: json['vinyl_weight']?.toString(),
      rpm: _intValue(json['rpm']),
      spars: json['spars']?.toString(),
      tracks: _musicTrackList(json['tracks']),
    );
  }
}

class MusicTrackDto extends CatalogTypedDto {
  MusicTrackDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.position,
    required this.durationMs,
    required this.instrument,
    required this.composition,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.music.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final String? position;
  final int? durationMs;
  final String? instrument;
  final String? composition;

  factory MusicTrackDto.fromJson(Map<String, dynamic> json) {
    return MusicTrackDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Track',
      position: json['position']?.toString(),
      durationMs: _intValue(json['duration_ms'] ?? json['durationMs']),
      instrument: json['instrument']?.toString(),
      composition: json['composition']?.toString(),
    );
  }
}

class ComicWorkDto extends CatalogTypedDto {
  ComicWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.issues,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.comic.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<Map<String, dynamic>> issues;

  factory ComicWorkDto.fromJson(Map<String, dynamic> json) {
    return ComicWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      issues: _mapList(json['issues']),
    );
  }
}

class MangaWorkDto extends CatalogTypedDto {
  MangaWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.chapters,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.manga.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<Map<String, dynamic>> chapters;

  factory MangaWorkDto.fromJson(Map<String, dynamic> json) {
    return MangaWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      chapters: _mapList(json['chapters']),
    );
  }
}

class AnimeSeriesDto extends CatalogTypedDto {
  AnimeSeriesDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.episodes,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.anime.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<Map<String, dynamic>> episodes;

  factory AnimeSeriesDto.fromJson(Map<String, dynamic> json) {
    return AnimeSeriesDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      episodes: _mapList(json['episodes']),
    );
  }
}

class MovieWorkDto extends CatalogTypedDto {
  MovieWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.releases,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.movie.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<Map<String, dynamic>> releases;

  factory MovieWorkDto.fromJson(Map<String, dynamic> json) {
    return MovieWorkDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      releases: _mapList(json['releases']),
    );
  }
}

class TvSeriesDto extends CatalogTypedDto {
  TvSeriesDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.seasons,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind = CollectarrItemKind.tv.apiValue;
  @override
  final DateTime? releaseDate = null;
  @override
  final String? coverImageUrl = null;
  @override
  final String? thumbnailImageUrl = null;
  @override
  final String? barcode = null;
  final List<Map<String, dynamic>> seasons;

  factory TvSeriesDto.fromJson(Map<String, dynamic> json) {
    return TvSeriesDto._(
      Map<String, dynamic>.from(json),
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      seasons: _mapList(json['seasons']),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  final result = <String>[];
  final seen = <String>{};
  for (final entry in value) {
    final text = entry?.toString().trim();
    if (text == null || text.isEmpty) {
      continue;
    }
    final marker = text.toLowerCase();
    if (seen.add(marker)) {
      result.add(text);
    }
  }
  return result;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}

List<MusicMediaDto> _musicMediaList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) MusicMediaDto.fromJson(entry),
  ];
}

List<MusicTrackDto> _musicTrackList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) MusicTrackDto.fromJson(entry),
  ];
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
