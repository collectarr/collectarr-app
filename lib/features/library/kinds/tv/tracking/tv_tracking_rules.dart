import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

/// TV-specific status transition derived from released episode progress.
class TvTrackingRuleResult {
  const TvTrackingRuleResult({
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

TvTrackingRuleResult deriveTvTrackingRuleResult({
  required int releasedEpisodes,
  required int watchedEpisodes,
  required bool hasUnairedEpisodes,
}) {
  if (releasedEpisodes <= 0) {
    return const TvTrackingRuleResult(
      status: MediaTrackingStatus.none,
      statusLabel: 'Not tracked',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: false,
    );
  }
  if (watchedEpisodes <= 0) {
    return const TvTrackingRuleResult(
      status: MediaTrackingStatus.planned,
      statusLabel: 'Plan to watch',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: false,
    );
  }
  if (watchedEpisodes >= releasedEpisodes && hasUnairedEpisodes) {
    return const TvTrackingRuleResult(
      status: MediaTrackingStatus.completed,
      statusLabel: 'Caught up',
      shouldMarkCompleted: false,
      shouldMarkCaughtUp: true,
    );
  }
  if (watchedEpisodes >= releasedEpisodes) {
    return const TvTrackingRuleResult(
      status: MediaTrackingStatus.completed,
      statusLabel: 'Watched',
      shouldMarkCompleted: true,
      shouldMarkCaughtUp: false,
    );
  }
  return const TvTrackingRuleResult(
    status: MediaTrackingStatus.inProgress,
    statusLabel: 'Watching',
    shouldMarkCompleted: false,
    shouldMarkCaughtUp: false,
  );
}
