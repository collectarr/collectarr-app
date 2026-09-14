import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

/// A release credit row matching Core's music_release_contributions table.
///
/// Person display data is provider/API metadata and remains inside
/// [metadataJson]; the canonical relation is identified by [personId].
@immutable
final class MusicReleaseContribution implements JsonEncodable {
  MusicReleaseContribution({
    required this.id,
    required this.releaseId,
    required this.personId,
    required this.role,
    this.roleId,
    this.sequence,
    this.metadataJson = const <String, dynamic>{},
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
  final Map<String, dynamic> metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? get displayName => _text(
        metadataJson['name'] ?? metadataJson['display_name'],
      );

  String? get imageUrl => _text(metadataJson['image_url']);

  factory MusicReleaseContribution.fromJson(Map<String, dynamic> json) {
    return MusicReleaseContribution(
      id: MusicReleaseContributionId(_text(json['id']) ?? ''),
      releaseId: MusicReleaseId(_text(json['release_id']) ?? ''),
      personId: _text(json['person_id']) ?? '',
      role: _text(json['role']) ?? 'Artist',
      roleId: _text(json['role_id']),
      sequence: _int(json['sequence']),
      metadataJson: _metadata(json),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...metadataJson,
        'id': id.value,
        'release_id': releaseId.value,
        'person_id': personId,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        'metadata_json': metadataJson,
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
    this.metadataJson = const <String, dynamic>{},
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
  final Map<String, dynamic> metadataJson;
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
      metadataJson: _metadata(json),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...metadataJson,
        'id': id.value,
        'release_id': releaseId.value,
        'identifier_type': identifierType,
        'value': value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
        if (sourceProvider != null) 'source_provider': sourceProvider,
        'metadata_json': metadataJson,
      };
}

Map<String, dynamic> _metadata(Map<String, dynamic> json) {
  final value = json['metadata_json'];
  final metadata =
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  for (final entry in json.entries) {
    if (!const {
      'id',
      'release_id',
      'person_id',
      'role',
      'role_id',
      'sequence',
      'identifier_type',
      'value',
      'normalized_value',
      'is_primary',
      'source_provider',
      'metadata_json',
    }.contains(entry.key)) {
      metadata[entry.key] = entry.value;
    }
  }
  return metadata;
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
