import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/add/dialog.dart';
import 'package:collectarr_app/features/library/add/launcher.dart';
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

void main() {
  for (final width in [390.0, 1024.0]) {
    testWidgets(
        'Add Manually follows platform policy at $width dp and closes with it',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
      final route =
          ModalRoute.of(tester.element(find.byType(ComicAddManualPane)))!;
      if (appPresentationPlatform.isNativeMobile) {
        expect(route, isA<MaterialPageRoute<void>>());
        expect((route as PageRoute).fullscreenDialog, isTrue);
      } else {
        expect(route, isA<AppDialogRoute<void>>());
      }
      // The search dialog stays hidden behind Add Manually.
      expect(find.byKey(const ValueKey('library-add-search-button')),
          findsNothing);

      await tester.tap(find.descendant(
          of: find.byType(ComicAddManualPane),
          matching: find.byTooltip(
              appPresentationPlatform.isNativeMobile ? 'Back' : 'Close')));
      await pumpUntilSettled(tester);
      expect(find.byType(ComicAddManualPane), findsNothing);
      expect(find.byType(LibraryAddDialog), findsNothing);
    },
        variant: TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.windows
        }));
  }
}
