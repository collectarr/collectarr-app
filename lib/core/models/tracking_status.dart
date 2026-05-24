enum MediaTrackingStatus {
  none('Not tracked'),
  planned('Planned'),
  inProgress('In progress'),
  completed('Completed'),
  paused('Paused'),
  dropped('Dropped'),
  repeating('Repeating');

  const MediaTrackingStatus(this.label);

  final String label;
}

MediaTrackingStatus? mediaTrackingStatusFromValue(Object? value) {
  if (value is MediaTrackingStatus) {
    return value;
  }
  if (value is String?) {
    return mediaTrackingStatusFromString(value);
  }
  return null;
}

MediaTrackingStatus? mediaTrackingStatusFromString(String? value) {
  return switch (value?.trim().toLowerCase()) {
    null || '' => null,
    'planned' ||
    'plan to read' ||
    'plan to watch' ||
    'backlog' ||
    'want to listen' =>
      MediaTrackingStatus.planned,
    'reading' ||
    'watching' ||
    'playing' ||
    'listening' ||
    'in progress' =>
      MediaTrackingStatus.inProgress,
    'read' ||
    'watched' ||
    'played' ||
    'completed' ||
    'finished' ||
    'listened' =>
      MediaTrackingStatus.completed,
    'paused' || 'on hold' => MediaTrackingStatus.paused,
    'dropped' || 'abandoned' => MediaTrackingStatus.dropped,
    'rereading' ||
    'rewatching' ||
    'replaying' ||
    'repeating' ||
    'on repeat' =>
      MediaTrackingStatus.repeating,
    _ => null,
  };
}

String? mediaTrackingStatusToStorageValue(MediaTrackingStatus? status) {
  return switch (status) {
    null => null,
    MediaTrackingStatus.none => null,
    MediaTrackingStatus.planned => 'Planned',
    MediaTrackingStatus.inProgress => 'In progress',
    MediaTrackingStatus.completed => 'Completed',
    MediaTrackingStatus.paused => 'Paused',
    MediaTrackingStatus.dropped => 'Dropped',
    MediaTrackingStatus.repeating => 'Repeating',
  };
}

String trackingStatusLabel(Object? value, {String unknownLabel = 'Unknown'}) {
  return mediaTrackingStatusFromValue(value)?.label ?? unknownLabel;
}