import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final config = LibraryWorkspaceConfig(
    kind: CatalogMediaKind.comic,
    title: 'Comics',
    icon: Icons.menu_book,
    accent: Colors.red,
    preferencePrefix: 'test.comics',
  );

  final typeConfig = LibraryTypeConfig(
    workspace: config,
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    defaultMetadataProvider: 'mock',
    metadataProviders: const [],
    trackingProfile: const MediaTrackingProfile(
      name: 'Mock',
      options: [],
    ),
  );
  final runtime = libraryKindRuntimeForType(typeConfig);
  LibraryFieldIdRuntime field(String value) =>
      runtime.fields.decodeColumnId(value);
  LibrarySortIdRuntime sort(String value) => runtime.fields.decodeSortId(value);

  final profile = LibraryWorkspaceViewProfile(
    type: typeConfig,
    defaultCoverSize: 128,
    minCoverSize: 100,
    maxCoverSize: 200,
    presetConfig: (preset) {
      return switch (preset) {
        LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.list,
            detailsLayout: LibraryDetailsLayout.bottom,
            coverSize: 128,
            visibleColumns: {
              field('title'),
              field('grade'),
            },
          ),
        _ => LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.grid,
            detailsLayout: LibraryDetailsLayout.right,
            coverSize: 144,
            visibleColumns: {
              field('title'),
              field('issue'),
            },
          ),
      };
    },
    clampColumnWidth: (column, width) => width.clamp(80, 240).toDouble(),
  );

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('workspace view profile builds defaults and applies presets', () {
    final defaults = profile.defaults();

    expect(defaults.viewMode, LibraryViewMode.grid);
    expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
    expect(defaults.sortId, sort('comic.series'));
    expect(defaults.coverSize, 128);
    expect(defaults.sidebarWidth, 250);
    expect(defaults.detailsWidth, 340);
    expect(defaults.detailsHeight, 300);
    expect(defaults.visibleColumnIds, runtime.fields.defaultVisibleColumns);

    final list = defaults.withPreset(LibraryWorkspacePreset.list, profile);
    expect(list.viewMode, LibraryViewMode.list);
    expect(list.detailsLayout, LibraryDetailsLayout.bottom);
    expect(list.visibleColumnIds, {
      field('title'),
      field('grade'),
    });
  });

  test('workspace view state toggles sort and clamps column widths', () {
    final state = profile
        .defaults()
        .withSortColumn(sort('grade'), profile)
        .withColumnWidth(field('title'), 999, profile);

    expect(state.sortId, sort('grade'));
    expect(state.sortAscending, isTrue);
    expect(state.columnWidths[field('title')], 240);

    final toggled = state.withSortColumn(sort('grade'), profile);
    expect(toggled.sortAscending, isFalse);
  });

  test('workspace view state preserves trailing multi-sort rules', () {
    final state = profile.defaults().withSortRules([
      LibrarySortRuleRuntime(
        sortId: sort('publisher'),
        ascending: true,
      ),
      LibrarySortRuleRuntime(
        sortId: sort('updated'),
        ascending: false,
      ),
    ], profile);

    final updated = state.withSortColumn(sort('grade'), profile);

    expect(updated.sortRules, [
      LibrarySortRuleRuntime(
        sortId: sort('grade'),
        ascending: true,
      ),
      LibrarySortRuleRuntime(
        sortId: sort('publisher'),
        ascending: true,
      ),
      LibrarySortRuleRuntime(
        sortId: sort('updated'),
        ascending: false,
      ),
    ]);
  });

  test('workspace view state reorders visible table columns', () {
    final state = profile.defaults().copyWith(
      visibleColumnIds: {
        field('title'),
        field('issue'),
        field('grade'),
      },
    );

    final reordered = state.withReorderedColumn(
      column: field('grade'),
      beforeColumn: field('issue'),
    );

    expect(reordered.visibleColumnIds.toList(), [
      field('title'),
      field('grade'),
      field('issue'),
    ]);
  });

  test('workspace view state reorders a visible column to the end', () {
    final state = profile.defaults().copyWith(
      visibleColumnIds: {
        field('title'),
        field('issue'),
        field('grade'),
      },
    );

    final reordered = state.withReorderedColumn(
      column: field('title'),
      beforeColumn: null,
    );

    expect(reordered.visibleColumnIds.toList(), [
      field('issue'),
      field('grade'),
      field('title'),
    ]);
  });

  test('workspace view profile controls initial sort direction', () {
    final newestFirstProfile = LibraryWorkspaceViewProfile(
      type: typeConfig,
      defaultCoverSize: 128,
      minCoverSize: 100,
      maxCoverSize: 200,
      presetConfig: profile.presetConfig,
      clampColumnWidth: profile.clampColumnWidth,
      sortAscendingForColumn: (column) => column != sort('updated'),
    );

    final state = newestFirstProfile.defaults().withSortColumn(
          sort('updated'),
          newestFirstProfile,
        );

    expect(state.sortId, sort('updated'));
    expect(state.sortAscending, isFalse);
  });

  test('workspace view profile persists through shared preferences', () async {
    final state = profile.defaults().copyWith(
          viewMode: LibraryViewMode.card,
          sortRules: const [
            LibrarySortRuleRuntime(
              sortId: LibrarySortId<ComicKind>('comic.publisher'),
              ascending: true,
            ),
            LibrarySortRuleRuntime(
              sortId: LibrarySortId<ComicKind>('comic.updated_at'),
              ascending: false,
            ),
          ],
          coverSize: 180,
          sidebarWidth: 300,
          detailsWidth: 420,
          detailsHeight: 280,
        );

    await profile.save(state);
    final restored = await profile.load();

    expect(restored.viewMode, LibraryViewMode.card);
    expect(restored.sortRules, [
      const LibrarySortRuleRuntime(
        sortId: LibrarySortId<ComicKind>('comic.publisher'),
        ascending: true,
      ),
      const LibrarySortRuleRuntime(
        sortId: LibrarySortId<ComicKind>('comic.updated_at'),
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 180);
    expect(restored.sidebarWidth, 300);
    expect(restored.detailsWidth, 420);
    expect(restored.detailsHeight, 280);
  });

  test('workspace view defaults reuse cached library chrome', () async {
    await LibraryWorkspacePreferences(typeConfig).write(
      profile
          .defaults()
          .copyWith(
            detailsLayout: LibraryDetailsLayout.bottom,
            sidebarWidth: 310,
            detailsWidth: 450,
          )
          .toPreferenceSnapshot(),
    );

    final defaults = profile.defaults();

    expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
    expect(defaults.sidebarWidth, 310);
    expect(defaults.detailsWidth, 450);
  });
}
