import 'package:flutter/foundation.dart';

/// A user-managed external link attached to a Music catalog item.
///
/// Music owns the meaning of these links. Generic catalog transport may still
/// serialize them as `external_links` or `trailer_urls` at the boundary.
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
        'kind': 'external',
      };

  factory MusicExternalLink.fromJson(Map<String, dynamic> json) {
    return MusicExternalLink(
      url: _text(json['url']) ?? '',
      title: _text(json['title']),
      description: _text(json['description']),
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

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
