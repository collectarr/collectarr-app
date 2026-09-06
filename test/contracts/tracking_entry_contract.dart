import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

import 'contract_test_helpers.dart';

void defineTrackingEntryContract({
  required String name,
  required TrackingEntry Function() create,
}) {
  defineTypedContract<TrackingEntry>(
    name: '$name tracking persistence contract',
    create: create,
    checks: [
      (entry) {
        expectSame(
          entry.status,
          MediaTrackingStatus.inProgress,
          '$name tracking status must be typed',
        );
        expectSame(
          entry.progressCurrent,
          3,
          '$name tracking progress current must be preserved',
        );
        expectSame(
          entry.progressTotal,
          10,
          '$name tracking progress total must be preserved',
        );
        expectSame(
          entry.mediaTracking.progressRatio,
          0.3,
          '$name tracking progress ratio must be derived',
        );
        expectSame(
          entry.mediaTracking.statusLabel,
          'In progress',
          '$name tracking status label must be shared',
        );

        final restored = TrackingEntry.fromJson({
          ...entry.toSyncPayload(),
          'id': entry.id,
          'updated_at': entry.updatedAt.toIso8601String(),
          'deleted_at': entry.deletedAt?.toIso8601String(),
        });
        expectSame(
          restored.status,
          entry.status,
          '$name tracking status must round-trip',
        );
        expectSame(
          restored.progressCurrent,
          entry.progressCurrent,
          '$name tracking progress current must round-trip',
        );
        expectSame(
          restored.progressTotal,
          entry.progressTotal,
          '$name tracking progress total must round-trip',
        );
        expectSame(
          restored.timesCompleted,
          entry.timesCompleted,
          '$name tracking completion count must round-trip',
        );

        final genericFallback = TrackingEntry.fromJson({
          ...entry.toSyncPayload(),
          'id': entry.id,
          'season_number': 9,
          'episode_number': 9,
          'episode_ratings': {'9:9': 10},
          'updated_at': entry.updatedAt.toIso8601String(),
          'deleted_at': entry.deletedAt?.toIso8601String(),
        });
        expectSame(
          genericFallback.seasonNumber,
          null,
          '$name generic tracking fallback must not parse season coordinates',
        );
        expectSame(
          genericFallback.episodeNumber,
          null,
          '$name generic tracking fallback must not parse episode coordinates',
        );
        expectSame(
          genericFallback.episodeRatings,
          const <String, int>{},
          '$name generic tracking fallback must not parse episode ratings',
        );

        final completed = entry.copyWith(
          status: MediaTrackingStatus.completed,
          finishedAt: DateTime.utc(2026, 3, 4),
          timesCompleted: (entry.timesCompleted ?? 0) + 1,
        );
        expectSame(
          completed.status,
          MediaTrackingStatus.completed,
          '$name completed tracking status must be representable',
        );
        expectSame(
          completed.finishedAt,
          DateTime.utc(2026, 3, 4),
          '$name completed tracking timestamp must be preserved',
        );
        expectSame(
          completed.timesCompleted,
          (entry.timesCompleted ?? 0) + 1,
          '$name completion count must increment explicitly',
        );

        final reset = entry.copyWith(
          status: MediaTrackingStatus.none,
          progressCurrent: null,
          progressTotal: null,
          finishedAt: null,
        );
        expectSame(
          reset.status,
          MediaTrackingStatus.none,
          '$name tracking reset must clear the status',
        );
        expectSame(
          reset.statusStorageValue,
          null,
          '$name tracking reset must clear stored status',
        );
        expectSame(
          reset.progressCurrent,
          null,
          '$name tracking reset must clear current progress',
        );
        expectSame(
          reset.progressTotal,
          null,
          '$name tracking reset must clear total progress',
        );
        expectSame(
          reset.finishedAt,
          null,
          '$name tracking reset must clear completion time',
        );
      },
    ],
  );
}
