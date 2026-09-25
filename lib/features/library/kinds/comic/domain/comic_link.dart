import 'package:flutter/foundation.dart';

@immutable
final class ComicLink {
  const ComicLink({
    required this.url,
    this.title,
    this.description,
    this.source,
    this.isAutomatic = true,
    this.kind = 'trailer',
  });

  final String url;
  final String? title;
  final String? description;
  final String? source;
  final bool isAutomatic;
  final String kind;

  bool get isExternalLink => kind == 'external' || kind == 'link';
  bool get isTrailerLink => !isExternalLink;

  factory ComicLink.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['type'])?.toString().toLowerCase();
    final source = json['source'] as String?;
    final inferredKind = rawKind ??
        ((source?.toLowerCase().contains('external') ?? false)
            ? 'external'
            : 'trailer');
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return ComicLink(
      url: json['url'] as String,
      title: title ?? description,
      description: description ?? title,
      source: source,
      isAutomatic: json['is_automatic'] as bool? ?? true,
      kind: inferredKind,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (source != null) 'source': source,
        'is_automatic': isAutomatic,
        'kind': kind,
      };
}
