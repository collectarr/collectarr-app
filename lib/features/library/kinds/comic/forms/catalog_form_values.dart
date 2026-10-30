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
    this.subtitle = '',
    this.variantDescription = '',
    this.barcode = '',
    this.physicalFormatLabel = '',
    this.coverDate,
    this.coverDateParts,
    this.releaseDate,
    this.releaseDateParts,
    this.publisher = '',
    this.imprint = '',
    this.seriesGroup = '',
    this.pageCount,
    this.publicationAge = '',
    this.genres = const [],
    this.language = '',
    this.country = '',
    this.crossover = '',
    this.storyArc = '',
    this.coverImageUrl = '',
  });

  String title;
  String description;
  String seriesTitle;
  String? seriesId;
  String issueNumber;
  String variant;
  String subtitle;
  String variantDescription;
  String barcode;
  String physicalFormatLabel;
  DateTime? coverDate;
  PartialDate? coverDateParts;
  DateTime? releaseDate;
  PartialDate? releaseDateParts;
  String publisher;
  String imprint;
  String seriesGroup;
  int? pageCount;
  String publicationAge;
  List<String> genres;
  String language;
  String country;
  String crossover;
  String storyArc;
  String coverImageUrl;
}

typedef ComicCatalogItemValuesReader<T> = ComicCatalogItemFormValues Function(
    T value);
