import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/secure_storage_mock.dart';

Widget testApp({List<Override> overrides = const []}) => ProviderScope(
      overrides: overrides,
      child: Consumer(
          builder: (context, ref, _) =>
              MaterialApp.router(routerConfig: ref.watch(appRouterProvider))),
    );

void setUpTestAppPreferences() {
  setUpSecureStorageMock();
  SharedPreferences.setMockInitialValues({});
}

Future<void> disposeTestApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}
