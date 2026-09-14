import 'package:flutter/foundation.dart';

import 'music_ids.dart';

@immutable
final class MusicTrack {
  MusicTrack({
    required this.id,
    required this.mediumId,
    required this.position,
    required this.title,
    this.composition,
    this.durationMs,
    this.offsetMs,
    this.bitrateKbps,
    this.fileSizeBytes,
    this.trackHash,
    this.instrument,
    this.metadataJson = const <String, dynamic>{},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicTrackId id;
  final MusicMediumId mediumId;
  final String position;
  final String title;
  final String? composition;
  final int? durationMs;
  final int? offsetMs;
  final int? bitrateKbps;
  final int? fileSizeBytes;
  final String? trackHash;
  final String? instrument;
  final Map<String, dynamic> metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get durationSeconds =>
      durationMs == null ? null : (durationMs! / 1000).round();

  factory MusicTrack.fromJson(Map<String, dynamic> json) => MusicTrack(
        id: MusicTrackId(_text(json['id']) ?? ''),
        mediumId: MusicMediumId(_text(json['medium_id']) ?? ''),
        position: _text(json['position']) ?? '',
        title: _text(json['title']) ?? 'Track',
        composition: _text(json['composition']),
        durationMs: _int(json['duration_ms']),
        offsetMs: _int(json['offset_ms']),
        bitrateKbps: _int(json['bitrate_kbps']),
        fileSizeBytes: _int(json['file_size_bytes']),
        trackHash: _text(json['track_hash']),
        instrument: _text(json['instrument']),
        metadataJson: _metadata(json),
        createdAt: _dateTime(json['created_at']),
        updatedAt: _dateTime(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        ...metadataJson,
        'id': id.value,
        'kind': 'music',
        'medium_id': mediumId.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'metadata_json': metadataJson,
        'position': position,
        'title': title,
        if (composition != null) 'composition': composition,
        if (durationMs != null) 'duration_ms': durationMs,
        if (offsetMs != null) 'offset_ms': offsetMs,
        if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
        if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
        if (trackHash != null) 'track_hash': trackHash,
        if (instrument != null) 'instrument': instrument,
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

Map<String, dynamic> _metadata(Map<String, dynamic> json) {
  final value = json['metadata_json'];
  return value is Map
      ? Map<String, dynamic>.from(value)
      : Map<String, dynamic>.from(json);
}
