import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';

class BookSeriesRef {
  const BookSeriesRef({
    required this.seriesId,
    required this.seriesTitle,
    this.volumeNumber,
  });

  final String seriesId;
  final String seriesTitle;
  final double? volumeNumber;
}

class BookCreatorCredit {
  const BookCreatorCredit({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;
}

class BookWorkMetadata {
  const BookWorkMetadata({
    required this.title,
    this.subtitle,
    this.originalTitle,
    this.synopsis,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublisher,
    this.series,
    this.creators = const [],
    this.subjects = const [],
    this.genres = const [],
  });

  final String title;
  final String? subtitle;
  final String? originalTitle;
  final String? synopsis;
  final String? originalCountry;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? originalPublisher;
  final BookSeriesRef? series;
  final List<BookCreatorCredit> creators;
  final List<String> subjects;
  final List<String> genres;
}

class BookPublishingMetadata {
  const BookPublishingMetadata({
    this.pageCount,
    this.imprint,
    this.publicationPlace,
    this.paperType,
    this.printedBy,
    this.dustJacket,
    this.firstEdition,
  });

  final int? pageCount;
  final String? imprint;
  final String? publicationPlace;
  final String? paperType;
  final String? printedBy;
  final bool? dustJacket;
  final bool? firstEdition;
}

class BookCatalogItem {
  const BookCatalogItem({
    required this.id,
    required this.work,
    required this.publishing,
    required this.releases,
  });

  final String id;
  final BookWorkMetadata work;
  final BookPublishingMetadata publishing;
  final List<BookRelease> releases;
}
