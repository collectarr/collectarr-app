import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = LibraryWorkspaceConfig(
    kind: 'comic',
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
    SharedPreferences.setMockInitialValues({});
  });

  test('workspace view profile builds defaults and applies presets', () {
    final defaults = profile.defaults();

    expect(defaults.viewMode, LibraryViewMode.grid);
    expect(defaults.detailsLayout, LibraryDetailsLayout.right);
    expect(defaults.sortColumn, LibrarySortColumn.title);
    expect(defaults.coverSize, 128);
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
        );

    await profile.save(state);
    final restored = await profile.load();

    expect(restored.viewMode, LibraryViewMode.card);
    expect(restored.coverSize, 180);
  });
}
