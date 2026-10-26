import 'dart:async';

import 'package:flutter/foundation.dart';

typedef AsyncActionErrorHandler = void Function(Object error, StackTrace stack);

/// Owns execution state only; the caller supplies the operation and reporting.
final class AsyncActionExecutor extends ChangeNotifier {
  bool _running = false;
  bool _disposed = false;

  bool get isRunning => _running;

  Future<bool> run(
    FutureOr<void> Function() action, {
    required AsyncActionErrorHandler onError,
  }) async {
    if (_running || _disposed) return false;
    _running = true;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error, stack) {
      onError(error, stack);
      return false;
    } finally {
      _running = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
