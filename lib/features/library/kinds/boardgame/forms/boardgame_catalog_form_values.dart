/// Flutter independent catalog values shared by Board Game Add and Edit.
final class BoardGameCatalogFormValues {
  BoardGameCatalogFormValues({
    this.title = '',
    this.originalTitle = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.description = '',
    this.originalLanguage = '',
    this.workReleaseDate,
    this.publisher = '',
    this.platforms = const [],
    this.identifiers = const [],
    this.contributors = const [],
    this.designers = const [],
    this.artists = const [],
    this.characters = const [],
    this.mechanics = const [],
    this.categories = const [],
    this.families = const [],
    this.themes = const [],
    this.expansions = const [],
    this.expansionFor = '',
    this.rankings = const [],
    this.searchAliases = const [],
    this.languages = const [],
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.recommendedPlayers = '',
    this.bestPlayers = '',
    this.minPlaytimeMinutes,
    this.maxPlaytimeMinutes,
    this.minimumAge,
    this.complexityWeight,
    this.bggRating,
    this.bggRatingCount,
    this.bggRank,
    this.seriesTitle = '',
    this.itemNumber = '',
    this.releaseTitle = '',
    this.editionTitle = '',
    this.variant = '',
    this.ageRating = '',
    this.audienceRating = '',
    this.barcode = '',
    this.catalogNumber = '',
    this.country = '',
    this.coverImageUrl = '',
    this.backCoverImageUrl = '',
    this.editionDescription = '',
    this.format = '',
    this.language = '',
    this.editionMaxPlayers,
    this.editionMinAge,
    this.editionMinPlayers,
    this.playingTimeMinutes,
    this.editionPublisher = '',
    this.releaseDate,
    this.releaseStatus = '',
  });

  String title;
  String originalTitle;
  String sortTitle;
  String subtitle;
  String description;
  String originalLanguage;
  DateTime? workReleaseDate;
  String publisher;
  List<String> platforms;
  List<String> identifiers;
  List<String> contributors;
  List<String> designers;
  List<String> artists;
  List<String> characters;
  List<String> mechanics;
  List<String> categories;
  List<String> families;
  List<String> themes;
  List<String> expansions;
  String expansionFor;
  List<String> rankings;
  List<String> searchAliases;
  List<String> languages;
  int? yearPublished;
  int? minPlayers;
  int? maxPlayers;
  String recommendedPlayers;
  String bestPlayers;
  int? minPlaytimeMinutes;
  int? maxPlaytimeMinutes;
  int? minimumAge;
  double? complexityWeight;
  double? bggRating;
  int? bggRatingCount;
  int? bggRank;
  String seriesTitle;
  String itemNumber;

  String releaseTitle;
  String editionTitle;
  String variant;
  String ageRating;
  String audienceRating;
  String barcode;
  String catalogNumber;
  String country;
  String coverImageUrl;
  String backCoverImageUrl;
  String editionDescription;
  String format;
  String language;
  int? editionMaxPlayers;
  int? editionMinAge;
  int? editionMinPlayers;
  int? playingTimeMinutes;
  String editionPublisher;
  DateTime? releaseDate;
  String releaseStatus;
}
