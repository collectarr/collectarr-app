import 'dart:async';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ControlledUpdateController extends AppUpdateController {
  _ControlledUpdateController({super.dio});
  @override
  Future<void> init() async {}
  Future<void> initializeFromPlatform() => super.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'closing the scope during package initialization ignores late completion',
      () async {
    SharedPreferences.setMockInitialValues(
        {'collectarr.updater.auto_check': false});
    const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
    final response = Completer<Map<String, Object?>>();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) => response.future);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final controller = _ControlledUpdateController();
    final container = ProviderContainer(
        overrides: [appUpdateProvider.overrideWith(() => controller)]);
    container.read(appUpdateProvider);
    final initialization = controller.initializeFromPlatform();
    container.dispose();
    response.complete({
      'appName': 'Test',
      'packageName': 'test.collectarr',
      'version': '1.5.0',
      'buildNumber': '6',
      'buildSignature': ''
    });
    await expectLater(initialization, completes);
  });

  for (final fail in [false, true]) {
    test(
        'closing the scope during an update request ignores late ${fail ? 'failure' : 'success'}',
        () async {
      final response = Completer<void>();
      final dio = Dio();
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (request, handler) async {
        await response.future;
        if (fail) {
          handler.reject(
              DioException(requestOptions: request, error: 'isolated failure'));
        } else {
          handler.resolve(Response<List<dynamic>>(
              requestOptions: request, data: [], statusCode: 200));
        }
      }));
      final controller = _ControlledUpdateController(dio: dio);
      final container = ProviderContainer(
          overrides: [appUpdateProvider.overrideWith(() => controller)]);
      container.read(appUpdateProvider);
      final checking = controller.checkForUpdate();
      await Future<void>.delayed(Duration.zero);
      container.dispose();
      response.complete();
      await expectLater(checking, completes);
      dio.close();
    });
  }
}
