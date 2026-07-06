import 'dart:math' as math;

import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_identity.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';

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
      keys.add(_episodeKey(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ));
    }
    for (final session in watchSessions) {
      if (!session.isEpisodeSession || session.isDeleted) {
        continue;
      }
      if (session.seasonNumber == null || session.episodeNumber == null) {
        continue;
      }
      keys.add(_episodeKey(
        seasonNumber: session.seasonNumber!,
        episodeNumber: session.episodeNumber!,
      ));
    }
    return keys;
  }

  static Map<String, List<WatchSession>> _watchedEpisodeMap(
    List<TrackingUnit> trackedUnits,
    List<WatchSession> watchSessions,
  ) {
    final map = <String, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (!session.isEpisodeSession || session.isDeleted) {
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
      map.putIfAbsent(key, () => <WatchSession>[]).add(
            WatchSession(
              id: unit.id,
              targetRef: unit.targetRef,
              watchedAt: unit.completedAt,
              updatedAt: unit.updatedAt,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
            ),
          );
    }
    for (final sessions in map.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    return map;
  }

  static VideoEpisodeIdentity? _lastWatchedEpisode(
    List<_SeasonEpisode> episodes, {
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
  }) {
    final latestSession = _latestWatchSession(watchSessions);
    if (latestSession != null &&
        latestSession.seasonNumber != null &&
        latestSession.episodeNumber != null) {
      return _lookupEpisode(
        episodes,
        latestSession.seasonNumber!,
        latestSession.episodeNumber!,
      );
    }
    final latestUnit = _latestWatchedTrackingUnit(trackedUnits);
    if (latestUnit != null &&
        latestUnit.seasonNumber != null &&
        latestUnit.episodeNumber != null) {
      return _lookupEpisode(
        episodes,
        latestUnit.seasonNumber!,
        latestUnit.episodeNumber!,
      );
    }
    return null;
  }

  static WatchSession? _latestWatchSession(List<WatchSession> watchSessions) {
    final sessions = watchSessions.where((session) => session.isEpisodeSession);
    WatchSession? latest;
    for (final session in sessions) {
      if (latest == null || session.watchedAt.isAfter(latest.watchedAt)) {
        latest = session;
      }
    }
    return latest;
  }

  static TrackingUnit? _latestWatchedTrackingUnit(List<TrackingUnit> trackedUnits) {
    TrackingUnit? latest;
    for (final unit in trackedUnits) {
      if (unit.isDeleted || unit.unitType != TrackingUnitType.episode) {
        continue;
      }
      if (latest == null || unit.completedAt.isAfter(latest.completedAt)) {
        latest = unit;
      }
    }
    return latest;
  }

  static WatchSession? _latestWatchSessionForSeason(
    int seasonNumber,
    List<WatchSession> watchSessions,
  ) {
    WatchSession? latest;
    for (final session in watchSessions) {
      if (!session.isEpisodeSession || session.seasonNumber != seasonNumber) {
        continue;
      }
      if (latest == null || session.watchedAt.isAfter(latest.watchedAt)) {
        latest = session;
      }
    }
    return latest;
  }

  static VideoEpisodeIdentity? _lookupEpisode(
    List<_SeasonEpisode> episodes,
    int seasonNumber,
    int episodeNumber,
  ) {
    for (final item in episodes) {
      if (item.season.seasonNumber == seasonNumber &&
          item.episode.episodeNumber == episodeNumber) {
        return VideoEpisodeIdentity(
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          title: item.episode.title,
          airDate: _episodeAirDate(item),
          runtimeMinutes: item.episode.runtimeMinutes,
        );
      }
    }
    return VideoEpisodeIdentity(
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
  }

  static VideoEpisodeIdentity? _nextEpisode(
    List<_SeasonEpisode> episodes,
    Set<String> watchedKeys,
    DateTime now,
  ) {
    for (final item in episodes) {
      final key = _episodeKeyForSeasonEpisode(item);
      if (watchedKeys.contains(key)) {
        continue;
      }
      if (_isReleased(item, now)) {
        return VideoEpisodeIdentity(
          seasonNumber: item.season.seasonNumber,
          episodeNumber: item.episode.episodeNumber,
          title: item.episode.title,
          airDate: _episodeAirDate(item),
          runtimeMinutes: item.episode.runtimeMinutes,
        );
      }
    }
    return null;
  }

  static int? _firstRegularSeasonNumber(List<Season> seasons) {
    for (final season in seasons) {
      if (season.seasonNumber > 0) {
        return season.seasonNumber;
      }
    }
    return seasons.isEmpty ? null : seasons.first.seasonNumber;
  }

  static String _seasonStatusLabel({
    required Season season,
    required int watchedCount,
    required int releaseCount,
    required int totalCount,
    required DateTime referenceNow,
  }) {
    final hasFutureEpisodes = season.episodes.any(
      (episode) =>
          _episodeAirDate(_SeasonEpisode(season, episode))?.isAfter(referenceNow) ==
          true,
    );
    if (watchedCount == 0) {
      return hasFutureEpisodes && releaseCount == 0 ? 'Upcoming' : 'Not started';
    }
    if (releaseCount > 0 && watchedCount >= releaseCount) {
      return hasFutureEpisodes && releaseCount < totalCount
          ? 'Caught up'
          : 'Completed';
    }
    return 'In progress';
  }
}

class _SeasonEpisode {
  const _SeasonEpisode(this.season, this.episode);

  final Season season;
  final Episode episode;
}

String _episodeKey({
  required int seasonNumber,
  required int episodeNumber,
}) {
  return '$seasonNumber:$episodeNumber';
}

String _episodeKeyForSeasonEpisode(_SeasonEpisode episode) {
  return _episodeKey(
    seasonNumber: episode.season.seasonNumber,
    episodeNumber: episode.episode.episodeNumber,
  );
}

DateTime? _episodeAirDate(_SeasonEpisode episode) {
  final raw = episode.episode.airDate;
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

DateTime? _parseEpisodeDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
