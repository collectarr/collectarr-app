import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

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
