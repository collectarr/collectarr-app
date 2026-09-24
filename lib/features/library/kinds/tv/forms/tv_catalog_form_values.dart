/// Form values used by TV Add and Edit; UI controllers remain in the renderer.
final class TvSeriesFormValues {
  TvSeriesFormValues({
    this.title = '',
    this.sortTitle = '',
    this.description = '',
    this.network = '',
    this.status = '',
    this.streamingService = '',
    this.originalLanguage = '',
    this.contentRating = '',
    this.genres = const [],
    this.creators = const [],
    this.characters = const [],
    this.originalAirDate,
    this.endDate,
  });

  String title;
  String sortTitle;
  String description;
  String network;
  String status;
  String streamingService;
  String originalLanguage;
  String contentRating;
  List<String> genres;
  List<String> creators;
  List<String> characters;
  DateTime? originalAirDate;
  DateTime? endDate;
}

final class TvReleaseFormValues {
  TvReleaseFormValues({
    this.title = '',
    this.sortTitle = '',
    this.format = '',
    this.region = '',
    this.releaseDate,
    this.publisher = '',
    this.barcode = '',
    this.caseType = '',
    this.description = '',
    this.contentRating = '',
    this.audioLanguages = const [],
    this.subtitleLanguages = const [],
    this.coverImageUrl = '',
  });

  String title;
  String sortTitle;
  String format;
  String region;
  DateTime? releaseDate;
  String publisher;
  String barcode;
  String caseType;
  String description;
  String contentRating;
  List<String> audioLanguages;
  List<String> subtitleLanguages;
  String coverImageUrl;
}
