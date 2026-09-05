import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookMedia {
  const BookMedia({
    required this.id,
    required this.title,
    this.sortTitle,
    this.description,
    this.firstPublicationDate,
    this.originalLanguage,
    this.originalPublicationDate,
    this.subtitle,
    this.searchAliases = const [],
    this.genres = const [],
    this.contributors = const [],
    this.editions = const [],
    this.series = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final BookMediaId id;
  final String title;
  final String? sortTitle;
  final String? description;
  final DateTime? firstPublicationDate;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? subtitle;
  final List<String> searchAliases;
  final List<String> genres;
  final List<dynamic> contributors;
  final List<BookRelease> editions;
  final List<dynamic> series;
  final Map<String, dynamic> rawPayload;

  CatalogMediaKind get mediaKind => CatalogMediaKind.book;

  String? get synopsis => description;
  List<BookRelease> get releases => editions;
  String? get coverImageUrl => _textValue(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _textValue(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
  String? get barcode => _textValue(rawPayload['barcode']);

  Map<String, dynamic> toSyncPayload() => toJson();

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': CatalogMediaKind.book.apiValue,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (firstPublicationDate != null)
          'first_publication_date': firstPublicationDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (subtitle != null) 'subtitle': subtitle,
        'search_aliases': searchAliases,
        'genres': genres,
        'contributors': contributors,
        'editions': editions.map((edition) => edition.toJson()).toList(),
        'series': series,
      };

  factory BookMedia.fromJson(Map<String, dynamic> json) {
    final editionRows = json['editions'];
    return BookMedia(
      id: BookMediaId((json['id'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      sortTitle: _textValue(json['sort_title']),
      description: _textValue(json['description']),
      firstPublicationDate: _dateValue(json['first_publication_date']),
      originalLanguage: _textValue(json['original_language']),
      originalPublicationDate: _dateValue(json['original_publication_date']),
      subtitle: _textValue(json['subtitle']),
      searchAliases: _strings(json['search_aliases']),
      genres: _strings(json['genres']),
      contributors: _list(json['contributors']),
      editions: editionRows is List
          ? [
              for (final entry in editionRows)
                if (entry is Map<Object?, Object?>)
                  BookRelease.fromJson(Map<String, dynamic>.from(entry)),
            ]
          : const <BookRelease>[],
      series: _list(json['series']),
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

  static List<dynamic> _list(Object? value) {
    return value is List ? List<dynamic>.from(value) : const <dynamic>[];
  }
}
