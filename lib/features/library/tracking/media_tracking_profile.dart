import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

class MediaTrackingOption {
  const MediaTrackingOption({
    required this.status,
    required this.label,
    required this.storageValue,
  });

  final MediaTrackingStatus status;
  final String label;
  final String storageValue;
}

class MediaTrackingProfile {
  const MediaTrackingProfile({
    required this.name,
    required this.options,
  });

  final String name;
  final List<MediaTrackingOption> options;

  String? normalizeStorageValue(String? value) {
    final status = mediaTrackingStatusFromString(value);
    for (final option in options) {
      if (option.status == status) {
        return option.storageValue;
      }
    }
    return null;
  }
}

const comicTrackingProfile = MediaTrackingProfile(
  name: 'Comics',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Plan to read',
      storageValue: 'Plan to read',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Reading',
      storageValue: 'Reading',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Read',
      storageValue: 'Read',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.paused,
      label: 'On hold',
      storageValue: 'On hold',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.dropped,
      label: 'Dropped',
      storageValue: 'Dropped',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.repeating,
      label: 'Rereading',
      storageValue: 'Rereading',
    ),
  ],
);

const gameTrackingProfile = MediaTrackingProfile(
  name: 'Games',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Backlog',
      storageValue: 'Backlog',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Playing',
      storageValue: 'Playing',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Completed',
      storageValue: 'Completed',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.paused,
      label: 'On hold',
      storageValue: 'On hold',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.dropped,
      label: 'Dropped',
      storageValue: 'Dropped',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.repeating,
      label: 'Replaying',
      storageValue: 'Replaying',
    ),
  ],
);

const readingTrackingProfile = MediaTrackingProfile(
  name: 'Reading',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Plan to read',
      storageValue: 'Plan to read',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Reading',
      storageValue: 'Reading',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Read',
      storageValue: 'Read',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.paused,
      label: 'On hold',
      storageValue: 'On hold',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.dropped,
      label: 'Dropped',
      storageValue: 'Dropped',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.repeating,
      label: 'Rereading',
      storageValue: 'Rereading',
    ),
  ],
);

const videoTrackingProfile = MediaTrackingProfile(
  name: 'Video',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Plan to watch',
      storageValue: 'Plan to watch',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Watching',
      storageValue: 'Watching',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Watched',
      storageValue: 'Watched',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.paused,
      label: 'On hold',
      storageValue: 'On hold',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.dropped,
      label: 'Dropped',
      storageValue: 'Dropped',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.repeating,
      label: 'Rewatching',
      storageValue: 'Rewatching',
    ),
  ],
);
