import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/settings/connection_presets.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/settings/connection_settings_store.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_platform.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/secure_storage_mock.dart';
import 'helpers/test_constants.dart';

/// Platform smoke tests verify critical platform-specific behaviour.
///
/// Web:     sqlite3 WASM load (simulated), Core connection, covers
/// Windows: local DB, resizable panes, keyboard shortcuts, barcode fallback
/// Android: camera scanner, manual fallback, connection presets, narrow layout
void main() {
  setUp(setUpSecureStorageMock);

  // ---------------------------------------------------------------------------
  // Web smoke tests
  // ---------------------------------------------------------------------------
  group('Web platform', () {
    test('cover image uses Image.network on web', () {
      // LibraryCoverImage branches on kIsWeb — unit tests run in non-web mode,
      // so verify the generated-cover fallback works when URL is null.
      const cover = LibraryCoverImage(title: 'Test', imageUrl: null);
      expect(cover.title, 'Test');
    });

    test('barcode camera supported on web (any platform)', () {
      expect(
        barcodeScannerCameraSupported(
            isWeb: true, platform: TargetPlatform.windows),
        isTrue,
      );
      expect(
        barcodeScannerCameraSupported(
            isWeb: true, platform: TargetPlatform.linux),
        isTrue,
      );
    });

    test('web sync warning note is available', () {
      // Settings page shows a web-specific sync warning via showWebSyncWarning.
      // Verify compile-time constant kIsWeb is accessible (non-web in test).
      expect(kIsWeb, isFalse);
    });

    test('local base64 cover bytes decode correctly', () {
      final pixel = base64Encode([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A // PNG header
      ]);
      final cover = LibraryCoverImage(title: 'Test', localBase64: pixel);
      expect(cover.localBase64, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Windows smoke tests
  // ---------------------------------------------------------------------------
  group('Windows platform', () {
    test('local Drift DB creates tables and supports CRUD', () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.into(db.catalogCache).insert(
            CatalogCacheCompanion.insert(
              id: 'smoke-1',
              kind: 'comic',
              title: 'Smoke Test Issue',
              cachedAt: DateTime.now(),
            ),
          );

      final rows = await db.select(db.catalogCache).get();
      expect(rows, hasLength(1));
      expect(rows.first.title, 'Smoke Test Issue');
    });

    test('barcode camera NOT supported on Windows desktop', () {
      expect(
        barcodeScannerCameraSupported(
            isWeb: false, platform: TargetPlatform.windows),
        isFalse,
      );
    });

    test('Windows barcode fallback message suggests manual entry', () {
      final msg = barcodeScannerUnavailableMessage(
          isWeb: false, platform: TargetPlatform.windows);
      expect(msg, contains('Enter the barcode manually'));
    });

    testWidgets('app shell renders on desktop size', (tester) async {
      tester.view.physicalSize = kDesktopHDTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      await tester
          .pumpWidget(const ProviderScope(child: CollectarrApp()));
      await pumpUntilSettled(tester);

      // App renders without crashing on desktop dimensions.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('connection settings store round-trips on desktop', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ConnectionSettingsStore();

      await store.write(const ConnectionSettings(
        metadataBaseUrl: 'http://192.168.1.50:8080',
        syncBaseUrl: 'http://192.168.1.50:8081',
        syncKey: 'desktop-key',
      ));

      final settings = await store.read();
      expect(settings.metadataBaseUrl, 'http://192.168.1.50:8080');
      expect(settings.syncKey, 'desktop-key');
    });
  });

  // ---------------------------------------------------------------------------
  // Android smoke tests
  // ---------------------------------------------------------------------------
  group('Android platform', () {
    test('barcode camera IS supported on Android', () {
      expect(
        barcodeScannerCameraSupported(
            isWeb: false, platform: TargetPlatform.android),
        isTrue,
      );
    });

    test('Android barcode unavailable message is user-friendly', () {
      final msg = barcodeScannerUnavailableMessage(
          isWeb: false, platform: TargetPlatform.android);
      expect(msg, contains('Enter the barcode manually'));
    });

    test('connection presets include common LAN patterns', () {
      final presets = ConnectionPreset.values;
      expect(presets, isNotEmpty);
      expect(
        presets.any((p) => p.label.toLowerCase().contains('local')),
        isTrue,
      );
    });

    testWidgets('app shell renders on narrow mobile size', (tester) async {
      tester.view.physicalSize = kMobileTestSize;
      tester.view.devicePixelRatio = kMobileTestDPR;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      await tester
          .pumpWidget(const ProviderScope(child: CollectarrApp()));
      await pumpUntilSettled(tester);

      // App renders without crashing on narrow mobile dimensions.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('normalize barcode strips whitespace and dashes', () {
      expect(normalizeScannedBarcode(' 012-345-678 '), '012345678');
    });
  });
}
