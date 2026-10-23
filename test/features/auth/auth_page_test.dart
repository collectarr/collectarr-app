import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fixtures/test_constants.dart';

class _AuthFake extends AuthController {
  _AuthFake([this.initial = const AuthState()]);
  final AuthState initial;
  String? submittedEmail;
  String? submittedPassword;
  int calls = 0;
  @override
  AuthState build() => initial;
  @override
  Future<void> login(String email, String password) async {
    submittedEmail = email;
    submittedPassword = password;
    calls++;
    state = AuthState(email: email, isLoading: true);
  }

  void reject() => state = AuthState(
      email: submittedEmail, error: 'Email or password is incorrect.');
}

Future<void> _pump(WidgetTester tester, _AuthFake auth, AppThemePalette palette,
    {Widget page = const AuthPage()}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [authControllerProvider.overrideWith(() => auth)],
    child: MaterialApp(theme: buildAppShellTheme(palette: palette), home: page),
  ));
  await pumpUntilSettled(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
        appName: 'Collectarr',
        packageName: 'org.collectarr.app',
        version: '9.8.7',
        buildNumber: '42',
        buildSignature: 'fixture');
  });

  for (final palette in [kDefaultAppThemePalette, kLightAppThemePalette]) {
    testWidgets(
        'sign in uses the installed version, app logo and ${palette.brightness} palette',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester,
          _AuthFake(const AuthState(email: 'saved@example.test')), palette);
      expect(find.text('v9.8.7+42'), findsOneWidget);
      expect(find.text('v1.0'), findsNothing);
      final logo = tester.widget<Image>(find.byKey(const Key('auth.app-logo')));
      expect((logo.image as AssetImage).assetName, AppIcons.appLogoPng);
      final field =
          tester.widget<TextField>(find.byKey(const Key('auth.email')));
      expect(field.controller!.text, 'saved@example.test');
      final theme =
          Theme.of(tester.element(find.byKey(const Key('auth.email'))));
      expect(theme.brightness, palette.brightness);
      expect(
          (theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder)
              .borderSide
              .color,
          palette.utilityAction);
      expect(find.text('Use dev credentials'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'sign in preserves password visibility, keyboard submit, busy and error states',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = _AuthFake();
    await _pump(tester, auth, kDefaultAppThemePalette);
    await tester.enterText(
        find.byKey(const Key('auth.email')), '  login@example.test  ');
    await tester.enterText(find.byKey(const Key('auth.password')), ' secret ');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('auth.password')))
            .obscureText,
        isFalse);
    await tester.tap(find.byKey(const Key('auth.password')));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(auth.submittedEmail, 'login@example.test');
    expect(auth.submittedPassword, ' secret ');
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('auth.submit')))
            .onPressed,
        isNull);
    expect(
        tester.widget<TextField>(find.byKey(const Key('auth.email'))).enabled,
        isFalse);
    expect(auth.calls, 1);
    auth.reject();
    await tester.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('auth.password')))
            .controller!
            .text,
        ' secret ');
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('auth.submit')))
            .onPressed,
        isNotNull);
  });

  testWidgets(
      'sign in remains usable in a narrow window with the keyboard open',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final auth = _AuthFake();
    await _pump(tester, auth, kLightAppThemePalette);
    await tester.ensureVisible(find.byKey(const Key('auth.email')));
    await tester.enterText(
        find.byKey(const Key('auth.email')), 'mobile@example.test');
    await tester.ensureVisible(find.byKey(const Key('auth.password')));
    await tester.enterText(find.byKey(const Key('auth.password')), 'password');
    await tester.ensureVisible(find.byKey(const Key('auth.submit')));
    await tester.tap(find.byKey(const Key('auth.submit')));
    await tester.pump();
    expect(auth.submittedEmail, 'mobile@example.test');
    expect(tester.takeException(), isNull);
  });

  testWidgets('continue to library keeps the selected kind', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
        overrides: [authControllerProvider.overrideWith(() => _AuthFake())]);
    addTearDown(container.dispose);
    container.read(selectedLibraryKindProvider.notifier).select('game');
    final router = GoRouter(initialLocation: '/auth', routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
      GoRoute(
          path: '/libraries',
          builder: (_, state) => Scaffold(
              body: Text('Library: ${state.uri.queryParameters['kind']}'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            theme: buildAppShellTheme(), routerConfig: router)));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Continue to library'));
    await tester.pumpAndSettle();
    expect(find.text('Library: game'), findsOneWidget);
  });

  testWidgets('restoring session shares the light branding and actual version',
      (tester) async {
    await _pump(tester, _AuthFake(), kLightAppThemePalette,
        page: const CollectarrRestoreScreen());
    expect(find.byKey(const Key('auth.app-logo')), findsOneWidget);
    expect(find.text('v9.8.7+42'), findsOneWidget);
    expect(find.text('Checking your saved session…'), findsOneWidget);
    expect(find.text('Continue to library'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
