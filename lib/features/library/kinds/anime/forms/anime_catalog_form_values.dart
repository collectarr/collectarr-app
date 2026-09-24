/// Kind-owned Anime catalog form values shared by Add and Edit.
final class AnimeMediaFormValues {
  AnimeMediaFormValues({
    this.title = '',
    this.sortTitle = '',
    this.description = '',
    this.coverImageUrl = '',
    this.animeType = '',
    this.season = '',
    this.sourceMaterial = '',
    this.originalLanguage = '',
    this.genres = const [],
    this.themes = const [],
    this.studios = const [],
    this.producers = const [],
    this.licensors = const [],
    this.status = '',
    this.seasonYear,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.startDate,
    this.endDate,
    this.nativeTitle = '',
    this.romajiTitle = '',
    this.englishTitle = '',
    this.alternateTitles = const [],
    this.country = 'JP',
    this.creators = const [],
    this.characters = const [],
  });

  String title;
  String sortTitle;
  String description;
  String coverImageUrl;
  String animeType;
  String season;
  String sourceMaterial;
  String originalLanguage;
  List<String> genres;
  List<String> themes;
  List<String> studios;
  List<String> producers;
  List<String> licensors;
  String status;
  int? seasonYear;
  int? episodeCount;
  int? episodeRuntimeMinutes;
  DateTime? startDate;
  DateTime? endDate;

  String nativeTitle;
  String romajiTitle;
  String englishTitle;
  List<String> alternateTitles;
  String country;
  List<String> creators;
  List<String> characters;
}

final class AnimeReleaseFormValues {
  AnimeReleaseFormValues({
    this.title = '',
    this.format = '',
    this.region = '',
    this.language = '',
    this.releaseDate,
    this.publisher = '',
    this.distributor = '',
    this.barcode = '',
    this.mediaCount,
    this.audioTracks = const [],
    this.subtitles = const [],
    this.description = '',
    this.coverImageUrl = '',
    this.variant = '',
  });

  String title;
  String format;
  String region;
  String language;
  DateTime? releaseDate;
  String publisher;
  String distributor;
  String barcode;
  int? mediaCount;
  List<String> audioTracks;
  List<String> subtitles;
  String description;
  String coverImageUrl;
  String variant;
}
