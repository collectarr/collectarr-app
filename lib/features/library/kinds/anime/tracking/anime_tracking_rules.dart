import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

/// Anime-specific status transition derived from released episode progress.
class AnimeTrackingRuleResult {
  const AnimeTrackingRuleResult({
    required this.status,
    required this.statusLabel,
    required this.shouldMarkCompleted,
    required this.shouldMarkCaughtUp,
  });

  final MediaTrackingStatus status;
  final String statusLabel;
  final bool shouldMarkCompleted;
  final bool shouldMarkCaughtUp;
}

AnimeTrackingRuleResult deriveAnimeTrackingRuleResult({
  required int releasedEpisodes,
  required int watchedEpisodes,
  required bool hasUnairedEpisodes,
}) {
  if (releasedEpisodes <= 0) {
    return const AnimeTrackingRuleResult(
      status: MediaTrackingStatus.none,
      statusLabel: 'Not tracked',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: false,
    );
  }
  if (watchedEpisodes <= 0) {
    return const AnimeTrackingRuleResult(
      status: MediaTrackingStatus.planned,
      statusLabel: 'Plan to watch',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: false,
    );
  }
  if (watchedEpisodes >= releasedEpisodes && hasUnairedEpisodes) {
    return const AnimeTrackingRuleResult(
      status: MediaTrackingStatus.completed,
      statusLabel: 'Caught up',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: true,
    );
  }
  if (watchedEpisodes >= releasedEpisodes) {
    return const AnimeTrackingRuleResult(
      status: MediaTrackingStatus.completed,
      statusLabel: 'Watched',
      shouldMarkCompleted: true,
      shouldMarkCaughtUp: false,
    );
  }
  return const AnimeTrackingRuleResult(
    status: MediaTrackingStatus.inProgress,
    statusLabel: 'Watching',
    shouldMarkCompleted: false,
    shouldMarkCaughtUp: false,
  );
}
