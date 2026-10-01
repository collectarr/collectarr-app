/// Flat values used by TV Catalog Item Add; controllers remain in the renderer.
final class TvCatalogItemFormValues {
  TvCatalogItemFormValues({
    this.sortKey = '',
    this.originalTitle = '',
    this.editionTitle = '',
    this.synopsis = '',
    this.coverImageUrl = '',
    this.physicalFormat = '',
    this.country = '',
    this.publisher = '',
    this.language = '',
    this.ageRating = '',
    this.barcode = '',
    this.genres = const [],
    this.creators = const [],
    this.characters = const [],
    this.audioTracks = '',
    this.subtitles = '',
    this.releaseDate,
    this.seasonNumber,
    this.runtimeMinutes,
    this.discCount,
    this.screenRatio = '',
  });

  String sortKey;
  String originalTitle;
  String editionTitle;
  String synopsis;
  String coverImageUrl;
  String physicalFormat;
  String country;
  String publisher;
  String language;
  String ageRating;
  String barcode;
  List<String> genres;
  List<String> creators;
  List<String> characters;
  String audioTracks;
  String subtitles;
  DateTime? releaseDate;
  int? seasonNumber;
  int? runtimeMinutes;
  int? discCount;
  String screenRatio;
}

/// Form values used by the previous TV editor adapters; UI controllers remain
/// in the renderer while these adapters are removed from the active path.
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
