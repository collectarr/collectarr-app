import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('schema cards stack inside a scrollable at narrow widths',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [1400.0, 900.0, 480.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CollectionSchemaManagementPanel(db: db),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('Custom fields'), findsOneWidget);
      expect(find.text('Pick lists'), findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
