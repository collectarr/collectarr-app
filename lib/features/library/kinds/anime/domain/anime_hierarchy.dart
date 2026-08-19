import 'package:flutter/foundation.dart';

@immutable
class AnimeSeasonHierarchyNode {
  const AnimeSeasonHierarchyNode({
    required this.seasonId,
    required this.seasonNumber,
    this.title,
    this.episodeCount,
    this.releases = const [],
  });

  final String seasonId;
  final int seasonNumber;
  final String? title;
  final int? episodeCount;
  final List<String> releases;
}

@immutable
class AnimeTitleHierarchy {
  const AnimeTitleHierarchy({
    required this.titleId,
    required this.canonicalTitle,
    this.seasons = const [],
    this.specials = const [],
    this.movies = const [],
  });

  final String titleId;
  final String canonicalTitle;
  final List<AnimeSeasonHierarchyNode> seasons;
  final List<String> specials;
  final List<String> movies;
}
