import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'local_font_face.dart';

@JS('window.queryLocalFonts')
external JSPromise<JSArray<_BrowserFont>> _queryLocalFonts();
extension type _BrowserFont(JSObject _) implements JSObject {
  external String get family;
  external JSPromise<web.Blob> blob();
}

bool get canDiscoverLocalFonts =>
    web.window.isSecureContext &&
    web.window
        .getProperty<JSAny?>('queryLocalFonts'.toJS)
        .typeofEquals('function');
bool get discoverFontsAtStartup => false;

Future<List<LocalFontFace>> discoverLocalFonts() async {
  if (!canDiscoverLocalFonts) {
    throw const FormatException(
        'This browser cannot access installed fonts. Import local files instead.');
  }
  // Invoke before the first await: the permission requires a user gesture.
  final request = _queryLocalFonts();
  final fonts = (await request.toDart).toDart;
  final faces = <int, LocalFontFace>{};
  for (final font in fonts) {
    if (!RegExp(r'^Gilroy(?:\s|$)', caseSensitive: false)
        .hasMatch(font.family)) {
      continue;
    }
    final blob = await font.blob().toDart;
    if (blob.size > 2 * 1024 * 1024) continue;
    try {
      final bytes = (await blob.arrayBuffer().toDart).toDart.asUint8List();
      final face = LocalFontFace.parse(bytes, source: 'Browser');
      faces.putIfAbsent(face.weight, () => face);
    } on FormatException {
      // Ignore unsupported/italic faces while retaining the usable weights.
    }
  }
  return faces.values.toList();
}
