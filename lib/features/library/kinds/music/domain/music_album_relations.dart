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
    final sequence = _requiredInt(json['sequence'], 'sequence', minimum: 1);
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
    required this.sequence,
    required this.displayName,
    this.roleId,
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
  final int sequence;
  final String displayName;
  final String? sortName;
  final String? instrument;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MusicAlbumContribution.fromJson(Map<String, dynamic> json) {
    const fields = {
      'id',
      'person_id',
      'role',
      'role_id',
      'sequence',
      'name',
      'sort_name',
      'instrument',
      'image_url',
      'created_at',
      'updated_at',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music contribution field "${unsupported.first}".',
      );
    }
    return MusicAlbumContribution(
      id: MusicAlbumContributionId(_requiredText(json['id'], 'id')),
      personId: _requiredText(json['person_id'], 'person_id'),
      role: _requiredText(json['role'], 'role'),
      roleId: _optionalText(json['role_id'], 'role_id'),
      sequence: _requiredInt(json['sequence'], 'sequence', minimum: 1),
      displayName: _requiredText(json['name'], 'name'),
      sortName: _optionalText(json['sort_name'], 'sort_name'),
      instrument: _optionalText(json['instrument'], 'instrument'),
      imageUrl: _optionalText(json['image_url'], 'image_url'),
      createdAt: _optionalDateTime(json['created_at'], 'created_at'),
      updatedAt: _optionalDateTime(json['updated_at'], 'updated_at'),
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
        'sequence': sequence,
        'name': displayName,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
        if (imageUrl != null) 'image_url': imageUrl,
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

int _requiredInt(Object? value, String field, {required int minimum}) {
  if (value is! int || value < minimum) {
    throw FormatException(
      'Music credit $field must be an integer >= $minimum.',
    );
  }
  return value;
}

DateTime? _optionalDateTime(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Music contribution $field must be text or null.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !value.contains('T') || value != value.trim()) {
    throw FormatException(
        'Music contribution $field must be an ISO date-time.');
  }
  return parsed.toUtc();
}
