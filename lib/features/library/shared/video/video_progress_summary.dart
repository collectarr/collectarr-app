import 'package:collectarr_app/features/library/shared/video/video_episode_identity.dart';

class VideoProgressSummary {
  const VideoProgressSummary({
    required this.totalSeasons,
    required this.totalEpisodes,
    required this.releasedEpisodes,
    required this.watchedEpisodes,
    required this.episodesLeft,
    required this.completionPercent,
    this.currentSeasonNumber,
    this.lastWatched,
    this.nextEpisode,
    this.lastWatchedAt,
    this.nextAirDate,
    this.isFullyWatched = false,
    this.hasUnairedEpisodes = false,
  });

  const VideoProgressSummary.empty()
      : totalSeasons = 0,
        totalEpisodes = 0,
        releasedEpisodes = 0,
        watchedEpisodes = 0,
        episodesLeft = 0,
        completionPercent = 0,
        currentSeasonNumber = null,
        lastWatched = null,
        nextEpisode = null,
        lastWatchedAt = null,
        nextAirDate = null,
        isFullyWatched = false,
        hasUnairedEpisodes = false;

  final int totalSeasons;
  final int totalEpisodes;
  final int releasedEpisodes;
  final int watchedEpisodes;
  final int episodesLeft;
  final double completionPercent;
  final int? currentSeasonNumber;
  final VideoEpisodeIdentity? lastWatched;
  final VideoEpisodeIdentity? nextEpisode;
  final DateTime? lastWatchedAt;
  final DateTime? nextAirDate;
  final bool isFullyWatched;
  final bool hasUnairedEpisodes;

  String get watchedSummary => '$watchedEpisodes / $releasedEpisodes watched';
  String get completionSummary =>
      '${(completionPercent * 100).round()}% complete';
  String get episodesLeftSummary => 'Episodes left: $episodesLeft';
  String get currentSeasonSummary =>
      currentSeasonNumber == null ? 'Current season: -' : 'Current season: Season $currentSeasonNumber';
  String get lastWatchedSummary =>
      lastWatched == null ? 'Last: -' : 'Last: ${lastWatched!.code}';
  String get nextEpisodeSummary =>
      nextEpisode == null ? 'Next: -' : 'Next: ${nextEpisode!.code}';
}

class VideoSeasonProgressSummary {
  const VideoSeasonProgressSummary({
    required this.seasonNumber,
    required this.title,
    required this.totalEpisodes,
    required this.releasedEpisodes,
    required this.watchedEpisodes,
    required this.completionPercent,
    required this.statusLabel,
    this.startedAt,
    this.finishedAt,
    this.lastWatchedAt,
    this.lastWatched,
    this.nextEpisode,
  });

  final int seasonNumber;
  final String title;
  final int totalEpisodes;
  final int releasedEpisodes;
  final int watchedEpisodes;
  final double completionPercent;
  final String statusLabel;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? lastWatchedAt;
  final VideoEpisodeIdentity? lastWatched;
  final VideoEpisodeIdentity? nextEpisode;

  String get progressSummary =>
      '$watchedEpisodes / $releasedEpisodes watched · ${(completionPercent * 100).round()}%';
}

class VideoEpisodeProgressSummary {
  const VideoEpisodeProgressSummary({
    required this.episode,
    required this.watchedCount,
    required this.isWatched,
    this.lastWatchedAt,
    this.rating,
    this.notes,
    this.seenWhere,
  });

  final VideoEpisodeIdentity episode;
  final int watchedCount;
  final bool isWatched;
  final DateTime? lastWatchedAt;
  final int? rating;
  final String? notes;
  final String? seenWhere;
}
