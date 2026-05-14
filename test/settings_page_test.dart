import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connection presets'), findsOneWidget);
    expect(find.text('Use Local desktop'), findsOneWidget);
    expect(find.text('Use Android emulator'), findsOneWidget);
    expect(find.text('Use LAN template'), findsOneWidget);
    expect(find.text('Metadata server'), findsOneWidget);
    expect(find.text('Personal sync service'), findsOneWidget);
    expect(find.text('Check metadata server'), findsOneWidget);
    expect(find.text('Check sync service'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Device pairing'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Device pairing'), findsOneWidget);
    expect(find.text('Device identity'), findsOneWidget);
    expect(find.text('Copy pairing code'), findsOneWidget);
    expect(find.text('Apply pairing code'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Local backup'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Local backup'), findsOneWidget);
    expect(find.text('Copy Collectarr CSV'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly CSV'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Metadata proposals'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Metadata proposals'), findsOneWidget);
    expect(find.text('No local proposal submissions yet.'), findsOneWidget);
    expect(find.text('Session expiry unavailable'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Save settings'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Save settings'), findsOneWidget);
  });

  testWidgets('settings page applies Android emulator endpoint preset',
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
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use Android emulator'));
    await tester.pumpAndSettle();

    expect(
      find.text('Android emulator endpoints applied. Save settings next.'),
      findsOneWidget,
    );
    expect(find.text('http://10.0.2.2:8010'), findsOneWidget);
    expect(find.text('http://10.0.2.2:8020'), findsOneWidget);
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
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply pairing code'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Pairing code'), code);
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Pairing settings applied'), findsOneWidget);
    expect(find.text('http://metadata.local:8010'), findsOneWidget);
    expect(find.text('http://sync.local:8020'), findsOneWidget);
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
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Account'),
      240,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.textContaining('Session expires'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
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
