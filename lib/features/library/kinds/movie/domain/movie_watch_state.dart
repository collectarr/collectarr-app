import 'package:flutter/foundation.dart';

/// Movie-specific watch state kept separate from owned-copy state.
@immutable
final class MovieWatchState {
  const MovieWatchState({
    this.rating,
    this.status,
    this.startedAt,
    this.finishedAt,
    this.timesCompleted = 0,
  });

  final int? rating;
  final String? status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int timesCompleted;

  bool get isStarted => startedAt != null;
  bool get isFinished => finishedAt != null;

  Map<String, dynamic> toJson() => {
        if (rating != null) 'rating': rating,
        if (status != null) 'status': status,
        if (startedAt != null)
          'started_at': startedAt!.toUtc().toIso8601String(),
        if (finishedAt != null)
          'finished_at': finishedAt!.toUtc().toIso8601String(),
        'times_completed': timesCompleted,
      };

  factory MovieWatchState.fromJson(Map<String, dynamic> json) {
    return MovieWatchState(
      rating: _intValue(json['rating']),
      status: _textValue(json['status']),
      startedAt: _dateValue(json['started_at']),
      finishedAt: _dateValue(json['finished_at']),
      timesCompleted: _intValue(json['times_completed']) ?? 0,
    );
  }

  MovieWatchState copyWith({
    Object? rating = _unset,
    Object? status = _unset,
    Object? startedAt = _unset,
    Object? finishedAt = _unset,
    int? timesCompleted,
  }) {
    return MovieWatchState(
      rating: identical(rating, _unset) ? this.rating : rating as int?,
      status: identical(status, _unset) ? this.status : status as String?,
      startedAt: identical(startedAt, _unset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _unset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieWatchState &&
          rating == other.rating &&
          status == other.status &&
          startedAt?.toUtc() == other.startedAt?.toUtc() &&
          finishedAt?.toUtc() == other.finishedAt?.toUtc() &&
          timesCompleted == other.timesCompleted;

  @override
  int get hashCode => Object.hash(
        rating,
        status,
        startedAt?.toUtc(),
        finishedAt?.toUtc(),
        timesCompleted,
      );
}

const Object _unset = Object();

String? _textValue(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateValue(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '');
