import 'package:flutter/foundation.dart';

/// Tracking values collected by Add and persisted as a typed tracking entry.
///
/// This is deliberately separate from [LibraryAddCommonDraft]: Add's
/// collection fields and progress state have different persistence owners.
@immutable
class LibraryAddTrackingDraft {
  const LibraryAddTrackingDraft({
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
    this.notes,
  });

  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? notes;

  LibraryAddTrackingDraft copyWith({
    Object? rating = _unchangedTrackingValue,
    Object? readStatus = _unchangedTrackingValue,
    Object? startedAt = _unchangedTrackingValue,
    Object? finishedAt = _unchangedTrackingValue,
    Object? notes = _unchangedTrackingValue,
  }) {
    return LibraryAddTrackingDraft(
      rating: identical(rating, _unchangedTrackingValue)
          ? this.rating
          : rating as int?,
      readStatus: identical(readStatus, _unchangedTrackingValue)
          ? this.readStatus
          : readStatus as String?,
      startedAt: identical(startedAt, _unchangedTrackingValue)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _unchangedTrackingValue)
          ? this.finishedAt
          : finishedAt as DateTime?,
      notes: identical(notes, _unchangedTrackingValue)
          ? this.notes
          : notes as String?,
    );
  }
}

const Object _unchangedTrackingValue = Object();
