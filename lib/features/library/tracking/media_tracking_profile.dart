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

/// Structural tracking vocabulary supplied by each owning kind.
class MediaTrackingProfile {
  const MediaTrackingProfile({
    required this.name,
    required this.options,
    this.supportsEpisodeCoordinates = false,
  });

  final String name;
  final List<MediaTrackingOption> options;

  /// A compatibility presentation capability for the current editor host.
  /// TV/Anime profiles opt in; the owning kind remains responsible for the
  /// actual season/episode state and persistence.
  final bool supportsEpisodeCoordinates;

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
