import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = LibraryWorkspaceConfig(
    kind: CatalogMediaKind.comic,
    title: 'Comics',
    icon: Icons.menu_book,
    preferencePrefix: 'test.comics',
    defaultSortColumn: LibrarySortColumn.title,
    defaultVisibleColumns: {
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
    },
  );

  final profile = LibraryWorkspaceViewProfile(
    config: config,
    defaultCoverSize: 128,
    minCoverSize: 100,
    maxCoverSize: 200,
    presetConfig: (preset) {
      return switch (preset) {
        LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.list,
            detailsLayout: LibraryDetailsLayout.bottom,
            coverSize: 128,
            visibleColumns: {
              LibraryTableColumn.title,
              LibraryTableColumn.grade,
            },
          ),
        _ => const LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.grid,
            detailsLayout: LibraryDetailsLayout.right,
            coverSize: 144,
            visibleColumns: {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
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
    expect(defaults.detailsLayout, LibraryDetailsLayout.right);
    expect(defaults.sortColumn, LibrarySortColumn.title);
    expect(defaults.coverSize, 128);
    expect(defaults.sidebarWidth, 250);
    expect(defaults.detailsWidth, 340);
    expect(defaults.visibleColumns, {
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
    });

    final list = defaults.withPreset(LibraryWorkspacePreset.list, profile);
    expect(list.viewMode, LibraryViewMode.list);
    expect(list.detailsLayout, LibraryDetailsLayout.bottom);
    expect(list.visibleColumns, {
      LibraryTableColumn.title,
      LibraryTableColumn.grade,
    });
  });

  test('workspace view state toggles sort and clamps column widths', () {
    final state = profile
        .defaults()
        .withSortColumn(LibrarySortColumn.grade, profile)
        .withColumnWidth(LibraryTableColumn.title, 999, profile);

    expect(state.sortColumn, LibrarySortColumn.grade);
    expect(state.sortAscending, isTrue);
    expect(state.columnWidths[LibraryTableColumn.title], 240);

    final toggled = state.withSortColumn(LibrarySortColumn.grade, profile);
    expect(toggled.sortAscending, isFalse);
  });

  test('workspace view state reorders visible table columns', () {
    final state = profile.defaults().copyWith(
      visibleColumns: {
        LibraryTableColumn.title,
        LibraryTableColumn.issue,
        LibraryTableColumn.grade,
      },
    );

    final reordered = state.withReorderedColumn(
      column: LibraryTableColumn.grade,
      beforeColumn: LibraryTableColumn.issue,
    );

    expect(reordered.visibleColumns.toList(), [
      LibraryTableColumn.title,
      LibraryTableColumn.grade,
      LibraryTableColumn.issue,
    ]);
  });

  test('workspace view state reorders a visible column to the end', () {
    final state = profile.defaults().copyWith(
      visibleColumns: {
        LibraryTableColumn.title,
        LibraryTableColumn.issue,
        LibraryTableColumn.grade,
      },
    );

    final reordered = state.withReorderedColumn(
      column: LibraryTableColumn.title,
      beforeColumn: null,
    );

    expect(reordered.visibleColumns.toList(), [
      LibraryTableColumn.issue,
      LibraryTableColumn.grade,
      LibraryTableColumn.title,
    ]);
  });

  test('workspace view profile controls initial sort direction', () {
    final newestFirstProfile = LibraryWorkspaceViewProfile(
      config: config,
      defaultCoverSize: 128,
      minCoverSize: 100,
      maxCoverSize: 200,
      presetConfig: profile.presetConfig,
      clampColumnWidth: profile.clampColumnWidth,
      sortAscendingForColumn: (column) => column != LibrarySortColumn.updated,
    );

    final state = newestFirstProfile.defaults().withSortColumn(
          LibrarySortColumn.updated,
          newestFirstProfile,
        );

    expect(state.sortColumn, LibrarySortColumn.updated);
    expect(state.sortAscending, isFalse);
  });

  test('workspace view profile persists through shared preferences', () async {
    final state = profile.defaults().copyWith(
          viewMode: LibraryViewMode.card,
          coverSize: 180,
          sidebarWidth: 300,
          detailsWidth: 420,
        );

    await profile.save(state);
    final restored = await profile.load();

    expect(restored.viewMode, LibraryViewMode.card);
    expect(restored.coverSize, 180);
    expect(restored.sidebarWidth, 300);
    expect(restored.detailsWidth, 420);
  });

  test('workspace view defaults reuse cached global chrome', () async {
    await LibraryWorkspacePreferences(config).write(
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
