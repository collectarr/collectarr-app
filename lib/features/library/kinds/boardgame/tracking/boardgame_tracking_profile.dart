import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

const boardGameTrackingProfile = MediaTrackingProfile(
  name: 'Board Games',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Want to play',
      storageValue: 'Want to play',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Playing',
      storageValue: 'Playing',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Played',
      storageValue: 'Played',
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
      label: 'Replay',
      storageValue: 'Replay',
    ),
  ],
);
