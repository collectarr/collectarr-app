import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

/// A preserved artist credit, including the display form and join phrase.
@immutable
final class MusicArtistCredit implements JsonEncodable {
  const MusicArtistCredit({
    required this.id,
    required this.creditedName,
    this.sortName,
    this.artistId,
    this.joinPhrase,
    this.sequence,
  });

  final String id;
  final String creditedName;
  final String? sortName;
  final String? artistId;
  final String? joinPhrase;
  final int? sequence;

  factory MusicArtistCredit.fromJson(Map<String, dynamic> json) {
    return MusicArtistCredit(
      id: _requiredText(json['id'], 'id'),
      creditedName: _requiredText(json['credited_name'], 'credited_name'),
      artistId: _optionalText(json['artist_id'], 'artist_id'),
      sortName: _optionalText(json['sort_name'], 'sort_name'),
      joinPhrase: _optionalString(json['join_phrase'], 'join_phrase'),
      sequence: _int(json['sequence']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'credited_name': creditedName,
        if (sortName != null) 'sort_name': sortName,
        if (artistId != null) 'artist_id': artistId,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (sequence != null) 'sequence': sequence,
      };
}

/// A contribution value contained by a Music album document.
///
/// The canonical relation is identified by [personId]; display data is kept
/// in explicit fields so it can be persisted without an untyped payload.
@immutable
final class MusicAlbumContribution implements JsonEncodable {
  MusicAlbumContribution({
    required this.id,
    required this.personId,
    required this.role,
    this.roleId,
    this.sequence,
    this.displayName,
    this.sortName,
    this.instrument,
    this.imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicAlbumContributionId id;
  final String personId;
  final String role;
  final String? roleId;
  final int? sequence;
  final String? displayName;
  final String? sortName;
  final String? instrument;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MusicAlbumContribution.fromJson(Map<String, dynamic> json) {
    return MusicAlbumContribution(
      id: MusicAlbumContributionId(_text(json['id']) ?? ''),
      personId: _text(json['person_id']) ?? '',
      role: _text(json['role']) ?? 'Artist',
      roleId: _text(json['role_id']),
      sequence: _int(json['sequence']),
      displayName: _text(json['name']),
      sortName: _text(json['sort_name']),
      instrument: _text(json['instrument']),
      imageUrl: _text(json['image_url']),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'person_id': personId,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (displayName != null) 'name': displayName,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
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

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime _dateTime(Object? value) {
  return DateTime.tryParse(value?.toString().trim() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
