import 'package:collectarr_app/features/library/tracking/media_tracking.dart'
    show MediaTrackingStatus;
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

const movieTrackingProfile = MediaTrackingProfile(
  name: 'Movies',
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
