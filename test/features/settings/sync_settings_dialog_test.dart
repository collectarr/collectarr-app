import 'package:collectarr_app/features/settings/sync_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sync settings migrates storage box policy to location',
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

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Location'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Storage Box'), findsNothing);
    expect(find.text('Always overwrite'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Sync Now'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('collectarr.sync_field_policy.location_id'),
      'overwrite',
    );
    expect(
      prefs.getString('collectarr.sync_field_policy.storage_box'),
      isNull,
    );
  });
}