import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the quick-view filter, group mode, and pinned group modes
/// for each generic library type.
class LibraryViewPreferenceStore {
  const LibraryViewPreferenceStore(this.kind);

  static final _cachedQuickViews = <String, LibraryQuickView>{};
  static final _cachedFolderPresets = <String, LibraryFolderPreset>{};
  static final _cachedPinnedGroupModes = <String, Set<LibraryGroupMode>>{};
  static final _cachedPinnedFolderPresets =
    <String, List<LibraryFolderPreset>>{};
  static final _cachedPinnedViewPresets =
      <String, Set<LibraryWorkspacePreset>>{};
  static final _cachedPinnedSortFavoriteIds = <String, Set<String>>{};
  static final _cachedPinnedColumnFavoriteKeys = <String, Set<String>>{};
  static final _cachedFolderDisplayModes =
      <String, LibraryFolderDisplayMode>{};
  static final _cachedFolderTreeExpandedNodeIds = <String, Set<String>>{};
  static final _cachedFolderTreeSelectedNodeIds = <String, String?>{};
  static final _cachedGroupPresentationOverrides =
      <String, LibraryGroupPresentation>{};
  static final _cachedCollapsedGroupBuckets = <String, Set<String>>{};

  final Object? kind;

  String _key(String suffix) =>
      'library.${catalogMediaKindFromValue(kind).apiValue}.$suffix';

  String get _cacheKey => _key('');

  LibraryQuickView? get cachedQuickView => _cachedQuickViews[_cacheKey];

  LibraryFolderPreset? get cachedFolderPreset => _cachedFolderPresets[_cacheKey];

  LibraryFolderDisplayMode? cachedFolderDisplayMode(
    LibraryFolderPreset preset,
  ) {
    return _cachedFolderDisplayModes[_folderTreeCacheKey(preset)];
  }

  LibraryGroupPresentation? cachedGroupPresentationOverride(
    LibraryFolderPreset preset,
  ) {
    return _cachedGroupPresentationOverrides[_folderTreeCacheKey(preset)];
  }

  Set<String> cachedCollapsedGroupBuckets(
    LibraryFolderPreset preset,
  ) {
    return _cachedCollapsedGroupBuckets[_folderTreeCacheKey(preset)] ??
        const <String>{};
  }

  Set<String> cachedFolderTreeExpandedNodeIds(
    LibraryFolderPreset preset,
  ) {
    return _cachedFolderTreeExpandedNodeIds[_folderTreeCacheKey(preset)] ??
        const <String>{};
  }

  String? cachedFolderTreeSelectedNodeId(
    LibraryFolderPreset preset,
  ) {
    return _cachedFolderTreeSelectedNodeIds[_folderTreeCacheKey(preset)];
  }

