import 'dart:math' as math;

import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/shared/video/video_episode_identity.dart';
import 'package:collectarr_app/features/library/shared/video/video_progress_summary.dart';

class VideoProgressPresenter {
  const VideoProgressPresenter();

  VideoProgressSummary build({
    required List<Season> seasons,
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now().toUtc();
    final regularSeasons = _regularSeasons(seasons);
    final headlineSeasons = regularSeasons.isEmpty ? seasons : regularSeasons;
    if (headlineSeasons.isEmpty) {
      return const VideoProgressSummary.empty();
    }

    final episodes = _flattenEpisodes(headlineSeasons);
    final totalSeasons = headlineSeasons.length;
    final totalEpisodes = episodes.length;
    final releasedEpisodes = episodes.isEmpty
        ? 0
        : _releasedEpisodes(episodes, referenceNow);
    final watchedEpisodeKeys = _watchedEpisodeKeys(trackedUnits, watchSessions);
    final releasedKeys = <String>{
      for (final episode in episodes)
        if (_isReleased(episode, referenceNow)) _episodeKeyForSeasonEpisode(episode)
    };
    final watchedReleasedCount =
        watchedEpisodeKeys.where(releasedKeys.contains).length;
    final watchedTotalCount = watchedEpisodeKeys.length;
    final watchedEpisodes = watchedTotalCount;
    final episodesLeft =
        math.max(releasedEpisodes - watchedReleasedCount, 0);
    final completionPercent = releasedEpisodes == 0
        ? 0.0
        : (math.min(watchedReleasedCount, releasedEpisodes) / releasedEpisodes)
            .toDouble();
    final lastWatched = _lastWatchedEpisode(
      episodes,
      trackedUnits: trackedUnits,
      watchSessions: watchSessions,
    );
    final nextEpisode = _nextEpisode(episodes, watchedEpisodeKeys, referenceNow);
    final currentSeasonNumber = nextEpisode?.seasonNumber ??
        lastWatched?.seasonNumber ??
        _firstRegularSeasonNumber(headlineSeasons);
    final lastWatchedAt = _latestWatchSession(watchSessions)?.watchedAt ??
        _latestWatchedTrackingUnit(trackedUnits)?.completedAt;
    final nextAirDate = nextEpisode?.airDate;
    final hasUnairedEpisodes = episodes.any(
      (episode) => _episodeAirDate(episode)?.isAfter(referenceNow) == true,
    );
    final isFullyWatched =
        releasedEpisodes > 0 && watchedReleasedCount >= releasedEpisodes;

    return VideoProgressSummary(
      totalSeasons: totalSeasons,
      totalEpisodes: totalEpisodes,
      releasedEpisodes: releasedEpisodes,
      watchedEpisodes: watchedEpisodes,
      episodesLeft: episodesLeft,
      completionPercent: completionPercent,
      currentSeasonNumber: currentSeasonNumber,
      lastWatched: lastWatched,
      nextEpisode: nextEpisode,
      lastWatchedAt: lastWatchedAt,
      nextAirDate: nextAirDate,
      isFullyWatched: isFullyWatched,
      hasUnairedEpisodes: hasUnairedEpisodes,
    );
  }

  VideoSeasonProgressSummary seasonSummary({
    required Season season,
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now().toUtc();
    final episodes = season.episodes;
    final seasonEpisodes = _flattenEpisodes([season]);
    final releaseCount = episodes
        .where((episode) => _isEpisodeReleased(episode, referenceNow))
        .length;
    final watchedKeys = _watchedEpisodeKeys(trackedUnits, watchSessions);
    final watchedCount = episodes
        .where(
          (episode) => watchedKeys.contains(
            _episodeKey(
              seasonNumber: season.seasonNumber,
              episodeNumber: episode.episodeNumber,
            ),
          ),
        )
        .length;
    final completionPercent = releaseCount == 0
        ? 0.0
        : (math.min(watchedCount, releaseCount) / releaseCount).toDouble();
    final lastWatched = _lastWatchedEpisode(
      seasonEpisodes,
      trackedUnits: trackedUnits,
      watchSessions: watchSessions,
    );
    final lastWatchedAt = _latestWatchSessionForSeason(
      season.seasonNumber,
      watchSessions,
    )?.watchedAt;
    final nextEpisode = _nextEpisode(seasonEpisodes, watchedKeys, referenceNow);
    final statusLabel = _seasonStatusLabel(
      season: season,
      watchedCount: watchedCount,
      releaseCount: releaseCount,
      totalCount: episodes.length,
      referenceNow: referenceNow,
    );
    return VideoSeasonProgressSummary(
      seasonNumber: season.seasonNumber,
      title: season.title,
      totalEpisodes: episodes.length,
      releasedEpisodes: releaseCount,
      watchedEpisodes: watchedCount,
      completionPercent: completionPercent,
      statusLabel: statusLabel,
      startedAt: lastWatchedAt,
      finishedAt: completionPercent >= 1.0 ? lastWatchedAt : null,
      lastWatchedAt: lastWatchedAt,
      lastWatched: lastWatched,
      nextEpisode: nextEpisode,
    );
  }

  List<VideoEpisodeProgressSummary> episodeRows({
    required Season season,
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
  }) {
    final watchedEpisodes = _watchedEpisodeMap(trackedUnits, watchSessions);
    final sessionsByEpisode = <String, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (!session.isEpisodeSession) {
        continue;
      }
      if (session.seasonNumber != season.seasonNumber) {
        continue;
      }
      final key = _episodeKey(
        seasonNumber: session.seasonNumber!,
        episodeNumber: session.episodeNumber!,
      );
      sessionsByEpisode.putIfAbsent(key, () => <WatchSession>[]).add(session);
    }
    final rows = <VideoEpisodeProgressSummary>[];
    for (final episode in season.episodes) {
      final identity = VideoEpisodeIdentity(
        seasonNumber: season.seasonNumber,
        episodeNumber: episode.episodeNumber,
        title: episode.title,
        airDate: _parseEpisodeDate(episode.airDate),
        runtimeMinutes: episode.runtimeMinutes,
      );
      final key = _episodeKey(
        seasonNumber: season.seasonNumber,
        episodeNumber: episode.episodeNumber,
      );
      final sessions = sessionsByEpisode[key] ?? const <WatchSession>[];
      rows.add(
        VideoEpisodeProgressSummary(
          episode: identity,
          watchedCount: sessions.length,
          isWatched: watchedEpisodes.containsKey(key),
          lastWatchedAt: sessions.isEmpty ? null : sessions.first.watchedAt,
          rating: sessions.isEmpty ? null : sessions.first.rating,
          notes: sessions.isEmpty ? null : sessions.first.notes,
          seenWhere: sessions.isEmpty ? null : sessions.first.seenWhere,
        ),
      );
    }
    return rows;
  }

  static List<Season> _regularSeasons(List<Season> seasons) {
    final regular = seasons.where((season) => season.seasonNumber > 0).toList();
    return regular.isEmpty ? seasons : regular;
  }

  static List<_SeasonEpisode> _flattenEpisodes(List<Season> seasons) {
    final result = <_SeasonEpisode>[];
    for (final season in seasons) {
      for (final episode in season.episodes) {
        result.add(_SeasonEpisode(season, episode));
      }
    }
    return result;
  }

  static int _releasedEpisodes(
    List<_SeasonEpisode> episodes,
    DateTime now,
  ) {
    final hasAirDates = episodes.any(
      (episode) => _episodeAirDate(episode) != null,
    );
    if (!hasAirDates) {
      return episodes.length;
    }
    return episodes.where((episode) => _isReleased(episode, now)).length;
  }

  static bool _isReleased(_SeasonEpisode episode, DateTime now) {
    final airDate = _episodeAirDate(episode);
    return airDate == null || !airDate.isAfter(now);
  }

  static bool _isEpisodeReleased(Episode episode, DateTime now) {
    final raw = episode.airDate;
    final airDate =
        raw == null || raw.trim().isEmpty ? null : DateTime.tryParse(raw);
    return airDate == null || !airDate.isAfter(now);
  }

  static Set<String> _watchedEpisodeKeys(
    List<TrackingUnit> trackedUnits,
    List<WatchSession> watchSessions,
  ) {
    final keys = <String>{};
    for (final unit in trackedUnits) {
      if (unit.isDeleted || unit.unitType != TrackingUnitType.episode) {
        continue;
      }
      final seasonNumber = unit.seasonNumber;
      final episodeNumber = unit.episodeNumber;
      if (seasonNumber == null || episodeNumber == null) {
        continue;
      }
      keys.add(
        _episodeKey(
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        ),
      );
    }
    for (final session in watchSessions) {
      if (!session.isEpisodeSession ||
          session.seasonNumber == null ||
          session.episodeNumber == null) {
        continue;
      }
      keys.add(
        _episodeKey(
          seasonNumber: session.seasonNumber!,
          episodeNumber: session.episodeNumber!,
        ),
      );
    }
    return keys;
  }

  static Map<String, List<WatchSession>> _watchedEpisodeMap(
    List<TrackingUnit> trackedUnits,
    List<WatchSession> watchSessions,
  ) {
    final map = <String, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (!session.isEpisodeSession ||
          session.seasonNumber == null ||
          session.episodeNumber == null) {
        continue;
      }
      final key = _episodeKey(
        seasonNumber: session.seasonNumber!,
        episodeNumber: session.episodeNumber!,
      );
      map.putIfAbsent(key, () => <WatchSession>[]).add(session);
    }
    for (final unit in trackedUnits) {
      if (unit.isDeleted || unit.unitType != TrackingUnitType.episode) {
        continue;
      }
      final seasonNumber = unit.seasonNumber;
      final episodeNumber = unit.episodeNumber;
      if (seasonNumber == null || episodeNumber == null) {
        continue;
      }
      final key = _episodeKey(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      map.putIfAbsent(key, () => <WatchSession>[]);
    }
    return map;
  }

  static String _episodeKey({
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return '$seasonNumber:$episodeNumber';
  }

  static String _episodeKeyForSeasonEpisode(_SeasonEpisode episode) {
    return _episodeKey(
      seasonNumber: episode.season.seasonNumber,
      episodeNumber: episode.episode.episodeNumber,
    );
  }

  static DateTime? _episodeAirDate(_SeasonEpisode episode) {
    final raw = episode.episode.airDate;
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static DateTime? _parseEpisodeDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static int? _firstRegularSeasonNumber(List<Season> seasons) {
    for (final season in seasons) {
      if (season.seasonNumber > 0) {
        return season.seasonNumber;
      }
    }
    return seasons.isEmpty ? null : seasons.first.seasonNumber;
  }

  static WatchSession? _latestWatchSession(List<WatchSession> watchSessions) {
    final active = watchSessions.where((session) => !session.isDeleted).toList();
    if (active.isEmpty) {
      return null;
    }
    active.sort((a, b) => a.watchedAt.compareTo(b.watchedAt));
    return active.last;
  }

  static TrackingUnit? _latestWatchedTrackingUnit(
    List<TrackingUnit> trackedUnits,
  ) {
    final active = trackedUnits
        .where(
          (unit) =>
              !unit.isDeleted && unit.unitType == TrackingUnitType.episode,
        )
        .toList();
    if (active.isEmpty) {
      return null;
    }
    active.sort((a, b) {
      final left = a.completedAt;
      final right = b.completedAt;
      return left.compareTo(right);
    });
    return active.last;
  }

  static WatchSession? _latestWatchSessionForSeason(
    int seasonNumber,
    List<WatchSession> watchSessions,
  ) {
    final matching = watchSessions
        .where(
          (session) =>
              !session.isDeleted &&
              session.isEpisodeSession &&
              session.seasonNumber == seasonNumber,
        )
        .toList();
    if (matching.isEmpty) {
      return null;
    }
    matching.sort((a, b) => a.watchedAt.compareTo(b.watchedAt));
    return matching.last;
  }

  static String _seasonStatusLabel({
    required Season season,
    required int watchedCount,
    required int releaseCount,
    required int totalCount,
    required DateTime referenceNow,
  }) {
    if (watchedCount == 0) {
      return releaseCount == 0 ? 'Upcoming' : 'Not started';
    }
    if (watchedCount >= releaseCount && releaseCount >= totalCount) {
      return 'Finished';
    }
    if (watchedCount >= releaseCount) {
      return 'Caught up';
    }
    if (releaseCount == 0) {
      return 'Upcoming';
    }
    return 'Watching';
  }

  static VideoEpisodeIdentity? _lastWatchedEpisode(
    List<_SeasonEpisode> episodes, {
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
  }) {
    final watchedKeys = _watchedEpisodeKeys(trackedUnits, watchSessions);
    for (final episode in episodes.reversed) {
      if (watchedKeys.contains(_episodeKeyForSeasonEpisode(episode))) {
        return VideoEpisodeIdentity(
          seasonNumber: episode.season.seasonNumber,
          episodeNumber: episode.episode.episodeNumber,
          title: episode.episode.title,
          airDate: _parseEpisodeDate(episode.episode.airDate),
          runtimeMinutes: episode.episode.runtimeMinutes,
        );
      }
    }
    return null;
  }

  static VideoEpisodeIdentity? _nextEpisode(
    List<_SeasonEpisode> episodes,
    Set<String> watchedKeys,
    DateTime referenceNow,
  ) {
    for (final episode in episodes) {
      final key = _episodeKeyForSeasonEpisode(episode);
      if (watchedKeys.contains(key)) {
        continue;
      }
      if (!_isReleased(episode, referenceNow)) {
        continue;
      }
      return VideoEpisodeIdentity(
        seasonNumber: episode.season.seasonNumber,
        episodeNumber: episode.episode.episodeNumber,
        title: episode.episode.title,
        airDate: _parseEpisodeDate(episode.episode.airDate),
        runtimeMinutes: episode.episode.runtimeMinutes,
      );
    }
    return null;
  }
}

class _SeasonEpisode {
  const _SeasonEpisode(this.season, this.episode);

  final Season season;
  final Episode episode;
}
