import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the quick-view filter and group mode for each generic library type.
class LibraryViewPreferenceStore {
  const LibraryViewPreferenceStore(this.kind);

  final String kind;

  String _key(String suffix) => 'library.$kind.$suffix';

  Future<LibraryQuickView?> readQuickView() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key('quickView'));
    if (name == null) return null;
    for (final view in LibraryQuickView.values) {
      if (view.name == name) return view;
    }
    return null;
  }

  Future<void> writeQuickView(LibraryQuickView? view) async {
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
    if (name == null) return null;
    for (final mode in LibraryGroupMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  Future<void> writeGroupMode(LibraryGroupMode? mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      await prefs.remove(_key('groupMode'));
    } else {
      await prefs.setString(_key('groupMode'), mode.name);
    }
  }
}
