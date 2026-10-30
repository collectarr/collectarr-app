import 'dart:typed_data';

/// A browser cannot read another site's image bytes without CORS, which
/// providers such as CLZ do not send, so the web build cannot download them.
const providerCoversDownloadable = false;

Future<Uint8List?> fetchProviderCover(Uri url) async => null;
