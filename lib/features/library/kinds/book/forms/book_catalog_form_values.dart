/// Flutter independent catalog values shared by Book Add and Edit.
final class BookCatalogFormValues {
  BookCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.description = '',
    this.originalLanguage = '',
    this.firstPublicationDate,
    this.originalPublicationDate,
    this.genres = const [],
    this.searchAliases = const [],
    this.number = '',
    this.variant = '',
    this.seriesTitle = '',
    this.seriesGroup = '',
    this.authors = '',
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
    this.firstEdition = false,
    this.audioLengthMinutes,
    this.coverImageUrl = '',
    this.thumbnailImageUrl = '',
    this.backCoverImageUrl = '',
  });

  String title;
  String sortTitle;
  String subtitle;
  String description;
  String originalLanguage;
  DateTime? firstPublicationDate;
  DateTime? originalPublicationDate;
  List<String> genres;
  List<String> searchAliases;

  String number;
  String variant;
  String seriesTitle;
  String seriesGroup;
  String authors;
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
  bool firstEdition;
  int? audioLengthMinutes;
  String coverImageUrl;
  String thumbnailImageUrl;
  String backCoverImageUrl;
}
