import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the quick-view filter and group mode for each generic library type.
class LibraryViewPreferenceStore {
  const LibraryViewPreferenceStore(this.kind);

  static final _cachedQuickViews = <String, LibraryQuickView>{};
  static final _cachedGroupModes = <String, LibraryGroupMode>{};

  final Object? kind;

  String _key(String suffix) =>
      'library.${catalogMediaKindFromValue(kind).apiValue}.$suffix';

  String get _cacheKey => _key('');

  LibraryQuickView? get cachedQuickView => _cachedQuickViews[_cacheKey];

  LibraryGroupMode? get cachedGroupMode => _cachedGroupModes[_cacheKey];

  static void resetCachedPreferencesForTesting() {
    _cachedQuickViews.clear();
    _cachedGroupModes.clear();
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
}
