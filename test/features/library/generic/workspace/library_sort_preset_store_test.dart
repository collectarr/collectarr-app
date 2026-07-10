import 'dart:convert';

import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves and migrates sort preset column ids', () async {
    SharedPreferences.setMockInitialValues({
      comicsWorkspaceConfig.preferenceKey('sort_presets'): jsonEncode([
        {
          'id': 'legacy-preset',
          'label': 'Legacy sort',
          'rules': [
            {'column': 'grade', 'ascending': false},
          ],
        },
      ]),
    });

    final store = LibrarySortPresetStore(comicsLibraryConfig);
    final restored = await store.read();

    expect(restored, hasLength(1));
    expect(restored.single.rules.single.column, LibrarySortColumn.grade);

    await store.savePreset(
      id: restored.single.id,
      label: 'Legacy sort',
      rules: restored.single.rules,
    );

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(comicsWorkspaceConfig.preferenceKey('sort_presets'));
    expect(raw, isNotNull);
    expect(raw, contains('comic.grade'));
  });
}
