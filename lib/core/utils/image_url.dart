import 'dart:io';

String? normalizeNetworkImageUrl(String? value) {
  final url = value?.trim();
  if (url == null || url.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(url);
  if (parsed == null || !parsed.hasScheme) {
    return null;
  }
  if (parsed.scheme != 'http' && parsed.scheme != 'https') {
    return null;
  }

  if (_isInvalidOpenLibraryCoverId(parsed)) {
    return null;
  }
  return url;
}

Future<bool> isLikelyImageUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return false;
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final request = await client.headUrl(uri);
    final response = await request.close();
    final contentType = response.headers.contentType;
    return response.statusCode >= 200 &&
        response.statusCode < 300 &&
        contentType != null &&
        contentType.mimeType.toLowerCase().startsWith('image/');
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

bool _isInvalidOpenLibraryCoverId(Uri uri) {
  if (uri.host.toLowerCase() != 'covers.openlibrary.org') {
    return false;
  }

  final segments = uri.pathSegments;
  if (segments.length < 3 || segments[0] != 'b' || segments[1] != 'id') {
    return false;
  }

  final coverToken = segments[2];
  final match = RegExp(r'^(-?\d+)').firstMatch(coverToken);
  if (match == null) {
    return false;
  }

  final coverId = int.tryParse(match.group(1)!);
  return coverId != null && coverId <= 0;
}
