import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
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
    preferencePrefix: 'comics',
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

  final mangaConfig = LibraryWorkspaceConfig(
    kind: CatalogMediaKind.comic,
    title: 'Manga',
    icon: Icons.auto_stories,
    accent: Colors.orange,
    preferencePrefix: 'manga',
  );

  final mangaTypeConfig = LibraryTypeConfig(
    workspace: mangaConfig,
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    defaultMetadataProvider: 'mock',
    metadataProviders: const [],
    trackingProfile: const MediaTrackingProfile(
      name: 'Mock',
      options: [],
    ),
  );

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('library workspace preferences persist reusable view settings',
      () async {
    final store = LibraryWorkspacePreferences(typeConfig);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: 'grade',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        sortRules: [
          LibrarySortRule(
            column: 'grade',
            ascending: false,
          ),
          LibrarySortRule(
            column: 'updated',
            ascending: false,
          ),
        ],
        coverSize: 144,
        sidebarWidth: 280,
        detailsWidth: 390,
        detailsHeight: 244,
        visibleColumns: {
          'title',
          'grade',
        },
        columnWidths: {
          'title': 320,
          'grade': 120,
        },
      ),
    );

    final restored = await store.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.viewMode, LibraryViewMode.list);
    expect(restored.detailsLayout, LibraryDetailsLayout.bottom);
    expect(restored.sortColumn, 'grade');
    expect(restored.sortAscending, isFalse);
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: 'grade',
        ascending: false,
      ),
      const LibrarySortRule(
        column: 'updated',
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 144);
    expect(restored.sidebarWidth, 280);
    expect(restored.detailsWidth, 390);
    expect(restored.detailsHeight, 244);
    expect(restored.visibleColumns, {
      'title',
      'grade',
    });
    expect(restored.visibleColumns.toList(), [
      'title',
      'grade',
    ]);
    expect(restored.columnWidths['title'], 320);
    expect(restored.columnWidths['grade'], 120);
  });

  test('library workspace preferences migrate legacy enum names', () async {
    SharedPreferences.setMockInitialValues({
      'comics.sort_column': 'grade',
      'comics.sort_rules': ['grade:desc', 'updated:asc'],
      'comics.visible_columns': ['title', 'grade'],
      'comics.column_widths': ['title:320', 'grade:120'],
    });

    final store = LibraryWorkspacePreferences(typeConfig);
    final restored = await store.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.sortColumn, 'grade');
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: 'grade',
        ascending: false,
      ),
      const LibrarySortRule(
        column: 'updated',
        ascending: true,
      ),
    ]);
    expect(restored.visibleColumns, {
      'title',
      'grade',
    });
    expect(restored.columnWidths['title'], 320);
    expect(restored.columnWidths['grade'], 120);
  });

  test('workspace chrome size and position are retained per library',
      () async {
    final comicsStore = LibraryWorkspacePreferences(typeConfig);
    final mangaStore = LibraryWorkspacePreferences(mangaTypeConfig);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: 'grade',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'title',
          'grade',
        },
        columnWidths: {
          'title': 320,
        },
      ),
    );

    final restored = await mangaStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.detailsLayout, LibraryDetailsLayout.right);
    expect(restored.sidebarWidth, kLibrarySidebarDefaultWidth);
    expect(restored.detailsWidth, kLibraryDetailsDefaultWidth);
    expect(restored.detailsHeight, kLibraryDetailsDefaultHeight);
    expect(restored.viewMode, LibraryViewMode.grid);
    expect(restored.sortColumn, 'title');
    expect(restored.visibleColumns, libraryKindModuleForType(mangaTypeConfig).fields.defaultVisibleColumnIds);
    expect(restored.columnWidths, isEmpty);
  });

  test('library workspace preferences keep pane widths beyond the old caps',
      () async {
    final store = LibraryWorkspacePreferences(typeConfig);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        isSidebarVisible: true,
        sortColumn: 'title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 640,
        detailsWidth: 980,
        detailsHeight: 540,
        visibleColumns: {
          'title',
          'issue',
        },
        columnWidths: {},
      ),
    );

    final restored = await store.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.sidebarWidth, 640);
    expect(restored.detailsWidth, 980);
    expect(restored.detailsHeight, 540);
  });

  test('sort and chrome preferences stay isolated between libraries', () async {
    final comicsStore = LibraryWorkspacePreferences(typeConfig);
    final mangaStore = LibraryWorkspacePreferences(mangaTypeConfig);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: false,
        sortColumn: 'grade',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'title',
          'grade',
        },
        columnWidths: {},
      ),
    );

    await mangaStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        isSidebarVisible: true,
        sortColumn: 'title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 128,
        sidebarWidth: 250,
        detailsWidth: 340,
        detailsHeight: 300,
        visibleColumns: {
          'title',
          'publisher',
        },
        columnWidths: {},
      ),
    );

    final comics = await comicsStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );
    final manga = await mangaStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(comics.sortColumn, 'grade');
    expect(comics.sortAscending, isFalse);
    expect(comics.detailsLayout, LibraryDetailsLayout.bottom);
    expect(comics.isSidebarVisible, isFalse);

    expect(manga.sortColumn, 'title');
    expect(manga.sortAscending, isTrue);
    expect(manga.detailsLayout, LibraryDetailsLayout.right);
    expect(manga.isSidebarVisible, isTrue);
  });
}
