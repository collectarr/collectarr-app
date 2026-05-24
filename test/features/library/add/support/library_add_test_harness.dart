import 'dart:ui';

import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void configureLibraryAddDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1100, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class TestAdminAuthController extends AuthController {
  TestAdminAuthController(super.ref) : super() {
    state = const AuthState(
      token: 'test-token',
      isAdmin: true,
      isRestoring: false,
    );
  }
}