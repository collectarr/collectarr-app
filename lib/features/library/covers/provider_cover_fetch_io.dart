import 'dart:io';
import 'dart:typed_data';

const providerCoversDownloadable = true;

const _maxCoverBytes = 10 * 1024 * 1024;

/// Downloads one provider image; null when it is missing, too large or not an
/// image, so the entry keeps its link and can be retried.
Future<Uint8List?> fetchProviderCover(Uri url) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..idleTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(url);
    final response = await request.close().timeout(const Duration(seconds: 30));
    final type = response.headers.contentType?.mimeType.toLowerCase() ?? '';
    if (response.statusCode != HttpStatus.ok || !type.startsWith('image/')) {
      await response.drain<void>();
      return null;
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.timeout(const Duration(seconds: 30))) {
      bytes.add(chunk);
      if (bytes.length > _maxCoverBytes) return null;
    }
    return bytes.takeBytes();
  } on Object {
    return null;
  } finally {
    client.close(force: true);
  }
}
