import 'package:collectarr_app/core/models/watch_session.dart';

class VideoWatchRunSummary {
  const VideoWatchRunSummary({
    required this.sessionCount,
    required this.uniqueEpisodeCount,
    required this.rewatchCount,
    this.firstWatchedAt,
    this.lastWatchedAt,
  });

  final int sessionCount;
  final int uniqueEpisodeCount;
  final int rewatchCount;
  final DateTime? firstWatchedAt;
  final DateTime? lastWatchedAt;

  String get label {
    if (sessionCount == 0) {
      return 'No watches logged';
    }
    if (rewatchCount == 0) {
      return '$sessionCount watches';
    }
    return '$sessionCount watches · $rewatchCount rewatches';
  }
}

class VideoWatchRunPresenter {
  const VideoWatchRunPresenter();

  VideoWatchRunSummary build(List<WatchSession> sessions) {
    final active = sessions.where((session) => !session.isDeleted).toList();
    if (active.isEmpty) {
      return const VideoWatchRunSummary(
        sessionCount: 0,
        uniqueEpisodeCount: 0,
        rewatchCount: 0,
      );
    }
    active.sort((a, b) => a.watchedAt.compareTo(b.watchedAt));
    final uniqueEpisodeKeys = <String>{};
    for (final session in active) {
      if (!session.isEpisodeSession ||
          session.seasonNumber == null ||
          session.episodeNumber == null) {
        continue;
      }
      uniqueEpisodeKeys.add(
        '${session.seasonNumber}:${session.episodeNumber}',
      );
    }
    return VideoWatchRunSummary(
      sessionCount: active.length,
      uniqueEpisodeCount: uniqueEpisodeKeys.length,
      rewatchCount: (active.length - uniqueEpisodeKeys.length).clamp(0, active.length),
      firstWatchedAt: active.first.watchedAt,
      lastWatchedAt: active.last.watchedAt,
    );
  }
}
