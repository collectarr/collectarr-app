import 'package:collectarr_app/features/library/tracking/media_tracking.dart'
    show MediaTrackingStatus;
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

const genericTrackingProfile = MediaTrackingProfile(
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
