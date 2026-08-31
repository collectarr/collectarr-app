import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../domain/models/provider_exception.dart';
import '../domain/models/provider_image_ref.dart';

/// Metadata stored alongside cached provider images.
@immutable
class ProviderImageMetadata {
  const ProviderImageMetadata({
    required this.url,
    required this.provider,
    required this.cachedAt,
    this.expiresAt,
    this.etag,
    this.contentType,
    this.attribution,
    this.contentLength,
  });

  final String url;
  final String provider;
  final DateTime cachedAt;
  final DateTime? expiresAt;
  final String? etag;
  final String? contentType;
  final String? attribution;
  final int? contentLength;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory ProviderImageMetadata.fromJson(Map<String, dynamic> json) {
    return ProviderImageMetadata(
      url: json['url']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      cachedAt: DateTime.tryParse(json['cached_at']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      etag: json['etag']?.toString(),
      contentType: json['content_type']?.toString(),
      attribution: json['attribution']?.toString(),
      contentLength: json['content_length'] is num
          ? (json['content_length'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'provider': provider,
      'cached_at': cachedAt.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (etag != null) 'etag': etag,
      if (contentType != null) 'content_type': contentType,
      if (attribution != null) 'attribution': attribution,
      if (contentLength != null) 'content_length': contentLength,
    };
  }
}

/// Content-addressed local disk and memory cache for provider images.
class ProviderImageCache {
  ProviderImageCache({
    required this.cacheDir,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 25),
                headers: {
                  'User-Agent': 'Collectarr/0.2.1 (contact@collectarr.app)',
                },
              ),
            );

  final Directory cacheDir;
  final Dio _dio;

  final Map<String, ProviderImageMetadata> _memoryIndex = {};

  /// Computes a deterministic content-addressed key from the URL.
  String keyForUrl(String url) {
    return sha256.convert(utf8.encode(url.trim())).toString();
  }

  File _imageFileForKey(String key, {String extension = 'img'}) {
    return File(p.join(cacheDir.path, '$key.$extension'));
  }

  File _metaFileForKey(String key) {
    return File(p.join(cacheDir.path, '$key.meta.json'));
  }

  String _inferExtension(String url, String? contentType) {
    if (contentType != null) {
      final ct = contentType.toLowerCase();
      if (ct.contains('image/jpeg') || ct.contains('image/jpg')) return 'jpg';
      if (ct.contains('image/png')) return 'png';
      if (ct.contains('image/webp')) return 'webp';
      if (ct.contains('image/gif')) return 'gif';
    }

    final uriPath = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (uriPath.endsWith('.jpg') || uriPath.endsWith('.jpeg')) return 'jpg';
    if (uriPath.endsWith('.png')) return 'png';
    if (uriPath.endsWith('.webp')) return 'webp';
    if (uriPath.endsWith('.gif')) return 'gif';
    return 'jpg';
  }

  /// Gets cached image file if available, not expired, and non-empty.
  Future<File?> getCachedImage(ProviderImageRef imageRef) async {
    final url = imageRef.url.trim();
    if (url.isEmpty) return null;

    final key = keyForUrl(url);
    final meta = await _getMetadata(key);

    if (meta != null && meta.isExpired) {
      await _evict(key);
      return null;
    }

    // Check if matching image file exists on disk.
    final ext = _inferExtension(url, meta?.contentType);
    final file = _imageFileForKey(key, extension: ext);
    if (await file.exists()) {
      final length = await file.length();
      if (length > 0) {
        return file;
      }
    }
    return null;
  }

  /// Fetches image from provider if not cached or if [forceRefresh] is true.
  Future<File> fetchAndCache(
    ProviderImageRef imageRef, {
    bool forceRefresh = false,
  }) async {
    final url = imageRef.url.trim();
    if (url.isEmpty) {
      throw ProviderException(
        provider: imageRef.provider,
        message: 'Cannot cache image with empty URL',
      );
    }

    if (!forceRefresh) {
      final cached = await getCachedImage(imageRef);
      if (cached != null) return cached;
    }

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final key = keyForUrl(url);

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: imageRef.headers.isNotEmpty ? imageRef.headers : null,
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw ProviderInvalidPayloadException(
          provider: imageRef.provider,
          message: 'Empty response bytes received for image: $url',
        );
      }

      final contentType = response.headers.value(Headers.contentTypeHeader);
      final etag = response.headers.value('etag');
      final ext = _inferExtension(url, contentType);

      DateTime? expiresAt;
      if (imageRef.expiresAt != null) {
        expiresAt = DateTime.tryParse(imageRef.expiresAt!);
      }

      final file = _imageFileForKey(key, extension: ext);
      await file.writeAsBytes(bytes, flush: true);

      final meta = ProviderImageMetadata(
        url: url,
        provider: imageRef.provider,
        cachedAt: DateTime.now().toUtc(),
        expiresAt: expiresAt,
        etag: etag,
        contentType: contentType,
        attribution: imageRef.attribution,
        contentLength: bytes.length,
      );

      final metaFile = _metaFileForKey(key);
      await metaFile.writeAsString(jsonEncode(meta.toJson()), flush: true);
      _memoryIndex[key] = meta;

      return file;
    } on DioException catch (dioErr) {
      throw ProviderException(
        provider: imageRef.provider,
        statusCode: dioErr.response?.statusCode,
        message: 'Failed to download image from $url: ${dioErr.message}',
      );
    }
  }

