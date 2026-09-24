import 'package:collectarr_app/core/models/partial_date.dart';

/// Flutter independent catalog values shared by Manga Add and Edit.
final class MangaCatalogFormValues {
  MangaCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.description = '',
    this.originalLanguage = '',
    this.status = '',
    this.firstPublicationDate,
    this.originalPublicationDate,
    this.genres = const [],
    this.searchAliases = const [],
    this.seriesTitle = '',
    this.seriesId = '',
    this.seriesGroup = '',
    this.volumeNumber = '',
    this.authors = '',
    this.characters = '',
    this.ageRating = '',
    this.country = '',
    this.releaseTitle = '',
    this.format = '',
    this.binding = '',
    this.publisher = '',
    this.imprint = '',
    this.distributor = '',
    this.isbn = '',
    this.barcode = '',
    this.language = '',
    this.region = '',
    this.releaseDate,
    this.releaseDateParts,
    this.releaseDateEdited = false,
    this.publicationYear,
    this.pageCount,
    this.releaseDescription = '',
    this.coverImageUrl = '',
    this.backCoverImageUrl = '',
    this.variant = '',
  });

  String title;
  String sortTitle;
  String subtitle;
  String description;
  String originalLanguage;
  String status;
  DateTime? firstPublicationDate;
  DateTime? originalPublicationDate;
  List<String> genres;
  List<String> searchAliases;

  String seriesTitle;
  String seriesId;
  String seriesGroup;
  String volumeNumber;
  String authors;
  String characters;
  String ageRating;
  String country;

  String releaseTitle;
  String format;
  String binding;
  String publisher;
  String imprint;
  String distributor;
  String isbn;
  String barcode;
  String language;
  String region;
  DateTime? releaseDate;
  PartialDate? releaseDateParts;
  bool releaseDateEdited;
  int? publicationYear;
  int? pageCount;
  String releaseDescription;
  String coverImageUrl;
  String backCoverImageUrl;
  String variant;
}
