import 'package:flutter/foundation.dart';

/// A user-managed external link attached to a Music catalog item.
///
/// Music owns the meaning of these links. Generic catalog transport may still
/// serialize them in the canonical `external_links` field.
@immutable
final class MusicExternalLink {
  const MusicExternalLink({
    required this.url,
    this.title,
    this.description,
  });

  final String url;
  final String? title;
  final String? description;

  Map<String, dynamic> toJson() => {
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      };

  factory MusicExternalLink.fromJson(Map<String, dynamic> json) {
    const fields = {'url', 'title', 'description'};
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music external link field "${unsupported.first}".',
      );
    }
    final url = _requiredText(json['url'], 'url');
    return MusicExternalLink(
      url: url,
      title: _optionalText(json['title'], 'title'),
      description: _optionalText(json['description'], 'description'),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicExternalLink &&
          url == other.url &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => Object.hash(url, title, description);
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException(
      'Music external link $field must be non-empty trimmed text.',
    );
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}
