import 'package:collectarr_app/features/settings/tmdb_import_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tmdb workspace uses preview-first labels in both source modes', (
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
    await tester.pumpAndSettle();

    expect(find.text('Preview JSON/CSV'), findsOneWidget);
    expect(find.text('Preview file'), findsOneWidget);
    expect(find.text('Preview TMDB import'), findsNothing);

    await tester.tap(find.text('Account sync'));
    await tester.pumpAndSettle();

    expect(find.text('Preview TMDB import'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Preview JSON/CSV'), findsNothing);
  });
}