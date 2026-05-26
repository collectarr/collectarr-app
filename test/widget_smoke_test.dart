import 'package:collectarr_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/secure_storage_mock.dart';
import 'helpers/test_constants.dart';

void main() {
  setUp(setUpSecureStorageMock);

  testWidgets('app shows auth screen first', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: CollectarrApp()));
    await pumpUntilSettled(tester);

    // Verify the auth screen renders with login controls.
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsWidgets);
  });
}
