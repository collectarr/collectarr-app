import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../support/fixtures/test_constants.dart';
import '../../../../../support/widget/library_add_test_harness.dart';

void main() {
  testWidgets('the menu entry opens Add Manually and closes with it',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    configureLibraryAddDesktopViewport(tester);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          localDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLibraryAddDialog(
                    context: context,
                    type: const ComicRegistration(),
                    startManually: true),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);
    expect(find.byType(ComicAddManualPane), findsOneWidget);
    // The search dialog stays hidden behind Add Manually.
    expect(
        find.byKey(const ValueKey('library-add-search-button')), findsNothing);

    await tester.tap(find.descendant(
        of: find.byType(ComicAddManualPane),
        matching: find.byTooltip('Close')));
    await pumpUntilSettled(tester);
    expect(find.byType(ComicAddManualPane), findsNothing);
    expect(find.byType(LibraryAddDialog), findsNothing);
  });
}
