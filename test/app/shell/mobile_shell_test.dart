import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/app/shell/mobile_shell.dart';
import 'package:collectarr_app/app/shell/desktop_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  for (final width in [390.0, 1024.0]) {
    testWidgets('shell policy and native destination history at $width dp',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(testApp(
          overrides:
              testAppOverrides(database: db, stubEmptyCollections: true)));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/libraries?kind=comic');
      await pumpUntilSettled(tester);
      if (!appPresentationPlatform.isNativeMobile) {
        expect(find.byType(DesktopShell), findsOneWidget);
        expect(find.byType(MobileShell), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
      } else {
        expect(find.byType(MobileShell), findsOneWidget);
        final nav = width < 840
            ? find.byType(NavigationBar)
            : find.byType(NavigationRail);
        expect(nav, findsOneWidget);
        expect(
            find.byKey(const Key('library.collection-picker')), findsOneWidget);
        expect(find.byKey(const ValueKey('library-collection-menu')),
            findsNothing);
        for (final (label, path) in [
          ('Activity', AppRoutes.activity),
          ('Calendar', AppRoutes.calendar),
          ('Library', AppRoutes.libraries)
        ]) {
          await tester
              .tap(find.descendant(of: nav, matching: find.text(label)));
          await pumpUntilSettled(tester);
          expect(router.routeInformationProvider.value.uri.path, path);
          expect(
              router.routeInformationProvider.value.uri.queryParameters['kind'],
              'comic');
        }
        expect(router.canPop(), isFalse);
        await tester.tap(find.descendant(of: nav, matching: find.text('More')));
        await pumpUntilSettled(tester);
        expect(find.byKey(const Key('drawer.account')), findsOneWidget);
        await tester.tap(find.byTooltip('Close navigation'));
        await pumpUntilSettled(tester);
      }
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    },
        variant: TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.windows
        }));
  }
}
