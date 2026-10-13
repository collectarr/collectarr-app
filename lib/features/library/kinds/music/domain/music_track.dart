import 'package:flutter/foundation.dart';

import 'music_ids.dart';

@immutable
final class MusicTrack {
  MusicTrack({
    required this.id,
    required this.position,
    required this.title,
    this.positionOrder,
    this.artist,
    this.composition,
    this.durationMs,
    this.offsetMs,
    this.bitrateKbps,
    this.fileSizeBytes,
    this.trackHash,
    this.instrument,
    this.isHeader = false,
    this.indentLevel = 0,
    this.parentHeaderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicTrackId id;
  final String position;
  final String title;

  /// Numeric catalog order, independent of display positions such as A1/B2.
  final int? positionOrder;

  /// Track-level artist credit. The Music mapper reads it at the Core
  /// transport boundary and preserves it in Music-entry persistence.
  final String? artist;
  final String? composition;
  final int? durationMs;
  final int? offsetMs;
  final int? bitrateKbps;
  final int? fileSizeBytes;
  final String? trackHash;
  final String? instrument;

  /// A structural track-list header authored by the user.
  ///
  /// Headers remain in the ordered Music track list but are excluded from
  /// playable track counts and duration aggregates.
  final bool isHeader;
  final int indentLevel;
  final String? parentHeaderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get durationSeconds =>
      durationMs == null ? null : (durationMs! / 1000).round();

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    const fields = {
      'id',
      'created_at',
      'updated_at',
      'position',
      'title',
      'position_order',
      'artist',
      'composition',
      'duration_ms',
      'offset_ms',
      'bitrate_kbps',
      'file_size_bytes',
      'track_hash',
      'instrument',
      'is_header',
      'indent_level',
      'parent_header_id',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music track field "${unsupported.first}".',
      );
    }
    return MusicTrack(
      id: MusicTrackId(_requiredText(json['id'], 'id')),
      position: _requiredText(json['position'], 'position', allowEmpty: true),
      title: _requiredText(json['title'], 'title'),
      positionOrder: _optionalInt(json['position_order'], 'position_order'),
      artist: _optionalText(json['artist'], 'artist'),
      composition: _optionalText(json['composition'], 'composition'),
      durationMs: _optionalInt(json['duration_ms'], 'duration_ms'),
      offsetMs: _optionalInt(json['offset_ms'], 'offset_ms'),
      bitrateKbps: _optionalInt(json['bitrate_kbps'], 'bitrate_kbps'),
      fileSizeBytes: _optionalInt(json['file_size_bytes'], 'file_size_bytes'),
      trackHash: _optionalText(json['track_hash'], 'track_hash'),
      instrument: _optionalText(json['instrument'], 'instrument'),
      isHeader: _requiredBool(json['is_header'], 'is_header'),
      indentLevel: _requiredIndentLevel(json['indent_level']),
      parentHeaderId:
          _optionalText(json['parent_header_id'], 'parent_header_id'),
      createdAt: _optionalDateTime(json['created_at'], 'created_at'),
      updatedAt: _optionalDateTime(json['updated_at'], 'updated_at'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'position': position,
        'title': title,
        if (positionOrder != null) 'position_order': positionOrder,
        if (artist != null) 'artist': artist,
        if (composition != null) 'composition': composition,
        if (durationMs != null) 'duration_ms': durationMs,
        if (offsetMs != null) 'offset_ms': offsetMs,
        if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
        if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
        if (trackHash != null) 'track_hash': trackHash,
        if (instrument != null) 'instrument': instrument,
        'is_header': isHeader,
        'indent_level': indentLevel,
        if (parentHeaderId != null) 'parent_header_id': parentHeaderId,
      };
}

String _requiredText(Object? value, String field, {bool allowEmpty = false}) {
  if (value is! String ||
      (!allowEmpty && value.isEmpty) ||
      value != value.trim()) {
    throw FormatException('Music track $field must be trimmed text.');
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}

int? _optionalInt(Object? value, String field) {
  if (value == null) return null;
  return _requiredInt(value, field);
}

int _requiredInt(Object? value, String field) {
  if (value is! int || value < 0) {
    throw FormatException('Music track $field must be a non-negative integer.');
  }
  return value;
}

int _requiredIndentLevel(Object? value) {
  final indentLevel = _requiredInt(value, 'indent_level');
  if (indentLevel > 8) {
    throw const FormatException('Music track indent_level must be <= 8.');
  }
  return indentLevel;
}

bool _requiredBool(Object? value, String field) {
  if (value is! bool) {
    throw FormatException('Music track $field must be boolean.');
  }
  return value;
}

DateTime? _optionalDateTime(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Music track $field must be an ISO date-time.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !value.contains('T') || value != value.trim()) {
    throw FormatException('Music track $field must be an ISO date-time.');
  }
  return parsed.toUtc();
}