  static void resetCachedPreferencesForTesting() {
    _cachedQuickViews.clear();
    _cachedFolderPresets.clear();
    _cachedPinnedGroupModes.clear();
    _cachedPinnedFolderPresets.clear();
    _cachedPinnedViewPresets.clear();
    _cachedPinnedSortFavoriteIds.clear();
    _cachedPinnedColumnFavoriteKeys.clear();
    _cachedFolderDisplayModes.clear();
    _cachedFolderTreeExpandedNodeIds.clear();
    _cachedFolderTreeSelectedNodeIds.clear();
    _cachedGroupPresentationOverrides.clear();
    _cachedCollapsedGroupBuckets.clear();
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

  List<LibraryFolderPreset> get cachedPinnedFolderPresets =>
      _cachedPinnedFolderPresets[_cacheKey] ?? const [];

  Future<LibraryFolderPreset?> readFolderPreset({
    Iterable<LibraryGroupMode>? allowedModes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key('folderPreset'));
    if (raw == null || raw.trim().isEmpty) {
      _cachedFolderPresets.remove(_cacheKey);
      return null;
    }
    final preset = _tryParsePreset(raw, allowedModes: allowedModes);
    if (preset == null) {
      _cachedFolderPresets.remove(_cacheKey);
      return null;
    }
    _cachedFolderPresets[_cacheKey] = preset;
    return preset;
  }

  Future<void> writeFolderPreset(LibraryFolderPreset? preset) async {
    if (preset == null) {
      _cachedFolderPresets.remove(_cacheKey);
    } else {
      _cachedFolderPresets[_cacheKey] = preset;
    }
    final prefs = await SharedPreferences.getInstance();
    if (preset == null) {
      await prefs.remove(_key('folderPreset'));
    } else {
      await prefs.setString(_key('folderPreset'), preset.storageValue);
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

  Future<Set<LibraryGroupMode>> readPinnedGroupModes({
    Iterable<LibraryGroupMode>? allowedModes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_key('pinnedGroupModes'));
    if (names == null) {
      _cachedPinnedGroupModes.remove(_cacheKey);
      return const {};
    }
    final allowed = allowedModes == null
        ? null
        : Set<LibraryGroupMode>.from(allowedModes);
    final modes = <LibraryGroupMode>{};
    for (final name in names) {
      final mode = libraryGroupModeFromStorageValue(name);
      if (mode != null && (allowed == null || allowed.contains(mode))) {
        modes.add(mode);
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
        modes.map(libraryGroupModeStorageValue).toList(),
      );
    }
  }

  Future<List<LibraryFolderPreset>> readPinnedFolderPresets({
    Iterable<LibraryGroupMode>? allowedModes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key('pinnedFolderPresets'));
    if (values == null) {
      final fallbackModes = await readPinnedGroupModes(allowedModes: allowedModes);
      final fallback = [
        for (final mode in fallbackModes) LibraryFolderPreset.single(mode),
      ];
      _cachedPinnedFolderPresets[_cacheKey] = fallback;
      return fallback;
    }
    final presets = <LibraryFolderPreset>[];
    for (final value in values) {
      final preset = _tryParsePreset(value, allowedModes: allowedModes);
      if (preset != null && !presets.contains(preset)) {
        presets.add(preset);
      }
    }
    _cachedPinnedFolderPresets[_cacheKey] = presets;
    return presets;
  }

  Future<void> writePinnedFolderPresets(List<LibraryFolderPreset> presets) async {
    final normalized = <LibraryFolderPreset>[];
    for (final preset in presets) {
      if (!normalized.contains(preset)) {
        normalized.add(preset);
      }
    }
    _cachedPinnedFolderPresets[_cacheKey] = normalized;
    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_key('pinnedFolderPresets'));
    } else {
      await prefs.setStringList(
        _key('pinnedFolderPresets'),
        normalized.map((preset) => preset.storageValue).toList(growable: false),
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
      final normalizedFallback = _orderedUniqueStrings(fallback);
      _cachedPinnedSortFavoriteIds[_cacheKey] = normalizedFallback;
      return normalizedFallback;
    }
    final ids = _orderedUniqueStrings(values);
    _cachedPinnedSortFavoriteIds[_cacheKey] = ids;
    return ids;
  }

  Future<void> writePinnedSortFavoriteIds(Set<String> ids) async {
    final normalizedIds = _orderedUniqueStrings(ids);
    _cachedPinnedSortFavoriteIds[_cacheKey] = normalizedIds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key('pinnedSortFavoriteIds'),
      normalizedIds.toList(growable: false),
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

  Future<LibraryFolderDisplayMode?> readFolderDisplayMode(
    LibraryFolderPreset preset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_folderTreeKey(preset, 'displayMode'));
    if (name == null) {
      _cachedFolderDisplayModes.remove(_folderTreeCacheKey(preset));
      return null;
    }
    for (final mode in LibraryFolderDisplayMode.values) {
      if (mode.name == name) {
        _cachedFolderDisplayModes[_folderTreeCacheKey(preset)] = mode;
        return mode;
      }
    }
    _cachedFolderDisplayModes.remove(_folderTreeCacheKey(preset));
    return null;
  }

  Future<void> writeFolderDisplayMode(
    LibraryFolderPreset preset,
    LibraryFolderDisplayMode? mode,
  ) async {
    final cacheKey = _folderTreeCacheKey(preset);
    if (mode == null) {
      _cachedFolderDisplayModes.remove(cacheKey);
    } else {
      _cachedFolderDisplayModes[cacheKey] = mode;
    }
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      await prefs.remove(_folderTreeKey(preset, 'displayMode'));
    } else {
      await prefs.setString(_folderTreeKey(preset, 'displayMode'), mode.name);
    }
  }

  Future<Set<String>> readFolderTreeExpandedNodeIds(
    LibraryFolderPreset preset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_folderTreeKey(preset, 'expandedNodeIds'));
    if (values == null) {
      _cachedFolderTreeExpandedNodeIds.remove(_folderTreeCacheKey(preset));
      return const <String>{};
    }
    final ids = _orderedUniqueStrings(values);
    _cachedFolderTreeExpandedNodeIds[_folderTreeCacheKey(preset)] = ids;
    return ids;
  }

  Future<void> writeFolderTreeExpandedNodeIds(
    LibraryFolderPreset preset,
    Set<String> ids,
  ) async {
    final cacheKey = _folderTreeCacheKey(preset);
    final normalizedIds = _orderedUniqueStrings(ids);
    _cachedFolderTreeExpandedNodeIds[cacheKey] = normalizedIds;
    final prefs = await SharedPreferences.getInstance();
    if (normalizedIds.isEmpty) {
      await prefs.remove(_folderTreeKey(preset, 'expandedNodeIds'));
    } else {
      await prefs.setStringList(
        _folderTreeKey(preset, 'expandedNodeIds'),
        normalizedIds.toList(growable: false),
      );
    }
  }

