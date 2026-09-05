import 'package:flutter/foundation.dart';

/// Comic-specific reading progress kept separate from owned-copy state.
@immutable
final class ComicReadingState {
  const ComicReadingState({
    this.rating,
    this.status,
    this.startedAt,
    this.finishedAt,
  });

  final int? rating;
  final String? status;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  bool get isStarted => startedAt != null;
  bool get isFinished => finishedAt != null;

  Map<String, dynamic> toJson() => {
        if (rating != null) 'rating': rating,
        if (status != null) 'status': status,
        if (startedAt != null)
          'started_at': startedAt!.toUtc().toIso8601String(),
        if (finishedAt != null)
          'finished_at': finishedAt!.toUtc().toIso8601String(),
      };

  factory ComicReadingState.fromJson(Map<String, dynamic> json) {
    return ComicReadingState(
      rating: (json['rating'] as num?)?.toInt(),
      status: json['status'] as String?,
      startedAt: _parseDate(json['started_at']),
      finishedAt: _parseDate(json['finished_at']),
    );
  }

  ComicReadingState copyWith({
    Object? rating = _readingUnset,
    Object? status = _readingUnset,
    Object? startedAt = _readingUnset,
    Object? finishedAt = _readingUnset,
  }) {
    return ComicReadingState(
      rating: identical(rating, _readingUnset) ? this.rating : rating as int?,
      status:
          identical(status, _readingUnset) ? this.status : status as String?,
      startedAt: identical(startedAt, _readingUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _readingUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicReadingState &&
          rating == other.rating &&
          status == other.status &&
          startedAt == other.startedAt &&
          finishedAt == other.finishedAt;

  @override
  int get hashCode => Object.hash(rating, status, startedAt, finishedAt);
}

const Object _readingUnset = Object();

DateTime? _parseDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
