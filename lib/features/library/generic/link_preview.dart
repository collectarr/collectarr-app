import 'dart:convert';

import 'package:dio/dio.dart';

/// The YouTube video a watch, short or embed URL points at, if any.
String? youTubeVideoId(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  final String? id;
  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    id = uri.pathSegments.firstOrNull;
  } else if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
    id = switch (uri.pathSegments) {
      ['watch', ...] => uri.queryParameters['v'],
      ['embed' || 'shorts' || 'live' || 'v', final id, ...] => id,
      _ => null,
    };
  } else {
    id = null;
  }
  return id == null || id.isEmpty ? null : id;
}

/// The still YouTube publishes for a video URL, null for other sites.
String? youTubeThumbnailUrl(String url) {
  final id = youTubeVideoId(url);
  return id == null ? null : 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}

/// The title a web page gives itself, as the reference fills a new link's
/// description; null when the page cannot be read.
///
/// YouTube is asked through its oEmbed endpoint, which also answers web
/// builds, and the title keeps the page's " - YouTube" suffix.
Future<String?> fetchLinkTitle(String url, {Dio? client}) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty) {
    return null;
  }
  final dio = client ??
      Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8)));
  final plain = Options(responseType: ResponseType.plain);
  try {
    if (youTubeVideoId(url) != null) {
      final response = await dio.getUri<String>(
          Uri.https('www.youtube.com', '/oembed',
              {'url': uri.toString(), 'format': 'json'}),
          options: plain);
      final title = (jsonDecode(response.data ?? '') as Map)['title'];
      return title is String && title.trim().isNotEmpty
          ? '${title.trim()} - YouTube'
          : null;
    }
    final response = await dio.getUri<String>(uri, options: plain);
    return htmlDocumentTitle(response.data ?? '');
  } catch (_) {
    // Offline, blocked by the site or not a page: the description stays.
    return null;
  } finally {
    if (client == null) dio.close();
  }
}

/// The text of [html]'s first title element, unescaped and on one line.
String? htmlDocumentTitle(String html) {
  final match = RegExp(r'<title[^>]*>([\s\S]*?)</title>', caseSensitive: false)
      .firstMatch(html);
  if (match == null) return null;
  final title = match
      .group(1)!
      .replaceAllMapped(
          RegExp(r'&(#x[0-9a-f]+|#[0-9]+|amp|lt|gt|quot|apos|nbsp);',
              caseSensitive: false), (entity) {
        final name = entity.group(1)!.toLowerCase();
        if (name.startsWith('#')) {
          final code = name.startsWith('#x')
              ? int.tryParse(name.substring(2), radix: 16)
              : int.tryParse(name.substring(1));
          return code == null ? entity.group(0)! : String.fromCharCode(code);
        }
        return switch (name) {
          'amp' => '&',
          'lt' => '<',
          'gt' => '>',
          'quot' => '"',
          'apos' => "'",
          _ => ' ',
        };
      })
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return title.isEmpty ? null : title;
}
