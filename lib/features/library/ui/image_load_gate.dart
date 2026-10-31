import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Tracks the covers a panel waits for before it shows, as the reference's
/// details panel stays on its loading spinner until its cover is in.
///
/// Covers built under a [LibraryImageLoadGate] register while they load and
/// report once their first frame, or an error, arrives. The loads settle
/// after the first frame has registered every cover and all of them are in,
/// or after [timeout] so a slow image never keeps the panel hidden.
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

class LibraryImageLoadGate extends InheritedWidget {
  const LibraryImageLoadGate({
    super.key,
    required this.loads,
    required super.child,
  });

  final LibraryImageLoads loads;

  static LibraryImageLoads? maybeOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<LibraryImageLoadGate>()
      ?.loads;

  @override
  bool updateShouldNotify(LibraryImageLoadGate oldWidget) =>
      loads != oldWidget.loads;
}
