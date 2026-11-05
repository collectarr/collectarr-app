import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KindSettingScope { globalOnly, kindOverridable, kindOnly }

typedef KindSettingEditor<T> = Widget Function(
    BuildContext context, T value, ValueChanged<T> change);

/// A kind supplies meaning and an editor; shared infrastructure stores values.
class KindSetting<T> {
  const KindSetting(
      {required this.id,
      required this.label,
      required this.defaultValue,
      required this.scope,
      required this.decode,
      required this.editor,
      this.category = 'Display',
      this.order = 0,
      this.validate});
  final String id;
  final String label;
  final T defaultValue;
  final KindSettingScope scope;
  final T Function(Object?) decode;
  final bool Function(T)? validate;
  final KindSettingEditor<T> editor;
  final String category;
  final int order;

  T checked(Object? raw) {
    final value = decode(raw);
    if (validate?.call(value) == false) {
      throw FormatException('Invalid setting: $id');
    }
    return value;
  }

  Widget buildEditor(
          BuildContext context, Object? value, ValueChanged<Object?> change) =>
      editor(context, checked(value), change);
}

typedef KindSettingsSectionBuilder = Widget Function(
    BuildContext context, CatalogMediaKind kind);

class LibraryKindSettingsContribution {
  const LibraryKindSettingsContribution(
      {this.settings = const [], this.sections = const []});
  final List<KindSettingsSectionBuilder> sections;
  final List<KindSetting<Object?>> settings;
  KindSettingResolution<T> resolve<T>(KindSettingsValues values,
      KindSetting<T> setting, CatalogMediaKind kind) {
    if (find(setting.id) == null) {
      return const KindSettingResolution.unavailable();
    }
    return KindSettingResolution.available(values.resolve(setting, kind: kind));
  }

  KindSetting<Object?>? find(String id) {
    for (final setting in settings) {
      if (setting.id == id) return setting;
    }
    return null;
  }
}

class KindSettingResolution<T> {
  const KindSettingResolution.unavailable()
      : available = false,
        value = null;
  const KindSettingResolution.available(this.value) : available = true;
  final bool available;
  final T? value;
}

bool decodeBooleanSetting(Object? value) {
  if (value is! bool) throw const FormatException('Expected a boolean setting');
  return value;
}

Widget booleanSettingEditor(
        BuildContext context, bool value, ValueChanged<bool> change) =>
    Switch(value: value, onChanged: change);

const trailerVideosSetting = KindSetting<bool>(
  id: 'inspector.trailers',
  label: 'Show trailer videos',
  defaultValue: true,
  scope: KindSettingScope.kindOverridable,
  decode: decodeBooleanSetting,
  editor: booleanSettingEditor,
);

class KindSettingsValues {
  KindSettingsValues(
      {Map<String, Object?> shared = const {},
      Map<String, Map<String, Object?>> kinds = const {}})
      : shared = Map.unmodifiable(shared),
        kinds = Map.unmodifiable({
          for (final e in kinds.entries)
            e.key: Map<String, Object?>.unmodifiable(e.value)
        });
  final Map<String, Object?> shared;
  final Map<String, Map<String, Object?>> kinds;
  bool hasOverride(KindSetting<Object?> setting, CatalogMediaKind kind) =>
      kinds[kind.apiValue]?.containsKey(setting.id) ?? false;
  T resolve<T>(KindSetting<T> setting, {CatalogMediaKind? kind}) {
    if (setting.scope != KindSettingScope.globalOnly && kind == null) {
      throw ArgumentError('A kind is required for ${setting.id}');
    }
    final values = kinds[kind?.apiValue];
    if (setting.scope != KindSettingScope.globalOnly &&
        values != null &&
        values.containsKey(setting.id)) {
      return setting.checked(values[setting.id]);
    }
    if (setting.scope != KindSettingScope.kindOnly &&
        shared.containsKey(setting.id)) {
      return setting.checked(shared[setting.id]);
    }
    return setting.defaultValue;
  }

  Object? sharedValue(KindSetting<Object?> setting) =>
      shared.containsKey(setting.id)
          ? setting.checked(shared[setting.id])
          : setting.defaultValue;
  String encode() =>
      jsonEncode({'version': 1, 'shared': shared, 'kinds': kinds});
}

class KindSettingsStore {
  static const key = 'collectarr.kind_settings';
  static const _oldTrailers = 'collectarr.ui.show_inspector_trailers';
  Future<KindSettingsValues> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['version'] != 1) {
        throw const FormatException('Unsupported kind settings version');
      }
      final result = KindSettingsValues(
        shared: Map<String, Object?>.from(json['shared'] as Map),
        kinds: {
          for (final e in (json['kinds'] as Map).entries)
            e.key as String: Map<String, Object?>.from(e.value as Map)
        },
      );
      await prefs.remove(_oldTrailers);
      return result;
    }
    final old = prefs.getBool(_oldTrailers);
    final result = KindSettingsValues(
        shared: {if (old != null) trailerVideosSetting.id: old});
    await write(result);
    await prefs.remove(_oldTrailers);
    return result;
  }

  Future<void> write(KindSettingsValues values) async {
    if (!await (await SharedPreferences.getInstance())
        .setString(key, values.encode())) {
      throw StateError('Could not save library settings');
    }
  }
}

final kindSettingsProvider =
    AsyncNotifierProvider<KindSettingsController, KindSettingsValues>(
        KindSettingsController.new);

class KindSettingsController extends AsyncNotifier<KindSettingsValues> {
  Future<void> _pending = Future.value();
  @override
  Future<KindSettingsValues> build() => KindSettingsStore().read();

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
