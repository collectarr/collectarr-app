import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/features/sync/presentation/sync_status_overlay.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/app_close_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fakes/secure_storage_mock.dart';

void main() {
  setUp(() {
    setUpSecureStorageMock();
    SharedPreferences.setMockInitialValues({});
  });
  for (final brightness in Brightness.values) {
    testWidgets('sync banner hover and full log navigation ($brightness)',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousUrlReflection = GoRouter.optionURLReflectsImperativeAPIs;
      GoRouter.optionURLReflectsImperativeAPIs = true;
      addTearDown(() =>
          GoRouter.optionURLReflectsImperativeAPIs = previousUrlReflection);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final time = DateTime.utc(2026, 11, 11);
      final container = ProviderContainer(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        syncControllerProvider.overrideWith(() => _FailedSyncController(time)),
      ]);
      addTearDown(container.dispose);
      container.read(appLogProvider.notifier).error('sync',
          'Full connection exception with details beyond the banner text.',
          detail: 'Full diagnostic stack trace', timestamp: time);
      for (var index = 0; index < 15; index++) {
        container
            .read(appLogProvider.notifier)
            .info('other', 'Later entry $index');
      }
      final router = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (_, state) =>
                const Scaffold(body: Stack(children: [SyncStatusOverlay()]))),
        GoRoute(
            path: '/settings',
            builder: (_, state) => SettingsPage(
                  initialSection: SettingsSection.logs,
                  initialLogTimestamp: DateTime.tryParse(
                      state.uri.queryParameters['logTime'] ?? ''),
                )),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            routerConfig: router,
            theme: buildAppShellTheme(
                palette: brightness == Brightness.dark
                    ? kDefaultAppThemePalette
                    : kLightAppThemePalette)),
      ));
      await tester.pumpAndSettle();
      final close = find.descendant(
          of: find.byType(AppCloseButton), matching: find.byType(IconButton));
      final style = tester.widget<IconButton>(close).style!;
      expect(style.backgroundColor!.resolve({}), Colors.transparent);
      expect(style.overlayColor!.resolve({WidgetState.hovered})!.a,
          greaterThan(0));
      await tester.tap(find.text('View in Logs'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/settings');
      expect(
          router.routeInformationProvider.value.uri.queryParameters['logTime'],
          time.toIso8601String());
      expect(find.text('Full diagnostic stack trace'), findsOneWidget);
      expect(find.text('Full diagnostic stack trace').hitTestable(),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _FailedSyncController extends SyncController {
  _FailedSyncController(this.time);
  final DateTime time;
  @override
  SyncState build() => SyncFailure(
          errorMessage: 'Cannot reach the sync service.',
          isOffline: true,
          syncLog: [
            SyncLogEntry(
                timestamp: time,
                success: false,
                errorMessage:
                    'Full connection exception with details beyond the banner text.')
          ]);
}
