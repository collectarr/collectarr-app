import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicsGroupingPreferenceStore {
  const ComicsGroupingPreferenceStore();

  static const _modeKey = 'comics.grouping.mode';

  Future<ComicsShelfGroupMode> read() async {
    final prefs = await SharedPreferences.getInstance();
    return _modeByName(prefs.getString(_modeKey));
  }

  Future<void> write(ComicsShelfGroupMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  static ComicsShelfGroupMode _modeByName(String? name) {
    for (final mode in ComicsShelfGroupMode.values) {
      if (mode.name == name) {
        return mode;
      }
    }
    return ComicsShelfGroupMode.series;
  }
}
