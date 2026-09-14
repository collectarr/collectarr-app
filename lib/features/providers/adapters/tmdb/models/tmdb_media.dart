import 'package:flutter/foundation.dart';

@immutable
class TmdbGenre {
  const TmdbGenre({this.id, this.name});

  final int? id;
  final String? name;

  factory TmdbGenre.fromJson(Map<String, dynamic> json) {
    return TmdbGenre(
      id: _int(json['id']),
      name: _text(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

@immutable
class TmdbProductionCompany {
  const TmdbProductionCompany({this.id, this.name});

  final int? id;
  final String? name;

  factory TmdbProductionCompany.fromJson(Map<String, dynamic> json) {
    return TmdbProductionCompany(
      id: _int(json['id']),
      name: _text(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

@immutable
class TmdbPerson {
  const TmdbPerson({this.id, this.name, this.job, this.character});

  final int? id;
  final String? name;
  final String? job;
  final String? character;

  factory TmdbPerson.fromJson(Map<String, dynamic> json) {
    return TmdbPerson(
      id: _int(json['id']),
      name: _text(json['name']),
      job: _text(json['job']),
      character: _text(json['character']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (job != null) 'job': job,
        if (character != null) 'character': character,
      };
}

@immutable
class TmdbCredits {
  const TmdbCredits({this.crew = const [], this.cast = const []});

  final List<TmdbPerson> crew;
  final List<TmdbPerson> cast;

  factory TmdbCredits.fromJson(Map<String, dynamic> json) {
    return TmdbCredits(
      crew: _people(json['crew']),
      cast: _people(json['cast']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (crew.isNotEmpty)
          'crew': crew.map((person) => person.toJson()).toList(),
        if (cast.isNotEmpty)
          'cast': cast.map((person) => person.toJson()).toList(),
      };
}

@immutable
class TmdbExternalIds {
  const TmdbExternalIds({this.imdbId});

  final String? imdbId;

  factory TmdbExternalIds.fromJson(Map<String, dynamic> json) {
    return TmdbExternalIds(imdbId: _text(json['imdb_id']));
  }

  Map<String, dynamic> toJson() => {
        if (imdbId != null) 'imdb_id': imdbId,
      };
}

abstract interface class TmdbMedia {
  int? get id;
  String? get title;
  String? get name;
  String? get originalTitle;
  String? get originalLanguage;
  String? get overview;
  num? get voteAverage;
  String? get posterPath;
  String? get releaseDate;
  String? get firstAirDate;
  List<TmdbGenre> get genres;
  List<TmdbProductionCompany> get productionCompanies;
  TmdbCredits? get credits;
  TmdbExternalIds? get externalIds;
}

@immutable
class TmdbMovie implements TmdbMedia {
  const TmdbMovie({
    this.id,
    this.title,
    this.name,
    this.originalTitle,
    this.originalLanguage,
    this.overview,
    this.voteAverage,
    this.posterPath,
    this.releaseDate,
    this.firstAirDate,
    this.runtime,
    this.genres = const [],
    this.productionCompanies = const [],
    this.credits,
    this.externalIds,
  });

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? name;
  @override
  final String? originalTitle;
  @override
  final String? originalLanguage;
  @override
  final String? overview;
  @override
  final num? voteAverage;
  @override
  final String? posterPath;
  @override
  final String? releaseDate;
  @override
  final String? firstAirDate;
  final int? runtime;
  @override
  final List<TmdbGenre> genres;
  @override
  final List<TmdbProductionCompany> productionCompanies;
  @override
  final TmdbCredits? credits;
  @override
  final TmdbExternalIds? externalIds;

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: _int(json['id']),
      title: _text(json['title']),
      name: _text(json['name']),
      originalTitle: _text(json['original_title']),
      originalLanguage: _text(json['original_language']),
      overview: _text(json['overview']),
      voteAverage: _number(json['vote_average']),
      posterPath: _text(json['poster_path']),
      releaseDate: _text(json['release_date']),
      firstAirDate: _text(json['first_air_date']),
      runtime: _int(json['runtime']),
      genres: _genres(json['genres']),
      productionCompanies: _companies(json['production_companies']),
      credits: _credits(json['credits']),
      externalIds: _externalIds(json['external_ids']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (name != null) 'name': name,
        if (originalTitle != null) 'original_title': originalTitle,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (overview != null) 'overview': overview,
        if (voteAverage != null) 'vote_average': voteAverage,
        if (posterPath != null) 'poster_path': posterPath,
        if (releaseDate != null) 'release_date': releaseDate,
        if (firstAirDate != null) 'first_air_date': firstAirDate,
        if (runtime != null) 'runtime': runtime,
        if (genres.isNotEmpty)
          'genres': genres.map((genre) => genre.toJson()).toList(),
        if (productionCompanies.isNotEmpty)
          'production_companies':
              productionCompanies.map((company) => company.toJson()).toList(),
        if (credits != null) 'credits': credits!.toJson(),
        if (externalIds != null) 'external_ids': externalIds!.toJson(),
      };
}

@immutable
class TmdbTvSeries implements TmdbMedia {
  const TmdbTvSeries({
    this.id,
    this.title,
    this.name,
    this.originalTitle,
    this.originalLanguage,
    this.overview,
    this.voteAverage,
    this.posterPath,
    this.releaseDate,
    this.firstAirDate,
    this.episodeRunTime = const [],
    this.numberOfSeasons,
    this.genres = const [],
    this.productionCompanies = const [],
    this.credits,
    this.externalIds,
  });

  @override
  final int? id;
  @override
  final String? title;
  @override
  final String? name;
  @override
  final String? originalTitle;
  @override
  final String? originalLanguage;
  @override
  final String? overview;
  @override
  final num? voteAverage;
  @override
  final String? posterPath;
  @override
  final String? releaseDate;
  @override
  final String? firstAirDate;
  final List<int> episodeRunTime;
  final int? numberOfSeasons;
  @override
  final List<TmdbGenre> genres;
  @override
  final List<TmdbProductionCompany> productionCompanies;
  @override
  final TmdbCredits? credits;
  @override
  final TmdbExternalIds? externalIds;

  factory TmdbTvSeries.fromJson(Map<String, dynamic> json) {
    return TmdbTvSeries(
      id: _int(json['id']),
      title: _text(json['title']),
      name: _text(json['name']),
      originalTitle: _text(json['original_name'] ?? json['original_title']),
      originalLanguage: _text(json['original_language']),
      overview: _text(json['overview']),
      voteAverage: _number(json['vote_average']),
      posterPath: _text(json['poster_path']),
      releaseDate: _text(json['release_date']),
      firstAirDate: _text(json['first_air_date']),
      episodeRunTime: _intList(json['episode_run_time']),
      numberOfSeasons: _int(json['number_of_seasons']),
      genres: _genres(json['genres']),
      productionCompanies: _companies(json['production_companies']),
      credits: _credits(json['credits']),
      externalIds: _externalIds(json['external_ids']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (name != null) 'name': name,
        if (originalTitle != null) 'original_name': originalTitle,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (overview != null) 'overview': overview,
        if (voteAverage != null) 'vote_average': voteAverage,
        if (posterPath != null) 'poster_path': posterPath,
        if (releaseDate != null) 'release_date': releaseDate,
        if (firstAirDate != null) 'first_air_date': firstAirDate,
        if (episodeRunTime.isNotEmpty) 'episode_run_time': episodeRunTime,
        if (numberOfSeasons != null) 'number_of_seasons': numberOfSeasons,
        if (genres.isNotEmpty)
          'genres': genres.map((genre) => genre.toJson()).toList(),
        if (productionCompanies.isNotEmpty)
          'production_companies':
              productionCompanies.map((company) => company.toJson()).toList(),
        if (credits != null) 'credits': credits!.toJson(),
        if (externalIds != null) 'external_ids': externalIds!.toJson(),
      };
}

List<TmdbGenre> _genres(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) TmdbGenre.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<TmdbProductionCompany> _companies(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        TmdbProductionCompany.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

TmdbCredits? _credits(Object? value) {
  if (value is! Map) return null;
  return TmdbCredits.fromJson(Map<String, dynamic>.from(value));
}

TmdbExternalIds? _externalIds(Object? value) {
  if (value is! Map) return null;
  return TmdbExternalIds.fromJson(Map<String, dynamic>.from(value));
}

List<TmdbPerson> _people(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) TmdbPerson.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<int> _intList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (_int(item) case final parsed?) parsed,
  ]);
}

int? _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

num? _number(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString().trim() ?? '');
}

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
