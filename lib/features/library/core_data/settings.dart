import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_metadata_contributors.dart';
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

/// One row of Add/Update from Core Settings: an editor field and the Core
/// keys it is filled from, which always share one choice. A key like
/// `discs.tracks` names a child list inside each entry of `discs`.
typedef CoreDataSettingsField = ({String label, List<String> keys});

/// One tab of a kind's edit dialog and the Core-filled fields it shows, in
/// the editor's order; the settings dialog groups its rows by these tabs.
typedef CoreDataSettingsTab = ({
  String id,
  String label,
  List<CoreDataSettingsField> fields,
});

/// Per-kind choice of which non-personal fields are downloaded when adding
/// from Core and how Update from Core treats each one. Each edit tab has its
/// own choice; a field set apart from its tab overrides it.
@immutable
class CoreDataSettings {
  const CoreDataSettings({
    this.fieldTabs = const {},
    this.skippedTabs = const {},
    this.skippedDownloads = const {},
    this.keptDownloads = const {},
    this.tabUpdateModes = const {},
    this.updateModes = const {},
  });

  /// The edit tab of each Core key, from the kind's settings tabs.
  final Map<String, String> fieldTabs;

  /// Tabs whose fields Add from Core leaves empty unless a field overrides.
  final Set<String> skippedTabs;

  /// Field keys Add from Core leaves empty whatever their tab says.
  final Set<String> skippedDownloads;

  /// Field keys Add from Core downloads although their tab is skipped.
  final Set<String> keptDownloads;

  /// Per-tab update choices; a missing tab means [CoreUpdateMode.update].
  final Map<String, CoreUpdateMode> tabUpdateModes;

  /// Per-field update choices that override their tab's.
  final Map<String, CoreUpdateMode> updateModes;

  /// Whether Add from Core leaves any field empty.
  bool get skipsAnyDownload =>
      skippedDownloads.isNotEmpty || skippedTabs.isNotEmpty;

  bool tabDownloads(String tab) => !skippedTabs.contains(tab);

  CoreUpdateMode tabModeFor(String tab) =>
      tabUpdateModes[tab] ?? CoreUpdateMode.update;

  bool downloads(String key) {
    if (kCoreDataAlwaysDownloaded.contains(key)) return true;
    if (skippedDownloads.contains(key)) return false;
    if (keptDownloads.contains(key)) return true;
    final tab = fieldTabs[key];
    return tab == null || tabDownloads(tab);
  }

  CoreUpdateMode modeFor(String key) {
    final tab = fieldTabs[key];
    return updateModes[key] ??
        (tab == null ? CoreUpdateMode.update : tabModeFor(tab));
  }

  CoreDataSettings copyWith({
    Set<String>? skippedTabs,
    Set<String>? skippedDownloads,
    Set<String>? keptDownloads,
    Map<String, CoreUpdateMode>? tabUpdateModes,
    Map<String, CoreUpdateMode>? updateModes,
  }) =>
      CoreDataSettings(
        fieldTabs: fieldTabs,
        skippedTabs: skippedTabs ?? this.skippedTabs,
        skippedDownloads: skippedDownloads ?? this.skippedDownloads,
        keptDownloads: keptDownloads ?? this.keptDownloads,
        tabUpdateModes: tabUpdateModes ?? this.tabUpdateModes,
        updateModes: updateModes ?? this.updateModes,
      );

  static String _key(CatalogMediaKind kind, String name) =>
      'collectarr.core_data.${kind.apiValue}.$name';

  /// The saved settings of [kind], resolved against its edit tabs.
  static Future<CoreDataSettings> load(CatalogMediaKind kind) async {
    final tabs = libraryCoreDataTabsForKind(kind) ?? const [];
    final prefs = await SharedPreferences.getInstance();
    Set<String> list(String name) =>
        (prefs.getStringList(_key(kind, name)) ?? const []).toSet();
    Map<String, CoreUpdateMode> modes(String name) {
      final json = prefs.getString(_key(kind, name));
      return json == null
          ? const {}
          : {
              for (final entry
                  in (jsonDecode(json) as Map<String, dynamic>).entries)
                entry.key: CoreUpdateMode.values.byName(entry.value as String),
            };
    }

    return CoreDataSettings(
      fieldTabs: {
        for (final tab in tabs)
          for (final field in tab.fields)
            for (final key in field.keys) key: tab.id,
      },
      skippedTabs: list('skipped_download_tabs'),
      skippedDownloads: list('skipped_downloads'),
      keptDownloads: list('kept_downloads'),
      tabUpdateModes: modes('tab_update_modes'),
      updateModes: modes('update_modes'),
    );
  }

  Future<void> save(CatalogMediaKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> list(String name, Set<String> values) =>
        prefs.setStringList(_key(kind, name), values.toList()..sort());
    Future<void> modes(String name, Map<String, CoreUpdateMode> values) =>
        prefs.setString(_key(kind, name),
            jsonEncode({for (final e in values.entries) e.key: e.value.name}));
    await list('skipped_download_tabs', skippedTabs);
    await list('skipped_downloads', skippedDownloads);
    await list('kept_downloads', keptDownloads);
    await modes('tab_update_modes', {
      for (final entry in tabUpdateModes.entries)
        if (entry.value != CoreUpdateMode.update) entry.key: entry.value,
    });
    await modes('update_modes', updateModes);
  }

  /// [coreData] without the fields Add from Core leaves empty.
  Map<String, dynamic> withoutSkippedDownloads(Map<String, dynamic> coreData) {
    final result = {
      for (final entry in coreData.entries)
        if (downloads(entry.key)) entry.key: entry.value,
    };
    for (final key in {...skippedDownloads, ...fieldTabs.keys}) {
      if (downloads(key)) continue;
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
    for (final key in {
      ...skippedDownloads,
      ...updateModes.keys,
      ...fieldTabs.keys
    }) {
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
