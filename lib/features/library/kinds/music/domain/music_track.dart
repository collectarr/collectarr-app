import 'package:flutter/foundation.dart';

import 'music_ids.dart';

@immutable
final class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.mediaId,
    required this.position,
    required this.title,
    this.composition,
    this.durationMs,
    this.instrument,
    this.artist,
    this.rawPayload = const <String, dynamic>{},
  });

  final MusicTrackId id;
  final MusicMediaId mediaId;
  final String position;
  final String title;
  final String? composition;
  final int? durationMs;
  final String? instrument;
  final String? artist;
  final Map<String, dynamic> rawPayload;

  int? get durationSeconds =>
      durationMs == null ? null : (durationMs! / 1000).round();

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: MusicTrackId(_text(json['id']) ?? ''),
      mediaId: MusicMediaId(_text(json['media_id']) ?? ''),
      position: _text(json['position']) ?? '',
      title: _text(json['title']) ?? 'Track',
      composition: _text(json['composition']),
      durationMs: _int(json['duration_ms']),
      instrument: _text(json['instrument']),
      artist: _text(json['artist']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'music',
        'media_id': mediaId.value,
        'position': position,
        'title': title,
        if (composition != null) 'composition': composition,
        if (durationMs != null) 'duration_ms': durationMs,
        if (instrument != null) 'instrument': instrument,
        if (artist != null) 'artist': artist,
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
