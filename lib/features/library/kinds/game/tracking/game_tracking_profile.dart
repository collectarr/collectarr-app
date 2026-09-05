import 'package:collectarr_app/features/library/tracking/media_tracking.dart'
    show MediaTrackingStatus;
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

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
