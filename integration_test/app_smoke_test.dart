import '../test/support/app/provider_overrides.dart';
import '../test/support/app/test_app_harness.dart';
// End-to-end smoke test for the Collectarr app across desktop and mobile form factors.
//
// Launches the full [CollectarrApp] with mocked auth/sync/database providers
// and navigates through the main navigation destinations.
//
// Run with:
//   flutter test integration_test/app_smoke_test.dart
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/fakes/secure_storage_mock.dart';
import '../test/support/fixtures/test_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabase database;
  setUp(() {
    setUpSecureStorageMock();
    database = LocalDatabase(NativeDatabase.memory());
  });
  tearDown(() async => database.close());

  group('App Smoke Tests', () {
    testWidgets(
        'desktop smoke: can navigate through all mandatory destinations',
        (tester) async {
      setUpTestAppPreferences();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpUntilSettled(tester);
      });

      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
            overrides: testAppOverrides(
                database: database, stubEmptyCollections: true)),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);
      expect(find.byKey(const Key('app.brand-title')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      Future<void> openDrawer() async {
        await tester.tap(find.byKey(const Key('app.open-navigation')));
        await pumpUntilSettled(tester);
      }

      // Verify all mandatory destination keys exist
      await openDrawer();
      expect(find.byKey(const Key('nav.library')), findsOneWidget);
      expect(find.byKey(const Key('nav.more')), findsOneWidget);
      expect(find.byKey(const Key('nav.calendar')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      // Close navigation by selecting the current library.
      await tester.tap(find.byKey(const Key('nav.library')));
      await pumpUntilSettled(tester);

      // Navigate to Loans / More
      await openDrawer();
      await tester.tap(find.byKey(const Key('nav.more')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Calendar
      await openDrawer();
      await tester.tap(find.byKey(const Key('nav.calendar')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'mobile phone smoke (390x844): navigates shell, settings, and back without overflow',
        (tester) async {
      setUpTestAppPreferences();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpUntilSettled(tester);
      });

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
            overrides: testAppOverrides(
                database: database, stubEmptyCollections: true)),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      // Mandatory keys must be present on mobile
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(find.byKey(const Key('nav.library')), findsOneWidget);

      // Return to the current library branch, which closes the drawer.
      await tester.tap(find.byKey(const Key('nav.library')));
      await pumpUntilSettled(tester);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Verify no exceptions or RenderFlex overflows occurred
      expect(tester.takeException(), isNull);
    });
  });
}
