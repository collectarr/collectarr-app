import 'package:go_router/go_router.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../support/fixtures/test_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fakes/secure_storage_mock.dart';

void main() {
  setUp(setUpSecureStorageMock);
  tearDown(DeviceIdentity.resetForTesting);

  testWidgets('settings page shows connection diagnostics controls',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Libraries'), findsNothing);
    expect(find.text('Customization'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    await _scrollToText(tester, 'Metadata server');
    expect(find.text('Metadata server'), findsOneWidget);
    expect(find.text('Check metadata server'), findsOneWidget);
    await _scrollToText(tester, 'Personal sync service');
    expect(find.text('Personal sync service'), findsOneWidget);
    expect(find.text('Check sync server connection'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    await _scrollToText(tester, 'Device pairing');
    expect(find.text('Device pairing'), findsOneWidget);
    expect(find.text('Copy pairing code'), findsOneWidget);
    expect(find.text('Show pairing QR'), findsOneWidget);
    expect(find.text('Apply pairing code'), findsOneWidget);
    expect(find.text('Reset connection defaults'), findsOneWidget);

    await _openSettingsTab(tester, 'Customization');
    expect(find.widgetWithText(Tab, 'General'), findsOneWidget);
    expect(find.text('Animations'), findsOneWidget);
    expect(find.text('Show trailer videos'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('settings.kind.tab.games')));
    await pumpUntilSettled(tester);
    expect(find.text('Show trailer videos'), findsNWidgets(3));
    await tester.tap(find.byKey(const ValueKey('settings.kind.tab.music')));
    await pumpUntilSettled(tester);
    expect(find.text('Show trailer videos'), findsNothing);
    await tester.tap(find.widgetWithText(Tab, 'General'));
    await pumpUntilSettled(tester);
    expect(find.text('Reset customization defaults'), findsOneWidget);

    await _openSettingsTab(tester, 'Data');
    expect(find.text('Local backup'), findsOneWidget);
    expect(find.text('Import collection'), findsOneWidget);
    expect(find.text('Export collection'), findsOneWidget);
    expect(find.text('Copy Collectarr export'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly export'), findsOneWidget);
    expect(find.text('Copy sync backup guide'), findsOneWidget);
    await _openSettingsTab(tester, 'Proposals');
    await _scrollToText(tester, 'Metadata proposals');
    expect(find.text('Metadata proposals'), findsOneWidget);
    expect(find.text('No local proposal submissions yet.'), findsOneWidget);
    await _openSettingsTab(tester, 'Account');
    expect(find.text('Device identity'), findsOneWidget);
    expect(find.text('Session expiry unavailable'), findsNothing);
    expect(find.text('Save settings'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'settings page renders drill-down list on compact screen and navigates',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final router = GoRouter(initialLocation: '/settings', routes: [
      GoRoute(
          path: '/settings',
          builder: (_, state) => SettingsPage(
              initialSection: settingsSectionFromRouteValue(
                  state.uri.queryParameters['section']))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await pumpUntilSettled(tester);

    // List of settings sections
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Libraries'), findsNothing);
    expect(find.text('Customization'), findsOneWidget);
    expect(find.text('Proposals'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);

    // Tap into Connection
    await tester.tap(find.text('Connection'));
    await pumpUntilSettled(tester);

    expect(find.text('Metadata server'), findsOneWidget);
    expect(find.text('Personal sync service'), findsOneWidget);

    // Back to root
    await tester.tap(find.text('Back'));
    await pumpUntilSettled(tester);

    // Tap into Customization
    await tester.tap(find.text('Customization'));
    await pumpUntilSettled(tester);

    expect(find.text('Application Skin'), findsOneWidget);
    expect(find.text('Animations'), findsOneWidget);
    expect(find.text('Platform icons'), findsNothing);
    final games = find.byKey(const ValueKey('settings.kind.tab.games'));
    await tester.ensureVisible(games);
    await tester.tap(games);
    await pumpUntilSettled(tester);
    expect(find.text('Platform icons'), findsOneWidget);
    expect(find.text('Custom label icons'), findsNothing);
    final comics = find.byKey(const ValueKey('settings.kind.tab.comic'));
    await tester.ensureVisible(comics);
    await tester.tap(comics);
    await pumpUntilSettled(tester);
    expect(find.text('Custom label icons'), findsOneWidget);
    expect(find.text('Platform icons'), findsNothing);
    // Let Drift finish cancelling the platform-image watch before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  },
      variant:
          TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS}));

  testWidgets('settings page renders scrollable section tabs on medium screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Two-pane: left sidebar with sections, right panel with content
    expect(find.text('Metadata server'), findsOneWidget);

    // Switch section via left pane
    await tester.tap(find.text('Customization'));
    await pumpUntilSettled(tester);

    expect(find.text('Application Skin'), findsOneWidget);
    expect(find.text('Animations'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('time zone menu groups cities and saves the device or city',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = defaultTargetPlatform == TargetPlatform.windows
        ? const Size(1100, 1200)
        : const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ThemeData(platform: TargetPlatform.windows),
        home: const SettingsPage(initialSection: SettingsSection.customization),
      ),
    ));
    await pumpUntilSettled(tester);
    final timeZoneGroup = find.ancestor(
        of: find.text('Time zone'), matching: find.byType(SettingsGroup));
    final select = find.descendant(
        of: timeZoneGroup, matching: find.byType(SettingsSelect<String>));
    await tester.ensureVisible(select);
    await tester.tap(select);
    await tester.pumpAndSettle();
    expect(find.text('Africa'), findsOneWidget);
    expect(
        tester
            .widget<MenuItemButton>(
                find.widgetWithText(MenuItemButton, 'Africa'))
            .onPressed,
        isNull);
    await tester.tap(find.text('Abidjan').last);
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(SettingsPage)));
    expect(container.read(uiPreferencesProvider).formats.timeZone,
        'Africa/Abidjan');
    await tester.tap(select);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device time zone').last);
    await tester.pumpAndSettle();
    expect(
        container.read(uiPreferencesProvider).formats.timeZone, deviceTimeZone);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  },
      variant: TargetPlatformVariant({
        TargetPlatform.windows,
        TargetPlatform.android,
        TargetPlatform.iOS
      }));

  testWidgets('settings page persists animation preference', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _openSettingsTab(tester, 'Customization');
    final animationTile = find.widgetWithText(SettingsCheck, 'Animations');
    expect(animationTile, findsOneWidget);
    expect(tester.widget<SettingsCheck>(animationTile).value, isTrue);

    await tester.tap(find.text('Animations'));
    await pumpUntilSettled(tester);

    expect(tester.widget<SettingsCheck>(animationTile).value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(UiPreferencesStore.animationsEnabledKey),
      isFalse,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'customization omits removed cover controls and retains saved layout values',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      UiPreferencesStore.gridSpacingKey: 24.0,
      UiPreferencesStore.cardCoverWidthKey: 120.0,
      UiPreferencesStore.sidebarRowPaddingKey: 8.0,
    });
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home:
              const SettingsPage(initialSection: SettingsSection.customization),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Covers & layout'), findsNothing);
    expect(find.text('Show titles in grid'), findsNothing);
    for (final label in [
      'Flat covers',
      'Grid spacing',
      'Card cover width',
      'Sidebar row padding'
    ]) {
      expect(find.text(label), findsNothing);
    }
    final container =
        ProviderScope.containerOf(tester.element(find.byType(SettingsPage)));
    final preferences = container.read(uiPreferencesProvider);
    expect(preferences.gridSpacing, 24.0);
    expect(preferences.cardCoverWidth, 120.0);
    expect(preferences.sidebarRowPadding, 8.0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('settings page warns that web sync can be browser-blocked',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: SettingsPage(
              showWebSyncWarning: true,
              initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, 'Personal sync service');
    expect(
      find.textContaining('Browser CORS, HTTPS, and local-network access'),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('settings page shows rejected sync changes for review',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            () => _StaticSyncController(
              SyncState(
                warningMessage: '1 sync change rejected',
                rejectedChanges: [
                  SyncRejectedChange(
                    entityType: 'library_entry',
                    entityId: 'entry-item-123456',
                    reason: 'stale_client_change',
                    currentClientChangedAt: DateTime.utc(2026, 5, 14, 9, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, '1 sync conflict needs a decision');
    await tester.tap(find.text('Review'));
    await pumpUntilSettled(tester);

    expect(find.text('Sync conflicts'), findsOneWidget);
    await tester.tap(find.text('Keep other version'));
    await pumpUntilSettled(tester);

    expect(find.text('Sync conflicts'), findsNothing);
    expect(find.text('1 sync conflict needs a decision'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('sync conflict review keeps this device\'s version',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            () => _KeepLocalSyncController(
              SyncState(
                pendingCount: 2,
                warningMessage: '1 sync change rejected',
                rejectedChanges: [
                  SyncRejectedChange(
                    entityType: 'library_entry',
                    entityId: 'entry-item-123456',
                    reason: 'stale_client_change',
                    localAction: 'upsert',
                    localPayload: {
                      'catalog_data': {'title': 'Saga', 'page_count': 208},
                    },
                    serviceAction: 'upsert',
                    servicePayload: {
                      'catalog_data': {'title': 'Saga', 'page_count': 209},
                    },
                  ),
                ],
              ),
              pendingCountAfterQueue: 3,
            ),
          ),
        ],
        child: const MaterialApp(
            home: SettingsPage(initialSection: SettingsSection.connection)),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, '1 sync conflict needs a decision');
    await tester.tap(find.text('Review'));
    await pumpUntilSettled(tester);

    expect(find.text('Saga'), findsOneWidget);
    expect(find.text('Page count'), findsOneWidget);
    expect(find.text('This device: 208'), findsOneWidget);
    expect(find.text('Other version: 209'), findsOneWidget);

    await tester.tap(find.text('Keep this device'));
    await pumpUntilSettled(tester);

    expect(find.text('Sync conflicts'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('settings page applies pasted pairing code', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final code = const ConnectionPairing().encode(
      const ConnectionSettings(
        metadataBaseUrl: 'http://metadata.local:8010',
        syncBaseUrl: 'http://sync.local:8020',
        syncKey: 'household-key',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, 'Apply pairing code');
    await tester.tap(find.text('Apply pairing code'));
    await pumpUntilSettled(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Pairing code'), code);
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await pumpUntilSettled(tester);

    expect(find.text('Pairing settings applied'), findsOneWidget);
    await _scrollToTextUp(tester, 'Metadata server');
    expect(find.text('http://metadata.local:8010'), findsOneWidget);
    await _scrollToText(tester, 'Personal sync service');
    expect(find.text('http://sync.local:8020'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('settings page shows pairing QR code', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, 'Device pairing');
    await _scrollToText(tester, 'Show pairing QR');
    await tester.tap(find.text('Show pairing QR'));
    await pumpUntilSettled(tester);

    expect(find.text('Pairing QR'), findsOneWidget);
    expect(find.text('Copy code'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('settings page shows account session status', (tester) async {
    final token = _jwtExpiringAt(
      DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    setSecureStorageValue('collectarr.auth.token', token);
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.email': 'user@example.com',
    });
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: const SettingsPage(initialSection: SettingsSection.connection),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _openSettingsTab(tester, 'Account');

    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.textContaining('Session expires'), findsOneWidget);
    expect(find.textContaining('Standard'), findsOneWidget);
    expect(
      find.textContaining('Admin-only'),
      findsOneWidget,
    );
    expect(find.textContaining('Sign out'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    320,
    scrollable: _verticalScrollable(),
  );
  await pumpUntilSettled(tester);
}

Future<void> _scrollToTextUp(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    -320,
    scrollable: _verticalScrollable(),
  );
  await pumpUntilSettled(tester);
}

Future<void> _openSettingsTab(WidgetTester tester, String label) async {
  final tab = find.widgetWithText(Tab, label);
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await pumpUntilSettled(tester);
}

Finder _verticalScrollable() {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;
}

String _jwtExpiringAt(DateTime expiresAt) {
  final encodedHeader = _base64UrlJson({'alg': 'none', 'typ': 'JWT'});
  final encodedPayload = _base64UrlJson({
    'sub': '00000000-0000-0000-0000-000000000001',
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });
  return '$encodedHeader.$encodedPayload.signature';
}

String _base64UrlJson(Map<String, Object> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}

class _StaticSyncController extends SyncController {
  _StaticSyncController(this.initial);

  final SyncState initial;

  @override
  SyncState build() => initial;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}
}

class _KeepLocalSyncController extends SyncController {
  _KeepLocalSyncController(
    this.initial, {
    required this.pendingCountAfterQueue,
  });

  final SyncState initial;

  @override
  SyncState build() => initial;

  final int pendingCountAfterQueue;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}

  @override
  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    state = SyncIdle.fromSnapshot(
      state.snapshot.copyWith(
        pendingCount: pendingCountAfterQueue,
        rejectedChanges: state.rejectedChanges
            .where((entry) => entry.key != change.key)
            .toList(growable: false),
        clearWarning: true,
      ),
    );
    return true;
  }
}
