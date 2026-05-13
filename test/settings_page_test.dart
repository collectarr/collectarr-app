import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
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

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Metadata server'), findsOneWidget);
    expect(find.text('Personal sync service'), findsOneWidget);
    expect(find.text('Device identity'), findsOneWidget);
    expect(find.text('Local backup'), findsOneWidget);
    expect(find.text('Check metadata server'), findsOneWidget);
    expect(find.text('Check sync service'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    expect(find.text('Copy Collectarr CSV'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly CSV'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save settings'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Save settings'), findsOneWidget);
  });
}
