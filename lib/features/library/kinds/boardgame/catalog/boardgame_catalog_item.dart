import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';

class BoardGameStatsMetadata {
  const BoardGameStatsMetadata({
    this.bggRank,
    this.bggRating,
    this.bggRatingCount,
    this.bggWeight,
    this.playCount,
    this.lastPlayed,
    this.favoritePlayerCount,
  });

  final int? bggRank;
  final double? bggRating;
  final int? bggRatingCount;
  final double? bggWeight;
  final int? playCount;
  final DateTime? lastPlayed;
  final int? favoritePlayerCount;

  String? get playerStats => null;
}

class BoardGameWorkMetadata {
  const BoardGameWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.releaseDate,
    this.yearPublished,
    this.originalLanguage,
    this.publisher,
    this.subtitle,
    this.platforms = const [],
    this.identifiers = const [],
    this.contributors = const [],
    this.rankings = const [],
    this.searchAliases = const [],
    this.minPlayers,
    this.maxPlayers,
    this.recommendedPlayers,
    this.bestPlayers,
    this.playingTimeMinutes,
    this.minPlaytimeMinutes,
    this.maxPlaytimeMinutes,
    this.minAge,
    this.complexityWeight,
    this.designers = const [],
    this.artists = const [],
    this.publishers = const [],
    this.mechanics = const [],
    this.categories = const [],
    this.families = const [],
    this.themes = const [],
    this.expansions = const [],
    this.languages = const [],
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? releaseDate;
  final int? yearPublished;
  final String? originalLanguage;
  final String? publisher;
  final String? subtitle;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> rankings;
  final List<String> searchAliases;
  final int? minPlayers;
  final int? maxPlayers;
  final String? recommendedPlayers;
  final String? bestPlayers;
  final int? playingTimeMinutes;
  final int? minPlaytimeMinutes;
  final int? maxPlaytimeMinutes;
  final int? minAge;
  final double? complexityWeight;
  final List<String> designers;
  final List<String> artists;
  final List<String> publishers;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> themes;
  final List<String> expansions;
  final List<String> languages;
  final List<String> genres;
}

class BoardGameCatalogItem {
  const BoardGameCatalogItem({
    required this.id,
    required this.work,
    required this.stats,
    required this.releases,
  });

  final String id;
  final BoardGameWorkMetadata work;
  final BoardGameStatsMetadata stats;
  final List<BoardGameRelease> releases;

  List<String> get categories => work.categories;
  List<String> get mechanics => work.mechanics;
  List<String> get families => work.families;
  List<String> get themes => work.themes;
  List<String> get expansions => work.expansions;
  List<String> get designers => work.designers;
  List<String> get artists => work.artists;
  List<String> get publishers => work.publishers;
  List<String> get languages => work.languages;
  List<BoardGameRelease> get editions => releases;
  BoardGameRelease? get primaryRelease =>
      releases.isEmpty ? null : releases.first;
  String get title => work.title;
  String? get displayTitle => work.title;
  String? get originalTitle => work.originalTitle;
  String? get synopsis => work.synopsis;
  DateTime? get releaseDate => primaryRelease?.releaseDate ?? work.releaseDate;
  int? get releaseYear => releaseDate?.year ?? work.yearPublished;
  String? get publisher =>
      primaryRelease?.publisher ??
      work.publisher ??
      work.publishers.firstOrNull;
  String? get barcode => primaryRelease?.barcode;
  String? get coverImageUrl => primaryRelease?.coverImageUrl;
  String? get thumbnailImageUrl => coverImageUrl;
  String? get country => primaryRelease?.country;
  String? get language =>
      primaryRelease?.language ??
      work.originalLanguage ??
      work.languages.firstOrNull;
  String? get ageRating => primaryRelease?.ageRating;
  String? get audienceRating => primaryRelease?.audienceRating;
  String? get format => primaryRelease?.format;
  List<Map<String, dynamic>>? get creators => null;
  List<String> get contributors => work.contributors;
  BoardGameStatsMetadata? get playStats => stats;
}
