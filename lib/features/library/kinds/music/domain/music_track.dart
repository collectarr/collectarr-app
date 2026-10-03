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

  factory MusicTrack.fromJson(Map<String, dynamic> json) => MusicTrack(
        id: MusicTrackId(_text(json['id']) ?? ''),
        position: _text(json['position']) ?? '',
        title: _text(json['title']) ?? 'Track',
        positionOrder: _int(json['position_order']),
        artist: _text(json['artist']),
        composition: _text(json['composition']),
        durationMs: _int(json['duration_ms']),
        offsetMs: _int(json['offset_ms']),
        bitrateKbps: _int(json['bitrate_kbps']),
        fileSizeBytes: _int(json['file_size_bytes']),
        trackHash: _text(json['track_hash']),
        instrument: _text(json['instrument']),
        isHeader: json['is_header'] == true || json['entry_type'] == 'header',
        indentLevel: _int(json['indent_level']) ?? 0,
        parentHeaderId: _text(json['parent_header_id']),
        createdAt: _dateTime(json['created_at']),
        updatedAt: _dateTime(json['updated_at']),
      );

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

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');

DateTime _dateTime(Object? value) =>
    _date(value) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
