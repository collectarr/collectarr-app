import 'package:flutter/foundation.dart';

/// Structural progress values exposed at cross-kind orchestration boundaries.
///
/// The owning kind remains responsible for storing and interpreting these
/// values. This snapshot exists so mixed providers can transfer progress
/// without receiving a common tracking aggregate.
@immutable
final class TrackingProgressSnapshot {
  const TrackingProgressSnapshot({
    this.current,
    this.total,
    this.timesCompleted,
  });

  final int? current;
  final int? total;
  final int? timesCompleted;

  TrackingProgressSnapshot copyWith({
    Object? current = _unset,
    Object? total = _unset,
    Object? timesCompleted = _unset,
  }) {
    return TrackingProgressSnapshot(
      current: identical(current, _unset) ? this.current : current as int?,
      total: identical(total, _unset) ? this.total : total as int?,
      timesCompleted: identical(timesCompleted, _unset)
          ? this.timesCompleted
          : timesCompleted as int?,
    );
  }
}

const Object _unset = Object();
