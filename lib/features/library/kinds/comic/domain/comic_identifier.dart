import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicIdentifier implements JsonEncodable {
  const ComicIdentifier({
    required this.identifierType,
    required this.value,
    this.id,
    this.normalizedValue,
    this.isPrimary = false,
  });

  final String identifierType;
  final String value;
  final String? id;
  final String? normalizedValue;
  final bool isPrimary;

  factory ComicIdentifier.fromValue(Object value) {
    if (value is String) {
      return ComicIdentifier(identifierType: 'other', value: value);
    }
    if (value is! Map) {
      throw const FormatException(
        'Comic identifiers must be strings or objects.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    final type = json['identifier_type'];
    final identifier = json['value'];
    if (type is! String ||
        type.trim().isEmpty ||
        identifier is! String ||
        identifier.trim().isEmpty) {
      throw const FormatException(
        'Comic identifier objects require identifier_type and value.',
      );
    }
    return ComicIdentifier(
      identifierType: type,
      value: identifier,
      id: json['id'] as String?,
      normalizedValue: json['normalized_value'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'identifier_type': identifierType,
        'value': value,
        if (id != null) 'id': id,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
      };
}
