import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/test_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/secure_storage_mock.dart';

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
          home: const SettingsPage(),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Libraries'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
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

    await _openSettingsTab(tester, 'Libraries');
    expect(find.text('Library navigation'), findsOneWidget);
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('View shortcuts'), findsOneWidget);

    await _openSettingsTab(tester, 'Appearance');
    expect(find.text('Appearance'), findsWidgets);
    expect(find.text('Animations'), findsOneWidget);
    expect(find.text('Reset appearance defaults'), findsOneWidget);

    await _openSettingsTab(tester, 'Data');
    expect(find.text('Local backup'), findsOneWidget);
    expect(find.text('Import collection'), findsOneWidget);
    expect(find.text('Export collection'), findsOneWidget);
    expect(find.text('Copy Collectarr export'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly export'), findsOneWidget);
    expect(find.text('Copy sync backup guide'), findsOneWidget);
    expect(find.text('Custom fields'), findsNothing);
    await _scrollToText(tester, 'Metadata proposals');
    expect(find.text('Metadata proposals'), findsOneWidget);
    expect(find.text('No local proposal submissions yet.'), findsOneWidget);
    await _scrollToText(tester, 'Pending TMDB imports');
    expect(find.text('Pending TMDB imports'), findsOneWidget);
    expect(find.text('No queued local TMDB proposals.'), findsOneWidget);
    await _scrollToText(tester, 'AniList');
    expect(find.text('AniList'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);

    await _openSettingsTab(tester, 'Account');
    expect(find.text('Device identity'), findsOneWidget);
    expect(find.text('Session expiry unavailable'), findsNothing);
    expect(find.text('Save settings'), findsNothing);
  });

  testWidgets('settings page hides keyboard shortcuts on Android',
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
          theme: ThemeData(platform: TargetPlatform.android),
          home: const SettingsPage(),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _openSettingsTab(tester, 'Libraries');
    expect(find.text('Library navigation'), findsOneWidget);
    expect(find.text('Keyboard shortcuts'), findsNothing);
    expect(find.text('View shortcuts'), findsNothing);
  });

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
          home: const SettingsPage(),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _openSettingsTab(tester, 'Appearance');
    final animationTile = find.widgetWithText(SwitchListTile, 'Animations');
    expect(animationTile, findsOneWidget);
    expect(tester.widget<SwitchListTile>(animationTile).value, isTrue);

    await tester.tap(animationTile);
    await pumpUntilSettled(tester);

    expect(tester.widget<SwitchListTile>(animationTile).value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(UiPreferencesStore.animationsEnabledKey),
      isFalse,
    );
  });

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
          home: SettingsPage(showWebSyncWarning: true),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, 'Personal sync service');
    expect(
      find.textContaining('Browser CORS, HTTPS, and local-network access'),
      findsOneWidget,
    );
  });

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
            (ref) => _StaticSyncController(
              ref,
              SyncState(
                warningMessage: '1 sync change rejected',
                rejectedChanges: [
                  SyncRejectedChange(
                    entityType: 'owned_item',
                    entityId: 'owned-item-123456',
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
          home: const SettingsPage(),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToText(tester, 'Sync conflict review');

    expect(find.text('Sync conflict review'), findsOneWidget);
    expect(find.text('owned_item:owned-it'), findsOneWidget);
    expect(
      find.textContaining('This device is behind the service'),
      findsOneWidget,
    );
    await _scrollToTooltip(tester, 'Copy conflict id');
    await tester.tap(find.byTooltip('Copy conflict id'));
    await pumpUntilSettled(tester);
    await _scrollToTooltip(tester, 'Keep service version');
    await tester.tap(find.byTooltip('Keep service version'));
    await pumpUntilSettled(tester);
    expect(find.text('Sync conflict review'), findsNothing);
  });

  testWidgets('settings page explains keep local queues the next sync',
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
            (ref) => _KeepLocalSyncController(
              ref,
              SyncState(
                pendingCount: 2,
                warningMessage: '1 sync change rejected',
                rejectedChanges: [
                  SyncRejectedChange(
                    entityType: 'owned_item',
                    entityId: 'owned-item-123456',
                    reason: 'stale_client_change',
                  ),
                ],
              ),
              pendingCountAfterQueue: 3,
            ),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await pumpUntilSettled(tester);

    await _scrollToTooltip(tester, 'Keep local version');
    await tester.tap(find.byTooltip('Keep local version'));
    await pumpUntilSettled(tester);

    expect(
      find.text(
        'Local version queued for the next sync. 3 pending changes are ready to upload.',
      ),
      findsOneWidget,
    );
    expect(find.text('Sync conflict review'), findsNothing);
  });

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
          home: const SettingsPage(),
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
  });

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
          home: const SettingsPage(),
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
  });

  testWidgets('settings page shows account session status', (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
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
          home: const SettingsPage(),
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
  });
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    320,
    scrollable: _verticalScrollable(),
  );
  await pumpUntilSettled(tester);
}

Future<void> _scrollToTooltip(WidgetTester tester, String tooltip) async {
  await tester.scrollUntilVisible(
    find.byTooltip(tooltip),
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
  _StaticSyncController(super.ref, SyncState initial) {
    state = initial;
  }

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}
}

class _KeepLocalSyncController extends SyncController {
  _KeepLocalSyncController(
    super.ref,
    SyncState initial, {
    required this.pendingCountAfterQueue,
  }) {
    state = initial;
  }

  final int pendingCountAfterQueue;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}

  @override
  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    state = state.copyWith(
      pendingCount: pendingCountAfterQueue,
      rejectedChanges: state.rejectedChanges
          .where((entry) => entry.key != change.key)
          .toList(growable: false),
      clearWarning: true,
    );
    return true;
  }
}
