import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_track.dart';

@immutable
final class MusicMedia {
  const MusicMedia({
    required this.id,
    required this.releaseId,
    required this.mediaNumber,
    this.mediaCondition,
    this.mediaType,
    this.packaging,
    this.rpm,
    this.soundType,
    this.spars,
    this.title,
    this.trackCount,
    this.tracks = const [],
    this.vinylColor,
    this.vinylWeight,
    this.rawPayload = const <String, dynamic>{},
  });

  final MusicMediaId id;
  final MusicReleaseId releaseId;
  final int mediaNumber;
  final String? mediaCondition;
  final String? mediaType;
  final String? packaging;
  final int? rpm;
  final String? soundType;
  final String? spars;
  final String? title;
  final int? trackCount;
  final List<MusicTrack> tracks;
  final String? vinylColor;
  final String? vinylWeight;
  final Map<String, dynamic> rawPayload;

  int? get discNumber => mediaNumber;
  String? get discName => title;
  String? get discFormat => mediaType;

  factory MusicMedia.fromJson(Map<String, dynamic> json) {
    final tracks =
        _maps(json['tracks']).map(MusicTrack.fromJson).toList(growable: false);
    return MusicMedia(
      id: MusicMediaId(_text(json['id']) ?? ''),
      releaseId: MusicReleaseId(_text(json['release_id']) ?? ''),
      mediaNumber: _int(json['media_number']) ?? 0,
      mediaCondition: _text(json['media_condition']),
      mediaType: _text(json['media_type']),
      packaging: _text(json['packaging']),
      rpm: _int(json['rpm']),
      soundType: _text(json['sound_type']),
      spars: _text(json['spars']),
      title: _text(json['title']),
      trackCount:
          _int(json['track_count']) ?? (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
      vinylColor: _text(json['vinyl_color']),
      vinylWeight: _text(json['vinyl_weight']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'music',
        'release_id': releaseId.value,
        'media_number': mediaNumber,
        if (mediaCondition != null) 'media_condition': mediaCondition,
        if (mediaType != null) 'media_type': mediaType,
        if (packaging != null) 'packaging': packaging,
        if (rpm != null) 'rpm': rpm,
        if (soundType != null) 'sound_type': soundType,
        if (spars != null) 'spars': spars,
        if (title != null) 'title': title,
        if (trackCount != null) 'track_count': trackCount,
        'tracks': tracks.map((track) => track.toJson()).toList(),
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
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

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}
