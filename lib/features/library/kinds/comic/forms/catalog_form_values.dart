import 'package:collectarr_app/core/models/partial_date.dart';

/// Catalog values shared by the Comic Add form and issue Edit schema.
final class ComicCatalogItemFormValues {
  ComicCatalogItemFormValues({
    this.title = '',
    this.description = '',
    this.seriesTitle = '',
    this.seriesId,
    this.issueNumber = '',
    this.variant = '',
    this.editionTitle = '',
    this.subtitle = '',
    this.variantDescription = '',
    this.barcode = '',
    this.isbn = '',
    this.upc = '',
    this.physicalFormatLabel = '',
    this.coverDate,
    this.coverDateParts,
    this.releaseDate,
    this.releaseDateParts,
    this.publisher = '',
    this.imprint = '',
    this.seriesGroup = '',
    this.pageCount,
    this.ageRating = '',
    this.publicationAge = '',
    this.genres = const [],
    this.language = '',
    this.country = '',
    this.crossover = '',
    this.storyArcs = const [],
    this.coverImageUrl = '',
  });

  String title;
  String description;
  String seriesTitle;
  String? seriesId;
  String issueNumber;
  String variant;
  String editionTitle;
  String subtitle;
  String variantDescription;
  String barcode;
  String isbn;
  String upc;
  String physicalFormatLabel;
  DateTime? coverDate;
  PartialDate? coverDateParts;
  DateTime? releaseDate;
  PartialDate? releaseDateParts;
  String publisher;
  String imprint;
  String seriesGroup;
  int? pageCount;
  String ageRating;
  String publicationAge;
  List<String> genres;
  String language;
  String country;
  String crossover;
  List<String> storyArcs;
  String coverImageUrl;
}

typedef ComicCatalogItemValuesReader<T> = ComicCatalogItemFormValues Function(
    T value);
