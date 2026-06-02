import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const movieStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);

  setUp(() {
    LibraryViewPreferenceStore.resetCachedPreferencesForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('write caches quick view and group mode for reuse', () async {
    await movieStore.writeQuickView(LibraryQuickView.wishlist);
    await movieStore.writeGroupMode(LibraryGroupMode.publisher);

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(reloadedStore.cachedQuickView, LibraryQuickView.wishlist);
    expect(reloadedStore.cachedGroupMode, LibraryGroupMode.publisher);
  });

  test('read populates cache and clearing removes cached values', () async {
    SharedPreferences.setMockInitialValues({
      'library.movie.quickView': LibraryQuickView.owned.name,
      'library.movie.groupMode': LibraryGroupMode.year.name,
    });

    expect(await movieStore.readQuickView(), LibraryQuickView.owned);
    expect(await movieStore.readGroupMode(), LibraryGroupMode.year);
    expect(movieStore.cachedQuickView, LibraryQuickView.owned);
    expect(movieStore.cachedGroupMode, LibraryGroupMode.year);

    await movieStore.writeQuickView(null);
    await movieStore.writeGroupMode(null);

    expect(movieStore.cachedQuickView, isNull);
    expect(movieStore.cachedGroupMode, isNull);
  });

  test('pinned group modes preserve persisted order', () async {
    await movieStore.writePinnedGroupModes({
      LibraryGroupMode.director,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.title,
    });

    final restored = await movieStore.readPinnedGroupModes();

    expect(restored.toList(), [
      LibraryGroupMode.director,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.title,
    ]);
  });

  test('folder preset caches and restores composite modes', () async {
    final preset = LibraryFolderPreset(
      modes: [
        LibraryGroupMode.ageRating,
        LibraryGroupMode.country,
        LibraryGroupMode.releaseYear,
      ],
    );

    await movieStore.writeFolderPreset(preset);

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(reloadedStore.cachedFolderPreset, preset);
    expect(await reloadedStore.readFolderPreset(), preset);
  });

  test('pinned folder presets preserve persisted order', () async {
    final presets = [
      LibraryFolderPreset.single(LibraryGroupMode.director),
      LibraryFolderPreset(
        modes: [LibraryGroupMode.ageRating, LibraryGroupMode.country],
      ),
      LibraryFolderPreset(
        modes: [
          LibraryGroupMode.ageRating,
          LibraryGroupMode.releaseYear,
          LibraryGroupMode.series,
        ],
      ),
    ];

    await movieStore.writePinnedFolderPresets(presets);

    final restored = await movieStore.readPinnedFolderPresets();

    expect(restored, presets);
  });

  test('pinned folder presets migrate legacy single-mode favorites', () async {
    SharedPreferences.setMockInitialValues({
      'library.movie.pinnedGroupModes': [
        LibraryGroupMode.director.name,
        LibraryGroupMode.releaseYear.name,
      ],
    });

    final restored = await movieStore.readPinnedFolderPresets();

    expect(
      restored,
      [
        LibraryFolderPreset.single(LibraryGroupMode.director),
        LibraryFolderPreset.single(LibraryGroupMode.releaseYear),
      ],
    );
  });

  test('pinned sort favorite ids preserve persisted order', () async {
    await movieStore.writePinnedSortFavoriteIds(
      <String>{'price_desc', 'title_asc', 'updated_desc'},
    );

    final restored = await movieStore.readPinnedSortFavoriteIds();

    expect(restored.toList(), ['price_desc', 'title_asc', 'updated_desc']);
  });
}