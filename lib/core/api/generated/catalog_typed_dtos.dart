import 'package:collectarr_app/core/models/catalog_item.dart';

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

  CatalogItem toCatalogItem() {
    final payload = Map<String, dynamic>.from(raw);
    payload.putIfAbsent('id', () => id);
    payload.putIfAbsent('title', () => title);
    payload.putIfAbsent('kind', () => kind);
    return CatalogItem.fromJson(payload);
  }
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
  final String? kind = 'book';
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
  final String? kind = 'book';
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
  final String? kind = 'game';
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
  final String? kind = 'game';
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
  final String? kind = 'boardgame';
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
  final String? kind = 'boardgame';
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
