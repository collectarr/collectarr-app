import 'package:flutter/foundation.dart';

enum ComicKeyEventType {
  firstAppearance,
  cameoAppearance,
  death,
  origin,
  firstIssue,
  iconicCover,
  other,
}

@immutable
class ComicKeyEvent {
  const ComicKeyEvent({
    required this.type,
    required this.characterOrSubject,
    this.description,
  });

  final ComicKeyEventType type;
  final String characterOrSubject;
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'character_or_subject': characterOrSubject,
        if (description != null) 'description': description,
      };

  factory ComicKeyEvent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type =
        ComicKeyEventType.values.where((event) => event.name == typeName);
    final subject = json['character_or_subject'];
    if (type.isEmpty || subject is! String || subject.trim().isEmpty) {
      throw const FormatException(
        'Comic key events require a recognized type and character_or_subject.',
      );
    }
    return ComicKeyEvent(
      type: type.first,
      characterOrSubject: subject,
      description: json['description'] as String?,
    );
  }
}
