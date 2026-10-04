/// Flutter and domain independent values shared by Movie Add and catalog Edit.
final class MovieCatalogFormValues {
  MovieCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.synopsis = '',
    this.genres = const [],
    this.originalLanguage = '',
    this.ageRating = '',
    this.audienceRating = '',
    this.runtimeMinutes,
    this.subtitle = '',
    this.editionTitle = '',
    this.format = '',
    this.region = '',
    this.releaseDate,
    this.distributor = '',
    this.language = '',
    this.coverImageUrl = '',
    this.barcode = '',
    this.itemNumber = '',
    this.variant = '',
    this.releaseYear,
    this.directors = '',
    this.characters = '',
  });

  String sortTitle;
  String title;
  String synopsis;
  List<String> genres;
  String originalLanguage;
  String ageRating;
  String audienceRating;
  int? runtimeMinutes;
  String subtitle;

  String editionTitle;
  String format;
  String region;
  DateTime? releaseDate;
  String distributor;
  String language;
  String coverImageUrl;
  String barcode;
  String itemNumber;
  String variant;
  int? releaseYear;
  String directors;
  String characters;
}
