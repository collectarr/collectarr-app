import 'package:flutter/foundation.dart';

/// A user/provider link attached to a Music release group.
///
/// Music owns the meaning of these links. Generic catalog transport may still
/// serialize them as `external_links` or `trailer_urls` at the boundary.
@immutable
final class MusicExternalLink {
  const MusicExternalLink({
    required this.url,
    this.title,
    this.description,
    this.source,
    this.isAutomatic = false,
  });

  final String url;
  final String? title;
  final String? description;
  final String? source;
  final bool isAutomatic;

  Map<String, dynamic> toJson() => {
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (source != null) 'source': source,
        'is_automatic': isAutomatic,
        'kind': 'external',
      };

  factory MusicExternalLink.fromJson(Map<String, dynamic> json) {
    return MusicExternalLink(
      url: _text(json['url']) ?? '',
      title: _text(json['title']),
      description: _text(json['description']),
      source: _text(json['source']),
      isAutomatic: json['is_automatic'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicExternalLink &&
          url == other.url &&
          title == other.title &&
          description == other.description &&
          source == other.source &&
          isAutomatic == other.isAutomatic;

  @override
  int get hashCode => Object.hash(url, title, description, source, isAutomatic);
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
