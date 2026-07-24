import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';

class BoardGameStatsMetadata {
  const BoardGameStatsMetadata({
    this.bggRank,
    this.bggRating,
    this.playCount,
    this.lastPlayed,
    this.favoritePlayerCount,
  });

  final int? bggRank;
  final double? bggRating;
  final int? playCount;
  final DateTime? lastPlayed;
  final int? favoritePlayerCount;
}

class BoardGameWorkMetadata {
  const BoardGameWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.minAge,
    this.mechanics = const [],
    this.categories = const [],
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final int? minAge;
  final List<String> mechanics;
  final List<String> categories;
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
}
