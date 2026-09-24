/// Flutter and domain independent values shared by Movie Add and catalog Edit.
final class MovieCatalogFormValues {
  MovieCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.workDescription = '',
    this.genres = const [],
    this.originalLanguage = '',
    this.ageRating = '',
    this.audienceRating = '',
    this.runtimeMinutes,
    this.workReleaseDate,
    this.subtitle = '',
    this.releaseTitle = '',
    this.format = '',
    this.region = '',
    this.releaseDate,
    this.distributor = '',
    this.language = '',
    this.releaseDescription = '',
    this.coverImageUrl = '',
    this.barcode = '',
    this.itemNumber = '',
    this.variant = '',
    this.releaseYear,
    this.directors = '',
    this.characters = '',
    this.backCoverImageUrl = '',
  });

  String sortTitle;
  String title;
  String workDescription;
  List<String> genres;
  String originalLanguage;
  String ageRating;
  String audienceRating;
  int? runtimeMinutes;
  DateTime? workReleaseDate;
  String subtitle;

  String releaseTitle;
  String format;
  String region;
  DateTime? releaseDate;
  String distributor;
  String language;
  String releaseDescription;
  String coverImageUrl;
  String barcode;
  String itemNumber;
  String variant;
  int? releaseYear;
  String directors;
  String characters;
  String backCoverImageUrl;
}
