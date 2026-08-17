import 'package:flutter/foundation.dart';

@immutable
class ProviderImageRef {
  const ProviderImageRef({
    required this.provider,
    required this.url,
    this.kind = 'cover',
    this.thumbnailUrl,
    this.imageId,
    this.headers = const {},
    this.cachePolicy,
    this.mirrorPolicy,
    this.attribution,
    this.expiresAt,
  });

  final String provider;
  final String url;
  final String kind;
  final String? thumbnailUrl;
  final String? imageId;
  final Map<String, String> headers;
  final String? cachePolicy;
  final String? mirrorPolicy;
  final String? attribution;
  final String? expiresAt;

  factory ProviderImageRef.fromJson(Map<String, dynamic> json) {
    final rawHeaders = json['headers'];
    final headers = <String, String>{};
    if (rawHeaders is Map) {
      for (final entry in rawHeaders.entries) {
        if (entry.key != null && entry.value != null) {
          headers[entry.key.toString()] = entry.value.toString();
        }
      }
    }

    return ProviderImageRef(
      provider: json['provider']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'cover',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      imageId: json['image_id']?.toString(),
      headers: headers,
      cachePolicy: json['cache_policy']?.toString(),
      mirrorPolicy: json['mirror_policy']?.toString(),
      attribution: json['attribution']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'url': url,
      'kind': kind,
      'thumbnail_url': thumbnailUrl,
      'image_id': imageId,
      'headers': headers,
      'cache_policy': cachePolicy,
      'mirror_policy': mirrorPolicy,
      'attribution': attribution,
      'expires_at': expiresAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderImageRef &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          url == other.url &&
          kind == other.kind &&
          thumbnailUrl == other.thumbnailUrl &&
          imageId == other.imageId &&
          mapEquals(headers, other.headers) &&
          cachePolicy == other.cachePolicy &&
          mirrorPolicy == other.mirrorPolicy &&
          attribution == other.attribution &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
        provider,
        url,
        kind,
        thumbnailUrl,
        imageId,
        Object.hashAll(headers.entries),
        cachePolicy,
        mirrorPolicy,
        attribution,
        expiresAt,
      );
}
