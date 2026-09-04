import 'package:flutter/foundation.dart';

@immutable
final class MovieTracking {
  const MovieTracking({
    this.status = '',
    this.rating,
    this.notes,
    this.startedAt,
    this.finishedAt,
    this.timesCompleted = 0,
  });

  final String status;
  final int? rating;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int timesCompleted;

  Map<String, dynamic> toJson() => {
        'status': status,
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
        'times_completed': timesCompleted,
      };

  factory MovieTracking.fromJson(Map<String, dynamic> json) {
    return MovieTracking(
      status: json['status']?.toString() ?? '',
      rating: _intValue(json['rating']),
      notes: _textValue(json['notes']),
      startedAt: _dateValue(json['started_at']),
      finishedAt: _dateValue(json['finished_at']),
      timesCompleted: _intValue(json['times_completed']) ?? 0,
    );
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
