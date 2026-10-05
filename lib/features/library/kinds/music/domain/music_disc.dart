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
    this.format,
    List<String> soundTypes = const [],
    this.vinylColor,
    this.vinylWeight,
    this.rpm,
    this.spars,
    this.matrixNumberSideA,
    this.matrixNumberSideB,
    List<MusicTrack> tracks = const [],
  })  : soundTypes = List<String>.unmodifiable(soundTypes),
        tracks = List<MusicTrack>.unmodifiable(tracks);

  final MusicDiscId id;
  final int discNumber;
  final String? title;
  final String? format;
  final List<String> soundTypes;
  final String? vinylColor;
  final String? vinylWeight;
  final int? rpm;
  final String? spars;
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
      format: _text(json['format']),
      soundTypes: _strings(json['sound_types']),
      vinylColor: _text(json['vinyl_color']),
      vinylWeight: _text(json['vinyl_weight']),
      rpm: _int(json['rpm']),
      spars: _text(json['spars']),
      matrixNumberSideA: _text(json['matrix_number_side_a']),
      matrixNumberSideB: _text(json['matrix_number_side_b']),
      tracks: tracks,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'disc_number': discNumber,
        if (title != null) 'title': title,
        if (format != null) 'format': format,
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (rpm != null) 'rpm': rpm,
        if (spars != null) 'spars': spars,
        if (matrixNumberSideA != null)
          'matrix_number_side_a': matrixNumberSideA,
        if (matrixNumberSideB != null)
          'matrix_number_side_b': matrixNumberSideB,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

/// Computes a user-facing album format summary from its ordered discs.
///
/// Examples:
/// - 1 disc "CD" -> "CD"
/// - 2 discs "Vinyl" -> "2× Vinyl"
/// - 2 discs "CD" + 1 disc "Vinyl" -> "2× CD + 1× Vinyl"
String? formatAlbumDiscsSummary(
  Iterable<MusicDisc> discs, {
  String? fallback,
}) {
  final formats = <String>[];
  for (final disc in discs) {
    final format = disc.format?.trim();
    if (format != null && format.isNotEmpty) {
      formats.add(format);
    }
  }
  if (formats.isEmpty) {
    final fb = fallback?.trim();
    return (fb == null || fb.isEmpty) ? null : fb;
  }
  final counts = <String, int>{};
  for (final format in formats) {
    counts[format] = (counts[format] ?? 0) + 1;
  }
  if (counts.length == 1) {
    final entry = counts.entries.first;
    return entry.value == 1 ? entry.key : '${entry.value}× ${entry.key}';
  }
  return counts.entries
      .map((entry) => '${entry.value}× ${entry.key}')
      .join(' + ');
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

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const <String>[];

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

