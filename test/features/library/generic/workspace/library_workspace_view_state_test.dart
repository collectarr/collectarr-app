import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_enums.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
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
    defaultSortColumn: LibrarySortColumn.title,
    defaultVisibleColumns: const {LibraryTableColumn.title, LibraryTableColumn.issue},
    availableSortColumns: const [LibrarySortColumn.title, LibrarySortColumn.issue],
    availableSortColumnDefinitions: const [],
    availableTableColumns: const [LibraryTableColumn.title, LibraryTableColumn.issue],
  );

  final profile = LibraryWorkspaceViewProfile(
    type: typeConfig,
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
    expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
    expect(defaults.sortColumn, LibrarySortColumn.title);
    expect(defaults.coverSize, 128);
    expect(defaults.sidebarWidth, 250);
    expect(defaults.detailsWidth, 340);
    expect(defaults.detailsHeight, 300);
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

  test('workspace view state preserves trailing multi-sort rules', () {
    final state = profile.defaults().withSortRules([
      const LibrarySortRule(
        column: LibrarySortColumn.publisher,
        ascending: true,
      ),
      const LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
    ], profile);

    final updated = state.withSortColumn(LibrarySortColumn.grade, profile);

    expect(updated.sortRules, [
      const LibrarySortRule(
        column: LibrarySortColumn.grade,
        ascending: true,
      ),
      const LibrarySortRule(
        column: LibrarySortColumn.publisher,
        ascending: true,
      ),
      const LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
    ]);
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
      type: typeConfig,
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
          sortRules: const [
            LibrarySortRule(
              column: LibrarySortColumn.publisher,
              ascending: true,
            ),
            LibrarySortRule(
              column: LibrarySortColumn.updated,
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
      const LibrarySortRule(
        column: LibrarySortColumn.publisher,
        ascending: true,
      ),
      const LibrarySortRule(
        column: LibrarySortColumn.updated,
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
