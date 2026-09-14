import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';

import 'contract_test_helpers.dart';

void defineTrackingLifecycleContract({
  required String name,
  required TrackingRecord Function() create,
  required TrackingLifecycleCodec codec,
}) {
  defineTypedContract<TrackingRecord>(
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
          entry.progress.current,
          3,
          '$name tracking progress current must be preserved',
        );
        expectSame(
          entry.progress.total,
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
          restored.progress.current,
          entry.progress.current,
          '$name tracking progress current must round-trip',
        );
        expectSame(
          restored.progress.total,
          entry.progress.total,
          '$name tracking progress total must round-trip',
        );
        expectSame(
          restored.progress.timesCompleted,
          entry.progress.timesCompleted,
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

        final completed = entry
            .copyWith(
              status: MediaTrackingStatus.completed,
              finishedAt: DateTime.utc(2026, 3, 4),
            )
            .copyWithProgress(
              entry.progress.copyWith(
                timesCompleted: (entry.progress.timesCompleted ?? 0) + 1,
              ),
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
          completed.progress.timesCompleted,
          (entry.progress.timesCompleted ?? 0) + 1,
          '$name completion count must increment explicitly',
        );

        final reset = entry
            .copyWith(
              status: MediaTrackingStatus.none,
              finishedAt: null,
            )
            .copyWithProgress(
              entry.progress.copyWith(current: null, total: null),
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
          reset.progress.current,
          null,
          '$name tracking reset must clear current progress',
        );
        expectSame(
          reset.progress.total,
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
