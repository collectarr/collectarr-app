import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Flutter independent catalog values shared by Book Add and Edit.
final class BookCatalogFormValues {
  BookCatalogFormValues({
    this.title = '',
    this.boxSet = '',
    this.publicationPlace = '',
    this.printedBy = '',
    this.paperType = '',
    this.numberLine = '',
    this.originalSubtitle = '',
    this.originalCountry = '',
    this.originalPublisher = '',
    this.originalPublicationPlace = '',
    this.printingNumber,
    this.widthMm,
    this.heightMm,
    this.spineThicknessMm,
    this.weightGrams,
    this.audioAbridged = false,
    this.extras = const [],
    this.sortTitle = '',
    this.subtitle = '',
    this.originalTitle = '',
    this.localizedTitle = '',
    this.description = '',
    this.originalLanguage = '',
    this.firstPublicationDate,
    this.originalPublicationDate,
    this.genres = const [],
    this.subjects = const [],
    this.searchAliases = const [],
    this.number = '',
    this.volumeName = '',
    this.volumeNumber = '',
    this.variant = '',
    this.seriesTitle = '',
    this.seriesGroup = '',
    this.authors = const [],
    this.translators = const [],
    this.otherContributors = const [],
    this.characters = '',
    this.ageRating = '',
    this.country = '',
    this.publicationYear,
    this.editionTitle = '',
    this.binding = '',
    this.format = '',
    this.isbn = '',
    this.upc = '',
    this.publisher = '',
    this.distributor = '',
    this.imprint = '',
    this.releaseDate,
    this.pageCount,
    this.language = '',
    this.region = '',
    this.releaseStatus = '',
    this.editionStatement = '',
    this.dimensions = '',
    this.lcControlNumber = '',
    this.lcClassification = '',
    this.dewey = '',
    this.firstEdition = false,
    this.audioLengthMinutes,
    this.coverImageUrl = '',
    this.thumbnailImageUrl = '',
    this.backCoverImageUrl = '',
  });

  String title;
  String boxSet;
  String publicationPlace;
  String printedBy;
  String paperType;
  String numberLine;
  String originalSubtitle;
  String originalCountry;
  String originalPublisher;
  String originalPublicationPlace;
  int? printingNumber;
  int? widthMm;
  int? heightMm;
  int? spineThicknessMm;
  int? weightGrams;
  bool audioAbridged;
  List<String> extras;
  String sortTitle;
  String subtitle;
  String originalTitle;
  String localizedTitle;
  String description;
  String originalLanguage;
  DateTime? firstPublicationDate;
  DateTime? originalPublicationDate;
  List<String> genres;
  List<String> subjects;
  List<String> searchAliases;

  String number;
  String volumeName;
  String volumeNumber;
  String variant;
  String seriesTitle;
  String seriesGroup;
  List<BookCatalogCredit> authors;
  List<BookCatalogCredit> translators;
  List<BookCatalogCredit> otherContributors;
  String characters;
  String ageRating;
  String country;
  int? publicationYear;

  String editionTitle;
  String binding;
  String format;
  String isbn;
  String upc;
  String publisher;
  String distributor;
  String imprint;
  DateTime? releaseDate;
  int? pageCount;
  String language;
  String region;
  String releaseStatus;
  String editionStatement;
  String dimensions;
  String lcControlNumber;
  String lcClassification;
  String dewey;
  bool firstEdition;
  int? audioLengthMinutes;
  String coverImageUrl;
  String thumbnailImageUrl;
  String backCoverImageUrl;
}
