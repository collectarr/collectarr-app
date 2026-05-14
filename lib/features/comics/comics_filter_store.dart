import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicsFilterPreferenceStore {
  const ComicsFilterPreferenceStore();

  static const _prefix = 'comics.filters';
  static final _ownershipFiltersByName = {
    for (final value in ComicsOwnershipFilter.values) value.name: value,
  };

  Future<ComicsFilterSelection> read() async {
    final prefs = await SharedPreferences.getInstance();
    return ComicsFilterSelection(
      ownershipFilter: _ownershipFilterByName(
        prefs.getString(_key('ownership')),
      ),
      grade: _clean(prefs.getString(_key('grade'))),
      condition: _clean(prefs.getString(_key('condition'))),
      publisher: _clean(prefs.getString(_key('publisher'))),
      releaseYear: _clean(prefs.getString(_key('release_year'))),
      missingCover: prefs.getBool(_key('missing_cover')) ?? false,
      missingMetadata: prefs.getBool(_key('missing_metadata')) ?? false,
    );
  }

  Future<void> write(ComicsFilterSelection selection) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_key('ownership'), selection.ownershipFilter.name),
      _writeNullable(prefs, _key('grade'), selection.grade),
      _writeNullable(prefs, _key('condition'), selection.condition),
      _writeNullable(prefs, _key('publisher'), selection.publisher),
      _writeNullable(prefs, _key('release_year'), selection.releaseYear),
      prefs.setBool(_key('missing_cover'), selection.missingCover),
      prefs.setBool(_key('missing_metadata'), selection.missingMetadata),
    ]);
  }

  static String _key(String suffix) => '$_prefix.$suffix';

  static ComicsOwnershipFilter _ownershipFilterByName(String? name) {
    return _ownershipFiltersByName[name] ?? ComicsOwnershipFilter.all;
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static Future<void> _writeNullable(
    SharedPreferences prefs,
    String key,
    String? value,
  ) {
    final cleaned = _clean(value);
    if (cleaned == null) {
      return prefs.remove(key);
    }
    return prefs.setString(key, cleaned);
  }
}
