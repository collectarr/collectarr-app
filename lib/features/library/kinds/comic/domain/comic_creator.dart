import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicCreator implements JsonEncodable {
  const ComicCreator({
    this.id,
    this.name,
    this.role,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.imageUrl,
    this.sortName,
  });

  final String? id;
  final String? name;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? imageUrl;
  final String? sortName;

  factory ComicCreator.fromValue(Object value) {
    if (value is String) return ComicCreator(name: value);
    if (value is! Map) {
      throw const FormatException('Comic creators must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    return ComicCreator(
      id: json['id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      roleId: json['role_id'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      creditedName: json['credited_name'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      imageUrl: json['image_url'] as String?,
      sortName: json['sort_name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (creditedName != null) 'credited_name': creditedName,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (imageUrl != null) 'image_url': imageUrl,
        if (sortName != null) 'sort_name': sortName,
      };

  Object toJsonValue() => id == null &&
          role == null &&
          roleId == null &&
          sequence == null &&
          creditedName == null &&
          joinPhrase == null &&
          imageUrl == null &&
          sortName == null
      ? name ?? ''
      : toJson();
}
