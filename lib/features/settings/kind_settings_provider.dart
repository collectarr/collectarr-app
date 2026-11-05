import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kind_settings.dart';

final kindSettingsProvider =
    AsyncNotifierProvider<KindSettingsController, KindSettingsValues>(
        KindSettingsController.new,
        retry: (_, error) => null);

class KindSettingsController extends AsyncNotifier<KindSettingsValues> {
  Future<void> _pending = Future.value();
  @override
  Future<KindSettingsValues> build() async {
    final values = await KindSettingsStore().read();
    for (final entry in collectarrKindSettings.entries) {
      for (final setting in entry.value.settings) {
        if (setting.scope != KindSettingScope.kindOnly &&
            values.shared.containsKey(setting.id)) {
          setting.checked(values.shared[setting.id]);
        }
        if (values.hasOverride(setting, entry.key)) {
          setting.checked(values.kinds[entry.key.apiValue]![setting.id]);
        }
      }
    }
    return values;
  }

  Future<void> _update(KindSettingsValues Function(KindSettingsValues) change) {
    final task = _pending.then((_) async {
      final previous = await future;
      final next = change(previous);
      await KindSettingsStore().write(next);
      state = AsyncData(next);
    });
    _pending = task.then((_) {}, onError: (Object error, StackTrace stack) {});
    return task;
  }

  Future<void> setShared<T>(KindSetting<T> setting, T value) {
    if (setting.scope == KindSettingScope.kindOnly) {
      throw ArgumentError('Kind-only setting');
    }
    setting.checked(value);
    return _update((s) => KindSettingsValues(
        shared: {...s.shared, setting.id: value}, kinds: s.kinds));
  }

  Future<void> setOverride<T>(
      KindSetting<T> setting, CatalogMediaKind kind, T value) {
    if (collectarrKindSettings[kind]?.find(setting.id) == null) {
      throw ArgumentError(
          'Setting ${setting.id} is unavailable for ${kind.apiValue}');
    }
    if (setting.scope == KindSettingScope.globalOnly) {
      throw ArgumentError('Global setting');
    }
    setting.checked(value);
    return _update((s) => KindSettingsValues(shared: s.shared, kinds: {
          ...s.kinds,
          kind.apiValue: {...?s.kinds[kind.apiValue], setting.id: value}
        }));
  }

  Future<void> reset(KindSetting<Object?> setting, CatalogMediaKind kind) =>
      _update((s) {
        final values = {...?s.kinds[kind.apiValue]}..remove(setting.id);
        return KindSettingsValues(
            shared: s.shared, kinds: {...s.kinds, kind.apiValue: values});
      });
  Future<void> apply<T>(
      KindSetting<T> setting,
      T value,
      Map<CatalogMediaKind, LibraryKindSettingsContribution>
          compatibleEnabledKinds) {
    if (setting.scope != KindSettingScope.kindOverridable) {
      throw ArgumentError('Setting does not support Apply to all');
    }
    setting.checked(value);
    return _update((s) => KindSettingsValues(shared: s.shared, kinds: {
          ...s.kinds,
          for (final kind in compatibleEnabledKinds.keys.where((kind) =>
              compatibleEnabledKinds[kind]!.find(setting.id)?.scope ==
              KindSettingScope.kindOverridable))
            kind.apiValue: {...?s.kinds[kind.apiValue], setting.id: value},
        }));
  }
}
