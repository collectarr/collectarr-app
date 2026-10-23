import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/presentation/sync_action_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/ui/app_icons.dart';

void main() {
  testWidgets('library nav strip centers its buttons when they fit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const types = [
      CatalogMediaType(
          kind: 'music', singularLabel: 'Album', pluralLabel: 'Albums')
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 42,
            child: MediaLibraryNavStrip(
              types: types,
              counts: const {},
              registry: defaultLibraryKindRegistry,
              selectedKind: 'music',
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    final strip = find.byType(MediaLibraryNavStrip);
    expect(strip, findsOneWidget);

    final navButtons = find.byType(MediaLibraryNavButton);
    expect(navButtons, findsNWidgets(types.length));
    final stripRect = tester.getRect(strip);
    final firstRect = tester.getRect(navButtons.at(0));
    final lastRect = tester.getRect(navButtons.at(types.length - 1));

    expect(firstRect.left, greaterThanOrEqualTo(stripRect.left));
    expect(lastRect.right, lessThanOrEqualTo(stripRect.right));
  });

  testWidgets(
      'sync action follows personal credentials without opening sync storage',
      (tester) async {
    final connection = _ConnectionFake(const ConnectionSettings());
    final sync = _FakeSyncController();
    var syncBuilds = 0;
    await tester.pumpWidget(ProviderScope(
        overrides: [
          connectionSettingsProvider.overrideWith(() => connection),
          syncControllerProvider.overrideWith(() {
            syncBuilds++;
            return sync;
          }),
        ],
        child: const MaterialApp(
            home: Scaffold(body: SyncActionButton(style: ButtonStyle())))));
    expect(find.byKey(const Key('app.sync')), findsNothing);
    expect(syncBuilds, 0);
    connection.update(const ConnectionSettings(isLoaded: true, syncKey: '   '));
    await tester.pump();
    expect(find.byKey(const Key('app.sync')), findsNothing);
    connection.update(const ConnectionSettings(
        isLoaded: true, syncKey: 'test-key', syncBaseUrl: ' '));
    await tester.pump();
    expect(find.byKey(const Key('app.sync')), findsNothing);
    connection
        .update(const ConnectionSettings(isLoaded: true, syncKey: 'test-key'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('app.sync')));
    expect(sync.calls, 1);
    connection.update(const ConnectionSettings(isLoaded: true));
    await tester.pump();
    expect(find.byKey(const Key('app.sync')), findsNothing);
  });

  testWidgets('home sync button is icon only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionSettingsProvider.overrideWith(() => _ConnectionFake(
              const ConnectionSettings(isLoaded: true, syncKey: 'test-key'))),
          syncControllerProvider.overrideWith(
            () => _FakeSyncController(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SyncActionButton(style: ButtonStyle()),
          ),
        ),
      ),
    );

    expect(find.text('Sync'), findsNothing);
    expect(find.byIcon(AppIcons.sync), findsOneWidget);
  });
}

class _FakeSyncController extends SyncController {
  int calls = 0;
  @override
  SyncState build() => SyncIdle();
  @override
  Future<void> syncNow() async {
    calls++;
  }
}

class _ConnectionFake extends ConnectionSettingsController {
  _ConnectionFake(this.initial);
  final ConnectionSettings initial;
  @override
  ConnectionSettings build() => initial;
  void update(ConnectionSettings value) => state = value;
}
