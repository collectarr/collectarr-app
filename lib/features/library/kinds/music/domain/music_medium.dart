import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_track.dart';

/// Physical or digital medium inside a concrete [MusicRelease].
@immutable
final class MusicMedium {
  MusicMedium({
    required this.id,
    required this.releaseId,
    required this.mediumNumber,
    this.mediumType,
    this.title,
    this.trackCount,
    this.expectedTrackCount,
    this.missingTrackCount,
    this.missingTrackPositions = const [],
    this.toc,
    this.cddbId,
    this.leadoutOffset,
    this.bpDiscId,
    this.soundType,
    this.vinylColor,
    this.vinylWeight,
    this.rpm,
    this.spars,
    this.tracks = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicMediumId id;
  final MusicReleaseId releaseId;
  final int mediumNumber;
  final String? mediumType;
  final String? title;
  final int? trackCount;
  final int? expectedTrackCount;
  final int? missingTrackCount;
  final List<String> missingTrackPositions;
  final String? toc;
  final String? cddbId;
  final int? leadoutOffset;
  final String? bpDiscId;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final int? rpm;
  final String? spars;
  final List<MusicTrack> tracks;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get effectiveTrackCount => tracks.isEmpty
      ? trackCount ?? 0
      : tracks.where((track) => !track.isHeader).length;

  factory MusicMedium.fromJson(Map<String, dynamic> json) {
    final tracks =
        _maps(json['tracks']).map(MusicTrack.fromJson).toList(growable: false);
    return MusicMedium(
      id: MusicMediumId(_text(json['id']) ?? ''),
      releaseId: MusicReleaseId(_text(json['release_id']) ?? ''),
      mediumNumber: _int(json['medium_number']) ?? 0,
      mediumType: _text(json['medium_type']),
      title: _text(json['title']),
      trackCount: _int(json['track_count']) ??
          (tracks.isEmpty
              ? null
              : tracks.where((track) => !track.isHeader).length),
      expectedTrackCount: _int(json['expected_track_count']),
      missingTrackCount: _int(json['missing_track_count']),
      missingTrackPositions: _strings(json['missing_track_positions']),
      toc: _text(json['toc']),
      cddbId: _text(json['cddb_id']),
      leadoutOffset: _int(json['leadout_offset']),
      bpDiscId: _text(json['bp_disc_id']),
      soundType: _text(json['sound_type']),
      vinylColor: _text(json['vinyl_color']),
      vinylWeight: _text(json['vinyl_weight']),
      rpm: _int(json['rpm']),
      spars: _text(json['spars']),
      tracks: tracks,
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'kind': 'music',
        'release_id': releaseId.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'medium_number': mediumNumber,
        if (mediumType != null) 'medium_type': mediumType,
        if (title != null) 'title': title,
        if (trackCount != null) 'track_count': trackCount,
        if (expectedTrackCount != null)
          'expected_track_count': expectedTrackCount,
        if (missingTrackCount != null) 'missing_track_count': missingTrackCount,
        if (missingTrackPositions.isNotEmpty)
          'missing_track_positions': missingTrackPositions,
        if (toc != null) 'toc': toc,
        if (cddbId != null) 'cddb_id': cddbId,
        if (leadoutOffset != null) 'leadout_offset': leadoutOffset,
        if (bpDiscId != null) 'bp_disc_id': bpDiscId,
        if (soundType != null) 'sound_type': soundType,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (rpm != null) 'rpm': rpm,
        if (spars != null) 'spars': spars,
        'tracks': tracks.map((track) => track.toJson()).toList(),
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

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text
      ]
    : const <String>[];

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];
