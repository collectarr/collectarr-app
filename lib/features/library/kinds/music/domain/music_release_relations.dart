import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

/// A preserved artist credit, including the display form and join phrase.
///
/// The plain artist display text remains a compact summary; this value is the
/// lossless credit used by the Music UI and provider round-trip.
@immutable
final class MusicArtistCredit implements JsonEncodable {
  const MusicArtistCredit({
    required this.id,
    required this.creditedName,
    this.artistId,
    this.joinPhrase,
    this.sequence,
    this.source,
  });

  final String id;
  final String creditedName;
  final String? artistId;
  final String? joinPhrase;
  final int? sequence;
  final String? source;

  factory MusicArtistCredit.fromJson(Map<String, dynamic> json) =>
      MusicArtistCredit(
        id: _text(json['id']) ?? '',
        creditedName: _text(json['credited_name'] ??
                json['name'] ??
                json['display_name']) ??
            '',
        artistId: _text(json['artist_id'] ?? json['person_id']),
        joinPhrase: _text(json['join_phrase']),
        sequence: _int(json['sequence']),
        source: _text(json['source'] ?? json['source_provider']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'credited_name': creditedName,
        if (artistId != null) 'artist_id': artistId,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (sequence != null) 'sequence': sequence,
        if (source != null) 'source': source,
      };
}

/// A release label/catalog-number pair. Keeping the pair together avoids
/// mismatching the first label with the first catalog number in provider data.
@immutable
final class MusicReleaseLabel implements JsonEncodable {
  const MusicReleaseLabel({
    required this.id,
    this.labelId,
    required this.labelName,
    this.catalogNumber,
    this.sequence,
    this.source,
  });

  final String id;
  final String? labelId;
  final String labelName;
  final String? catalogNumber;
  final int? sequence;
  final String? source;

  factory MusicReleaseLabel.fromJson(Map<String, dynamic> json) =>
      MusicReleaseLabel(
        id: _text(json['id']) ?? '',
        labelId: _text(json['label_id']),
        labelName:
            _text(json['label_name'] ?? json['name'] ?? json['label']) ?? '',
        catalogNumber: _text(json['catalog_number'] ?? json['catalog-number']),
        sequence: _int(json['sequence']),
        source: _text(json['source'] ?? json['source_provider']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        if (labelId != null) 'label_id': labelId,
        'label_name': labelName,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (sequence != null) 'sequence': sequence,
        if (source != null) 'source': source,
      };
}

/// A release credit row matching Core's music_release_contributions table.
///
/// The canonical relation is identified by [personId]; display data is kept
/// in explicit fields so it can be persisted without an untyped payload.
@immutable
final class MusicReleaseContribution implements JsonEncodable {
  MusicReleaseContribution({
    required this.id,
    required this.releaseId,
    required this.personId,
    required this.role,
    this.roleId,
    this.sequence,
    this.displayName,
    this.imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicReleaseContributionId id;
  final MusicReleaseId releaseId;
  final String personId;
  final String role;
  final String? roleId;
  final int? sequence;
  final String? displayName;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MusicReleaseContribution.fromJson(Map<String, dynamic> json) {
    return MusicReleaseContribution(
      id: MusicReleaseContributionId(_text(json['id']) ?? ''),
      releaseId: MusicReleaseId(_text(json['release_id']) ?? ''),
      personId: _text(json['person_id']) ?? '',
      role: _text(json['role']) ?? 'Artist',
      roleId: _text(json['role_id']),
      sequence: _int(json['sequence']),
      displayName: _text(json['name'] ?? json['display_name']),
      imageUrl: _text(json['image_url']),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'release_id': releaseId.value,
        'person_id': personId,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (displayName != null) 'name': displayName,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}

/// A release identifier row matching Core's music_release_identifiers table.
@immutable
final class MusicReleaseIdentifier implements JsonEncodable {
  MusicReleaseIdentifier({
    required this.id,
    required this.releaseId,
    required this.identifierType,
    required this.value,
    this.normalizedValue,
    this.isPrimary = false,
    this.sourceProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicReleaseIdentifierId id;
  final MusicReleaseId releaseId;
  final String identifierType;
  final String value;
  final String? normalizedValue;
  final bool isPrimary;
  final String? sourceProvider;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MusicReleaseIdentifier.fromJson(Map<String, dynamic> json) {
    return MusicReleaseIdentifier(
      id: MusicReleaseIdentifierId(_text(json['id']) ?? ''),
      releaseId: MusicReleaseId(_text(json['release_id']) ?? ''),
      identifierType: _text(json['identifier_type']) ?? 'unknown',
      value: _text(json['value']) ?? '',
      normalizedValue: _text(json['normalized_value']),
      isPrimary: json['is_primary'] as bool? ?? false,
      sourceProvider: _text(json['source_provider']),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'release_id': releaseId.value,
        'identifier_type': identifierType,
        'value': value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
        if (sourceProvider != null) 'source_provider': sourceProvider,
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

DateTime _dateTime(Object? value) {
  return DateTime.tryParse(value?.toString().trim() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
