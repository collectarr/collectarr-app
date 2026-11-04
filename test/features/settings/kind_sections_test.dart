import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/nav_preferences.dart';
import 'package:collectarr_app/features/library/home/catalog.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/config/preferences.dart';
import 'package:collectarr_app/features/settings/core_data_settings_dialog.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_fields_tab_settings_dialog.dart';
import 'package:collectarr_app/features/library/add/mobile/method_preferences.dart';
import 'package:collectarr_app/ui/app_select.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final platform in [TargetPlatform.windows, TargetPlatform.android]) {
    testWidgets('enabled libraries can be hidden and restored on $platform',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = platform == TargetPlatform.windows
          ? const Size(1400, 1000)
          : const Size(390, 900);
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
      await tester.pumpWidget(ProviderScope(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
      ], child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      if (platform != TargetPlatform.windows) {
        await tester.tap(find.widgetWithText(ListTile, 'Customization'));
        await tester.pumpAndSettle();
      }
      final games =
          find.byKey(const ValueKey('settings.library.enabled.games'));
      expect(games, findsOneWidget);
      expect(
          find.byKey(const ValueKey('settings.library.enabled.game_hardware')),
          findsNothing);
      expect(find.byKey(const ValueKey('settings.library.enabled.game_toy')),
          findsNothing);
      await tester.ensureVisible(games);
      await tester.tap(games);
      await tester.pumpAndSettle();
      final appContainer = ProviderScope.containerOf(tester.element(games));
      var modulePrefs = appContainer.read(libraryNavPreferencesProvider);
      for (final kind in ['game', 'game_hardware', 'game_toy']) {
        expect(modulePrefs.isVisible(kind), isFalse);
        expect(
            selectableLibraryHomeTypes(fallbackMediaCatalog, modulePrefs)
                .map((type) => type.kind),
            isNot(contains(kind)));
      }
      expect(
          find.byKey(const ValueKey('settings.kind.tab.games'),
              skipOffstage: false),
          findsNothing);
      expect((await const LibraryNavPreferencesStore().read()).isHidden('game'),
          isTrue);
      await tester.ensureVisible(games);
      await tester.tap(games);
      await tester.pumpAndSettle();
      modulePrefs = appContainer.read(libraryNavPreferencesProvider);
      for (final kind in ['game', 'game_hardware', 'game_toy']) {
        expect(modulePrefs.isVisible(kind), isTrue);
      }
      expect(
          find.byKey(const ValueKey('settings.kind.tab.games'),
              skipOffstage: false),
          findsOneWidget);
      final toggle =
          find.byKey(const ValueKey('settings.library.enabled.comic'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(toggle));
      var preferences = container.read(libraryNavPreferencesProvider);
      expect(preferences.isVisible('comic'), isFalse);
      expect(
          selectableLibraryHomeTypes(fallbackMediaCatalog, preferences)
              .map((type) => type.kind),
          isNot(contains('comic')));
      expect(
          find.byKey(const ValueKey('settings.kind.tab.comic'),
              skipOffstage: false),
          findsNothing);
      expect(
          (await const LibraryNavPreferencesStore().read()).isHidden('comic'),
          isTrue);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      preferences = container.read(libraryNavPreferencesProvider);
      expect(preferences.isVisible('comic'), isTrue);
      expect(
          find.byKey(const ValueKey('settings.kind.tab.comic'),
              skipOffstage: false),
          findsOneWidget);
      expect(
          (await const LibraryNavPreferencesStore().read()).isVisible('comic'),
          isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }, variant: TargetPlatformVariant({platform}));
  }

  for (final platform in [
    TargetPlatform.windows,
    TargetPlatform.android,
    TargetPlatform.iOS
  ]) {
    testWidgets(
        'kind settings follow visible kinds and use the selected kind on $platform',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'collectarr.library_nav.hidden': ['comic']
      });
      LibraryWorkspacePreferences.resetCachedChromeForTesting();
      tester.view.physicalSize = platform == TargetPlatform.windows
          ? const Size(1400, 1000)
          : const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final router = GoRouter(initialLocation: '/settings?kind=game', routes: [
        GoRoute(
            path: '/settings',
            builder: (_, state) => SettingsPage(
                  initialSection: settingsSectionFromRouteValue(
                      state.uri.queryParameters['section']),
                  initialKind: state.uri.queryParameters['settingsKind'],
                )),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(ProviderScope(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
      ], child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('settings.kind.tab.comic'),
              skipOffstage: false),
          findsNothing);
      if (platform != TargetPlatform.windows) {
        await tester.tap(find.widgetWithText(ListTile, 'Customization'));
        await tester.pumpAndSettle();
      }
      final games = find.byKey(const ValueKey('settings.kind.tab.games'));
      expect(games, findsOneWidget);
      expect(find.byKey(const ValueKey('settings.kind.tab.game_hardware')),
          findsNothing);
      expect(find.byKey(const ValueKey('settings.kind.tab.game_toy')),
          findsNothing);
      await tester.ensureVisible(games);
      await tester.tap(games);
      await tester.pumpAndSettle();
      for (final kind in ['game', 'game_hardware', 'game_toy']) {
        expect(
            find.byKey(ValueKey('settings.kind.layout.$kind')), findsOneWidget);
      }
      final music = find.byKey(const ValueKey('settings.kind.tab.music'));
      await tester.ensureVisible(music);
      await tester.tap(music);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings.kind.layout.music')),
          findsOneWidget);
      expect(find.text('Add/Update from Core settings'), findsOneWidget);
      expect(find.text('Pre-fill settings'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings.kind.layout.game')),
          findsNothing);
      await tester.tap(find.byType(AppSelect<LibraryDetailsLayout>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Details panel').last);
      await tester.pumpAndSettle();
      final musicPreferences = LibraryWorkspacePreferences(
          defaultLibraryKindRegistry.require(CatalogMediaKind.music));
      final gamePreferences = LibraryWorkspacePreferences(
          defaultLibraryKindRegistry.require(CatalogMediaKind.game));
      expect((await musicPreferences.read(defaultCoverSize: 120)).detailsLayout,
          LibraryDetailsLayout.hidden);
      expect((await gamePreferences.read(defaultCoverSize: 120)).detailsLayout,
          isNot(LibraryDetailsLayout.hidden));
      await tester.tap(find.text('Add/Update from Core settings'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<CoreDataSettingsDialog>(
                  find.byType(CoreDataSettingsDialog))
              .kind,
          CatalogMediaKind.music);
      Navigator.of(tester.element(find.byType(CoreDataSettingsDialog)),
              rootNavigator: true)
          .pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Pre-fill settings'));
      await tester.tap(find.text('Pre-fill settings'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<PrefillSettingsDialog>(find.byType(PrefillSettingsDialog))
              .kind,
          CatalogMediaKind.music);
      Navigator.of(tester.element(find.byType(PrefillSettingsDialog)),
              rootNavigator: true)
          .pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Custom Fields tab settings'));
      await tester.tap(find.text('Custom Fields tab settings'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.descendant(
              of: find.byType(CustomFieldsTabSettingsDialog),
              matching: find.byType(TextFormField)),
          'Music extras');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect((await CustomFieldsDisplaySettings.read('music')).tabName,
          'Music extras');
      expect((await CustomFieldsDisplaySettings.read('game')).tabName,
          'Custom Fields');
      if (platform != TargetPlatform.windows) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(
            mobileAddDefaultMethodKey('music'), 'barcode');
        await preferences.setString(
            mobileAddDefaultMethodKey('game'), 'search');
        await tester.ensureVisible(find.text('Reset default Add method'));
        await tester.tap(find.text('Reset default Add method'));
        await tester.pumpAndSettle();
        expect(
            preferences.getString(mobileAddDefaultMethodKey('music')), isNull);
        expect(
            preferences.getString(mobileAddDefaultMethodKey('game')), 'search');
        await tester.tap(find.byKey(const Key('settings.back')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('settings.kind.layout.music')),
            findsNothing);
        router.go('/settings?kind=game&settingsKind=music');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('settings.kind.layout.music')),
            findsOneWidget);
        router.go('/settings?kind=game&section=customization');
        await tester.pumpAndSettle();
        await tester.ensureVisible(music);
        await tester.tap(music);
        await tester.pumpAndSettle();
      }
      final container =
          ProviderScope.containerOf(tester.element(find.byType(SettingsPage)));
      final prefs = await SharedPreferences.getInstance();
      await prefs
          .setStringList('collectarr.library_nav.hidden', ['comic', 'game']);
      await container.read(libraryNavPreferencesProvider.notifier).load();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings.kind.layout.music')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('settings.kind.tab.games'),
              skipOffstage: false),
          findsNothing);
      await prefs
          .setStringList('collectarr.library_nav.hidden', ['comic', 'music']);
      await container.read(libraryNavPreferencesProvider.notifier).load();
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('settings.kind.tab.music'),
              skipOffstage: false),
          findsNothing);
      expect(find.byKey(const ValueKey('settings.kind.layout.music')),
          findsNothing);
      await prefs.setStringList('collectarr.library_nav.hidden', ['comic']);
      await container.read(libraryNavPreferencesProvider.notifier).load();
      await tester.pumpAndSettle();
      if (find
          .byKey(const ValueKey('settings.kind.layout.music'))
          .evaluate()
          .isEmpty) {
        final restored = find.byKey(const ValueKey('settings.kind.tab.music'));
        await tester.ensureVisible(restored);
        await tester.tap(restored);
        await tester.pumpAndSettle();
      }
      expect(
          tester
              .widget<AppSelect<LibraryDetailsLayout>>(
                  find.byType(AppSelect<LibraryDetailsLayout>))
              .value,
          LibraryDetailsLayout.hidden);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }, variant: TargetPlatformVariant.only(platform));
  }
}
