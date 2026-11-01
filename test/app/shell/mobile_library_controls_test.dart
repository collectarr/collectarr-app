import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/workspace/chrome/view_and_organize_sheet.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  for (final (size, palette) in [
    (const Size(320, 700), kLightAppThemePalette),
    (const Size(407, 904), kDefaultAppThemePalette),
    (const Size(850, 407), kDefaultAppThemePalette),
  ]) {
    testWidgets('mobile library has one control row and all views at $size',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      addTearDown(() => disposeTestApp(tester));
      await tester.pumpWidget(ProviderScope(
        overrides: testAppOverrides(database: db, stubEmptyCollections: true),
        child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
                theme: buildAppShellTheme(palette: palette),
                routerConfig: ref.watch(appRouterProvider))),
      ));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      container.read(appRouterProvider).go('/libraries?kind=comic');
      await pumpUntilSettled(tester);
      final row = find.byKey(const Key('library.mobile-controls'));
      expect(row, findsOneWidget);
      expect(find.text('0 comics'), findsOneWidget);
      expect(find.byTooltip('Group By'), findsOneWidget);
      expect(find.byTooltip('Library tools'), findsOneWidget);
      final material = tester.widget<Material>(
          find.ancestor(of: row, matching: find.byType(Material)).first);
      expect(material.color,
          palette.isDark ? const Color(0xff28454d) : const Color(0xffd8e8ee));
      expect(tester.getSize(row).height, 48);
      await tester.tap(find.byKey(const Key('library.mobile-views')));
      await pumpUntilSettled(tester);
      for (final mode in LibraryViewMode.values) {
        expect(find.byKey(ValueKey('view_mode_${mode.name}')), findsOneWidget);
      }
      final horizontal =
          find.byKey(const ValueKey('view_mode_horizontalCards'));
      await tester.ensureVisible(horizontal);
      await tester.tap(horizontal);
      await pumpUntilSettled(tester);
      await tester.tap(find.byTooltip('Close'));
      await pumpUntilSettled(tester);
      await tester.tap(find.byKey(const Key('library.mobile-views')));
      await pumpUntilSettled(tester);
      expect(
          tester
              .widget<ViewAndOrganizeSheet>(find.byType(ViewAndOrganizeSheet))
              .currentViewMode,
          LibraryViewMode.horizontalCards);
      await tester
          .ensureVisible(find.byKey(const ValueKey('view_mode_cardFlow')));
      await tester.tap(find.byKey(const ValueKey('view_mode_cardFlow')));
      await pumpUntilSettled(tester);
      expect(find.byKey(const ValueKey('cover_size_slider')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('view_mode_grid')));
      await tester.tap(find.byKey(const ValueKey('view_mode_grid')));
      await pumpUntilSettled(tester);
      expect(find.byKey(const ValueKey('cover_size_slider')), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await pumpUntilSettled(tester);
      await tester.tap(find.byKey(const Key('library.mobile-sort')));
      await pumpUntilSettled(tester);
      expect(find.text('Sort...'), findsOneWidget);
      Navigator.of(tester.element(find.text('Sort...'))).pop();
      await pumpUntilSettled(tester);
      await tester.tap(find.byTooltip('Library tools'));
      await pumpUntilSettled(tester);
      expect(find.text('Folders...'), findsOneWidget);
      Navigator.of(tester.element(find.text('Folders...'))).pop();
      await pumpUntilSettled(tester);
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}
