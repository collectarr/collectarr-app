import '../support/app/auth_fakes.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes/secure_storage_mock.dart';
import '../support/fixtures/test_constants.dart';

void main() {
  setUp(setUpSecureStorageMock);

  testWidgets('app auth route renders sign-in controls', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(SignedOutAuthFake.new),
    ]);
    addTearDown(container.dispose);
    container.read(appRouterProvider).go(AppRoutes.auth);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const CollectarrApp(),
    ));
    await pumpUntilSettled(tester);

    // Verify the auth screen renders with login controls.
    expect(find.byWidgetPredicate((widget) => widget is FilledButton),
        findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  });
}
