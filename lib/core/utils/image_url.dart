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
