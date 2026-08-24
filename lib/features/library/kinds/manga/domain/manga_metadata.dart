import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

enum MangaDemographic {
  shonen('Shonen'),
  shojo('Shojo'),
  seinen('Seinen'),
  josei('Josei'),
  kodomo('Kodomo'),
  other('Other');

  const MangaDemographic(this.label);
  final String label;

  static MangaDemographic fromString(String? value) {
    if (value == null) return MangaDemographic.other;
    final normalized = value.trim().toLowerCase();
    return MangaDemographic.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaDemographic.other,
    );
  }
}

enum MangaPublicationStatus {
  ongoing('Ongoing'),
  completed('Completed'),
  hiatus('On Hiatus'),
  cancelled('Cancelled'),
  upcoming('Upcoming');

  const MangaPublicationStatus(this.label);
  final String label;

  static MangaPublicationStatus fromString(String? value) {
    if (value == null) return MangaPublicationStatus.ongoing;
    final normalized = value.trim().toLowerCase();
    return MangaPublicationStatus.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaPublicationStatus.ongoing,
    );
  }
}

enum MangaEditionFormat {
  tankobon('Tankobon'),
  bunkoban('Bunkoban'),
  kanzenban('Kanzenban'),
  omnibus('Omnibus'),
  hardcover('Hardcover'),
  digital('Digital'),
  other('Other');

  const MangaEditionFormat(this.label);
  final String label;

  static MangaEditionFormat fromString(String? value) {
    if (value == null) return MangaEditionFormat.tankobon;
    final normalized = value.trim().toLowerCase();
    return MangaEditionFormat.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaEditionFormat.other,
    );
  }
}

enum MangaReadingDirection {
  rightToLeft('Right-to-Left (Japanese Default)'),
  leftToRight('Left-to-Right (Western Style)');

  const MangaReadingDirection(this.label);
  final String label;

  static MangaReadingDirection fromString(String? value) {
    if (value == null) return MangaReadingDirection.rightToLeft;
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('left_to_right') ||
        normalized.contains('left-to-right') ||
        normalized == 'ltr') {
      return MangaReadingDirection.leftToRight;
    }
    return MangaReadingDirection.rightToLeft;
  }
}

@immutable
class MangaMetadata implements LibraryKindMetadataRuntime {
  const MangaMetadata({
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.authors = const [],
    this.artists = const [],
    this.demographic = MangaDemographic.other,
    this.serializationPlatform,
    this.publicationStatus = MangaPublicationStatus.ongoing,
    this.originalPublisher,
    this.localizedPublisher,
    this.volumeNumber,
    this.totalVolumes,
    this.chapterCount,
    this.originalPublicationDate,
    this.localizedReleaseDate,
    this.isbn,
    this.editionFormat = MangaEditionFormat.tankobon,
    this.language = 'ja',
    this.country = 'JP',
    this.genres = const [],
    this.themes = const [],
    this.translator,
    this.readingDirection = MangaReadingDirection.rightToLeft,
    this.relations = const [],
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.manga;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final List<String> alternateTitles;
  final List<String> authors;
  final List<String> artists;
  final MangaDemographic demographic;
  final String? serializationPlatform;
  final MangaPublicationStatus publicationStatus;
  final String? originalPublisher;
  final String? localizedPublisher;
  final int? volumeNumber;
  final int? totalVolumes;
  final int? chapterCount;
  final DateTime? originalPublicationDate;
  final DateTime? localizedReleaseDate;
  final String? isbn;
  final MangaEditionFormat editionFormat;
  final String language;
  final String country;
  final List<String> genres;
  final List<String> themes;
  final String? translator;
  final MangaReadingDirection readingDirection;
  final List<String> relations;

  Map<String, dynamic> toJson() => {
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
        if (alternateTitles.isNotEmpty) 'alternate_titles': alternateTitles,
        if (authors.isNotEmpty) 'authors': authors,
        if (artists.isNotEmpty) 'artists': artists,
        'demographic': demographic.name,
        if (serializationPlatform != null)
          'serialization_platform': serializationPlatform,
        'publication_status': publicationStatus.name,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (localizedPublisher != null)
          'localized_publisher': localizedPublisher,
        if (volumeNumber != null) 'volume_number': volumeNumber,
        if (totalVolumes != null) 'total_volumes': totalVolumes,
        if (chapterCount != null) 'chapter_count': chapterCount,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (localizedReleaseDate != null)
          'localized_release_date': localizedReleaseDate!.toIso8601String(),
        if (isbn != null) 'isbn': isbn,
        'edition_format': editionFormat.name,
        'language': language,
        'country': country,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        if (translator != null) 'translator': translator,
        'reading_direction': readingDirection.name,
        if (relations.isNotEmpty) 'relations': relations,
      };

  factory MangaMetadata.fromJson(Map<String, dynamic> json) {
    return MangaMetadata(
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      demographic: MangaDemographic.fromString(json['demographic'] as String?),
      serializationPlatform: json['serialization_platform'] as String?,
      publicationStatus: MangaPublicationStatus.fromString(
          json['publication_status'] as String?),
      originalPublisher: json['original_publisher'] as String?,
      localizedPublisher: json['localized_publisher'] as String?,
      volumeNumber: json['volume_number'] as int?,
      totalVolumes: json['total_volumes'] as int?,
      chapterCount: json['chapter_count'] as int?,
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      localizedReleaseDate: json['localized_release_date'] != null
          ? DateTime.tryParse(json['localized_release_date'] as String)
          : null,
      isbn: json['isbn'] as String?,
      editionFormat:
          MangaEditionFormat.fromString(json['edition_format'] as String?),
      language: (json['language'] as String?) ?? 'ja',
      country: (json['country'] as String?) ?? 'JP',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translator: json['translator'] as String?,
      readingDirection: MangaReadingDirection.fromString(
          json['reading_direction'] as String?),
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
