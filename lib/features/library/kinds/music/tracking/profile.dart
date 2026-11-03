import 'package:collectarr_app/features/library/tracking/media_tracking.dart'
    show MediaTrackingStatus;
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

/// Music's album/listening vocabulary, kept separate from generic video/read
/// tracking profiles even though the storage contract is shared.
const musicTrackingProfile = MediaTrackingProfile(
  name: 'Music',
  options: [
    MediaTrackingOption(
      status: MediaTrackingStatus.none,
      label: 'Not tracked',
      storageValue: '',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.planned,
      label: 'Want to listen',
      storageValue: 'Want to listen',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.inProgress,
      label: 'Listening',
      storageValue: 'Listening',
    ),
    MediaTrackingOption(
      status: MediaTrackingStatus.completed,
      label: 'Listened',
      storageValue: 'Listened',
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
      label: 'On repeat',
      storageValue: 'On repeat',
    ),
  ],
);
