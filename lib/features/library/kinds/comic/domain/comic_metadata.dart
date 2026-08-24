import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

enum ComicKeyEventType {
  firstAppearance,
  cameoAppearance,
  death,
  origin,
  firstIssue,
  iconicCover,
  other,
}

@immutable
class ComicKeyEvent {
  const ComicKeyEvent({
    required this.type,
    required this.characterOrSubject,
    this.description,
  });

  final ComicKeyEventType type;
  final String characterOrSubject;
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'character_or_subject': characterOrSubject,
        if (description != null) 'description': description,
      };

  factory ComicKeyEvent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type = ComicKeyEventType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ComicKeyEventType.other,
    );
    return ComicKeyEvent(
      type: type,
      characterOrSubject: (json['character_or_subject'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }
}

@immutable
class ComicCreatorCredit {
  const ComicCreatorCredit({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
      };

  factory ComicCreatorCredit.fromJson(Map<String, dynamic> json) {
    return ComicCreatorCredit(
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
    );
  }
}

typedef ComicMetadata = ComicCatalogMetadata;

@immutable
class ComicCatalogMetadata implements LibraryKindMetadataRuntime {
  const ComicCatalogMetadata({
    required this.title,
    this.seriesTitle,
    this.issueNumber,
    this.publisher,
    this.imprint,
    this.releaseDate,
    this.coverDate,
    this.pageCount,
    this.country = 'US',
    this.language = 'en',
    this.genres = const [],
    this.synopsis,
    this.writers = const [],
    this.artists = const [],
    this.inkers = const [],
    this.colorists = const [],
    this.letterers = const [],
    this.editors = const [],
    this.coverArtists = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.keyEvents = const [],
    this.isKeyComic = false,
    this.keyReason,
    this.variant,
    this.variantDescription,
    this.barcode,
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.comic;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? seriesTitle;
  final String? issueNumber;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final int? pageCount;
  final String country;
  final String language;
  final List<String> genres;
  final String? synopsis;
  final List<String> writers;
  final List<String> artists;
  final List<String> inkers;
  final List<String> colorists;
  final List<String> letterers;
  final List<String> editors;
  final List<String> coverArtists;
  final List<String> characters;
  final List<String> storyArcs;
  final List<ComicKeyEvent> keyEvents;
  final bool isKeyComic;
  final String? keyReason;
  final String? variant;
  final String? variantDescription;
  final String? barcode;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (issueNumber != null) 'issue_number': issueNumber,
        if (publisher != null) 'publisher': publisher,
        if (imprint != null) 'imprint': imprint,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (coverDate != null) 'cover_date': coverDate!.toIso8601String(),
        if (pageCount != null) 'page_count': pageCount,
        'country': country,
        'language': language,
        if (genres.isNotEmpty) 'genres': genres,
        if (synopsis != null) 'synopsis': synopsis,
        if (writers.isNotEmpty) 'writers': writers,
        if (artists.isNotEmpty) 'artists': artists,
        if (inkers.isNotEmpty) 'inkers': inkers,
        if (colorists.isNotEmpty) 'colorists': colorists,
        if (letterers.isNotEmpty) 'letterers': letterers,
        if (editors.isNotEmpty) 'editors': editors,
        if (coverArtists.isNotEmpty) 'cover_artists': coverArtists,
        if (characters.isNotEmpty) 'characters': characters,
        if (storyArcs.isNotEmpty) 'story_arcs': storyArcs,
        if (keyEvents.isNotEmpty)
          'key_events': keyEvents.map((e) => e.toJson()).toList(),
        if (isKeyComic) 'is_key_comic': true,
        if (keyReason != null) 'key_reason': keyReason,
        if (variant != null) 'variant': variant,
        if (variantDescription != null)
          'variant_description': variantDescription,
        if (barcode != null) 'barcode': barcode,
      };

  factory ComicCatalogMetadata.fromJson(Map<String, dynamic> json) {
    return ComicCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      seriesTitle: json['series_title'] as String?,
      issueNumber: json['issue_number'] as String?,
      publisher: json['publisher'] as String?,
      imprint: json['imprint'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      coverDate: json['cover_date'] != null
          ? DateTime.tryParse(json['cover_date'] as String)
          : null,
      pageCount: json['page_count'] as int?,
      country: (json['country'] as String?) ?? 'US',
      language: (json['language'] as String?) ?? 'en',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      writers: (json['writers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      inkers: (json['inkers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      colorists: (json['colorists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      letterers: (json['letterers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      storyArcs: (json['story_arcs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keyEvents: (json['key_events'] as List<dynamic>?)
              ?.map((e) => ComicKeyEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isKeyComic: json['is_key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      variant: json['variant'] as String?,
      variantDescription: json['variant_description'] as String?,
      barcode: json['barcode'] as String?,
    );
  }
}
