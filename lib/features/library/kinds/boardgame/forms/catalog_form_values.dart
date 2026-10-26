import 'package:collectarr_app/core/models/partial_date.dart';

/// Editable fields for one concrete Board Game Catalog Item.
final class BoardGameCatalogFormValues {
  BoardGameCatalogFormValues({
    this.title = '',
    this.originalTitle = '',
    this.localizedTitle = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.description = '',
    this.originalLanguage = '',
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
    this.editionTitle = '',
    this.itemNumber = '',
    this.variant = '',
    this.ageRating = '',
    this.audienceRating = '',
    this.barcode = '',
    this.catalogNumber = '',
    this.country = '',
    this.coverImageUrl = '',
    this.format = '',
    this.language = '',
    this.playingTimeMinutes,
    this.releaseDate,
    this.releaseDateParts,
    this.releaseStatus = '',
  });

  String title;
  String originalTitle;
  String localizedTitle;
  String sortTitle;
  String subtitle;
  String description;
  String originalLanguage;
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
  String editionTitle;
  String itemNumber;
  String variant;
  String ageRating;
  String audienceRating;
  String barcode;
  String catalogNumber;
  String country;
  String coverImageUrl;
  String format;
  String language;
  int? playingTimeMinutes;
  DateTime? releaseDate;
  PartialDate? releaseDateParts;
  String releaseStatus;
}
