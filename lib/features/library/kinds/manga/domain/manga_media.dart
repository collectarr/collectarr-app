import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MangaMedia implements LibraryKindMetadataRuntime {
  const MangaMedia({
    required this.id,
    required this.title,
    this.sortTitle,
    this.description,
    this.firstPublicationDate,
    this.originalLanguage,
    this.originalPublicationDate,
    this.status,
    this.subtitle,
    this.chapters = const [],
    this.characterAppearances = const [],
    this.contributions = const [],
    this.identifiers = const [],
    this.series = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? sortTitle;
  final String? description;
  final DateTime? firstPublicationDate;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? status;
  final String? subtitle;
  final List<dynamic> chapters;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final List<dynamic> identifiers;
  final List<dynamic> series;
  final Map<String, dynamic> rawPayload;

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.manga;

  String? get synopsis => description;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (firstPublicationDate != null)
          'first_publication_date': firstPublicationDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (status != null) 'status': status,
        if (subtitle != null) 'subtitle': subtitle,
        'chapters': chapters,
        'character_appearances': characterAppearances,
        'contributions': contributions,
        'identifiers': identifiers,
        'series': series,
        'kind': CatalogMediaKind.manga.apiValue,
      };

  factory MangaMedia.fromJson(Map<String, dynamic> json) {
    return MangaMedia(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sortTitle: json['sort_title'] as String?,
      description: json['description'] as String?,
      firstPublicationDate: _parseDate(json['first_publication_date']),
      originalLanguage: json['original_language'] as String?,
      originalPublicationDate: _parseDate(json['original_publication_date']),
      status: json['status'] as String?,
      subtitle: json['subtitle'] as String?,
      chapters: _list(json['chapters']),
      characterAppearances: _list(json['character_appearances']),
      contributions: _list(json['contributions']),
      identifiers: _list(json['identifiers']),
      series: _list(json['series']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static List<dynamic> _list(Object? value) {
    return value is List ? List<dynamic>.from(value) : const <dynamic>[];
  }
}
