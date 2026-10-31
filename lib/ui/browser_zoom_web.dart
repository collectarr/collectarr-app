import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Whether the browser owns page zoom instead of the app.
///
/// The browser zoom is part of the device pixel ratio, so an app zoom on top
/// of it reads 100% while the page is still zoomed. One zoom avoids that.
bool get browserOwnsZoom => true;

const _zoomKeys = {'+', '=', '-', '0'};

/// Stops Flutter from seeing zoom shortcuts so the browser zooms the page.
///
/// Flutter Web prevents the default of Ctrl + wheel and of handled keys, so
/// these listeners run first, in the capture phase, and end propagation
/// without preventing the browser's own zoom.
void leaveZoomToBrowser() {
  void stopZoomKey(web.Event event) {
    final key = event as web.KeyboardEvent;
    if ((key.ctrlKey || key.metaKey) && _zoomKeys.contains(key.key)) {
      key.stopImmediatePropagation();
    }
  }

  void stopZoomWheel(web.Event event) {
    if ((event as web.WheelEvent).ctrlKey) event.stopImmediatePropagation();
  }

  final options = web.AddEventListenerOptions(capture: true, passive: true);
  web.window
    ..addEventListener('keydown', stopZoomKey.toJS, options)
    ..addEventListener('keyup', stopZoomKey.toJS, options)
    ..addEventListener('wheel', stopZoomWheel.toJS, options);
}
