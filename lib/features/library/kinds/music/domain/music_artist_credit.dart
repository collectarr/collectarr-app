import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicArtistCredit implements JsonEncodable {
  const MusicArtistCredit({
    required this.id,
    required this.creditedName,
    this.sortName,
    this.artistId,
    this.joinPhrase,
    required this.sequence,
  });

  final String id;
  final String creditedName;
  final String? sortName;
  final String? artistId;
  final String? joinPhrase;
  final int sequence;

  factory MusicArtistCredit.fromJson(Map<String, dynamic> json) {
    const fields = {
      'id',
      'credited_name',
      'sort_name',
      'artist_id',
      'join_phrase',
      'sequence',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music artist credit field "${unsupported.first}".',
      );
    }
    final sequence = json['sequence'];
    if (sequence is! int || sequence < 1) {
      throw const FormatException('Music artist credit sequence must be >= 1.');
    }
    return MusicArtistCredit(
      id: _requiredText(json['id'], 'id'),
      creditedName: _requiredText(json['credited_name'], 'credited_name'),
      artistId: _optionalText(json['artist_id'], 'artist_id'),
      sortName: _optionalText(json['sort_name'], 'sort_name'),
      joinPhrase: _optionalString(json['join_phrase'], 'join_phrase'),
      sequence: sequence,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'credited_name': creditedName,
        if (sortName != null) 'sort_name': sortName,
        if (artistId != null) 'artist_id': artistId,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        'sequence': sequence,
      };
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException(
      'Music artist credit $field must be non-empty trimmed text.',
    );
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}

String? _optionalString(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Music artist credit $field must be text or null.');
  }
  return value;
}
