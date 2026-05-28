import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the quick-view filter, group mode, and pinned group modes
/// for each generic library type.
class LibraryViewPreferenceStore {
  const LibraryViewPreferenceStore(this.kind);

  static final _cachedQuickViews = <String, LibraryQuickView>{};
  static final _cachedGroupModes = <String, LibraryGroupMode>{};
  static final _cachedPinnedGroupModes = <String, Set<LibraryGroupMode>>{};
  static final _cachedPinnedViewPresets =
      <String, Set<LibraryWorkspacePreset>>{};
  static final _cachedPinnedSortFavoriteIds = <String, Set<String>>{};
  static final _cachedPinnedColumnFavoriteKeys = <String, Set<String>>{};

  final Object? kind;

  String _key(String suffix) =>
      'library.${catalogMediaKindFromValue(kind).apiValue}.$suffix';

  String get _cacheKey => _key('');

  LibraryQuickView? get cachedQuickView => _cachedQuickViews[_cacheKey];

  LibraryGroupMode? get cachedGroupMode => _cachedGroupModes[_cacheKey];

  static void resetCachedPreferencesForTesting() {
    _cachedQuickViews.clear();
    _cachedGroupModes.clear();
    _cachedPinnedGroupModes.clear();
    _cachedPinnedViewPresets.clear();
    _cachedPinnedSortFavoriteIds.clear();
    _cachedPinnedColumnFavoriteKeys.clear();
  }

  Future<LibraryQuickView?> readQuickView() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key('quickView'));
    if (name == null) {
      _cachedQuickViews.remove(_cacheKey);
      return null;
    }
    for (final view in LibraryQuickView.values) {
      if (view.name == name) {
        _cachedQuickViews[_cacheKey] = view;
        return view;
      }
    }
    _cachedQuickViews.remove(_cacheKey);
    return null;
  }

  Future<void> writeQuickView(LibraryQuickView? view) async {
    if (view == null) {
      _cachedQuickViews.remove(_cacheKey);
    } else {
      _cachedQuickViews[_cacheKey] = view;
    }
    final prefs = await SharedPreferences.getInstance();
    if (view == null) {
      await prefs.remove(_key('quickView'));
    } else {
      await prefs.setString(_key('quickView'), view.name);
    }
  }

  Future<LibraryGroupMode?> readGroupMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key('groupMode'));
    if (name == null) {
      _cachedGroupModes.remove(_cacheKey);
      return null;
    }
    for (final mode in LibraryGroupMode.values) {
      if (mode.name == name) {
        _cachedGroupModes[_cacheKey] = mode;
        return mode;
      }
    }
    _cachedGroupModes.remove(_cacheKey);
    return null;
  }

  Future<void> writeGroupMode(LibraryGroupMode? mode) async {
    if (mode == null) {
      _cachedGroupModes.remove(_cacheKey);
    } else {
      _cachedGroupModes[_cacheKey] = mode;
    }
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      await prefs.remove(_key('groupMode'));
    } else {
      await prefs.setString(_key('groupMode'), mode.name);
    }
  }

  Set<LibraryGroupMode> get cachedPinnedGroupModes =>
      _cachedPinnedGroupModes[_cacheKey] ?? const {};

  Set<LibraryWorkspacePreset> get cachedPinnedViewPresets =>
      _cachedPinnedViewPresets[_cacheKey] ?? const {};

  Set<String> get cachedPinnedSortFavoriteIds =>
      _cachedPinnedSortFavoriteIds[_cacheKey] ?? const {};

  Set<String> get cachedPinnedColumnFavoriteKeys =>
      _cachedPinnedColumnFavoriteKeys[_cacheKey] ?? const {};

  Future<Set<LibraryGroupMode>> readPinnedGroupModes() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_key('pinnedGroupModes'));
    if (names == null) {
      _cachedPinnedGroupModes.remove(_cacheKey);
      return const {};
    }
    final modes = <LibraryGroupMode>{};
    for (final name in names) {
      for (final mode in LibraryGroupMode.values) {
        if (mode.name == name) {
          modes.add(mode);
          break;
        }
      }
    }
    _cachedPinnedGroupModes[_cacheKey] = modes;
    return modes;
  }

  Future<void> writePinnedGroupModes(Set<LibraryGroupMode> modes) async {
    _cachedPinnedGroupModes[_cacheKey] = modes;
    final prefs = await SharedPreferences.getInstance();
    if (modes.isEmpty) {
      await prefs.remove(_key('pinnedGroupModes'));
    } else {
      await prefs.setStringList(
        _key('pinnedGroupModes'),
        modes.map((m) => m.name).toList(),
      );
    }
  }

  Future<Set<LibraryWorkspacePreset>> readPinnedViewPresets({
    Set<LibraryWorkspacePreset> fallback = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_key('pinnedViewPresets'));
    if (names == null) {
      _cachedPinnedViewPresets[_cacheKey] = fallback;
      return fallback;
    }
    final presets = <LibraryWorkspacePreset>{};
    for (final name in names) {
      for (final preset in LibraryWorkspacePreset.values) {
        if (preset.name == name) {
          presets.add(preset);
          break;
        }
      }
    }
    _cachedPinnedViewPresets[_cacheKey] = presets;
    return presets;
  }

  Future<void> writePinnedViewPresets(
    Set<LibraryWorkspacePreset> presets,
  ) async {
    _cachedPinnedViewPresets[_cacheKey] = presets;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key('pinnedViewPresets'),
      presets.map((preset) => preset.name).toList(),
    );
  }

  Future<Set<String>> readPinnedSortFavoriteIds({
    Set<String> fallback = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key('pinnedSortFavoriteIds'));
    if (values == null) {
      _cachedPinnedSortFavoriteIds[_cacheKey] = fallback;
      return fallback;
    }
    final ids = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    _cachedPinnedSortFavoriteIds[_cacheKey] = ids;
    return ids;
  }

  Future<void> writePinnedSortFavoriteIds(Set<String> ids) async {
    _cachedPinnedSortFavoriteIds[_cacheKey] = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key('pinnedSortFavoriteIds'),
      ids.toList(growable: false),
    );
  }

  Future<Set<String>> readPinnedColumnFavoriteKeys({
    Set<String> fallback = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key('pinnedColumnFavoriteKeys'));
    if (values == null) {
      _cachedPinnedColumnFavoriteKeys[_cacheKey] = fallback;
      return fallback;
    }
    final keys = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    _cachedPinnedColumnFavoriteKeys[_cacheKey] = keys;
    return keys;
  }

  Future<void> writePinnedColumnFavoriteKeys(Set<String> keys) async {
    _cachedPinnedColumnFavoriteKeys[_cacheKey] = keys;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key('pinnedColumnFavoriteKeys'),
      keys.toList(growable: false),
    );
  }
}
