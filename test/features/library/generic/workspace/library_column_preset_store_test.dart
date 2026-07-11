import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves updates and deletes table column presets', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LibraryColumnPresetStore(comicsLibraryConfig);

    final saved = await store.savePreset(
      label: 'My Value View',
      columns: const {
        'status',
        'price',
      },
    );

    expect(saved.single.id, isNotNull);
    expect(saved.single.label, 'My Value View');
    expect(saved.single.columns, contains('title'));
    expect(saved.single.columns, contains('price'));

    final updated = await store.savePreset(
      label: 'my value view',
      columns: const {
        'status',
        'grade',
      },
    );

    expect(updated.length, 1);
    expect(updated.single.columns, contains('grade'));
    expect(updated.single.columns, isNot(contains('price')));

    final deleted = await store.deletePreset(updated.single.id!);
    expect(deleted, isEmpty);
  });
}
