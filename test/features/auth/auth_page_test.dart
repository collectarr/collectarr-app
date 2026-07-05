import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/secure_storage_mock.dart';
import '../../helpers/test_constants.dart';

void main() {
  setUp(setUpSecureStorageMock);
  tearDown(DeviceIdentity.resetForTesting);

  testWidgets('auth page keeps the login surface concise', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const AuthPage(),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Sign in to your catalog'), findsOneWidget);
    expect(find.text('Enter your Collectarr credentials.'), findsOneWidget);
    expect(find.text('Use dev credentials'), findsOneWidget);
    expect(find.text('Local personal database'), findsNothing);
    expect(find.text('Ready'), findsNothing);
    expect(find.text('Dev credentials: user@example.com / password123'), findsNothing);
    expect(find.text('Metadata account gates server search only.'), findsNothing);
    expect(find.text('Last account:'), findsNothing);
  });
}
