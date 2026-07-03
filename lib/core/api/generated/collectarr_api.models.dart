import 'package:flutter/foundation.dart';

import 'collectarr_api.enums.dart';

@immutable
abstract class TypedMetadataResponse {
  const TypedMetadataResponse(this.raw);

  final Map<String, dynamic> raw;

  String get id;
  String get title;
  String? get kind;
  CollectarrItemKind? get mediaKind => CollectarrItemKind.fromApiValue(kind);
  DateTime? get releaseDate;
  String? get coverImageUrl;
  String? get thumbnailImageUrl;
  String? get barcode;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}


String _stringValue(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _nullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _nullableDate(dynamic value) {
  final text = _nullableString(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<dynamic> _dynamicList(dynamic value) {
  if (value is List) {
    return List<dynamic>.from(value);
  }
  return const <dynamic>[];
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
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

class BookWorkDto extends TypedMetadataResponse {
  const BookWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.searchAliases,
    required this.genres,
    required this.contributors,
    required this.editions,
    required this.series,
    required this.firstPublicationDate,
    required this.originalPublicationDate,
    required this.originalLanguage,
    required this.sortTitle,
    required this.subtitle,
    required this.description,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<String> searchAliases;
  final List<String> genres;
  final List<dynamic> contributors;
  final List<BookEditionDto> editions;
  final List<dynamic> series;
  final DateTime? firstPublicationDate;
  final DateTime? originalPublicationDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? subtitle;
  final String? description;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => firstPublicationDate ?? originalPublicationDate;
  @override
  String? get coverImageUrl => _nullableString(raw['cover_image_url']);
  @override
  String? get thumbnailImageUrl =>
      _nullableString(raw['thumbnail_image_url']) ?? coverImageUrl;
  @override
  String? get barcode => _nullableString(raw['barcode']);
  String? get publisherName => _nullableString(raw['publisher']);
  DateTime? get coverDateValue => _nullableDate(raw['cover_date']);
  int? get releaseYearValue => _nullableInt(raw['release_year']);
  String? get variantValue => _nullableString(raw['variant']);
  String? get crossoverValue => _nullableString(raw['crossover']);
  String? get plotSummaryValue => _nullableString(raw['plot_summary']);
  String? get plotDescriptionValue => _nullableString(raw['plot_description']);
  List<Map<String, dynamic>> get creatorValues => _mapList(raw['creators']);
  List<String> get characterNames => _stringList(raw['characters']);
  List<String> get storyArcNames => _stringList(raw['story_arcs']);
  String? get countryValue => _nullableString(raw['country']);
  String? get languageValue => _nullableString(raw['language']);
  String? get ageRatingValue => _nullableString(raw['age_rating']);
  String? get audienceRatingValue => _nullableString(raw['audience_rating']);
  String? get physicalFormatLabelValue =>
      _nullableString(raw['physical_format_label']);

  factory BookWorkDto.fromJson(Map<String, dynamic> json) {
    return BookWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      searchAliases: _stringList(json['search_aliases']),
      genres: _stringList(json['genres']),
      contributors: _dynamicList(json['contributors']),
      editions: _bookEditionList(json['editions']),
      series: _dynamicList(json['series']),
      firstPublicationDate: _nullableDate(json['first_publication_date']),
      originalPublicationDate: _nullableDate(
        json['original_publication_date'],
      ),
      originalLanguage: _nullableString(json['original_language']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      description: _nullableString(json['description']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.book.apiValue,
    );
  }
}

class BookEditionDto extends TypedMetadataResponse {
  const BookEditionDto._(
    super.raw, {
    required this.id,
    required this.workId,
    required this.ageRating,
    required this.audioLengthMinutes,
    required this.binding,
    required this.contributors,
    required this.coverImageKey,
    required this.coverImageUrlValue,
    required this.description,
    required this.displayTitle,
    required this.editionStatement,
    required this.format,
    required this.identifiers,
    required this.imprint,
    required this.language,
    required this.isbn,
    required this.pageCount,
    required this.publicationDate,
    required this.publisher,
    required this.region,
    required this.releaseStatus,
    required this.upc,
  });

  @override
  final String id;
  final String workId;
  final String? ageRating;
  final int? audioLengthMinutes;
  final String? binding;
  final List<dynamic> contributors;
  final String? coverImageKey;
  final String? coverImageUrlValue;
  final String? description;
  final String? displayTitle;
  final String? editionStatement;
  final String? format;
  final String? isbn;
  final List<dynamic> identifiers;
  final String? imprint;
  final String? language;
  final int? pageCount;
  final DateTime? publicationDate;
  final String? publisher;
  final String? region;
  final String? releaseStatus;
  final String? upc;
  @override
  String get title => displayTitle ?? 'Edition';
  @override
  String? get kind => CollectarrItemKind.book.apiValue;
  @override
  DateTime? get releaseDate => publicationDate;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => null;

  factory BookEditionDto.fromJson(Map<String, dynamic> json) {
    return BookEditionDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      workId: _stringValue(json['work_id']),
      ageRating: _nullableString(json['age_rating']),
      audioLengthMinutes: _nullableInt(json['audio_length_minutes']),
      binding: _nullableString(json['binding']),
      contributors: _dynamicList(json['contributors']),
      coverImageKey: _nullableString(json['cover_image_key']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      description: _nullableString(json['description']),
      displayTitle: _nullableString(json['display_title']),
      editionStatement: _nullableString(json['edition_statement']),
      format: _nullableString(json['format']),
      isbn: _nullableString(json['isbn']),
      identifiers: _dynamicList(json['identifiers']),
      imprint: _nullableString(json['imprint']),
      language: _nullableString(json['language']),
      pageCount: _nullableInt(json['page_count']),
      publicationDate: _nullableDate(json['publication_date']),
      publisher: _nullableString(json['publisher']),
      region: _nullableString(json['region']),
      releaseStatus: _nullableString(json['release_status']),
      upc: _nullableString(json['upc']),
    );
  }
}

class GameWorkDto extends TypedMetadataResponse {
  const GameWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.platforms,
    required this.identifiers,
    required this.companyRoles,
    required this.ageRatings,
    required this.genres,
    required this.searchAliases,
    required this.releases,
    required this.originalLanguage,
    required this.publisher,
    required this.releaseDateValue,
    required this.sortTitle,
    required this.subtitle,
    required this.description,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> companyRoles;
  final List<String> ageRatings;
  final List<String> genres;
  final List<String> searchAliases;
  final List<dynamic> releases;
  final String? originalLanguage;
  final String? publisher;
  final DateTime? releaseDateValue;
  final String? sortTitle;
  final String? subtitle;
  final String? description;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory GameWorkDto.fromJson(Map<String, dynamic> json) {
    return GameWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      platforms: _stringList(json['platforms']),
      identifiers: _stringList(json['identifiers']),
      companyRoles: _stringList(json['company_roles']),
      ageRatings: _stringList(json['age_ratings']),
      genres: _stringList(json['genres']),
      searchAliases: _stringList(json['search_aliases']),
      releases: _dynamicList(json['releases']),
      originalLanguage: _nullableString(json['original_language']),
      publisher: _nullableString(json['publisher']),
      releaseDateValue: _nullableDate(json['release_date']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      description: _nullableString(json['description']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.game.apiValue,
    );
  }
}

class GameReleaseDto extends TypedMetadataResponse {
  const GameReleaseDto._(
    super.raw, {
    required this.id,
    required this.workId,
    required this.releaseTitle,
    required this.platform,
    required this.releaseDateValue,
    required this.regionCode,
    required this.format,
    required this.publisher,
    required this.catalogNumber,
    required this.releaseStatus,
    required this.language,
    required this.barcodeValue,
    required this.coverImageUrlValue,
  });

  @override
  final String id;
  final String workId;
  final String? releaseTitle;
  final String? platform;
  final DateTime? releaseDateValue;
  final String? regionCode;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? language;
  final String? barcodeValue;
  final String? coverImageUrlValue;
  @override
  String get title => releaseTitle ?? 'Release';
  @override
  String? get kind => CollectarrItemKind.game.apiValue;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => barcodeValue;

  factory GameReleaseDto.fromJson(Map<String, dynamic> json) {
    return GameReleaseDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      workId: _stringValue(json['work_id']),
      releaseTitle:
          _nullableString(json['release_title']) ?? _nullableString(json['title']),
      platform: _nullableString(json['platform']),
      releaseDateValue: _nullableDate(json['release_date']),
      regionCode:
          _nullableString(json['region_code']) ?? _nullableString(json['region']),
      format: _nullableString(json['format']),
      publisher: _nullableString(json['publisher']),
      catalogNumber: _nullableString(json['catalog_number']),
      releaseStatus: _nullableString(json['release_status']),
      language: _nullableString(json['language']),
      barcodeValue: _nullableString(json['barcode']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
    );
  }
}

class BoardGameWorkDto extends TypedMetadataResponse {
  const BoardGameWorkDto._(
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
    required this.searchAliases,
    required this.originalLanguage,
    required this.publisher,
    required this.releaseDateValue,
    required this.sortTitle,
    required this.subtitle,
    required this.description,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> expansions;
  final List<String> rankings;
  final List<String> searchAliases;
  final String? originalLanguage;
  final String? publisher;
  final DateTime? releaseDateValue;
  final String? sortTitle;
  final String? subtitle;
  final String? description;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory BoardGameWorkDto.fromJson(Map<String, dynamic> json) {
    return BoardGameWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      platforms: _stringList(json['platforms']),
      identifiers: _stringList(json['identifiers']),
      contributors: _stringList(json['contributors']),
      mechanics: _stringList(json['mechanics']),
      categories: _stringList(json['categories']),
      families: _stringList(json['families']),
      expansions: _stringList(json['expansions']),
      rankings: _stringList(json['rankings']),
      searchAliases: _stringList(json['search_aliases']),
      originalLanguage: _nullableString(json['original_language']),
      publisher: _nullableString(json['publisher']),
      releaseDateValue: _nullableDate(json['release_date']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      description: _nullableString(json['description']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.boardgame.apiValue,
    );
  }
}

class BoardGameEditionDto extends TypedMetadataResponse {
  const BoardGameEditionDto._(
    super.raw, {
    required this.id,
    required this.workId,
    required this.titleValue,
    required this.ageRating,
    required this.audienceRating,
    required this.barcodeValue,
    required this.catalogNumber,
    required this.country,
    required this.coverImageUrlValue,
    required this.description,
    required this.editionTitle,
    required this.format,
    required this.language,
    required this.maxPlayers,
    required this.minAge,
    required this.minPlayers,
    required this.playingTimeMinutes,
    required this.publisher,
    required this.releaseDateValue,
    required this.releaseStatus,
  });

  @override
  final String id;
  final String workId;
  final String titleValue;
  final String? ageRating;
  final String? audienceRating;
  final String? barcodeValue;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrlValue;
  final String? description;
  final String? editionTitle;
  final String? format;
  final String? language;
  final int? maxPlayers;
  final int? minAge;
  final int? minPlayers;
  final int? playingTimeMinutes;
  final String? publisher;
  final DateTime? releaseDateValue;
  final String? releaseStatus;
  @override
  String get title => editionTitle ?? titleValue;
  @override
  String? get kind => CollectarrItemKind.boardgame.apiValue;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => barcodeValue;

  factory BoardGameEditionDto.fromJson(Map<String, dynamic> json) {
    return BoardGameEditionDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      workId: _stringValue(json['work_id']),
      titleValue: _stringValue(json['title'], fallback: 'Edition'),
      ageRating: _nullableString(json['age_rating']),
      audienceRating: _nullableString(json['audience_rating']),
      barcodeValue: _nullableString(json['barcode']),
      catalogNumber: _nullableString(json['catalog_number']),
      country: _nullableString(json['country']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      description: _nullableString(json['description']),
      editionTitle: _nullableString(json['edition_title']),
      format: _nullableString(json['format']),
      language: _nullableString(json['language']),
      maxPlayers: _nullableInt(json['max_players']),
      minAge: _nullableInt(json['min_age']),
      minPlayers: _nullableInt(json['min_players']),
      playingTimeMinutes: _nullableInt(json['playing_time_minutes']),
      publisher: _nullableString(json['publisher']),
      releaseDateValue: _nullableDate(json['release_date']),
      releaseStatus: _nullableString(json['release_status']),
    );
  }
}

class MusicReleaseDto extends TypedMetadataResponse {
  const MusicReleaseDto._(
    super.raw, {
    required this.id,
    required this.titleValue,
    required this.contributions,
    required this.identifiers,
    required this.media,
    required this.countryCode,
    required this.extras,
    required this.publisher,
    required this.recordingDate,
    required this.releaseDateValue,
    required this.releaseStatus,
    required this.releaseType,
    required this.sortTitle,
    required this.studio,
    required this.subtitle,
    required this.trackCount,
    required this.kind,
    required this.barcodeValue,
    required this.coverImageUrlValue,
    required this.language,
  });

  @override
  final String id;
  final String titleValue;
  final List<dynamic> contributions;
  final List<dynamic> identifiers;
  final List<MusicMediaDto> media;
  final String? countryCode;
  final String? extras;
  final String? publisher;
  final DateTime? recordingDate;
  final DateTime? releaseDateValue;
  final String? releaseStatus;
  final String? releaseType;
  final String? sortTitle;
  final String? studio;
  final String? subtitle;
  final int? trackCount;
  @override
  final String? kind;
  final String? barcodeValue;
  final String? coverImageUrlValue;
  final String? language;
  @override
  String get title => titleValue;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => barcodeValue;

  factory MusicReleaseDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      titleValue: _stringValue(json['title'], fallback: 'Untitled item'),
      contributions: _dynamicList(json['contributions']),
      identifiers: _dynamicList(json['identifiers']),
      media: _musicMediaList(json['media']),
      countryCode: _nullableString(json['country_code']),
      extras: _nullableString(json['extras']),
      publisher: _nullableString(json['publisher']),
      recordingDate: _nullableDate(json['recording_date']),
      releaseDateValue: _nullableDate(json['release_date']),
      releaseStatus: _nullableString(json['release_status']),
      releaseType: _nullableString(json['release_type']),
      sortTitle: _nullableString(json['sort_title']),
      studio: _nullableString(json['studio']),
      subtitle: _nullableString(json['subtitle']),
      trackCount: _nullableInt(json['track_count']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.music.apiValue,
      barcodeValue: _nullableString(json['barcode']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      language: _nullableString(json['language']),
    );
  }
}

class MusicMediaDto extends TypedMetadataResponse {
  const MusicMediaDto._(
    super.raw, {
    required this.id,
    required this.releaseId,
    required this.mediaNumber,
    required this.mediaCondition,
    required this.mediaType,
    required this.packaging,
    required this.rpm,
    required this.soundType,
    required this.spars,
    required this.titleValue,
    required this.trackCount,
    required this.tracks,
    required this.vinylColor,
    required this.vinylWeight,
  });

  @override
  final String id;
  final String releaseId;
  final int mediaNumber;
  final String? mediaCondition;
  final String? mediaType;
  final String? packaging;
  final int? rpm;
  final String? soundType;
  final String? spars;
  final String? titleValue;
  final int? trackCount;
  final List<MusicTrackDto> tracks;
  final String? vinylColor;
  final String? vinylWeight;
  @override
  String get title => titleValue ?? 'Media';
  @override
  String? get kind => CollectarrItemKind.music.apiValue;
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory MusicMediaDto.fromJson(Map<String, dynamic> json) {
    return MusicMediaDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      releaseId: _stringValue(json['release_id']),
      mediaNumber: _nullableInt(json['media_number']) ?? 0,
      mediaCondition: _nullableString(json['media_condition']),
      mediaType: _nullableString(json['media_type']),
      packaging: _nullableString(json['packaging']),
      rpm: _nullableInt(json['rpm']),
      soundType: _nullableString(json['sound_type']),
      spars: _nullableString(json['spars']),
      titleValue: _nullableString(json['title']),
      trackCount: _nullableInt(json['track_count']),
      tracks: _musicTrackList(json['tracks']),
      vinylColor: _nullableString(json['vinyl_color']),
      vinylWeight: _nullableString(json['vinyl_weight']),
    );
  }

}

class MusicTrackDto extends TypedMetadataResponse {
  const MusicTrackDto._(
    super.raw, {
    required this.id,
    required this.mediaId,
    required this.position,
    required this.titleValue,
    required this.composition,
    required this.durationMs,
    required this.instrument,
  });

  @override
  final String id;
  final String mediaId;
  final String position;
  final String titleValue;
  final String? composition;
  final int? durationMs;
  final String? instrument;
  @override
  String get title => titleValue;
  @override
  String? get kind => CollectarrItemKind.music.apiValue;
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory MusicTrackDto.fromJson(Map<String, dynamic> json) {
    return MusicTrackDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      mediaId: _stringValue(json['media_id']),
      position: _stringValue(json['position']),
      titleValue: _stringValue(json['title'], fallback: 'Track'),
      composition: _nullableString(json['composition']),
      durationMs: _nullableInt(json['duration_ms']),
      instrument: _nullableString(json['instrument']),
    );
  }
}

List<MusicMediaDto> _musicMediaList(dynamic value) {
  if (value is! List) {
    return const <MusicMediaDto>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) MusicMediaDto.fromJson(entry),
  ];
}

List<MusicTrackDto> _musicTrackList(dynamic value) {
  if (value is! List) {
    return const <MusicTrackDto>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) MusicTrackDto.fromJson(entry),
  ];
}

List<BookEditionDto> _bookEditionList(dynamic value) {
  if (value is! List) {
    return const <BookEditionDto>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) BookEditionDto.fromJson(entry),
  ];
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}

class ComicWorkDto extends TypedMetadataResponse {
  const ComicWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.contributors,
    required this.description,
    required this.firstPublicationDate,
    required this.originalLanguage,
    required this.sortTitle,
    required this.subtitle,
    required this.issues,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> contributors;
  final String? description;
  final DateTime? firstPublicationDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? subtitle;
  final List<dynamic> issues;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => firstPublicationDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory ComicWorkDto.fromJson(Map<String, dynamic> json) {
    return ComicWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      contributors: _dynamicList(json['contributors']),
      description: _nullableString(json['description']),
      firstPublicationDate: _nullableDate(json['first_publication_date']),
      originalLanguage: _nullableString(json['original_language']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      issues: _dynamicList(json['issues']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.comic.apiValue,
    );
  }
}

class MangaWorkDto extends TypedMetadataResponse {
  const MangaWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.chapters,
    required this.characterAppearances,
    required this.contributions,
    required this.description,
    required this.firstPublicationDate,
    required this.identifiers,
    required this.originalLanguage,
    required this.originalPublicationDate,
    required this.series,
    required this.sortTitle,
    required this.status,
    required this.subtitle,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> chapters;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final String? description;
  final DateTime? firstPublicationDate;
  final List<dynamic> identifiers;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final List<dynamic> series;
  final String? sortTitle;
  final String? status;
  final String? subtitle;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => firstPublicationDate ?? originalPublicationDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory MangaWorkDto.fromJson(Map<String, dynamic> json) {
    return MangaWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      chapters: _dynamicList(json['chapters']),
      characterAppearances: _dynamicList(json['character_appearances']),
      contributions: _dynamicList(json['contributions']),
      description: _nullableString(json['description']),
      firstPublicationDate: _nullableDate(json['first_publication_date']),
      identifiers: _dynamicList(json['identifiers']),
      originalLanguage: _nullableString(json['original_language']),
      originalPublicationDate: _nullableDate(
        json['original_publication_date'],
      ),
      series: _dynamicList(json['series']),
      sortTitle: _nullableString(json['sort_title']),
      status: _nullableString(json['status']),
      subtitle: _nullableString(json['subtitle']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.manga.apiValue,
    );
  }
}

class AnimeSeriesDto extends TypedMetadataResponse {
  const AnimeSeriesDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.characterAppearances,
    required this.contributions,
    required this.description,
    required this.endDate,
    required this.episodeCount,
    required this.episodes,
    required this.identifiers,
    required this.originalAirDate,
    required this.originalLanguage,
    required this.sortTitle,
    required this.status,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final String? description;
  final DateTime? endDate;
  final int? episodeCount;
  final List<dynamic> episodes;
  final List<dynamic> identifiers;
  final DateTime? originalAirDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? status;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => originalAirDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory AnimeSeriesDto.fromJson(Map<String, dynamic> json) {
    return AnimeSeriesDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      characterAppearances: _dynamicList(json['character_appearances']),
      contributions: _dynamicList(json['contributions']),
      description: _nullableString(json['description']),
      endDate: _nullableDate(json['end_date']),
      episodeCount: _nullableInt(json['episode_count']),
      episodes: _dynamicList(json['episodes']),
      identifiers: _dynamicList(json['identifiers']),
      originalAirDate: _nullableDate(json['original_air_date']),
      originalLanguage: _nullableString(json['original_language']),
      sortTitle: _nullableString(json['sort_title']),
      status: _nullableString(json['status']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.anime.apiValue,
    );
  }
}

class MovieWorkDto extends TypedMetadataResponse {
  const MovieWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.ageRating,
    required this.audienceRating,
    required this.characterAppearances,
    required this.contributions,
    required this.description,
    required this.externalLinks,
    required this.identifiers,
    required this.originalLanguage,
    required this.releaseDateValue,
    required this.releases,
    required this.runtimeMinutes,
    required this.sortTitle,
    required this.subtitle,
    required this.trailerUrls,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final String? ageRating;
  final String? audienceRating;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final String? description;
  final List<dynamic> externalLinks;
  final List<dynamic> identifiers;
  final String? originalLanguage;
  final DateTime? releaseDateValue;
  final List<dynamic> releases;
  final int? runtimeMinutes;
  final String? sortTitle;
  final String? subtitle;
  final List<dynamic> trailerUrls;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory MovieWorkDto.fromJson(Map<String, dynamic> json) {
    return MovieWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      ageRating: _nullableString(json['age_rating']),
      audienceRating: _nullableString(json['audience_rating']),
      characterAppearances: _dynamicList(json['character_appearances']),
      contributions: _dynamicList(json['contributions']),
      description: _nullableString(json['description']),
      externalLinks: _dynamicList(json['external_links']),
      identifiers: _dynamicList(json['identifiers']),
      originalLanguage: _nullableString(json['original_language']),
      releaseDateValue: _nullableDate(json['release_date']),
      releases: _dynamicList(json['releases']),
      runtimeMinutes: _nullableInt(json['runtime_minutes']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      trailerUrls: _dynamicList(json['trailer_urls']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.movie.apiValue,
    );
  }
}

class TvSeriesDto extends TypedMetadataResponse {
  const TvSeriesDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.characterAppearances,
    required this.contributions,
    required this.description,
    required this.endDate,
    required this.episodeCount,
    required this.identifiers,
    required this.media,
    required this.network,
    required this.originalAirDate,
    required this.originalLanguage,
    required this.seasonCount,
    required this.seasons,
    required this.sortTitle,
    required this.status,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final String? description;
  final DateTime? endDate;
  final int? episodeCount;
  final List<dynamic> identifiers;
  final List<dynamic> media;
  final String? network;
  final DateTime? originalAirDate;
  final String? originalLanguage;
  final int? seasonCount;
  final List<dynamic> seasons;
  final String? sortTitle;
  final String? status;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => originalAirDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory TvSeriesDto.fromJson(Map<String, dynamic> json) {
    return TvSeriesDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      characterAppearances: _dynamicList(json['character_appearances']),
      contributions: _dynamicList(json['contributions']),
      description: _nullableString(json['description']),
      endDate: _nullableDate(json['end_date']),
      episodeCount: _nullableInt(json['episode_count']),
      identifiers: _dynamicList(json['identifiers']),
      media: _dynamicList(json['media']),
      network: _nullableString(json['network']),
      originalAirDate: _nullableDate(json['original_air_date']),
      originalLanguage: _nullableString(json['original_language']),
      seasonCount: _nullableInt(json['season_count']),
      seasons: _dynamicList(json['seasons']),
      sortTitle: _nullableString(json['sort_title']),
      status: _nullableString(json['status']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.tv.apiValue,
    );
  }
}
