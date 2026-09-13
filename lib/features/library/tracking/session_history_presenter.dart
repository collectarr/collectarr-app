import 'package:collectarr_app/core/models/watch_session.dart';

class SessionHistorySummary {
  const SessionHistorySummary({
    required this.sessionCount,
    required this.uniqueTargetCount,
    required this.rewatchCount,
    this.firstWatchedAt,
    this.lastWatchedAt,
  });

  final int sessionCount;
  final int uniqueTargetCount;
  final int rewatchCount;
  final DateTime? firstWatchedAt;
  final DateTime? lastWatchedAt;

  String label({
    String nounSingular = 'watch',
    String nounPlural = 'watches',
  }) {
    if (sessionCount == 0) {
      return 'No $nounPlural logged';
    }
    final noun = sessionCount == 1 ? nounSingular : nounPlural;
    if (rewatchCount == 0) {
      return '$sessionCount $noun';
    }
    return '$sessionCount $noun · $rewatchCount rewatches';
  }
}

class SessionHistoryPresenter {
  const SessionHistoryPresenter();

  SessionHistorySummary build(List<WatchSession> sessions) {
    final active = sessions.where((session) => !session.isDeleted).toList();
    if (active.isEmpty) {
      return const SessionHistorySummary(
        sessionCount: 0,
        uniqueTargetCount: 0,
        rewatchCount: 0,
      );
    }
    active.sort((a, b) => a.watchedAt.compareTo(b.watchedAt));
    final uniqueTargetRefs = active.map((session) => session.targetRef).toSet();
    return SessionHistorySummary(
      sessionCount: active.length,
      uniqueTargetCount: uniqueTargetRefs.length,
      rewatchCount:
          (active.length - uniqueTargetRefs.length).clamp(0, active.length),
      firstWatchedAt: active.first.watchedAt,
      lastWatchedAt: active.last.watchedAt,
    );
  }
}
