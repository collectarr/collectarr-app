import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

import 'anime_episode.dart';
import 'anime_ids.dart';
import 'anime_release.dart';

@immutable
final class AnimeContributor {
  const AnimeContributor({
    required this.name,
    required this.role,
    this.id,
    this.personId,
    this.imageUrl,
    this.sequence,
  });

  final String name;
  final String role;
  final String? id;
  final String? personId;
  final String? imageUrl;
  final int? sequence;

  factory AnimeContributor.fromJson(Map<String, dynamic> json) {
    return AnimeContributor(
      name: _textValue(json['name']) ?? '',
      role: _textValue(json['role']) ?? '',
      id: _textValue(json['id']),
      personId: _textValue(json['person_id']),
      imageUrl: _textValue(json['image_url']),
      sequence: _intValue(json['sequence']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personId != null) 'person_id': personId,
        'name': name,
        'role': role,
        if (imageUrl != null) 'image_url': imageUrl,
        if (sequence != null) 'sequence': sequence,
      };
}

@immutable
final class AnimeCharacterAppearance {
  const AnimeCharacterAppearance({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.role,
  });

  final String id;
  final String characterId;
  final String characterName;
  final String role;

  factory AnimeCharacterAppearance.fromJson(Map<String, dynamic> json) {
    return AnimeCharacterAppearance(
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
}

@immutable
final class AnimeIdentifier {
  const AnimeIdentifier({
    required this.id,
    required this.identifierType,
    required this.value,
    this.isPrimary = false,
  });

  final String id;
  final String identifierType;
  final String value;
  final bool isPrimary;

  factory AnimeIdentifier.fromJson(Map<String, dynamic> json) {
    return AnimeIdentifier(
      id: _textValue(json['id']) ?? '',
      identifierType: _textValue(json['identifier_type'] ?? json['type']) ?? '',
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
}

@immutable
final class AnimeMedia implements LibraryKindMetadataRuntime {
  const AnimeMedia({
    required this.id,
    required this.title,
    this.animeType,
    this.characterAppearances = const [],
    this.contributions = const [],
    this.description,
    this.endDate,
    this.episodeCount,
    this.episodes = const [],
    this.identifiers = const [],
    this.originalAirDate,
    this.originalLanguage,
    this.sortTitle,
    this.status,
    this.releases = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final AnimeMediaId id;
  final String title;
  final String? animeType;
  final List<AnimeCharacterAppearance> characterAppearances;
  final List<AnimeContributor> contributions;
  final String? description;
  final DateTime? endDate;
  final int? episodeCount;
  final List<AnimeEpisode> episodes;
  final List<AnimeIdentifier> identifiers;
  final DateTime? originalAirDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? status;
  final List<AnimeRelease> releases;
  final Map<String, dynamic> rawPayload;

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.anime;

  String? get synopsis => description;
  AnimeRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String? get coverImageUrl => _textValue(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _textValue(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
  String? get barcode => _textValue(rawPayload['barcode']);

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  factory AnimeMedia.fromJson(Map<String, dynamic> json) {
    return AnimeMedia(
      id: AnimeMediaId(_textValue(json['id']) ?? ''),
      title: _textValue(json['title']) ?? '',
      animeType: _textValue(json['anime_type'] ?? json['type']),
      characterAppearances: _mapCharacters(json['character_appearances']),
      contributions: _mapContributors(json['contributions']),
      description: _textValue(json['description'] ?? json['synopsis']),
      endDate: _dateValue(json['end_date']),
      episodeCount: _intValue(json['episode_count']),
      episodes: _maps(json['episodes'])
          .map(AnimeEpisode.fromJson)
          .toList(growable: false),
      identifiers: _mapIdentifiers(json['identifiers']),
      originalAirDate: _dateValue(json['original_air_date']),
      originalLanguage: _textValue(json['original_language']),
      sortTitle: _textValue(json['sort_title']),
      status: _textValue(json['status']),
      releases: _maps(json['releases'] ?? json['editions'])
          .map(AnimeRelease.fromJson)
          .toList(growable: false),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': CatalogMediaKind.anime.apiValue,
        'title': title,
        if (animeType != null) 'anime_type': animeType,
        'character_appearances':
            characterAppearances.map((entry) => entry.toJson()).toList(),
        'contributions': contributions.map((entry) => entry.toJson()).toList(),
        if (description != null) 'description': description,
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        if (episodeCount != null) 'episode_count': episodeCount,
        'episodes': episodes.map((entry) => entry.toJson()).toList(),
        'identifiers': identifiers.map((entry) => entry.toJson()).toList(),
        if (originalAirDate != null)
          'original_air_date': originalAirDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (status != null) 'status': status,
        'releases': releases.map((entry) => entry.toJson()).toList(),
      };
}

String? _textValue(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _dateValue(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}

List<AnimeContributor> _mapContributors(Object? value) => [
      for (final entry in _maps(value)) AnimeContributor.fromJson(entry),
    ];

List<AnimeCharacterAppearance> _mapCharacters(Object? value) => [
      for (final entry in _maps(value))
        AnimeCharacterAppearance.fromJson(entry),
    ];

List<AnimeIdentifier> _mapIdentifiers(Object? value) => [
      for (final entry in _maps(value)) AnimeIdentifier.fromJson(entry),
    ];
