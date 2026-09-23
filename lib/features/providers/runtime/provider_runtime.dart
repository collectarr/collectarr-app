import 'dart:async';

/// Cancellation token abstraction for provider requests.
class ProviderCancellationToken {
  ProviderCancellationToken();

  bool _isCancelled = false;
  final List<void Function()> _listeners = [];
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _isCancelled;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _cancelled.complete();
    for (final listener in _listeners) {
      listener();
    }
    _listeners.clear();
  }

  void Function() onCancelled(void Function() listener) {
    if (_isCancelled) {
      listener();
      return () {};
    } else {
      _listeners.add(listener);
      return () => _listeners.remove(listener);
    }
  }
}
