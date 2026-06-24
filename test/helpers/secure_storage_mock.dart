import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory mock for the FlutterSecureStorage method channel.
///
/// Call [setUpSecureStorageMock] in a `setUp` block to register a
/// method-channel handler that stores values in a simple [Map].
final _store = <String, String>{};
Object? _writeFailure;
bool _hangReads = false;
final _pendingReadCompleters = <Completer<String?>>{};

void setUpSecureStorageMock() {
  _releasePendingReadCompleters();
  _store.clear();
  _writeFailure = null;
  _hangReads = false;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async {
      switch (call.method) {
        case 'read':
          if (_hangReads) {
            final completer = Completer<String?>();
            _pendingReadCompleters.add(completer);
            unawaited(completer.future.whenComplete(() {
              _pendingReadCompleters.remove(completer);
            }));
            return completer.future;
          }
          final key = (call.arguments as Map)['key'] as String;
          return _store[key];
        case 'write':
          final failure = _writeFailure;
          if (failure != null) {
            throw failure;
          }
          final key = (call.arguments as Map)['key'] as String;
          final value = (call.arguments as Map)['value'] as String;
          _store[key] = value;
          return null;
        case 'delete':
          final key = (call.arguments as Map)['key'] as String;
          _store.remove(key);
          return null;
        case 'deleteAll':
          _store.clear();
          return null;
        default:
          return null;
      }
    },
  );
}

void failSecureStorageWrites([Object? error]) {
  _writeFailure = error ??
      PlatformException(
        code: 'write_failed',
        message: 'Secure storage write failed.',
      );
}

void hangSecureStorageReads() {
  _hangReads = true;
}

void clearSecureStorageFailures() {
  _releasePendingReadCompleters();
  _writeFailure = null;
  _hangReads = false;
}

void _releasePendingReadCompleters() {
  for (final completer in _pendingReadCompleters.toList()) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }
  _pendingReadCompleters.clear();
}
