import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';

import '../../helpers/test_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('prefill settings dialog saves structured location ids',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Short Box 1',
            sortOrder: const Value(1),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(
            body: PrefillSettingsDialog(accent: Colors.orange),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.byIcon(Icons.place));
    await pumpUntilSettled(tester);
    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Short Box 1').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save').first);
    await pumpUntilSettled(tester);

    final defaults = await PrefillDefaults.load();
    expect(defaults.locationId, 'loc-1');
  });
}