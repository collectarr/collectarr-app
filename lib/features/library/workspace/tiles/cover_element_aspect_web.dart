import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The width / height of the image at [url], read from an `<img>` element: a
/// cover that blocks cross-origin reads still tells an element its size.
Future<double?> coverElementAspectRatio(String url) async {
  final element = web.HTMLImageElement()..src = url;
  try {
    await element.decode().toDart;
  } catch (_) {
    return null;
  }
  final height = element.naturalHeight;
  return height > 0 ? element.naturalWidth / height : null;
}
