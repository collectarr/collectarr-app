import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What Update from Core does with one field of a linked entry.
enum CoreUpdateMode {
  /// Leave the entry's value alone.
  skip,

  /// Fill the field only when the entry has no value.
  update,

  /// Overwrite the entry's value with Core's.
  replace,
}

/// Fields Core owns for identity; an update never changes them.
const Set<String> kCoreDataLockedFields = {'id', 'kind', 'revision'};

/// Fields every Add from Core downloads, because an entry cannot exist
/// without them.
const Set<String> kCoreDataAlwaysDownloaded = {
  ...kCoreDataLockedFields,
  'title'
};

/// One non-personal field the Core data settings let the user control. A key
/// like `discs.tracks` names a child list inside each entry of `discs`.
typedef CoreDataField = ({String key, String label});

/// Per-kind choice of which non-personal fields are downloaded when adding
/// from Core and how Update from Core treats each one.
@immutable
class CoreDataSettings {
  const CoreDataSettings({
    this.skippedDownloads = const {},
    this.updateModes = const {},
  });

  /// Field keys that Add from Core leaves empty.
  final Set<String> skippedDownloads;

  /// Explicit per-field update choices; a missing key means [CoreUpdateMode.update].
  final Map<String, CoreUpdateMode> updateModes;

  bool downloads(String key) =>
      kCoreDataAlwaysDownloaded.contains(key) ||
      !skippedDownloads.contains(key);

  CoreUpdateMode modeFor(String key) =>
      updateModes[key] ?? CoreUpdateMode.update;

  CoreDataSettings copyWith({
    Set<String>? skippedDownloads,
    Map<String, CoreUpdateMode>? updateModes,
  }) =>
      CoreDataSettings(
        skippedDownloads: skippedDownloads ?? this.skippedDownloads,
        updateModes: updateModes ?? this.updateModes,
      );

  static String _skipKey(CatalogMediaKind kind) =>
      'collectarr.core_data.${kind.apiValue}.skipped_downloads';
  static String _modesKey(CatalogMediaKind kind) =>
      'collectarr.core_data.${kind.apiValue}.update_modes';

  static Future<CoreDataSettings> load(CatalogMediaKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    final modes = prefs.getString(_modesKey(kind));
    return CoreDataSettings(
      skippedDownloads:
          (prefs.getStringList(_skipKey(kind)) ?? const []).toSet(),
      updateModes: modes == null
          ? const {}
          : {
              for (final entry
                  in (jsonDecode(modes) as Map<String, dynamic>).entries)
                entry.key: CoreUpdateMode.values.byName(entry.value as String),
            },
    );
  }

  Future<void> save(CatalogMediaKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _skipKey(kind), skippedDownloads.toList()..sort());
    await prefs.setString(
        _modesKey(kind),
        jsonEncode({
          for (final entry in updateModes.entries)
            if (entry.value != CoreUpdateMode.update)
              entry.key: entry.value.name,
        }));
  }

  /// [coreData] without the fields Add from Core leaves empty.
  Map<String, dynamic> withoutSkippedDownloads(Map<String, dynamic> coreData) {
    final result = {
      for (final entry in coreData.entries)
        if (downloads(entry.key)) entry.key: entry.value,
    };
    for (final key in skippedDownloads) {
      final (parent, child) = _nested(key) ?? ('', '');
      final list = result[parent];
      if (list is! List) continue;
      result[parent] = [
        for (final element in list)
          element is Map ? ({...element}..remove(child)) : element,
      ];
    }
    return result;
  }

  static (String, String)? _nested(String key) {
    final dot = key.indexOf('.');
    return dot < 0 ? null : (key.substring(0, dot), key.substring(dot + 1));
  }

  /// [entryData] after Update from Core: each field follows its mode, using
  /// Core's value only when it has one.
  Map<String, dynamic> applyUpdate({
    required Map<String, dynamic> entryData,
    required Map<String, dynamic> coreData,
  }) {
    final result = Map<String, dynamic>.from(entryData);
    for (final entry in coreData.entries) {
      final key = entry.key;
      if (kCoreDataLockedFields.contains(key) ||
          !downloads(key) ||
          _isEmpty(entry.value)) {
        continue;
      }
      switch (modeFor(key)) {
        case CoreUpdateMode.skip:
          break;
        case CoreUpdateMode.update:
          if (_isEmpty(result[key])) result[key] = entry.value;
        case CoreUpdateMode.replace:
          result[key] = entry.value;
      }
    }
    for (final key in {...skippedDownloads, ...updateModes.keys}) {
      final nested = _nested(key);
      if (nested == null) continue;
      _applyNestedUpdate(
          result, entryData, coreData, key, nested.$1, nested.$2);
    }
    return result;
  }

  /// Applies the mode of `parent.child` to each element of the list `parent`,
  /// pairing the entry's and Core's elements by position.
  void _applyNestedUpdate(
    Map<String, dynamic> result,
    Map<String, dynamic> entryData,
    Map<String, dynamic> coreData,
    String key,
    String parent,
    String child,
  ) {
    final base = result[parent];
    if (base is! List) return;
    final old = entryData[parent];
    final core = coreData[parent];
    Map<dynamic, dynamic>? at(Object? list, int index) =>
        list is List && index < list.length && list[index] is Map
            ? list[index] as Map<dynamic, dynamic>
            : null;
    final mode = downloads(key) ? modeFor(key) : CoreUpdateMode.skip;
    result[parent] = [
      for (var i = 0; i < base.length; i++)
        if (base[i] is! Map)
          base[i]
        else
          () {
            final element = Map<String, dynamic>.from(base[i] as Map);
            final oldElement = at(old, i);
            final coreValue = at(core, i)?[child];
            switch (mode) {
              case CoreUpdateMode.skip:
                if (oldElement != null && oldElement.containsKey(child)) {
                  element[child] = oldElement[child];
                }
              case CoreUpdateMode.update:
                if (_isEmpty(element[child]) && !_isEmpty(coreValue)) {
                  element[child] = coreValue;
                }
              case CoreUpdateMode.replace:
                if (!_isEmpty(coreValue)) element[child] = coreValue;
            }
            return element;
          }(),
    ];
  }

  static bool _isEmpty(Object? value) =>
      value == null ||
      (value is String && value.trim().isEmpty) ||
      (value is Iterable && value.isEmpty) ||
      (value is Map && value.isEmpty);
}