  /// Directly saves bytes into cache for an image reference.
  Future<File> putBytes(
    ProviderImageRef imageRef,
    Uint8List bytes, {
    String? contentType,
  }) async {
    final url = imageRef.url.trim();
    if (url.isEmpty) {
      throw ProviderException(
        provider: imageRef.provider,
        message: 'Cannot cache image with empty URL',
      );
    }

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final key = keyForUrl(url);
    final ext = _inferExtension(url, contentType);
    final file = _imageFileForKey(key, extension: ext);
    await file.writeAsBytes(bytes, flush: true);

    DateTime? expiresAt;
    if (imageRef.expiresAt != null) {
      expiresAt = DateTime.tryParse(imageRef.expiresAt!);
    }

    final meta = ProviderImageMetadata(
      url: url,
      provider: imageRef.provider,
      cachedAt: DateTime.now().toUtc(),
      expiresAt: expiresAt,
      contentType: contentType,
      attribution: imageRef.attribution,
      contentLength: bytes.length,
    );

    final metaFile = _metaFileForKey(key);
    await metaFile.writeAsString(jsonEncode(meta.toJson()), flush: true);
    _memoryIndex[key] = meta;

    return file;
  }

  Future<ProviderImageMetadata?> _getMetadata(String key) async {
    if (_memoryIndex.containsKey(key)) {
      return _memoryIndex[key];
    }

    final metaFile = _metaFileForKey(key);
    if (!await metaFile.exists()) return null;

    try {
      final jsonText = await metaFile.readAsString();
      final meta = ProviderImageMetadata.fromJson(
        jsonDecode(jsonText) as Map<String, dynamic>,
      );
      _memoryIndex[key] = meta;
      return meta;
    } catch (_) {
      return null;
    }
  }

  Future<void> _evict(String key) async {
    _memoryIndex.remove(key);
    for (final ext in ['jpg', 'jpeg', 'png', 'webp', 'gif', 'img']) {
      final file = _imageFileForKey(key, extension: ext);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
    final metaFile = _metaFileForKey(key);
    if (await metaFile.exists()) {
      try {
        await metaFile.delete();
      } catch (_) {}
    }
  }

  /// Scans cache and deletes expired items.
  Future<int> pruneExpired() async {
    if (!await cacheDir.exists()) return 0;
    var prunedCount = 0;

    final files = cacheDir.listSync();
    for (final file in files) {
      if (file is File && file.path.endsWith('.meta.json')) {
        try {
          final content = await file.readAsString();
          final meta = ProviderImageMetadata.fromJson(
            jsonDecode(content) as Map<String, dynamic>,
          );
          if (meta.isExpired) {
            final key = keyForUrl(meta.url);
            await _evict(key);
            prunedCount++;
          }
        } catch (_) {}
      }
    }
    return prunedCount;
  }

  /// Clears all files in the cache directory.
  Future<void> clearCache() async {
    _memoryIndex.clear();
    if (await cacheDir.exists()) {
      final entities = cacheDir.listSync();
      for (final entity in entities) {
        try {
          entity.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Returns the total size of cached files in bytes.
  Future<int> getCacheSizeBytes() async {
    if (!await cacheDir.exists()) return 0;
    var totalBytes = 0;
    final entities = cacheDir.listSync(recursive: false);
    for (final entity in entities) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes;
  }
}
