import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

@immutable
final class MusicCredit implements JsonEncodable {
  MusicCredit({
    required this.id,
    this.contributorId,
    required this.name,
    this.sortName,
    required this.role,
    this.roleId,
    List<String> instruments = const [],
    required this.sequence,
  }) : instruments = List<String>.unmodifiable(instruments);

  final MusicCreditId id;
  final String? contributorId;
  final String name;
  final String? sortName;
  final String role;
  final String? roleId;
  final List<String> instruments;
  final int sequence;

  factory MusicCredit.fromJson(Map<String, dynamic> json) {
    const fields = {
      'id',
      'contributor_id',
      'name',
      'sort_name',
      'role',
      'role_id',
      'instruments',
      'sequence',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music credit field "${unsupported.first}".',
      );
    }
    return MusicCredit(
      id: MusicCreditId(_requiredText(json['id'], 'id')),
      contributorId: _optionalText(json['contributor_id'], 'contributor_id'),
      name: _requiredText(json['name'], 'name'),
      sortName: _optionalText(json['sort_name'], 'sort_name'),
      role: _requiredText(json['role'], 'role'),
      roleId: _optionalText(json['role_id'], 'role_id'),
      instruments: _requiredStrings(json['instruments']),
      sequence: _requiredInt(json['sequence']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        if (contributorId != null) 'contributor_id': contributorId,
        'name': name,
        if (sortName != null) 'sort_name': sortName,
        'role': role,
        if (roleId != null) 'role_id': roleId,
        'instruments': instruments,
        'sequence': sequence,
      };
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException(
        'Music credit $field must be non-empty trimmed text.');
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}

int _requiredInt(Object? value) {
  if (value is! int || value < 1) {
    throw const FormatException(
        'Music credit sequence must be an integer >= 1.');
  }
  return value;
}

List<String> _requiredStrings(Object? value) {
  if (value is! List || value.any((entry) => entry is! String)) {
    throw const FormatException(
        'Music credit instruments must be a list of text values.');
  }
  return List<String>.unmodifiable([
    for (final (index, entry) in value.cast<String>().indexed)
      if (entry.isNotEmpty && entry == entry.trim())
        entry
      else
        throw FormatException(
          'Music credit instrument ${index + 1} must be non-empty trimmed text.',
        ),
  ]);
}
