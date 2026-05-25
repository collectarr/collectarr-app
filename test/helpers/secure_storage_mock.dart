import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory mock for the FlutterSecureStorage method channel.
///
/// Call [setUpSecureStorageMock] in a `setUp` block to register a
/// method-channel handler that stores values in a simple [Map].
final _store = <String, String>{};

void setUpSecureStorageMock() {
  _store.clear();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async {
      switch (call.method) {
        case 'read':
          final key = call.arguments['key'] as String;
          return _store[key];
        case 'write':
          final key = call.arguments['key'] as String;
          final value = call.arguments['value'] as String;
          _store[key] = value;
          return null;
        case 'delete':
          final key = call.arguments['key'] as String;
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
