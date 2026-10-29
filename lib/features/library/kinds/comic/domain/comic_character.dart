import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicCharacter implements JsonEncodable {
  const ComicCharacter({
    this.id,
    this.characterId,
    this.name,
    this.realName,
    this.aliases = const [],
    this.role,
    this.description,
    this.imageUrl,
  });

  final String? id;
  final String? characterId;
  final String? name;
  final String? realName;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? imageUrl;

  factory ComicCharacter.fromValue(Object value) {
    if (value is String) return ComicCharacter(name: value);
    if (value is! Map) {
      throw const FormatException(
          'Comic characters must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    final aliasesValue = json['aliases'];
    if (aliasesValue != null &&
        (aliasesValue is! List ||
            aliasesValue.any((value) => value is! String))) {
      throw const FormatException('Comic character aliases must be strings.');
    }
    return ComicCharacter(
      id: json['id'] as String?,
      characterId: json['character_id'] as String?,
      name: json['name'] as String?,
      realName: json['real_name'] as String?,
      aliases: (aliasesValue as List<dynamic>?)?.cast<String>() ?? const [],
      role: json['role'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        if (name != null) 'name': name,
        if (realName != null) 'real_name': realName,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  Object toJsonValue() => id == null &&
          characterId == null &&
          realName == null &&
          aliases.isEmpty &&
          role == null &&
          description == null &&
          imageUrl == null
      ? name ?? ''
      : toJson();
}
