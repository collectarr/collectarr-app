import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_track.dart';

/// Physical or digital disc inside a concrete [MusicAlbum].
@immutable
final class MusicDisc {
  MusicDisc({
    required this.id,
    required this.discNumber,
    this.title,
    this.matrixNumberSideA,
    this.matrixNumberSideB,
    List<MusicTrack> tracks = const [],
  }) : tracks = List<MusicTrack>.unmodifiable(tracks);

  final MusicDiscId id;
  final int discNumber;
  final String? title;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final List<MusicTrack> tracks;

  int get effectiveTrackCount =>
      tracks.where((track) => !track.isHeader).length;

  factory MusicDisc.fromJson(Map<String, dynamic> json) {
    final tracks =
        _maps(json['tracks']).map(MusicTrack.fromJson).toList(growable: false);
    return MusicDisc(
      id: MusicDiscId(_text(json['id']) ?? ''),
      discNumber: _int(json['disc_number']) ?? 0,
      title: _text(json['title']),
      matrixNumberSideA: _text(json['matrix_number_side_a']),
      matrixNumberSideB: _text(json['matrix_number_side_b']),
      tracks: tracks,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'disc_number': discNumber,
        if (title != null) 'title': title,
        if (matrixNumberSideA != null)
          'matrix_number_side_a': matrixNumberSideA,
        if (matrixNumberSideB != null)
          'matrix_number_side_b': matrixNumberSideB,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : int.tryParse(value?.toString().trim() ?? '');

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];
