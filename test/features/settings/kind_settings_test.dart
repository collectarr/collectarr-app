import 'package:collectarr_app/features/settings/kind_settings_provider.dart';
import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('migration preserves false as shared default and is idempotent',
      () async {
    SharedPreferences.setMockInitialValues(
        {'collectarr.ui.show_inspector_trailers': false});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final initial = await container.read(kindSettingsProvider.future);
    expect(initial.resolve(trailerVideosSetting, kind: CatalogMediaKind.game),
        false);
    expect(initial.kinds, isEmpty);
    await container
        .read(kindSettingsProvider.notifier)
        .setOverride(trailerVideosSetting, CatalogMediaKind.game, true);
    final reread = await KindSettingsStore().read();
    expect(reread.resolve(trailerVideosSetting, kind: CatalogMediaKind.game),
        true);
    expect(reread.resolve(trailerVideosSetting, kind: CatalogMediaKind.gameToy),
        false);
    expect(
        (await SharedPreferences.getInstance())
            .containsKey('collectarr.ui.show_inspector_trailers'),
        false);
    expect(
        (jsonDecode((await SharedPreferences.getInstance())
                .getString(KindSettingsStore.key)!)
            as Map<String, dynamic>)['version'],
        1);
  });
  test(
      'explicit false, concurrent writes, reload and reset preserve inheritance',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    final controller = container.read(kindSettingsProvider.notifier);
    await Future.wait([
      controller.setOverride(
          trailerVideosSetting, CatalogMediaKind.game, false),
      controller.setOverride(
          trailerVideosSetting, CatalogMediaKind.gameToy, true),
    ]);
    await controller.setShared(trailerVideosSetting, false);
    final reloaded = await KindSettingsStore().read();
    expect(
        reloaded.resolve(trailerVideosSetting, kind: CatalogMediaKind.gameToy),
        true);
    expect(reloaded.resolve(trailerVideosSetting, kind: CatalogMediaKind.game),
        false);
    expect(reloaded.hasOverride(trailerVideosSetting, CatalogMediaKind.game),
        true);
    await controller.reset(trailerVideosSetting, CatalogMediaKind.gameToy);
    expect(
        (await KindSettingsStore().read())
            .resolve(trailerVideosSetting, kind: CatalogMediaKind.gameToy),
        false);
  });
  test('apply only writes settings declared by compatible enabled kinds',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    await container
        .read(kindSettingsProvider.notifier)
        .apply(trailerVideosSetting, false, {
      CatalogMediaKind.game: const LibraryKindSettingsContribution(
          settings: [trailerVideosSetting]),
      CatalogMediaKind.music: const LibraryKindSettingsContribution(),
    });
    final result = await KindSettingsStore().read();
    expect(
        result.hasOverride(trailerVideosSetting, CatalogMediaKind.game), true);
    expect(result.hasOverride(trailerVideosSetting, CatalogMediaKind.music),
        false);
    expect(result.hasOverride(trailerVideosSetting, CatalogMediaKind.gameToy),
        false);
  });
  test('presence preserves explicit null and kind-only ignores shared defaults',
      () {
    final nullable = KindSetting<String?>(
        id: 'synthetic',
        label: 'Synthetic',
        defaultValue: 'default',
        scope: KindSettingScope.kindOverridable,
        decode: (value) => value as String?,
        editor: (_, value, change) => const SizedBox());
    final only = KindSetting<String?>(
        id: 'synthetic',
        label: 'Synthetic',
        defaultValue: 'own',
        scope: KindSettingScope.kindOnly,
        decode: (value) => value as String?,
        editor: (_, value, change) => const SizedBox());
    final values = KindSettingsValues(shared: {
      'synthetic': 'shared'
    }, kinds: {
      'game': {'synthetic': null}
    });
    expect(values.resolve(nullable, kind: CatalogMediaKind.game), null);
    expect(values.resolve(nullable, kind: CatalogMediaKind.gameToy), 'shared');
    expect(values.resolve(only, kind: CatalogMediaKind.gameToy), 'own');
    expect(values.resolve(only, kind: CatalogMediaKind.game), null);
  });
  test('unsupported kinds are unavailable and global-only ignores kind values',
      () {
    final values = KindSettingsValues(shared: {
      'global': 0
    }, kinds: {
      'game': {'global': 7}
    });
    final global = KindSetting<int>(
        id: 'global',
        label: 'Global',
        defaultValue: 1,
        scope: KindSettingScope.globalOnly,
        decode: (value) => value as int,
        editor: (_, value, change) => const SizedBox());
    expect(values.resolve(global), 0);
    expect(values.resolve(global, kind: CatalogMediaKind.game), 0);
    expect(
        const LibraryKindSettingsContribution()
            .resolve(values, trailerVideosSetting, CatalogMediaKind.music)
            .available,
        false);
    expect(
        const LibraryKindSettingsContribution(settings: [trailerVideosSetting])
            .resolve(values, trailerVideosSetting, CatalogMediaKind.game)
            .value,
        true);
  });
  test('invalid persisted setting types are exposed as loading errors',
      () async {
    final raw = jsonEncode({
      'version': 1,
      'shared': {trailerVideosSetting.id: 'wrong type'},
      'kinds': <String, Object?>{}
    });
    SharedPreferences.setMockInitialValues({KindSettingsStore.key: raw});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await expectLater(
        container.read(kindSettingsProvider.future), throwsFormatException);
    expect(
        (await SharedPreferences.getInstance())
            .getString(KindSettingsStore.key),
        raw);
  });
  test('unsupported overrides are rejected before persistence', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    expect(
        () => container
            .read(kindSettingsProvider.notifier)
            .setOverride(trailerVideosSetting, CatalogMediaKind.music, false),
        throwsArgumentError);
    expect((await KindSettingsStore().read()).kinds, isEmpty);
  });
  test('future storage versions fail without changing persisted data',
      () async {
    final raw = jsonEncode({'version': 99});
    SharedPreferences.setMockInitialValues({KindSettingsStore.key: raw});
    await expectLater(KindSettingsStore().read(), throwsFormatException);
    expect(
        (await SharedPreferences.getInstance())
            .getString(KindSettingsStore.key),
        raw);
  });
}
