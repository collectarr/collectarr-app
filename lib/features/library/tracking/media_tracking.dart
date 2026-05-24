import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

export 'package:collectarr_app/core/models/tracking_status.dart';

class MediaTracking {
  const MediaTracking({
    required this.status,
    this.rating,
    this.startedAt,
    this.completedAt,
    this.lastActivityAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
  });

  final MediaTrackingStatus status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastActivityAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;

  bool get hasProgress =>
      progressCurrent != null && progressTotal != null && progressTotal! > 0;

  double? get progressRatio {
    if (!hasProgress) {
      return null;
    }
    return (progressCurrent! / progressTotal!).clamp(0, 1).toDouble();
  }

  String get statusLabel => switch (status) {
        MediaTrackingStatus.none => 'Not tracked',
        MediaTrackingStatus.planned => 'Planned',
        MediaTrackingStatus.inProgress => 'In progress',
        MediaTrackingStatus.completed => 'Completed',
        MediaTrackingStatus.paused => 'Paused',
        MediaTrackingStatus.dropped => 'Dropped',
        MediaTrackingStatus.repeating => 'Repeating',
      };
}

extension OwnedItemTracking on OwnedItem {
  MediaTracking get mediaTracking {
    return MediaTracking(
      status: mediaTrackingStatusFromString(readStatus) ??
          MediaTrackingStatus.none,
      rating: rating,
      startedAt: startedAt,
      completedAt: finishedAt ?? purchaseDate,
      lastActivityAt: updatedAt,
      notes: personalNotes,
    );
  }
}

extension TrackingEntryMediaTracking on TrackingEntry {
  MediaTracking get mediaTracking {
    return MediaTracking(
      status: status ?? MediaTrackingStatus.none,
      rating: rating,
      startedAt: startedAt,
      completedAt: finishedAt,
      lastActivityAt: updatedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
    );
  }
}
