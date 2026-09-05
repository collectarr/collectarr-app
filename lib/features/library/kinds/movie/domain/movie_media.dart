import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

import 'movie_ids.dart';
import 'movie_release.dart';

@immutable
final class MovieContributor {
  const MovieContributor({
    required this.name,
    required this.role,
    this.id,
    this.personId,
    this.characterName,
    this.imageUrl,
    this.sequence,
  });

  final String name;
  final String role;
  final String? id;
  final String? personId;
  final String? characterName;
  final String? imageUrl;
  final int? sequence;

  factory MovieContributor.fromJson(Map<String, dynamic> json) {
    return MovieContributor(
      name: _textValue(json['name']) ?? '',
      role: _textValue(json['role']) ?? '',
      id: _textValue(json['id']),
      personId: _textValue(json['person_id']),
      characterName: _textValue(json['character_name']),
      imageUrl: _textValue(json['image_url']),
      sequence: _intValue(json['sequence']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personId != null) 'person_id': personId,
        'name': name,
        'role': role,
        if (characterName != null) 'character_name': characterName,
        if (imageUrl != null) 'image_url': imageUrl,
        if (sequence != null) 'sequence': sequence,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

@immutable
final class MovieCharacterAppearance {
  const MovieCharacterAppearance({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.role,
  });

  final String id;
  final String characterId;
  final String characterName;
  final String role;

  factory MovieCharacterAppearance.fromJson(Map<String, dynamic> json) {
    return MovieCharacterAppearance(
      id: _textValue(json['id']) ?? '',
      characterId: _textValue(json['character_id']) ?? '',
      characterName: _textValue(json['character_name']) ?? '',
      role: _textValue(json['role']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'character_id': characterId,
        'character_name': characterName,
        'role': role,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

@immutable
final class MovieIdentifier {
  const MovieIdentifier({
    required this.id,
    required this.identifierType,
    required this.value,
    this.isPrimary = false,
  });

  final String id;
  final String identifierType;
  final String value;
  final bool isPrimary;

  factory MovieIdentifier.fromJson(Map<String, dynamic> json) {
    return MovieIdentifier(
      id: _textValue(json['id']) ?? '',
      identifierType: _textValue(json['identifier_type']) ?? '',
      value: _textValue(json['value']) ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'identifier_type': identifierType,
        'value': value,
        'is_primary': isPrimary,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

@immutable
final class MovieMedia {
  const MovieMedia({
    required this.id,
    required this.title,
    this.ageRating,
    this.audienceRating,
    this.characterAppearances = const [],
    this.contributions = const [],
    this.description,
    this.externalLinks = const [],
    this.identifiers = const [],
    this.originalLanguage,
    this.releaseDate,
    this.releases = const [],
    this.runtimeMinutes,
    this.sortTitle,
    this.subtitle,
    this.trailerUrls = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final MovieMediaId id;
  final String title;
  final String? ageRating;
  final String? audienceRating;
  final List<MovieCharacterAppearance> characterAppearances;
  final List<MovieContributor> contributions;
  final String? description;
  final List<MovieExternalLink> externalLinks;
  final List<MovieIdentifier> identifiers;
  final String? originalLanguage;
  final DateTime? releaseDate;
  final List<MovieRelease> releases;
  final int? runtimeMinutes;
  final String? sortTitle;
  final String? subtitle;
  final List<MovieTrailerLink> trailerUrls;
  final Map<String, dynamic> rawPayload;

  CatalogMediaKind get mediaKind => CatalogMediaKind.movie;

  String? get synopsis => description;
  MovieRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String? get coverImageUrl => _textValue(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _textValue(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
  String? get barcode => _textValue(rawPayload['barcode']);
  int? get providerValueCents =>
      _intValue(rawPayload['estimated_value_cents']) ??
      _intValue(rawPayload['market_value_cents']) ??
      _intValue(rawPayload['value_cents']);

  Map<String, dynamic> toSyncPayload() => toJson();

  factory MovieMedia.fromJson(Map<String, dynamic> json) {
    final releaseRows = json['releases'];
    final characterRows = json['character_appearances'];
    final contributorRows = json['contributions'];
    final identifierRows = json['identifiers'];

    return MovieMedia(
      id: MovieMediaId(_textValue(json['id']) ?? ''),
      title: _textValue(json['title']) ?? '',
      ageRating: _textValue(json['age_rating']),
      audienceRating: _textValue(json['audience_rating']),
      characterAppearances: _mapCharacters(characterRows),
      contributions: _mapContributors(contributorRows),
      description: _textValue(json['description'] ?? json['synopsis']),
      externalLinks: _mapExternalLinks(json['external_links']),
      identifiers: _mapIdentifiers(identifierRows),
      originalLanguage: _textValue(json['original_language']),
      releaseDate: _dateValue(json['release_date']),
      releases: releaseRows is List
          ? [
              for (final entry in releaseRows)
                if (entry is Map<Object?, Object?>)
                  MovieRelease.fromJson(Map<String, dynamic>.from(entry)),
            ]
          : const <MovieRelease>[],
      runtimeMinutes: _intValue(json['runtime_minutes']),
      sortTitle: _textValue(json['sort_title']),
      subtitle: _textValue(json['subtitle']),
      trailerUrls: _mapTrailerLinks(json['trailer_urls']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': CatalogMediaKind.movie.apiValue,
        'title': title,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        'character_appearances':
            characterAppearances.map((entry) => entry.toJson()).toList(),
        'contributions': contributions.map((entry) => entry.toJson()).toList(),
        if (description != null) 'description': description,
        'external_links': externalLinks.map((entry) => entry.toJson()).toList(),
        'identifiers': identifiers.map((entry) => entry.toJson()).toList(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        'releases': releases.map((entry) => entry.toJson()).toList(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        'trailer_urls': trailerUrls.map((entry) => entry.toJson()).toList(),
      };

  static List<MovieCharacterAppearance> _mapCharacters(Object? value) {
    if (value is! List) return const <MovieCharacterAppearance>[];
    return [
      for (final entry in value)
        if (entry is Map<Object?, Object?>)
          MovieCharacterAppearance.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieContributor> _mapContributors(Object? value) {
    if (value is! List) return const <MovieContributor>[];
    return [
      for (final entry in value)
        if (entry is Map<Object?, Object?>)
          MovieContributor.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieExternalLink> _mapExternalLinks(Object? value) {
    if (value is! List) return const <MovieExternalLink>[];
    return [for (final entry in value) MovieExternalLink.fromJson(entry)];
  }

  static List<MovieIdentifier> _mapIdentifiers(Object? value) {
    if (value is! List) return const <MovieIdentifier>[];
    return [
      for (final entry in value)
        if (entry is Map<Object?, Object?>)
          MovieIdentifier.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieTrailerLink> _mapTrailerLinks(Object? value) {
    if (value is! List) return const <MovieTrailerLink>[];
    return [for (final entry in value) MovieTrailerLink.fromJson(entry)];
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
