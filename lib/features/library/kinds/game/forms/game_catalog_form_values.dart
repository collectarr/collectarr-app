/// Editable fields for one concrete Game Catalog Item.
///
/// Release-specific fields are kept on this item; the form does not model a
/// separate Work or Release record.
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
    this.franchise = '',
    this.series = '',
    this.languages = const [],
    this.country = 'US',
    this.editionTitle = '',
    this.platform = '',
    this.region = '',
    this.format = '',
    this.releaseDate,
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
  String franchise;
  String series;
  List<String> languages;
  String country;

  String editionTitle;
  String platform;
  String region;
  String format;
  DateTime? releaseDate;
  String catalogNumber;
  String releaseStatus;
  String language;
  String barcode;
  String coverImageUrl;
  int? releaseYear;
  String variant;
  String backCoverImageUrl;
}
