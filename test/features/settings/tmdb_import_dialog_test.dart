import 'package:collectarr_app/features/settings/tmdb_import_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tmdb workspace uses import labels in both source modes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TmdbImportWorkspace(
              initialSettings: TmdbImportSettings(isLoaded: true),
            ),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Import JSON / CSV'), findsOneWidget);
    expect(find.text('Import file'), findsOneWidget);
    expect(find.text('Import from TMDB'), findsNothing);

    await tester.tap(find.text('Account sync'));
    await pumpUntilSettled(tester);

    expect(find.text('Import from TMDB'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Import JSON / CSV'), findsNothing);
  });
}