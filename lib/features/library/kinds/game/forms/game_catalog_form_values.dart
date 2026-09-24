/// Flutter independent catalog values shared by Game Add and catalog Edit.
final class GameCatalogFormValues {
  GameCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.description = '',
    this.publisher = '',
    this.platforms = const [],
    this.identifiers = const [],
    this.companyRoles = const [],
    this.developers = const [],
    this.ageRatings = const [],
    this.genres = const [],
    this.searchAliases = const [],
    this.originalLanguage = '',
    this.workReleaseDate,
    this.franchise = '',
    this.series = '',
    this.languages = const [],
    this.country = 'US',
    this.releaseTitle = '',
    this.platform = '',
    this.region = '',
    this.format = '',
    this.releaseDate,
    this.releasePublisher = '',
    this.catalogNumber = '',
    this.releaseStatus = '',
    this.language = '',
    this.barcode = '',
    this.coverImageUrl = '',
    this.releaseYear,
    this.variant = '',
    this.backCoverImageUrl = '',
  });

  String title;
  String sortTitle;
  String subtitle;
  String description;
  String publisher;
  List<String> platforms;
  List<String> identifiers;
  List<String> companyRoles;
  List<String> developers;
  List<String> ageRatings;
  List<String> genres;
  List<String> searchAliases;
  String originalLanguage;
  DateTime? workReleaseDate;
  String franchise;
  String series;
  List<String> languages;
  String country;

  String releaseTitle;
  String platform;
  String region;
  String format;
  DateTime? releaseDate;
  String releasePublisher;
  String catalogNumber;
  String releaseStatus;
  String language;
  String barcode;
  String coverImageUrl;
  int? releaseYear;
  String variant;
  String backCoverImageUrl;
}
