import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tracks what a panel waits for before it shows, as the reference's details
/// panel stays on its loading spinner until its cover is in.
///
/// Covers, images and data built under a [LibraryImageLoadGate] register while
/// they load and report once they are in. The loads settle after the first
/// frame has registered all of them and all are in, or after [timeout] so a
/// slow image never keeps the panel hidden.
final class LibraryImageLoads extends ChangeNotifier {
  LibraryImageLoads({Duration timeout = const Duration(seconds: 10)}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _primed = true;
      _notify();
    });
    _timeout = Timer(timeout, () {
      _pending.clear();
      _primed = true;
      _notify();
    });
  }

  final _pending = <Object>{};
  final _done = <Object>{};
  bool _primed = false;
  bool _disposed = false;
  late final Timer _timeout;

  bool get settled => _primed && _pending.isEmpty;

  /// Registers a cover that is still loading; called while it builds.
  void expect(Object key) {
    if (!_done.contains(key)) _pending.add(key);
  }

  /// Marks a cover as shown or failed.
  void done(Object key) {
    _done.add(key);
    if (_pending.remove(key)) _notify();
  }

  // Reports arrive while covers build, so listeners rebuild after the frame.
  void _notify() {
    if (_disposed) return;
    if (settled) _timeout.cancel();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    _timeout.cancel();
    super.dispose();
  }
}

/// Holds a gated panel while data it shows is still [pending].
void reportLibraryPanelLoad(BuildContext context, Object key,
    {required bool pending}) {
  final loads = LibraryImageLoadGate.maybeOf(context);
  if (loads == null) return;
  pending ? loads.expect(key) : loads.done(key);
}

/// Holds a gated panel until this image's first frame; pass it as the image's
/// frameBuilder. A failed image waits for the panel's timeout.
ImageFrameBuilder? libraryPanelImageFrames(BuildContext context, Object key) {
  final loads = LibraryImageLoadGate.maybeOf(context);
  if (loads == null) return null;
  loads.expect(key);
  return (_, child, frame, sync) {
    if (frame != null || sync) loads.done(key);
    return child;
  };
}

/// Holds a gated panel until an SVG's bytes are in; SvgPicture finds them in
/// the same cache.
void reportLibraryPanelSvg(BuildContext context, SvgLoader<Object?> loader) {
  final loads = LibraryImageLoadGate.maybeOf(context);
  if (loads == null) return;
  final key = loader.cacheKey(context);
  loads.expect(key);
  svg.cache
      .putIfAbsent(key, () => loader.loadBytes(context))
      .whenComplete(() => loads.done(key))
      .ignore();
}

class LibraryImageLoadGate extends InheritedWidget {
  const LibraryImageLoadGate({
    super.key,
    required this.loads,
    required super.child,
  });

  final LibraryImageLoads loads;

  static LibraryImageLoads? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LibraryImageLoadGate>()?.loads;

  @override
  bool updateShouldNotify(LibraryImageLoadGate oldWidget) =>
      loads != oldWidget.loads;
}
