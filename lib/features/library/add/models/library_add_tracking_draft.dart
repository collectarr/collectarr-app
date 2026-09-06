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
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? notes,
  }) {
    return LibraryAddTrackingDraft(
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      notes: notes ?? this.notes,
    );
  }
}
