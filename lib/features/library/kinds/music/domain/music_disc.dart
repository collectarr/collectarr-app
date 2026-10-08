import 'package:flutter/foundation.dart';

import 'music_disc_format_family.dart';
import 'music_ids.dart';
import 'music_track.dart';

/// Physical or digital disc inside a concrete [MusicAlbum].
@immutable
final class MusicDisc {
  MusicDisc({
    required this.id,
    required this.discNumber,
    this.title,
    this.formatFamily,
    this.format,
    List<String> soundTypes = const [],
    this.color,
    this.vinylWeightGrams,
    this.rpm,
    this.matrixNumber,
    this.matrixNumberSideA,
    this.matrixNumberSideB,
    List<MusicTrack> tracks = const [],
  })  : soundTypes = List<String>.unmodifiable(soundTypes),
        tracks = List<MusicTrack>.unmodifiable(tracks);

  final MusicDiscId id;
  final int discNumber;
  final String? title;
  final MusicDiscFormatFamily? formatFamily;
  final String? format;
  final List<String> soundTypes;
  final String? color;
  final int? vinylWeightGrams;
  final String? rpm;
  final String? matrixNumber;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final List<MusicTrack> tracks;

  int get effectiveTrackCount =>
      tracks.where((track) => !track.isHeader).length;

  factory MusicDisc.fromJson(Map<String, dynamic> json) {
    const fields = {
      'id',
      'disc_number',
      'title',
      'format_family',
      'format',
      'sound_types',
      'color',
      'vinyl_weight_grams',
      'rpm',
      'matrix_number',
      'matrix_number_side_a',
      'matrix_number_side_b',
      'tracks',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music disc field "${unsupported.first}".',
      );
    }
    final tracks = _requiredMaps(json['tracks'], 'tracks')
        .map(MusicTrack.fromJson)
        .toList(growable: false);
    return MusicDisc(
      id: MusicDiscId(_requiredText(json['id'], 'id')),
      discNumber: _requiredInt(json['disc_number'], 'disc_number', minimum: 1),
      title: _optionalText(json['title'], 'title'),
      formatFamily: _formatFamily(json['format_family']),
      format: _optionalText(json['format'], 'format'),
      soundTypes: _stringList(json['sound_types'], 'sound_types'),
      color: _optionalText(json['color'], 'color'),
      vinylWeightGrams: _optionalInt(
        json['vinyl_weight_grams'],
        'vinyl_weight_grams',
        minimum: 1,
      ),
      rpm: _optionalText(json['rpm'], 'rpm'),
      matrixNumber: _optionalText(json['matrix_number'], 'matrix_number'),
      matrixNumberSideA:
          _optionalText(json['matrix_number_side_a'], 'matrix_number_side_a'),
      matrixNumberSideB:
          _optionalText(json['matrix_number_side_b'], 'matrix_number_side_b'),
      tracks: tracks,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'disc_number': discNumber,
        if (title != null) 'title': title,
        if (formatFamily != null) 'format_family': formatFamily!.value,
        if (format != null) 'format': format,
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (color != null) 'color': color,
        if (vinylWeightGrams != null) 'vinyl_weight_grams': vinylWeightGrams,
        if (rpm != null) 'rpm': rpm,
        if (matrixNumber != null) 'matrix_number': matrixNumber,
        if (matrixNumberSideA != null)
          'matrix_number_side_a': matrixNumberSideA,
        if (matrixNumberSideB != null)
          'matrix_number_side_b': matrixNumberSideB,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

/// Computes a user-facing album format summary from a collection of disc formats.
String? formatDiscsSummary(
  Iterable<String?> formats, {
  String? fallback,
}) {
  final clean = <String>[];
  for (final f in formats) {
    final t = f?.trim();
    if (t != null && t.isNotEmpty) {
      clean.add(t);
    }
  }
  if (clean.isEmpty) {
    final fb = fallback?.trim();
    return (fb == null || fb.isEmpty) ? null : fb;
  }
  final counts = <String, int>{};
  for (final format in clean) {
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

/// Computes a user-facing album format summary from its ordered discs.
///
/// Examples:
/// - 1 disc "CD" -> "CD"
/// - 2 discs "Vinyl" -> "2× Vinyl"
/// - 2 discs "CD" + 1 disc "Vinyl" -> "2× CD + 1× Vinyl"
String? formatAlbumDiscsSummary(
  Iterable<MusicDisc> discs, {
  String? fallback,
}) =>
    formatDiscsSummary(discs.map((d) => d.format), fallback: fallback);

String _requiredText(Object? value, String field) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException('Music disc $field must be non-empty trimmed text.');
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}

int _requiredInt(Object? value, String field, {required int minimum}) {
  if (value is! int || value < minimum) {
    throw FormatException('Music disc $field must be an integer >= $minimum.');
  }
  return value;
}

int? _optionalInt(Object? value, String field, {required int minimum}) {
  if (value == null) return null;
  return _requiredInt(value, field, minimum: minimum);
}

MusicDiscFormatFamily? _formatFamily(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException(
        'Music disc format_family must be text or null.');
  }
  for (final family in MusicDiscFormatFamily.values) {
    if (family.value == value) return family;
  }
  throw FormatException('Unrecognized Music disc format_family "$value".');
}

List<String> _stringList(Object? value, String field) {
  if (value == null) return const [];
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('Music disc $field must be a list of strings.');
  }
  for (final (index, entry) in value.indexed) {
    if (entry.isEmpty || entry != entry.trim()) {
      throw FormatException(
        'Music disc $field entry ${index + 1} must be non-empty trimmed text.',
      );
    }
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<Map<String, dynamic>> _requiredMaps(Object? value, String field) {
  if (value is! List) {
    throw FormatException('Music disc $field must be a list.');
  }
  return [
    for (final (index, entry) in value.indexed)
      if (entry is Map)
        Map<String, dynamic>.from(entry)
      else
        throw FormatException(
          'Music disc $field entry ${index + 1} must be an object.',
        ),
  ];
}
