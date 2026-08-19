import 'package:flutter/foundation.dart';

@immutable
class AudiobookDetails {
  const AudiobookDetails({
    this.narrator,
    this.durationMinutes,
    this.isAbridged = false,
  });

  final String? narrator;
  final int? durationMinutes;
  final bool isAbridged;

  Map<String, dynamic> toJson() => {
        if (narrator != null) 'narrator': narrator,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (isAbridged) 'is_abridged': true,
      };

  factory AudiobookDetails.fromJson(Map<String, dynamic> json) {
    return AudiobookDetails(
      narrator: json['narrator'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isAbridged: json['is_abridged'] as bool? ?? false,
    );
  }
}

@immutable
class BookEditionMetadata {
  const BookEditionMetadata({
    required this.id,
    required this.title,
    this.isbn,
    this.format,
    this.publisher,
    this.imprint,
    this.publicationDate,
    this.editionCountry,
    this.editionLanguage,
    this.pageCount,
    this.heightMm,
    this.widthMm,
    this.printing,
    this.firstEdition = false,
    this.numberLine,
    this.printedBy,
    this.paperType,
    this.locClassification,
    this.locControlNumber,
    this.dewey,
    this.boxSetName,
    this.audiobook,
  });

  final String id;
  final String title;
  final String? isbn;
  final String? format;
  final String? publisher;
  final String? imprint;
  final DateTime? publicationDate;
  final String? editionCountry;
  final String? editionLanguage;
  final int? pageCount;
  final int? heightMm;
  final int? widthMm;
  final String? printing;
  final bool firstEdition;
  final String? numberLine;
  final String? printedBy;
  final String? paperType;
  final String? locClassification;
  final String? locControlNumber;
  final String? dewey;
  final String? boxSetName;
  final AudiobookDetails? audiobook;

  bool get isAudiobook =>
      format?.toLowerCase().contains('audio') == true || audiobook != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (isbn != null) 'isbn': isbn,
        if (format != null) 'format': format,
        if (publisher != null) 'publisher': publisher,
        if (imprint != null) 'imprint': imprint,
        if (publicationDate != null)
          'publication_date': publicationDate!.toIso8601String(),
        if (editionCountry != null) 'edition_country': editionCountry,
        if (editionLanguage != null) 'edition_language': editionLanguage,
        if (pageCount != null) 'page_count': pageCount,
        if (heightMm != null) 'height_mm': heightMm,
        if (widthMm != null) 'width_mm': widthMm,
        if (printing != null) 'printing': printing,
        if (firstEdition) 'first_edition': true,
        if (numberLine != null) 'number_line': numberLine,
        if (printedBy != null) 'printed_by': printedBy,
        if (paperType != null) 'paper_type': paperType,
        if (locClassification != null) 'loc_classification': locClassification,
        if (locControlNumber != null) 'loc_control_number': locControlNumber,
        if (dewey != null) 'dewey': dewey,
        if (boxSetName != null) 'box_set_name': boxSetName,
        if (audiobook != null) 'audiobook': audiobook!.toJson(),
      };

  factory BookEditionMetadata.fromJson(Map<String, dynamic> json) {
    return BookEditionMetadata(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      isbn: json['isbn'] as String?,
      format: json['format'] as String?,
      publisher: json['publisher'] as String?,
      imprint: json['imprint'] as String?,
      publicationDate: json['publication_date'] != null
          ? DateTime.tryParse(json['publication_date'] as String)
          : null,
      editionCountry: json['edition_country'] as String?,
      editionLanguage: json['edition_language'] as String?,
      pageCount: json['page_count'] as int?,
      heightMm: json['height_mm'] as int?,
      widthMm: json['width_mm'] as int?,
      printing: json['printing'] as String?,
      firstEdition: json['first_edition'] as bool? ?? false,
      numberLine: json['number_line'] as String?,
      printedBy: json['printed_by'] as String?,
      paperType: json['paper_type'] as String?,
      locClassification: json['loc_classification'] as String?,
      locControlNumber: json['loc_control_number'] as String?,
      dewey: json['dewey'] as String?,
      boxSetName: json['box_set_name'] as String?,
      audiobook: json['audiobook'] != null
          ? AudiobookDetails.fromJson(json['audiobook'] as Map<String, dynamic>)
          : null,
    );
  }
}

@immutable
class BookCatalogMetadata {
  const BookCatalogMetadata({
    required this.title,
    this.subtitle,
    this.sortTitle,
    this.synopsis,
    this.authors = const [],
    this.genres = const [],
    this.subjects = const [],
    this.editors = const [],
    this.translators = const [],
    this.illustrators = const [],
    this.photographers = const [],
    this.coverArtists = const [],
    this.forewordAuthors = const [],
    this.ghostwriters = const [],
    this.originalTitle,
    this.originalSubtitle,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublisher,
    this.originalPublicationDate,
    this.editions = const [],
  });

  final String title;
  final String? subtitle;
  final String? sortTitle;
  final String? synopsis;
  final List<String> authors;
  final List<String> genres;
  final List<String> subjects;
  final List<String> editors;
  final List<String> translators;
  final List<String> illustrators;
  final List<String> photographers;
  final List<String> coverArtists;
  final List<String> forewordAuthors;
  final List<String> ghostwriters;
  final String? originalTitle;
  final String? originalSubtitle;
  final String? originalCountry;
  final String? originalLanguage;
  final String? originalPublisher;
  final DateTime? originalPublicationDate;
  final List<BookEditionMetadata> editions;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (authors.isNotEmpty) 'authors': authors,
        if (genres.isNotEmpty) 'genres': genres,
        if (subjects.isNotEmpty) 'subjects': subjects,
        if (editors.isNotEmpty) 'editors': editors,
        if (translators.isNotEmpty) 'translators': translators,
        if (illustrators.isNotEmpty) 'illustrators': illustrators,
        if (photographers.isNotEmpty) 'photographers': photographers,
        if (coverArtists.isNotEmpty) 'cover_artists': coverArtists,
        if (forewordAuthors.isNotEmpty) 'foreword_authors': forewordAuthors,
        if (ghostwriters.isNotEmpty) 'ghostwriters': ghostwriters,
        if (originalTitle != null) 'original_title': originalTitle,
        if (originalSubtitle != null) 'original_subtitle': originalSubtitle,
        if (originalCountry != null) 'original_country': originalCountry,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (editions.isNotEmpty)
          'editions': editions.map((e) => e.toJson()).toList(),
      };

  factory BookCatalogMetadata.fromJson(Map<String, dynamic> json) {
    return BookCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translators: (json['translators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      illustrators: (json['illustrators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photographers: (json['photographers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      forewordAuthors: (json['foreword_authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ghostwriters: (json['ghostwriters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      originalTitle: json['original_title'] as String?,
      originalSubtitle: json['original_subtitle'] as String?,
      originalCountry: json['original_country'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublisher: json['original_publisher'] as String?,
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      editions: (json['editions'] as List<dynamic>?)
              ?.map((e) =>
                  BookEditionMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
