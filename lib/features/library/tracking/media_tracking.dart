import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';

enum MediaTrackingStatus {
  none,
  planned,
  inProgress,
  completed,
  paused,
  dropped,
  repeating
}

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
      status: mediaTrackingStatusFromString(readStatus),
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
      status: mediaTrackingStatusFromString(status),
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

MediaTrackingStatus mediaTrackingStatusFromString(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'planned' ||
    'plan to read' ||
    'plan to watch' ||
    'backlog' =>
      MediaTrackingStatus.planned,
    'reading' ||
    'watching' ||
    'playing' ||
    'in progress' =>
      MediaTrackingStatus.inProgress,
    'read' ||
    'watched' ||
    'played' ||
    'completed' ||
    'finished' =>
      MediaTrackingStatus.completed,
    'paused' || 'on hold' => MediaTrackingStatus.paused,
    'dropped' || 'abandoned' => MediaTrackingStatus.dropped,
    'rereading' ||
    'rewatching' ||
    'replaying' ||
    'repeating' =>
      MediaTrackingStatus.repeating,
    _ => MediaTrackingStatus.none,
  };
}

String mediaTrackingStatusToStorageValue(MediaTrackingStatus status) {
  return switch (status) {
    MediaTrackingStatus.none => '',
    MediaTrackingStatus.planned => 'Planned',
    MediaTrackingStatus.inProgress => 'In progress',
    MediaTrackingStatus.completed => 'Completed',
    MediaTrackingStatus.paused => 'Paused',
    MediaTrackingStatus.dropped => 'Dropped',
    MediaTrackingStatus.repeating => 'Repeating',
  };
}
