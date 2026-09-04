import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GameMedia implements LibraryKindMetadataRuntime {
  const GameMedia({
    required this.id,
    required this.title,
    this.sortTitle,
    this.description,
    this.releaseDate,
    this.originalLanguage,
    this.publisher,
    this.subtitle,
    this.platforms = const [],
    this.identifiers = const [],
    this.companyRoles = const [],
    this.ageRatings = const [],
    this.genres = const [],
    this.searchAliases = const [],
    this.releases = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final GameMediaId id;
  final String title;
  final String? sortTitle;
  final String? description;
  final DateTime? releaseDate;
  final String? originalLanguage;
  final String? publisher;
  final String? subtitle;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> companyRoles;
  final List<String> ageRatings;
  final List<String> genres;
  final List<String> searchAliases;
  final List<GameRelease> releases;
  final Map<String, dynamic> rawPayload;

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.game;

  String? get synopsis => description;
  GameRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String? get coverImageUrl => _textValue(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _textValue(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
  String? get barcode => _textValue(rawPayload['barcode']);

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': CatalogMediaKind.game.apiValue,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (publisher != null) 'publisher': publisher,
        if (subtitle != null) 'subtitle': subtitle,
        'platforms': platforms,
        'identifiers': identifiers,
        'company_roles': companyRoles,
        'age_ratings': ageRatings,
        'genres': genres,
        'search_aliases': searchAliases,
        'releases': releases.map((release) => release.toJson()).toList(),
      };

  factory GameMedia.fromJson(Map<String, dynamic> json) {
    final releaseRows = json['releases'];
    return GameMedia(
      id: GameMediaId((json['id'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      sortTitle: _textValue(json['sort_title']),
      description: _textValue(json['description']),
      releaseDate: _dateValue(json['release_date']),
      originalLanguage: _textValue(json['original_language']),
      publisher: _textValue(json['publisher']),
      subtitle: _textValue(json['subtitle']),
      platforms: _strings(json['platforms']),
      identifiers: _strings(json['identifiers']),
      companyRoles: _strings(json['company_roles']),
      ageRatings: _strings(json['age_ratings']),
      genres: _strings(json['genres']),
      searchAliases: _strings(json['search_aliases']),
      releases: releaseRows is List
          ? [
              for (final entry in releaseRows)
                if (entry is Map<Object?, Object?>)
                  GameRelease.fromJson(Map<String, dynamic>.from(entry)),
            ]
          : const <GameRelease>[],
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static List<String> _strings(Object? value) {
    if (value is! List) return const <String>[];
    return [
      for (final entry in value)
        if (_textValue(entry) case final text?) text,
    ];
  }
}
