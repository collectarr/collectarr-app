import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

import 'boardgame_edition.dart';
import 'boardgame_ids.dart';

@immutable
final class BoardGameMedia {
  const BoardGameMedia({
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
    this.contributors = const [],
    this.mechanics = const [],
    this.categories = const [],
    this.families = const [],
    this.expansions = const [],
    this.rankings = const [],
    this.searchAliases = const [],
    this.editions = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final BoardGameMediaId id;
  final String title;
  final String? sortTitle;
  final String? description;
  final DateTime? releaseDate;
  final String? originalLanguage;
  final String? publisher;
  final String? subtitle;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> expansions;
  final List<String> rankings;
  final List<String> searchAliases;
  final List<BoardGameEdition> editions;
  final Map<String, dynamic> rawPayload;

  CatalogMediaKind get mediaKind => CatalogMediaKind.boardgame;

  String? get synopsis => description;
  List<BoardGameEdition> get releases => editions;
  String? get coverImageUrl => _textValue(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _textValue(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
  String? get barcode => _textValue(rawPayload['barcode']);

  Map<String, dynamic> toSyncPayload() => toJson();

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': CatalogMediaKind.boardgame.apiValue,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (publisher != null) 'publisher': publisher,
        if (subtitle != null) 'subtitle': subtitle,
        'platforms': platforms,
        'identifiers': identifiers,
        'contributors': contributors,
        'mechanics': mechanics,
        'categories': categories,
        'families': families,
        'expansions': expansions,
        'rankings': rankings,
        'search_aliases': searchAliases,
        'editions': editions.map((edition) => edition.toJson()).toList(),
      };

  factory BoardGameMedia.fromJson(Map<String, dynamic> json) {
    final editionRows = json['editions'];
    return BoardGameMedia(
      id: BoardGameMediaId((json['id'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      sortTitle: _textValue(json['sort_title']),
      description: _textValue(json['description'] ?? json['synopsis']),
      releaseDate: _dateValue(json['release_date']),
      originalLanguage: _textValue(json['original_language']),
      publisher: _textValue(json['publisher']),
      subtitle: _textValue(json['subtitle']),
      platforms: _strings(json['platforms']),
      identifiers: _strings(json['identifiers']),
      contributors: _strings(json['contributors']),
      mechanics: _strings(json['mechanics']),
      categories: _strings(json['categories']),
      families: _strings(json['families']),
      expansions: _strings(json['expansions']),
      rankings: _strings(json['rankings']),
      searchAliases: _strings(json['search_aliases']),
      editions: editionRows is List
          ? [
              for (final entry in editionRows)
                if (entry is Map<Object?, Object?>)
                  BoardGameEdition.fromJson(
                    Map<String, dynamic>.from(entry),
                  ),
            ]
          : const <BoardGameEdition>[],
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
