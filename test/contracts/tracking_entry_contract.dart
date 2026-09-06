import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

import 'contract_test_helpers.dart';

void defineTrackingEntryContract({
  required String name,
  required TrackingEntry Function() create,
  required TrackingEntryCodec codec,
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

        final restored = codec.fromSyncPayload(
          payload: codec.toSyncPayload(entry),
          id: entry.id,
          updatedAt: entry.updatedAt,
          deletedAt: entry.deletedAt,
        );
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

        final lifecyclePayload = entry.toSyncPayload();
        expectSame(
          lifecyclePayload.containsKey('season_number'),
          false,
          '$name common tracking payload must not own season coordinates',
        );
        expectSame(
          lifecyclePayload.containsKey('episode_number'),
          false,
          '$name common tracking payload must not own episode coordinates',
        );
        expectSame(
          lifecyclePayload.containsKey('episode_ratings'),
          false,
          '$name common tracking payload must not own episode ratings',
        );
        expectSame(
          entry.seasonNumber,
          null,
          '$name base tracking fixture must not contain season coordinates',
        );
        expectSame(
          entry.episodeNumber,
          null,
          '$name base tracking fixture must not contain episode coordinates',
        );
        expectSame(
          entry.episodeRatings,
          const <String, int>{},
          '$name base tracking fixture must not contain episode ratings',
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
