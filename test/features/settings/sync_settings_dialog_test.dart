import 'package:collectarr_app/features/settings/sync_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sync settings ignores storage box policy legacy key',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.sync_field_policy.storage_box': 'overwrite',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SyncSettingsDialog(accent: Colors.orange),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    await tester.scrollUntilVisible(
      find.text('Location'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilSettled(tester);

    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Storage Box'), findsNothing);
  expect(find.text('Update empty fields only'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Sync Now'));
    await pumpUntilSettled(tester);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('collectarr.sync_field_policy.location_id'),
      'updateEmpty',
    );
    expect(
      prefs.getString('collectarr.sync_field_policy.storage_box'),
      isNull,
    );
  });
}