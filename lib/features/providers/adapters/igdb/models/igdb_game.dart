import 'package:flutter/foundation.dart';

@immutable
class IgdbNamedReference {
  const IgdbNamedReference({this.id, this.name});

  final int? id;
  final String? name;

  factory IgdbNamedReference.fromJson(Map<String, dynamic> json) {
    return IgdbNamedReference(
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
class IgdbCover {
  const IgdbCover({this.id, this.url});

  final int? id;
  final String? url;

  factory IgdbCover.fromJson(Map<String, dynamic> json) {
    return IgdbCover(
      id: _int(json['id']),
      url: _text(json['url']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (url != null) 'url': url,
      };
}

@immutable
class IgdbCompanyCredit {
  const IgdbCompanyCredit(
      {this.company, this.developer = false, this.publisher = false});

  final IgdbNamedReference? company;
  final bool developer;
  final bool publisher;

  factory IgdbCompanyCredit.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    return IgdbCompanyCredit(
      company: company is Map
          ? IgdbNamedReference.fromJson(Map<String, dynamic>.from(company))
          : null,
      developer: json['developer'] == true,
      publisher: json['publisher'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (company != null) 'company': company!.toJson(),
        if (developer) 'developer': true,
        if (publisher) 'publisher': true,
      };
}

@immutable
class IgdbAgeRating {
  const IgdbAgeRating({this.rating, this.category});

  final int? rating;
  final int? category;

  factory IgdbAgeRating.fromJson(Map<String, dynamic> json) {
    return IgdbAgeRating(
      rating: _int(json['rating']),
      category: _int(json['category']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (rating != null) 'rating': rating,
        if (category != null) 'category': category,
      };
}

@immutable
class IgdbGame {
  const IgdbGame({
    this.id,
    this.name,
    this.summary,
    this.storyline,
    this.firstReleaseDate,
    this.cover,
    this.genres = const [],
    this.involvedCompanies = const [],
    this.platforms = const [],
    this.gameModes = const [],
    this.ageRatings = const [],
    this.totalRating,
    this.slug,
  });

  final int? id;
  final String? name;
  final String? summary;
  final String? storyline;
  final int? firstReleaseDate;
  final IgdbCover? cover;
  final List<IgdbNamedReference> genres;
  final List<IgdbCompanyCredit> involvedCompanies;
  final List<IgdbNamedReference> platforms;
  final List<IgdbNamedReference> gameModes;
  final List<IgdbAgeRating> ageRatings;
  final num? totalRating;
  final String? slug;

  factory IgdbGame.fromJson(Map<String, dynamic> json) {
    final cover = json['cover'];
    return IgdbGame(
      id: _int(json['id']),
      name: _text(json['name']),
      summary: _text(json['summary']),
      storyline: _text(json['storyline']),
      firstReleaseDate: _int(json['first_release_date']),
      cover: cover is Map
          ? IgdbCover.fromJson(Map<String, dynamic>.from(cover))
          : null,
      genres: _references(json['genres']),
      involvedCompanies: _companyCredits(json['involved_companies']),
      platforms: _references(json['platforms']),
      gameModes: _references(json['game_modes']),
      ageRatings: _ageRatings(json['age_ratings']),
      totalRating: _number(json['total_rating']),
      slug: _text(json['slug']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (summary != null) 'summary': summary,
        if (storyline != null) 'storyline': storyline,
        if (firstReleaseDate != null) 'first_release_date': firstReleaseDate,
        if (cover != null) 'cover': cover!.toJson(),
        if (genres.isNotEmpty)
          'genres': genres.map((genre) => genre.toJson()).toList(),
        if (involvedCompanies.isNotEmpty)
          'involved_companies':
              involvedCompanies.map((company) => company.toJson()).toList(),
        if (platforms.isNotEmpty)
          'platforms': platforms.map((platform) => platform.toJson()).toList(),
        if (gameModes.isNotEmpty)
          'game_modes': gameModes.map((mode) => mode.toJson()).toList(),
        if (ageRatings.isNotEmpty)
          'age_ratings': ageRatings.map((rating) => rating.toJson()).toList(),
        if (totalRating != null) 'total_rating': totalRating,
        if (slug != null) 'slug': slug,
      };
}

List<IgdbNamedReference> _references(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        IgdbNamedReference.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<IgdbCompanyCredit> _companyCredits(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        IgdbCompanyCredit.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<IgdbAgeRating> _ageRatings(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) IgdbAgeRating.fromJson(Map<String, dynamic>.from(item)),
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
