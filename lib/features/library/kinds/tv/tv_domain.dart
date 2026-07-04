class TvWork {
  const TvWork({
    required this.id,
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.genres = const <String>[],
  });

  final String id;
  final String title;
  final String? originalTitle;
  final String? synopsis;
  final List<String> genres;
}

class TvSeason {
  const TvSeason({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    this.title,
    this.synopsis,
  });

  final String id;
  final String seriesId;
  final int seasonNumber;
  final String? title;
  final String? synopsis;
}

class TvEpisode {
  const TvEpisode({
    required this.id,
    required this.seriesId,
    required this.seasonId,
    required this.episodeNumber,
    this.title,
    this.synopsis,
    this.runtimeMinutes,
  });

  final String id;
  final String seriesId;
  final String seasonId;
  final int episodeNumber;
  final String? title;
  final String? synopsis;
  final int? runtimeMinutes;
}

class TvRelease {
  const TvRelease({
    required this.id,
    required this.seriesId,
    this.title,
    this.releaseDate,
    this.country,
    this.language,
  });

  final String id;
  final String seriesId;
  final String? title;
  final DateTime? releaseDate;
  final String? country;
  final String? language;
}

class TvReleaseMedia {
  const TvReleaseMedia({
    required this.id,
    required this.releaseId,
    this.title,
    this.formatLabel,
  });

  final String id;
  final String releaseId;
  final String? title;
  final String? formatLabel;
}

class TvPersonalOverlay {
  const TvPersonalOverlay({
    this.isOwned = false,
    this.isWishlisted = false,
    this.isTracked = false,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
}

enum TvWorkspaceNodeType {
  series,
  season,
  episode,
  release,
  releaseMedia,
}

class TvWorkspaceNode {
  const TvWorkspaceNode({
    required this.id,
    required this.title,
    required this.nodeType,
    this.parentId,
    this.seasonNumber,
    this.episodeNumber,
    this.releaseDate,
    this.formatLabel,
  });

  final String id;
  final String title;
  final TvWorkspaceNodeType nodeType;
  final String? parentId;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime? releaseDate;
  final String? formatLabel;
}
