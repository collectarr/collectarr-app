import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> restartPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = {for (final key in prefs.getKeys()) key: prefs.get(key)!};
    SharedPreferences.setMockInitialValues(saved);
  }

  test(
      'sort favorite retains identity, direction and priority after storage restart',
      () async {
    const store = LibrarySortPresetStore(MusicRegistration());
    final saved = (await store.savePreset(label: 'Audit sort', rules: const [
      LibrarySortRule(column: 'music.release_date', ascending: false),
      LibrarySortRule(column: 'music.title', ascending: true),
    ]))
        .single;
    await restartPreferences();
    final restored =
        (await const LibrarySortPresetStore(MusicRegistration()).read()).single;
    expect(restored.id, saved.id);
    expect(restored.rules, saved.rules);
    expect(
        await const LibrarySortPresetStore(BookRegistration()).read(), isEmpty);
    await store.deletePreset(saved.id!);
    await restartPreferences();
    expect(await store.read(), isEmpty);
  });

  test('column favorite retains exact order and deletion after storage restart',
      () async {
    const store = LibraryColumnPresetStore(MusicRegistration());
    final saved = (await store.savePreset(label: 'Audit columns', columns: {
      'music.publisher',
      'music.title',
      'music.barcode',
    }))
        .single;
    expect(saved.columns, hasLength(3));
    await restartPreferences();
    final restored =
        (await const LibraryColumnPresetStore(MusicRegistration()).read())
            .single;
    expect(restored.id, saved.id);
    expect(restored.columns.toList(), saved.columns.toList());
    expect(await const LibraryColumnPresetStore(BookRegistration()).read(),
        isEmpty);
    await store.deletePreset(saved.id!);
    await restartPreferences();
    expect(await store.read(), isEmpty);
  });

  test(
      'nested folder favorites retain field and favorite order after storage restart',
      () async {
    const store = LibraryViewPreferenceStore(CatalogMediaKind.music);
    final nested =
        LibraryFolderPreset(modes: ['music.genre', 'music.disc.format']);
    final single = LibraryFolderPreset.single('music.artist');
    await store.writePinnedFolderPresets([nested, single]);
    await restartPreferences();
    expect(
        await const LibraryViewPreferenceStore(CatalogMediaKind.music)
            .readPinnedFolderPresets(),
        [nested, single]);
    await store.writePinnedFolderPresets([single, nested]);
    await restartPreferences();
    expect(await store.readPinnedFolderPresets(), [single, nested]);
    await store.writePinnedFolderPresets([]);
    await restartPreferences();
    expect(await store.readPinnedFolderPresets(), isEmpty);
  });
}