  Future<String?> readFolderTreeSelectedNodeId(
    LibraryFolderPreset preset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_folderTreeKey(preset, 'selectedNodeId'));
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      _cachedFolderTreeSelectedNodeIds.remove(_folderTreeCacheKey(preset));
      return null;
    }
    _cachedFolderTreeSelectedNodeIds[_folderTreeCacheKey(preset)] = normalized;
    return normalized;
  }

  Future<void> writeFolderTreeSelectedNodeId(
    LibraryFolderPreset preset,
    String? nodeId,
  ) async {
    final cacheKey = _folderTreeCacheKey(preset);
    final normalized = nodeId?.trim();
    if (normalized == null || normalized.isEmpty) {
      _cachedFolderTreeSelectedNodeIds.remove(cacheKey);
    } else {
      _cachedFolderTreeSelectedNodeIds[cacheKey] = normalized;
    }
    final prefs = await SharedPreferences.getInstance();
    if (normalized == null || normalized.isEmpty) {
      await prefs.remove(_folderTreeKey(preset, 'selectedNodeId'));
    } else {
      await prefs.setString(_folderTreeKey(preset, 'selectedNodeId'), normalized);
    }
  }

  Future<LibraryGroupPresentation?> readGroupPresentationOverride(
    LibraryFolderPreset preset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_folderTreeKey(preset, 'groupPresentation'));
    if (name == null) {
      _cachedGroupPresentationOverrides.remove(_folderTreeCacheKey(preset));
      return null;
    }
    for (final presentation in LibraryGroupPresentation.values) {
      if (presentation.name == name) {
        _cachedGroupPresentationOverrides[_folderTreeCacheKey(preset)] =
            presentation;
        return presentation;
      }
    }
    _cachedGroupPresentationOverrides.remove(_folderTreeCacheKey(preset));
    return null;
  }

  Future<void> writeGroupPresentationOverride(
    LibraryFolderPreset preset,
    LibraryGroupPresentation? presentation,
  ) async {
    final cacheKey = _folderTreeCacheKey(preset);
    if (presentation == null) {
      _cachedGroupPresentationOverrides.remove(cacheKey);
    } else {
      _cachedGroupPresentationOverrides[cacheKey] = presentation;
    }
    final prefs = await SharedPreferences.getInstance();
    if (presentation == null) {
      await prefs.remove(_folderTreeKey(preset, 'groupPresentation'));
    } else {
      await prefs.setString(
        _folderTreeKey(preset, 'groupPresentation'),
        presentation.name,
      );
    }
  }

  Future<Set<String>> readCollapsedGroupBuckets(
    LibraryFolderPreset preset,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final values =
        prefs.getStringList(_folderTreeKey(preset, 'collapsedGroupBuckets'));
    if (values == null) {
      _cachedCollapsedGroupBuckets.remove(_folderTreeCacheKey(preset));
      return const <String>{};
    }
    final buckets = _orderedUniqueStrings(values);
    _cachedCollapsedGroupBuckets[_folderTreeCacheKey(preset)] = buckets;
    return buckets;
  }

  Future<void> writeCollapsedGroupBuckets(
    LibraryFolderPreset preset,
    Set<String> buckets,
  ) async {
    final cacheKey = _folderTreeCacheKey(preset);
    final normalized = _orderedUniqueStrings(buckets);
    _cachedCollapsedGroupBuckets[cacheKey] = normalized;
    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_folderTreeKey(preset, 'collapsedGroupBuckets'));
    } else {
      await prefs.setStringList(
        _folderTreeKey(preset, 'collapsedGroupBuckets'),
        normalized.toList(growable: false),
      );
    }
  }

  Set<String> _orderedUniqueStrings(Iterable<String> values) {
    final normalized = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        normalized.add(trimmed);
      }
    }
    return normalized;
  }

  LibraryFolderPreset? _tryParsePreset(
    String value, {
    Iterable<LibraryGroupMode>? allowedModes,
  }) {
    try {
      return sanitizeLibraryFolderPreset(
        LibraryFolderPreset.parse(value),
        allowedModes: allowedModes,
      );
    } on ArgumentError {
      return null;
    }
  }

  String _folderTreeCacheKey(LibraryFolderPreset preset) {
    return '$_cacheKey|${preset.storageValue}';
  }

  String _folderTreeKey(LibraryFolderPreset preset, String suffix) {
    return 'library.${catalogMediaKindFromValue(kind).apiValue}.folderTree.${preset.storageValue}.$suffix';
  }
}
