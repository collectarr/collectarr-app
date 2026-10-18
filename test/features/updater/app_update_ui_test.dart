import 'package:collectarr_app/app/shell/app_update_header_button.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/settings_updates_section.dart';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _release = GitHubRelease(
  version: '1.4.0',
  tagName: 'v1.4.0',
  name: 'v1.4.0',
  body: '- Faster sync',
  publishedAt: DateTime.utc(2026, 10, 1),
  isPrerelease: false,
);

class _FakeUpdateController extends AppUpdateController {
  _FakeUpdateController(this.initial);

  final AppUpdateState initial;
  int checks = 0;
  int downloads = 0;

  @override
  AppUpdateState build() => initial;

  @override
  Future<void> checkForUpdate() async => checks++;

  @override
  Future<void> downloadUpdate() async => downloads++;
}

Future<_FakeUpdateController> _pump(
    WidgetTester tester, AppUpdateState state, Widget child,
    {GoRouter? router}) async {
  final controller = _FakeUpdateController(state);
  await tester.pumpWidget(ProviderScope(
    overrides: [appUpdateProvider.overrideWith(() => controller)],
    child: router == null
        ? MaterialApp(home: Scaffold(body: child))
        : MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  const header =
      AppUpdateHeaderButton(style: ButtonStyle(), kind: CatalogMediaKind.music);

  testWidgets('the header button stays hidden until a release is found',
      (tester) async {
    await _pump(
        tester,
        const AppUpdateState(
            status: UpdateStatus.upToDate, currentVersion: '1.3.0'),
        header);

    expect(find.byKey(const Key('app.update')), findsNothing);
  });

  testWidgets('the header button opens Settings > Updates for a new release',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: header)),
      GoRoute(
          path: '/settings',
          builder: (_, state) =>
              Text('settings ${state.uri.queryParameters['section']}')),
    ]);
    await _pump(
        tester,
        AppUpdateState(
            status: UpdateStatus.updateAvailable,
            currentVersion: '1.3.0',
            release: _release),
        const SizedBox(),
        router: router);

    final button = find.byKey(const Key('app.update'));
    expect(button, findsOneWidget);
    expect(tester.widget<IconButton>(button).tooltip,
        'Collectarr 1.4.0 is available');
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('settings updates'), findsOneWidget);
  });

  testWidgets('Updates offers the download of an available release',
      (tester) async {
    final controller = await _pump(
        tester,
        AppUpdateState(
            status: UpdateStatus.updateAvailable,
            currentVersion: '1.3.0',
            release: _release),
        const SettingsUpdatesSection());

    expect(find.text('Installed version: 1.3.0'), findsOneWidget);
    expect(find.text('Version 1.4.0 is available.'), findsOneWidget);
    expect(find.text('- Faster sync'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.updates.download')));
    await tester.tap(find.byKey(const Key('settings.updates.check')));

    expect(controller.downloads, 1);
    expect(controller.checks, 1);
  });

  testWidgets('Updates offers installing a downloaded release', (tester) async {
    await _pump(
        tester,
        AppUpdateState(
            status: UpdateStatus.readyToInstall,
            currentVersion: '1.3.0',
            release: _release,
            downloadedPath: 'collectarr-installer.exe'),
        const SettingsUpdatesSection());

    expect(find.byKey(const Key('settings.updates.install')), findsOneWidget);
    expect(find.byKey(const Key('settings.updates.download')), findsNothing);
  });
}
