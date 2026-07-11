import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
    await movieStore.writeFolderPreset(
      LibraryFolderPreset.single('publisher'),
    );

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(reloadedStore.cachedQuickView, LibraryQuickView.wishlist);
    expect(reloadedStore.cachedFolderPreset, LibraryFolderPreset.single('publisher'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('library.movie.folderPreset'), 'group.publisher');
  });

  test('read populates cache and clearing removes cached values', () async {
    SharedPreferences.setMockInitialValues({
      'library.movie.quickView': LibraryQuickView.owned.name,
      'library.movie.folderPreset': 'year',
    });

    expect(await movieStore.readQuickView(), LibraryQuickView.owned);
    expect(
      await movieStore.readFolderPreset(),
      LibraryFolderPreset.single('year'),
    );
    expect(movieStore.cachedQuickView, LibraryQuickView.owned);
    expect(movieStore.cachedFolderPreset, LibraryFolderPreset.single('year'));

    await movieStore.writeQuickView(null);
    await movieStore.writeFolderPreset(null);

    expect(movieStore.cachedQuickView, isNull);
    expect(movieStore.cachedFolderPreset, isNull);
  });

  test('pinned group modes preserve persisted order', () async {
    await movieStore.writePinnedGroupModes({
      'director',
      'release_year',
      'title',
    });

    final restored = await movieStore.readPinnedGroupModes();

    expect(restored.toList(), [
      'director',
      'release_year',
      'title',
    ]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('library.movie.pinnedGroupModes'), [
      'group.director',
      'group.release_year',
      'group.title',
    ]);
  });

  test('folder preset caches and restores composite modes', () async {
    final preset = LibraryFolderPreset(
      modes: [
        'age_rating',
        'country',
        'release_year',
      ],
    );

    await movieStore.writeFolderPreset(preset);

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(reloadedStore.cachedFolderPreset, preset);
    expect(await reloadedStore.readFolderPreset(), preset);
  });

  test('pinned folder presets preserve persisted order', () async {
    final presets = [
      LibraryFolderPreset.single('director'),
      LibraryFolderPreset(
        modes: ['age_rating', 'country'],
      ),
      LibraryFolderPreset(
        modes: [
          'age_rating',
          'release_year',
          'series',
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
        'director',
        'release_year',
      ],
    });

    final restored = await movieStore.readPinnedFolderPresets();

    expect(
      restored,
      [
        LibraryFolderPreset.single('director'),
        LibraryFolderPreset.single('release_year'),
      ],
    );
  });

  test('folder tree state is cached per preset', () async {
    final preset = LibraryFolderPreset.single('series');

    await movieStore.writeFolderDisplayMode(
      preset,
      LibraryFolderDisplayMode.tree,
    );
    await movieStore.writeFolderTreeExpandedNodeIds(
      preset,
      <String>{'root', 'root|series=Batman'},
    );
    await movieStore.writeFolderTreeSelectedNodeId(
      preset,
      'root|series=Batman',
    );

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(
      reloadedStore.cachedFolderDisplayMode(preset),
      LibraryFolderDisplayMode.tree,
    );
    expect(
      reloadedStore.cachedFolderTreeExpandedNodeIds(preset),
      <String>{'root', 'root|series=Batman'},
    );
    expect(
      reloadedStore.cachedFolderTreeSelectedNodeId(preset),
      'root|series=Batman',
    );

    expect(
      await movieStore.readFolderDisplayMode(preset),
      LibraryFolderDisplayMode.tree,
    );
    expect(
      await movieStore.readFolderTreeExpandedNodeIds(preset),
      <String>{'root', 'root|series=Batman'},
    );
    expect(
      await movieStore.readFolderTreeSelectedNodeId(preset),
      'root|series=Batman',
    );
  });

  test('group presentation override and collapsed groups are cached per preset',
      () async {
    final preset = LibraryFolderPreset.single('series');

    await movieStore.writeGroupPresentationOverride(
      preset,
      LibraryGroupPresentation.folderGrid,
    );
    await movieStore.writeCollapsedGroupBuckets(
      preset,
      <String>{'Batman', 'Superman'},
    );

    const reloadedStore = LibraryViewPreferenceStore(CatalogMediaKind.movie);
    expect(
      reloadedStore.cachedGroupPresentationOverride(preset),
      LibraryGroupPresentation.folderGrid,
    );
    expect(
      reloadedStore.cachedCollapsedGroupBuckets(preset),
      <String>{'Batman', 'Superman'},
    );
    expect(
      await reloadedStore.readGroupPresentationOverride(preset),
      LibraryGroupPresentation.folderGrid,
    );
    expect(
      await reloadedStore.readCollapsedGroupBuckets(preset),
      <String>{'Batman', 'Superman'},
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
