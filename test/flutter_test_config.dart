import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/secure_storage_mock.dart';

/// Global test configuration.
///
/// Flutter's test runner calls [testExecutable] before every test file.
/// This ensures the FlutterSecureStorage method channel is always mocked,
/// preventing MissingPluginException in any test that triggers the auth flow.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUp(setUpSecureStorageMock);
  await testMain();
}
