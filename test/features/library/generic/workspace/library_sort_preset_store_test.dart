import 'dart:convert';

import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves and restores canonical sort preset column ids', () async {
    SharedPreferences.setMockInitialValues({
      comicKindModule.identity.preferenceKey('sort_presets'): jsonEncode([
        {
          'id': 'canonical-preset',
          'label': 'Canonical sort',
          'rules': [
            {'column': 'comic.condition', 'ascending': false},
          ],
        },
      ]),
    });

    final store = LibrarySortPresetStore(comicKindModule);
    final restored = await store.read();

    expect(restored, hasLength(1));
    expect(restored.single.rules.single.column, 'comic.condition');

    await store.savePreset(
      id: restored.single.id,
      label: 'Canonical sort',
      rules: restored.single.rules,
    );

    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getString(comicKindModule.identity.preferenceKey('sort_presets'));
    expect(raw, isNotNull);
    expect(raw, contains('comic.condition'));
  });
}
